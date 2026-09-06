local vgui = vgui
local draw = draw
local Vector = Vector
local Angle = Angle
local net = net
local Material = Material
local render = render
local hook = hook
local math = math
local surface = surface
local ScrW = ScrW
local ScrH = ScrH

LocalInv = LocalInv or {
    ITEMS = {},
}

LANG = LANG or {
    Get = function() end
}

local UI = {
    bg = Color( 7, 7, 7, 248),
    bgSoft = Color( 15, 15, 15, 236),
    panel = Color( 17, 17, 17, 238),
    panel2 = Color( 26, 26, 26, 238),
    empty = Color( 24, 24, 24, 230),
    line = Color( 100, 100, 100, 130),
    lineSoft = Color( 85, 85, 85, 80),
    text = Color( 238, 238, 238),
    muted = Color( 160, 160, 160),
    dim = Color( 95, 95, 95),
    accent = Color( 232, 161, 54 ),
    accentBright = Color( 255, 190, 76 ),
    accentSoft = Color( 232, 161, 54, 80 ),
    danger = Color( 218, 74, 65 ),
    dangerSoft = Color( 218, 74, 65, 80 ),
    selected = Color( 77, 151, 192 ),
    selectedSoft = Color( 132, 164, 182, 85),
}

local MAT_UNINSPECTED = Material( "side_stripes.png", "noclamp smooth" )
local MAT_SUIT = Material( "failedprotocol/inventory/main/special_outline.png", "smooth" )
local MAT_HELMET = Material( "failedprotocol/inventory/main/helmet_outline.png", "smooth" )
local MAT_VEST = Material( "failedprotocol/inventory/main/vest_outline.png", "smooth" )
local MAT_HAND = Material( "failedprotocol/inventory/main/hand.png", "smooth" )
local MAT_HAND_OUTLINE = Material( "failedprotocol/inventory/main/hand_outline.png", "smooth" )

local function FontSafe( name, size, weight )
    surface.CreateFont( name, {
        font = "Roboto Condensed",
        size = size,
        weight = weight or 600,
        extended = true,
        antialias = true,
    } )
end

local function RefreshFonts()
    local scale = math.Clamp( ScrH() / 900, 0.85, 1.25 )
    FontSafe( "FP_INV_TITLE", math.floor( 27 * scale ), 800 )
    FontSafe( "FP_INV_SUB", math.floor( 12 * scale ), 700 )
    FontSafe( "FP_INV_SLOT", math.floor( 12 * scale ), 700 )
    FontSafe( "FP_INV_ITEM", math.floor( 15 * scale ), 700 )
    FontSafe( "FP_INV_BODY", math.floor( 13 * scale ), 500 )
    FontSafe( "FP_INV_TINY", math.floor( 10 * scale ), 700 )
    FontSafe( "FP_INV_MONO", math.floor( 11 * scale ), 700 )
end

RefreshFonts()

local function DrawCornerFrame( x, y, w, h, col, len, thickness )
    len = len or 12
    thickness = thickness or 1

    surface.SetDrawColor( col )
    surface.DrawRect( x, y, len, thickness )
    surface.DrawRect( x, y, thickness, len )
    surface.DrawRect( x + w - len, y, len, thickness )
    surface.DrawRect( x + w - thickness, y, thickness, len )
    surface.DrawRect( x, y + h - thickness, len, thickness )
    surface.DrawRect( x, y + h - len, thickness, len )
    surface.DrawRect( x + w - len, y + h - thickness, len, thickness )
    surface.DrawRect( x + w - thickness, y + h - len, thickness, len )
end

local function DrawPanel( x, y, w, h, fill, outline, highlight, progress )
    surface.SetDrawColor( fill or UI.panel )
    surface.DrawRect( x, y, w, h )

    surface.SetDrawColor( UI.lineSoft )
    surface.DrawOutlinedRect( x, y, w, h, 1 )

    if outline then
        surface.SetDrawColor( outline )
        surface.DrawOutlinedRect( x, y, w, h, 1 )
    end

    if highlight and highlight > 0 then
        surface.SetDrawColor( Color( outline.r, outline.g, outline.b, highlight ) )
        surface.DrawRect( x, y + h - 2, w, 2 )
    end

    if progress then
        surface.SetDrawColor( outline or UI.accent )
        surface.DrawRect( x + 1, y + h - 3, math.Clamp( w - 2, 0, ( w - 2 ) * progress ), 2 )
    end
end

local function DrawHeader( x, y, w, title, tag, accent )
    accent = accent or UI.accent
    surface.SetDrawColor( accent )
    surface.DrawRect( x, y, 3, 24 )

    draw.SimpleText( string.upper( title or LANG.Get( "INV", "inventory" ) ), "FP_INV_TITLE", x + 12, y + 1, UI.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    if tag then
        draw.SimpleText( string.upper( tag ), "FP_INV_TINY", x + w, y + 7, UI.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
    end
end

local function GetWeaponIcon( wep )
    if not IsValid( wep ) then return nil end
    return wep.WepSelectIcon or wep.SelectIcon or surface.GetTextureID( "weapons/swep" )
end

local function DrawWeaponIcon( wep, x, y, w, h, col )
    local icon = GetWeaponIcon( wep )
    if not icon then return end

    surface.SetDrawColor( col or color_white )
    if isnumber( icon ) then
        surface.SetTexture( icon )
    else
        surface.SetMaterial( icon )
    end

    surface.DrawTexturedRect( x, y, w, h )
end

local function GetWeaponDisplayName( wep )
    if not IsValid( wep ) then return "UNKNOWN" end
    return wep.PrintName or wep:GetClass()
end

local function GetWeaponDescription( wep )
    if not IsValid( wep ) then return "" end
    return wep.PrintDesc or ""
end

local function GetClassData( ply )
    if not IsValid( ply ) then return {} end
    return CLASSES[ply:GetFPClass()] or {}
end

local function IsHuman( ply )
    return IsValid( ply ) and ply:Alive() and FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN )
end

function SyncInv()
    local ply = LocalPlayer()
    if not IsValid( ply ) then return end

    local weaponsList = ply:GetWeapons()
    local slots = math.max( 0, GetInvSlots() or 0 )
    local classData = GetClassData( ply )

    for index, wep in pairs( LocalInv.ITEMS ) do
        if not IsValid( wep ) or not table.HasValue( weaponsList, wep ) or index > slots then
            LocalInv.ITEMS[index] = nil
        end
    end

    for _, wep in ipairs( weaponsList ) do
        local isHands = wep:GetClass() == ( classData.hands_override or "" ) or wep:GetClass() == "fp_hands"
        local isSCPWeapon = false

        if ply:FPTeam() == TEAM_SCP then
            local scpData = SCPS[ply:GetFPClass()]
            isSCPWeapon = scpData and wep:GetClass() == scpData.swep or false
        end

        if not IsValid( wep ) or table.HasValue( LocalInv.ITEMS, wep ) or ( ply:FPTeam() ~= TEAM_SCP and isHands ) or ( ply:FPTeam() == TEAM_SCP and isSCPWeapon ) then
            continue
        end

        for index = 1, slots do
            if LocalInv.ITEMS[index] == nil then
                LocalInv.ITEMS[index] = wep
                break
            end
        end
    end
end

function GM:HUDDrawPickupHistory()
end

function GM:HUDWeaponPickedUp( wep )
    SyncInv()
end

function GM:HUDItemPickedUp( item )
    return true
end

function GM:HUDAmmoPickedUp( ammo, amount )
    return true
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetInvSlots()
    return self:Get_InvSlots()
end

function GetInvSlots()
    local ply = LocalPlayer()
    return IsValid( ply ) and ply:Get_InvSlots() or 0
end

hook.Add( "Think", "FPInventorySync", function()
    local ply = LocalPlayer()
    if not IsValid( ply ) then return end

    local nextSync = LocalPlayer().FPInventoryNextSync or 0
    if CurTime() < nextSync then return end

    LocalPlayer().FPInventoryNextSync = CurTime() + 0.15
    SyncInv()
end )

local EQUIPMENT = {
    {
        id = "helmet",
        short = LANG.Get( "INV", "helmet" ),
        icon = MAT_HELMET,
        enabled = function( ply )
            return ply.FPArmor and ply.FPArmor.helmet and ply.FPArmor.helmet.name ~= nil and not ( GetClassData( ply ).noarmordrop == true )
        end,
        action = function()
            net.Start( "FPInvArmor" )
                net.WriteString( "helmet" )
            net.SendToServer()
        end,
        item = function( ply )
            return ply.FPArmor and ply.FPArmor.helmet or nil
        end,
    },
    {
        id = "vest",
        short = LANG.Get( "INV", "armor" ),
        icon = MAT_VEST,
        enabled = function( ply )
            return ply.FPArmor and ply.FPArmor.vest and ply.FPArmor.vest.name ~= nil and not ( GetClassData( ply ).noarmordrop == true )
        end,
        action = function()
            net.Start( "FPInvArmor" )
                net.WriteString( "vest" )
            net.SendToServer()
        end,
        item = function( ply )
            return ply.FPArmor and ply.FPArmor.vest or nil
        end,
    },
    {
        id = "suit",
        short = LANG.Get( "INV", "suit" ),
        icon = MAT_SUIT,
        enabled = function()
            return false
        end,
        action = function()
            net.Start( "FPInvArmor" )
                net.WriteString( "suit" )
            net.SendToServer()
        end,
        item = function()
            return nil
        end,
    },
    {
        id = "hands",
        short = LANG.Get( "INV", "ready" ),
        icon = MAT_HAND,
        iconInactive = MAT_HAND_OUTLINE,
        enabled = function()
            return true
        end,
        action = function()
            local ply = LocalPlayer()
            local classData = GetClassData( ply )
            local hands = "fp_hands"

            if ply:FPTeam() == TEAM_SCP then
                local scpData = SCPS[ply:GetFPClass()]
                hands = scpData and scpData.swep or hands
            else
                hands = classData.hands_override or hands
            end

            local wep = ply:GetWeapon( hands )
            if IsValid( wep ) then
                input.SelectWeapon( wep )
            end
        end,
        item = function()
            return nil
        end,
    },
}

local function ArmorPercent( armor )
    if not armor or not armor.name or not REGISTERED_ARMOR or not REGISTERED_ARMOR[armor.name] then return 0 end
    local maxDurability = REGISTERED_ARMOR[armor.name].durability or 0
    if maxDurability <= 0 then return 0 end
    return math.Clamp( armor.durability / maxDurability, 0, 1 )
end

local function ArmorName( armor )
    if not armor or not armor.name then return LANG.Get( "INV", "empty" ) end
    return LANG.Get( "ARMOR", armor.name )
end

local function CreateItemDetails( parent )
    local panel = vgui.Create( "DPanel", parent )
    panel:SetVisible( false )
    panel.Item = nil
    panel.LootData = nil
    panel.InspectRequired = false
    panel.IsEquipment = false
    panel:SetMouseInputEnabled( false )

    function panel:SetItem( wep )
        self.Item = wep
        self.LootData = nil
        self.InspectRequired = false
        self.IsEquipment = false
        self:SetVisible( IsValid( wep ) )
    end

    function panel:SetLoot( lootData, inspected )
        self.Item = nil
        self.LootData = lootData
        self.InspectRequired = not inspected
        self.IsEquipment = false
        self:SetVisible( lootData ~= nil )
    end

    function panel:SetEquipment( armor )
        self.Item = nil
        self.LootData = nil
        self.InspectRequired = false
        self.IsEquipment = true
        self.Equipment = armor
        self:SetVisible( armor ~= nil and armor.name ~= nil )
    end

    function panel:Paint( w, h )
        DrawPanel( 0, 0, w, h, UI.panel, nil, nil )

        surface.SetDrawColor( UI.accent )
        surface.DrawRect( 0, 0, 3, h )

        if self.IsEquipment then
            local armor = self.Equipment
            local name = ArmorName( armor )
            local durability = ArmorPercent( armor )

            draw.SimpleText( LANG.Get( "INV", "equipped" ), "FP_INV_TINY", 16, 14, UI.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            draw.SimpleText( name, "FP_INV_ITEM", 16, 31, UI.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            draw.SimpleText( math.floor( durability * 100 ) .. "% " .. LANG.Get( "INV", "condition" ), "FP_INV_MONO", 16, h - 24, UI.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

            surface.SetDrawColor( UI.lineSoft )
            surface.DrawRect( 16, h - 10, w - 32, 3 )
            surface.SetDrawColor( durability > 0.25 and UI.accent or UI.danger )
            surface.DrawRect( 16, h - 10, ( w - 32 ) * durability, 3 )
            return
        end

        if IsValid( self.Item ) then
            local name = GetWeaponDisplayName( self.Item )
            local desc = GetWeaponDescription( self.Item )

            draw.SimpleText( name, "FP_INV_ITEM", 16, 14, UI.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

            if desc ~= "" then
                local lines = string.Wrap( "FP_INV_BODY", desc, w - 32 )
                for i, line in ipairs( lines ) do
                    draw.SimpleText( line, "FP_INV_BODY", 16, 32 + ( i - 1 ) * 16, UI.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
                    if i >= 4 then break end
                end
            end
            return
        end

        if self.LootData then
            local class = self.LootData.class
            local wepData = weapons.Get( class )
            local name

            if class == "fp_keycard" and self.LootData.data then
                name = LANG.Get( "WEP", class, "name" ) .. " - " .. LANG.Get( "KEYCARDS", self.LootData.data.access )
            else
                name = wepData and wepData.PrintName or LANG.Get( "WEP", class ) or class
            end

            draw.SimpleText( self.InspectRequired and LANG.Get( "INV", "unverified_contact" ) or LANG.Get( "INV", "loot_contact" ), "FP_INV_TINY", 16, 14, self.InspectRequired and UI.accent or UI.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            draw.SimpleText( name, "FP_INV_ITEM", 16, 31, UI.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

            if self.LootData.amount and self.LootData.amount > 1 then
                draw.SimpleText( LANG.Get( "INV", "quantity" ) .. "  x" .. self.LootData.amount, "FP_INV_MONO", 16, h - 22, UI.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            elseif self.InspectRequired then
                draw.SimpleText( LANG.Get( "INV", "lmb_hold_identify" ), "FP_INV_MONO", 16, h - 22, UI.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            else
                draw.SimpleText( LANG.Get( "INV", "lmb_take" ), "FP_INV_MONO", 16, h - 22, UI.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            end
        end
    end

    return panel
end

local function CreatePlayerModel( parent )
    local modelPanel = vgui.Create( "DModelPanel", parent )
    modelPanel:SetMouseInputEnabled( true )
    modelPanel:SetModel( LocalPlayer():GetModel() )
    modelPanel:SetFOV( 25 )
    modelPanel.LayoutEntity = function( self, ent )
        local lp = LocalPlayer()
        if not IsValid( lp ) then return end

        if self:IsHovered() and input.IsMouseDown( MOUSE_LEFT ) then
            local mx = gui.MouseX()
            local delta = mx - ( self.LastRotateX or mx )
            self.RotateYaw = ( self.RotateYaw or 20 ) + delta * 0.45
            self.LastRotateX = mx
        else
            self.LastRotateX = gui.MouseX()
            self.RotateYaw = Lerp( FrameTime() * 5, self.RotateYaw or 20, 20 )
        end

        ent:SetAngles( Angle( 0, self.RotateYaw or 20, 0 ) )
        ent:SetSequence( lp:SelectWeightedSequence( ACT_HL2MP_IDLE ) )
        self:RunAnimation()

        local vMin, vMax = lp:GetModelBounds()
        local height = math.max( 1, ( vMax.z - vMin.z ) * 0.65 )
        self:SetCamPos( Vector( 62, 62, height ) )
        self:SetLookAt( Vector( 0, 0, height ) )

        local teamColor = FPTeams.GetColor( lp:FPTeam() ) or UI.accent
        self:SetAmbientLight( Color( teamColor.r * 0.45, teamColor.g * 0.45, teamColor.b * 0.45 ) )
        self:SetDirectionalLight( BOX_TOP, Color( 105, 105, 105 ) )
        self:SetDirectionalLight( BOX_FRONT, Color( 185, 185, 185 ) )

        if self:GetModel() ~= lp:GetModel() then
            self:SetModel( lp:GetModel() )
        end
    end

    local boneMergedModels = {}
    modelPanel.DrawModel = function( self )
        local ply = LocalPlayer()
        local leftX, topY = self:LocalToScreen( 0, 0 )
        local rightX, bottomY = self:LocalToScreen( self:GetWide(), self:GetTall() )
        local parent = self

        while parent:GetParent() ~= nil do
            parent = parent:GetParent()
            local x1, y1 = parent:LocalToScreen( 0, 0 )
            local x2, y2 = parent:LocalToScreen( parent:GetWide(), parent:GetTall() )
            leftX = math.max( leftX, x1 )
            topY = math.max( topY, y1 )
            rightX = math.min( rightX, x2 )
            bottomY = math.min( bottomY, y2 )
        end

        render.ClearDepth( false )
        render.SetScissorRect( leftX, topY, rightX, bottomY, true )

        local ret = self:PreDrawModel( self.Entity )
        if ret ~= false then
            for _, child in ipairs( ply:GetChildren() ) do
                if not child:IsDerived( "fp_bonemerge" ) then continue end

                local merged = ClientsideModel( child:GetModel(), RENDERGROUP_OPAQUE )
                if IsValid( merged ) then
                    merged:SetNoDraw( true )
                    merged:AddEffects( EF_BONEMERGE )
                    merged:SetParent( self.Entity )
                    boneMergedModels[#boneMergedModels + 1] = merged
                end
            end

            self.Entity:SetSkin( ply:GetSkin() )
            self.Entity:DrawModel()

            if IsValid( self.WeaponModel ) then
                self.WeaponModel:DrawModel()
            end

            for _, merged in ipairs( boneMergedModels ) do
                merged:DrawModel()
                merged:Remove()
            end
            boneMergedModels = {}

            self:PostDrawModel( self.Entity )
        end

        render.SetScissorRect( 0, 0, 0, 0, false )
    end

    return modelPanel
end

local function CreateAnimatedButton( parent )
    local btn = vgui.Create( "DButton", parent )
    btn:SetText( "" )
    btn.Hover = 0
    btn.Press = 0

    function btn:Think()
        local target = self:IsHovered() and 1 or 0
        self.Hover = Lerp( FrameTime() * 12, self.Hover, target )

        local targetPress = self:IsDown() and 1 or 0
        self.Press = Lerp( FrameTime() * 15, self.Press, targetPress )
    end

    return btn
end

local function DrawSlotBase( self, w, h, stateColor, cornerColor )
    stateColor = stateColor or UI.line
    cornerColor = cornerColor or stateColor

    surface.SetDrawColor( UI.empty )
    surface.DrawRect( 0, 0, w, h )

    if self.Hover > 0 then
        surface.SetDrawColor( Color( stateColor.r, stateColor.g, stateColor.b, 18 + self.Hover * 35 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    surface.SetDrawColor( UI.lineSoft )
    surface.DrawOutlinedRect( 0, 0, w, h, 1 )

    DrawCornerFrame( 0, 0, w, h, Color( cornerColor.r, cornerColor.g, cornerColor.b, 120 + self.Hover * 100 ), math.min( 10, math.floor( math.min( w, h ) * 0.18 ) ), 1 )
end

function CreateInventoryUI( isContainerInventory, widthOverride, heightOverride )
    local ply = LocalPlayer()
    if not IsHuman( ply ) or ( CONT_UI ~= nil and not isContainerInventory ) then return end

    RefreshFonts()
    SyncInv()

    local sw, sh = ScrW(), ScrH()
    local scale = math.Clamp( sw / 1600, 0.82, 1.15 )

    local frameW = math.floor( widthOverride or math.min( 840 * scale, sw - 32 ) )
    local frameH = math.floor( heightOverride or math.min( 640 * scale, sh - 40 ) )
    local margin = math.floor( 18 * scale )
    local gap = math.floor( 12 * scale )

    local frame = vgui.Create( "DPanel" )
    frame:SetSize( frameW, frameH )
    frame:SetPos( ( sw - frameW ) / 2, ( sh - frameH ) / 2 )
    frame:MakePopup()
    frame:SetKeyboardInputEnabled( false )
    frame:SetAlpha( 0 )
    frame:AlphaTo( 255, 0.13, 0 )
    frame.IsContainerInventory = isContainerInventory == true
    frame.Tooltip = nil
    frame.Selected = nil

    function frame:CloseInventory()
        if not IsValid( self ) then return end
        local x, y = input.GetCursorPos()
        LAST_CURSOR_POS = { x = x, y = y }
        self:AlphaTo( 0, 0.07, 0, function()
            if IsValid( self ) then self:Remove() end
        end )
    end

    function frame:Paint( w, h )
        if not self.IsContainerInventory and ( not LocalPlayer():Alive() or not input.IsButtonDown( CL_SETTINGS.Get( "fp_inventory_button" ) ) or CONT_UI ~= nil ) then
            if not self.Closing then
                self.Closing = true
                self:CloseInventory()
            end
            return
        end

        KMASKS.Start()
            DrawPanel( 0, 0, w, h, UI.bg, UI.line, 0 )

            local clr = UI.muted:Copy()
            clr.a = 5
            surface.SetDrawColor( clr )

            draw.VAnimatedLines( "inv_lines", ScreenScale( 8 ), 16 )
        KMASKS.Source()
            surface.SetDrawColor( color_white )
            surface.DrawRect( 0, 0, w, h )
        KMASKS.End()

        DrawCornerFrame( 0, 0, w, h, UI.accent, 18, 2 )

        draw.SimpleText( LANG.Get( "INV", "controls_equip_drop" ), "FP_INV_TINY", w - margin, 13, UI.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
    end

    if LAST_CURSOR_POS then
        input.SetCursorPos( LAST_CURSOR_POS.x, LAST_CURSOR_POS.y )
    end

    local leftW = math.floor( frameW * 0.31 )
    local rightX = margin + leftW + gap
    local rightW = frameW - rightX - margin
    local bodyY = margin + 14
    local bodyH = frameH - bodyY - margin

    local headpan = vgui.Create( "DPanel", frame )
    headpan:SetPos( margin, bodyY )
    headpan:SetSize( leftW, bodyH )
    function headpan:Paint( w, h )
        DrawPanel( 0, 0, w, h, UI.panel, nil, nil )
    end

    local modelBox = vgui.Create( "DPanel", headpan )
    modelBox:SetPos( 14, 14 )
    modelBox:SetSize( leftW - 28, math.floor( bodyH * 0.50 ) )
    function modelBox:Paint( w, h )
        DrawPanel( 0, 0, w, h, LerpColor( .05, UI.bg, FPTeams.GetColor( ply:FPTeam() ) ), UI.lineSoft, nil )
        DrawCornerFrame( 0, 0, w, h, UI.line, 12, 1 )
    end

    local model = CreatePlayerModel( modelBox )
    model:SetPos( 1, 1 )
    model:SetSize( modelBox:GetWide() - 2, modelBox:GetTall() - 2 )

    local equipmentPanel = vgui.Create( "DPanel", headpan )
    equipmentPanel:SetPos( 14, modelBox:GetY() + modelBox:GetTall() + gap )
    equipmentPanel:SetSize( leftW - 28, bodyH - equipmentPanel:GetY() - 14 )
    equipmentPanel:SetMouseInputEnabled( true )
    function equipmentPanel:Paint( w, h )
        DrawPanel( 0, 0, w, h, UI.panel2, nil, nil )
    end

    local equipGap = 8
    local equipH = math.floor( ( equipmentPanel:GetTall() - 28 - equipGap * 3 ) / 4 )
    local equipButtons = {}

    local detailPanel = CreateItemDetails( frame )
    detailPanel:SetPos( rightX, frameH - margin - math.floor( 108 * scale ) )
    detailPanel:SetSize( rightW, math.floor( 108 * scale ) )

    for i, data in ipairs( EQUIPMENT ) do
        local bt = CreateAnimatedButton( equipmentPanel )
        equipButtons[i] = bt
        bt:SetPos( 10, 13 + ( i - 1 ) * ( equipH + equipGap ) )
        bt:SetSize( equipmentPanel:GetWide() - 20, equipH )
        bt.Data = data
        bt.HoverTime = 0

        function bt:Paint( w, h )
            local lply = LocalPlayer()
            local enabled = self.Data.enabled( lply )
            self:SetEnabled( enabled )
            self:SetCursor( enabled and "hand" or "arrow" )

            local armor = self.Data.item( lply )
            local isActive = self.Data.id == "hands" and IsValid( lply:GetActiveWeapon() ) and lply:GetActiveWeapon():GetClass() == ( GetClassData( lply ).hands_override or "fp_hands" )
            local outline = enabled and ( isActive and UI.selected or self:IsHovered() and UI.accentBright or UI.line ) or UI.dim

            DrawSlotBase( self, w, h, outline, outline )

            surface.SetDrawColor( enabled and outline or Color( 65, 70, 74 ) )
            surface.SetMaterial( self.Data.iconInactive and not enabled and self.Data.iconInactive or self.Data.icon )
            local iconSize = math.floor( h * 0.52 )
            surface.DrawTexturedRect( 10, math.floor( ( h - iconSize ) / 2 ) + 3, iconSize, iconSize )

            local x = iconSize + 24
            local name = LANG.Get( "INV", "empty" )
            local condition = nil

            if armor and armor.name then
                name = ArmorName( armor )
                condition = ArmorPercent( armor )
            elseif self.Data.id == "hands" then
                local classData = GetClassData( LocalPlayer() )

                local hands = "fp_hands"
                if lply:FPTeam() == TEAM_SCP then
                    local scpData = SCPS[lply:GetFPClass()]
                    hands = scpData and scpData.swep or hands
                else
                    hands = classData.hands_override or hands
                end
                
                local wep = lply:GetWeapon( hands )
                name = wep:GetPrintName()
            end

            draw.SimpleText( name, "FP_INV_ITEM", x, h * 0.37, enabled and UI.text or UI.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

            if condition then
                surface.SetDrawColor( UI.lineSoft )
                surface.DrawRect( x, h - 8, w - x - 10, 3 )
                surface.SetDrawColor( condition > 0.25 and UI.accent or UI.danger )
                surface.DrawRect( x, h - 8, ( w - x - 10 ) * condition, 3 )
            end
        end

        function bt:Think()
            self.BaseClass.Think( self )
            local hovered = self:IsHovered() and 1 or 0
            self.HoverTime = Lerp( FrameTime() * 10, self.HoverTime, hovered )
        end

        function bt:DoClick()
            if self.Data.enabled( LocalPlayer() ) then
                self.Data.action( self )
            end
        end

        function bt:DoRightClick()
            if self.Data.enabled( LocalPlayer() ) then
                self.Data.action( self )
            end
        end

        function bt:OnCursorEntered()
            local armor = self.Data.item( LocalPlayer() )
            if armor and armor.name then
                detailPanel:SetEquipment( armor )
            elseif self.Data.id == "hands" then
                local classData = GetClassData( LocalPlayer() )
                local wep = LocalPlayer():GetWeapon( classData.hands_override or "fp_hands" )
                if IsValid( wep ) then
                    detailPanel:SetItem( wep )
                end
            end
        end

        function bt:OnCursorExited()
            if not frame.Selected then
                detailPanel:SetVisible( false )
            end
        end
    end

    local invPanel = vgui.Create( "DPanel", frame )
    invPanel:SetPos( rightX, bodyY )
    invPanel:SetSize( rightW, bodyH - detailPanel:GetTall() - gap )
    function invPanel:Paint( w, h )
        DrawPanel( 0, 0, w, h, UI.panel, nil, nil )
    end

    local gridX = 14
    local gridY = 14
    local gridW = invPanel:GetWide() - 28
    local gridH = invPanel:GetTall() - 60
    local cols = gridW >= 540 and 5 or 4
    local slotGap = 8
    local slotW = math.floor( ( gridW - slotGap * ( cols - 1 ) ) / cols )
    local rows = math.max( 1, math.ceil( math.max( 1, GetInvSlots() ) / cols ) )
    local slotH = math.floor( ( gridH - slotGap * ( rows - 1 ) ) / rows )
    slotH = math.min( slotH, slotW * 0.85 )

    local itemButtons = {}

    for i = 1, GetInvSlots() do
        local slot = CreateAnimatedButton( invPanel )
        itemButtons[i] = slot
        local row = math.floor( ( i - 1 ) / cols )
        local col = ( i - 1 ) % cols

        slot:SetSize( slotW, slotH )
        slot:SetPos( gridX + col * ( slotW + slotGap ), gridY + row * ( slotH + slotGap ) )
        slot.Index = i
        slot.SWEP = LocalInv.ITEMS[i]
        slot.HoverTime = 0

        function slot:Paint( w, h )
            local wep = LocalInv.ITEMS[self.Index]
            self.SWEP = wep
            local hasItem = IsValid( wep )
            self:SetEnabled( hasItem )
            self:SetCursor( hasItem and "hand" or "arrow" )

            local isActive = hasItem and LocalPlayer():GetActiveWeapon() == wep
            local outline = isActive and UI.selected or self:IsHovered() and UI.accentBright or hasItem and UI.line or UI.dim

            DrawSlotBase( self, w, h, outline, outline )

            if not hasItem then
                draw.SimpleText( LANG.Get( "INV", "empty" ), "FP_INV_TINY", w / 2, h / 2 + 2, UI.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                return
            end

            DrawWeaponIcon( wep, math.floor( w * 0.12 ), math.floor( h * 0.12 ), math.floor( w * 0.76 ), math.floor( h * 0.76 ), isActive and UI.selected or UI.text )
        end

        function slot:Think()
            self.BaseClass.Think( self )
            local hovered = self:IsHovered() and 1 or 0
            self.HoverTime = Lerp( FrameTime() * 10, self.HoverTime, hovered )
            self.SWEP = LocalInv.ITEMS[self.Index]
        end

        function slot:DoClick()
            if not IsValid( self.SWEP ) then return end
            input.SelectWeapon( self.SWEP )
            frame.Selected = self
            detailPanel:SetItem( self.SWEP )
        end

        function slot:DoRightClick()
            if not IsValid( self.SWEP ) then return end
            local wep = self.SWEP
            self.SWEP = nil
            LocalInv.ITEMS[self.Index] = nil

            net.Start( "FPInv" )
                net.WriteEntity( wep )
            net.SendToServer()

            detailPanel:SetVisible( false )
        end

        function slot:OnCursorEntered()
            if IsValid( self.SWEP ) then
                detailPanel:SetItem( self.SWEP )
            end
        end

        function slot:OnCursorExited()
            if frame.Selected ~= self then
                detailPanel:SetVisible( false )
            end
        end

        function slot:Exchange( panel )
            if not panel or panel == self then return end

            local sourceIndex = panel.Index
            local targetIndex = self.Index
            local source = LocalInv.ITEMS[sourceIndex]
            local target = LocalInv.ITEMS[targetIndex]

            LocalInv.ITEMS[targetIndex] = source
            LocalInv.ITEMS[sourceIndex] = target
        end

        slot:Droppable( "FPItem" )
        slot:Receiver( "FPItem", function( self, panels, dropped )
            if not dropped or not panels or not panels[1] then return end
            self:Exchange( panels[1] )
        end )
    end

    function frame:OnRemove()
        if not self.IsContainerInventory and not CONT_UI then
            local x, y = input.GetCursorPos()
            LAST_CURSOR_POS = { x = x, y = y }
        end
    end

    return frame
end

hook.Add( "PlayerButtonDown", "FPInventoryOpen", function( ply, button )
    if button ~= CL_SETTINGS.Get( "fp_inventory_button" ) then return end
    if IsValid( CONT_UI ) then return end
    if IsValid( ply ) and ply ~= LocalPlayer() then return end

    CreateInventoryUI( false )
end )

net.ReceivePing( "FPInvSync", function()
    SyncInv()
end )

local function CreateLootSlot( parent, ent, index, lootData, detailPanel )
    local slot = CreateAnimatedButton( parent )
    slot:SetText( "" )
    slot.Index = index
    slot.LootData = lootData
    slot.Inspected = lootData and lootData.inspected or false
    slot.Inspection = false
    slot.InspectProgress = 0
    slot.HoverTime = 0

    function slot:Paint( w, h )
        local data = self.LootData
        local hasLoot = data ~= nil
        self:SetEnabled( hasLoot )
        self:SetCursor( hasLoot and "hand" or "arrow" )

        if not hasLoot then
            DrawSlotBase( self, w, h, UI.dim, UI.dim )
            return
        end

        if not self.Inspected then
            DrawSlotBase( self, w, h, UI.accent, UI.accent )

            local wepData = weapons.Get( data.class )
            if wepData then
                local icon = wepData.WepSelectIcon or wepData.SelectIcon or surface.GetTextureID( "weapons/swep" )
                surface.SetDrawColor( Color( 215, 215, 215, 80 ) )
                if isnumber( icon ) then surface.SetTexture( icon ) else surface.SetMaterial( icon ) end
                surface.DrawTexturedRect( math.floor( w * 0.12 ), math.floor( h * 0.12 ), math.floor( w * 0.76 ), math.floor( h * 0.62 ) )
            end

            surface.SetDrawColor( Color( 50, 53, 56, 120 ) )
            surface.SetMaterial( MAT_UNINSPECTED )
            surface.DrawTexturedRectUV( 0, 0, w, h, 0, 0, w / 5, h / 5 )

            draw.SimpleText( LANG.Get( "INV", "unverified" ), "FP_INV_TINY", w / 2, h - 18, UI.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            surface.SetDrawColor( UI.accent )
            surface.DrawOutlinedRect( 0, 0, w, h, 1 )

            if self.Inspection then
                surface.SetDrawColor( Color( 8, 10, 12, 245 ) )
                surface.DrawRect( 0, h - 4, w, 4 )
                surface.SetDrawColor( UI.accent )
                surface.DrawRect( 0, h - 4, w * math.Clamp( self.InspectProgress, 0, 1 ), 4 )

                draw.SimpleText( LANG.Get( "INV", "scanning" ), "FP_INV_TINY", w / 2, h / 2, UI.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            return
        end

        local canTake = canTakeLoot( LocalPlayer(), ent.LootTable[self.Index] )
        local isBlocked = not canTake
        local isHover = self:IsHovered()
        local outline = isBlocked and UI.danger or isHover and UI.accentBright or UI.line

        DrawSlotBase( self, w, h, outline, outline )

        local wepData = weapons.Get( data.class )
        if wepData then
            local icon = wepData.WepSelectIcon or wepData.SelectIcon or surface.GetTextureID( "weapons/swep" )
            surface.SetDrawColor( isBlocked and UI.danger or UI.text )
            if isnumber( icon ) then surface.SetTexture( icon ) else surface.SetMaterial( icon ) end
            surface.DrawTexturedRect( math.floor( w * 0.12 ), math.floor( h * 0.10 ), math.floor( w * 0.76 ), math.floor( h * 0.64 ) )
        else
            draw.SimpleText( data.class or LANG.Get( "INV", "unknown" ), "FP_INV_TINY", w / 2, h / 2, UI.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        if data.amount and data.amount > 1 then
            draw.SimpleText( "x" .. data.amount, "FP_INV_MONO", w - 7, h - 7, UI.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
        end

        if isBlocked then
            draw.SimpleText( LANG.Get( "INV", "blocked" ), "FP_INV_TINY", 8, h - 20, UI.danger, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        else
            draw.SimpleText( LANG.Get( "INV", "take" ), "FP_INV_TINY", 8, h - 20, UI.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        end
    end

    function slot:Think()
        self.BaseClass.Think( self )
        local hovered = self:IsHovered() and 1 or 0
        self.HoverTime = Lerp( FrameTime() * 10, self.HoverTime, hovered )

        if self.Inspection then
            self.InspectProgress = self.InspectProgress + FrameTime() / 0.75
            if self.InspectProgress >= 1 then
                self.InspectProgress = 1
                self.Inspection = false
                self.Inspected = true
                if ent.LootTable[self.Index] then
                    ent.LootTable[self.Index].inspected = true
                end
            end
        end
    end

    function slot:DoClick()
        if not self.LootData then return end

        if not self.Inspected then
            self.Inspection = true
            self.InspectProgress = 0
            return
        end

        if not canTakeLoot( LocalPlayer(), ent.LootTable[self.Index] ) then return end

        net.Start( "FPLoot" )
            net.WriteEntity( ent )
            net.WriteFloat( self.Index )
        net.SendToServer()

        self.LootData = nil
        detailPanel:SetVisible( false )
    end

    function slot:OnCursorEntered()
        if self.LootData then
            detailPanel:SetLoot( self.LootData, self.Inspected )
        end
    end

    function slot:OnCursorExited()
        detailPanel:SetVisible( false )
    end

    return slot
end

function CreateContainerUI( ent )
    local ply = LocalPlayer()
    if not IsHuman( ply ) or not IsValid( ent ) or not ent.LootTable or not LOOT_CFG[ent:GetType()] then return end
    if IsValid( CONT_UI ) then return end

    RefreshFonts()
    SyncInv()

    local sw, sh = ScrW(), ScrH()
    local scale = math.Clamp( sw / 1600, 0.78, 1.05 )
    local gap = math.floor( 12 * scale )
    local maxTotalW = sw - 32
    local pairW = math.min( 1680 * scale, maxTotalW )
    local frameW = math.floor( ( pairW - gap ) * 0.54 )
    local lootW = pairW - gap - frameW
    local frameH = math.floor( math.min( 720 * scale, sh - 40 ) )

    local inventoryFrame = CreateInventoryUI( true, frameW, frameH )
    if not IsValid( inventoryFrame ) then return end

    local totalW = frameW + gap + lootW
    local startX = ( sw - totalW ) / 2
    local startY = ( sh - frameH ) / 2
    inventoryFrame:SetPos( startX, startY )

    local lootFrame = vgui.Create( "DPanel" )
    lootFrame:SetSize( lootW, frameH )
    lootFrame:SetPos( startX + frameW + gap, startY )
    lootFrame:SetAlpha( 0 )
    lootFrame:AlphaTo( 255, 0.13, 0 )
    lootFrame:MakePopup()
    lootFrame:SetKeyboardInputEnabled( false )
    lootFrame.Entity = ent
    lootFrame.Lootable = {
        tbl = ent.LootTable,
        type = ent:GetType(),
        slots = LOOT_CFG[ent:GetType()].size,
    }

    CONT_UI = lootFrame

    function lootFrame:Paint( w, h )
        if not LocalPlayer():Alive() or not IsValid( self.Entity ) then
            self:Remove()
            return
        end

        KMASKS.Start()
            DrawPanel( 0, 0, w, h, UI.bg, UI.line, nil )

            local clr = UI.muted:Copy()
            clr.a = 5
            surface.SetDrawColor( clr )

            draw.VAnimatedLines( "inv_loot_lines", ScreenScale( 8 ), 16 )
        KMASKS.Source()
            surface.SetDrawColor( color_white )
            surface.DrawRect( 0, 0, w, h )
        KMASKS.End()

        DrawCornerFrame( 0, 0, w, h, UI.accent, 18, 2 )
        local title = LANG.Get( "LOOT", self.Lootable.type ) or LANG.Get( "INV", "loot" )
        draw.SimpleText( string.upper( title ), "FP_INV_TINY", 18, 13, UI.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    end

    local close = vgui.Create( "DButton", lootFrame )
    close:SetText( "" )
    close:SetSize( 34, 24 )
    close:SetPos( lootW - 46, 5 )
    function close:Paint( w, h )
        draw.SimpleText( "ESC", "FP_INV_TINY", w / 2, h / 2, self:IsHovered() and UI.accentBright or UI.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    function close:DoClick()
        lootFrame:CloseLoot()
    end

    function lootFrame:CloseLoot()
        if IsValid( inventoryFrame ) then
            inventoryFrame:Remove()
        end
        if IsValid( self ) then
            self:Remove()
        end
    end

    function lootFrame:OnRemove()
        if IsValid( inventoryFrame ) then inventoryFrame:Remove() end
        CONT_UI = nil
    end

    local detailHeight = math.floor( 108 * scale )
    local detail = CreateItemDetails( lootFrame )
    detail:SetPos( 16, frameH - detailHeight - 14 )
    detail:SetSize( lootW - 32, detailHeight )

    local gridX = 16
    local gridY = 48
    local gridW = lootW - 32
    local gridH = frameH - 62 - detailHeight - gap
    local cols = gridW >= 500 and 4 or 3
    local slotGap = 8
    local slots = lootFrame.Lootable.slots
    local rows = math.max( 1, math.ceil( slots / cols ) )
    local slotW = math.floor( ( gridW - slotGap * ( cols - 1 ) ) / cols )
    local slotH = math.floor( ( gridH - slotGap * ( rows - 1 ) ) / rows )
    slotH = math.min( slotH, slotW * 0.85 )

    for i = 1, lootFrame.Lootable.slots do
        local row = math.floor( ( i - 1 ) / cols )
        local col = ( i - 1 ) % cols
        local lootData = lootFrame.Lootable.tbl[i]
        local slot = CreateLootSlot( lootFrame, ent, i, lootData, detail )
        slot:SetSize( slotW, slotH )
        slot:SetPos( gridX + col * ( slotW + slotGap ), gridY + row * ( slotH + slotGap ) )
    end

    function lootFrame:Think()
        if input.IsKeyDown( KEY_ESCAPE ) then
            self.EscapeLatch = self.EscapeLatch or false
            if not self.EscapeLatch then
                self.EscapeLatch = true
                self:CloseLoot()
            end
        else
            self.EscapeLatch = false
        end
    end

    return lootFrame
end

net.Receive( "FPLoot", function()
    CreateContainerUI( net.ReadEntity() )
end )
