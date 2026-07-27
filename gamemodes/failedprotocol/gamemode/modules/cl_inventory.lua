local vgui = vgui
local draw = draw
local KMASKS = KMASKS
local Vector = Vector
local Angle = Angle
local net = net
local Material = Material
local render = render
local hook = hook
local ScrW = ScrW
local ScrH = ScrH
local math = math
local surface = surface

LocalInv = LocalInv or {
    ITEMS = {},
}

function SyncInv()
    local ply = LocalPlayer()
    local tbl = ply:GetWeapons()
    local slots = GetInvSlots()

    for _, v in pairs( LocalInv.ITEMS ) do
        if not IsValid( v ) or not table.HasValue( tbl, v ) or _ > slots then
            LocalInv.ITEMS[_] = nil
        end
    end

    for _, v in ipairs( tbl ) do
        local classdata = CLASSES[ply:GetFPClass()] != nil and CLASSES[ply:GetFPClass()] or {}
        if not IsValid( v ) or table.HasValue( LocalInv.ITEMS, v ) or ply:FPTeam() != TEAM_SCP and ( v:GetClass() == classdata.hands_override or v:GetClass() == "fp_hands" ) or ply:FPTeam() == TEAM_SCP and v:GetClass() == SCPS[ply:GetFPClass()].swep then continue end

        for i = 1, slots do
            if LocalInv.ITEMS[i] == nil then
                LocalInv.ITEMS[i] = v
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
    return LocalPlayer():Get_InvSlots()
end

local main_buttons = {
    {
        icon = Material( "failedprotocol/inventory/main/helmet_outline.png", "smooth" ),
        inact_icon = Material( "failedprotocol/inventory/main/helmet_outline.png", "smooth" ),
        check = function( self )
            if LocalPlayer().FPArmor.helmet.name == nil or ( CLASSES[LocalPlayer():GetFPClass()] != nil and CLASSES[LocalPlayer():GetFPClass()].noarmordrop == true ) then
                return false
            end

            return true
        end,
        lmb = function( self )
            net.Start( "FPInvArmor" )
                net.WriteString( "helmet" )
            net.SendToServer()
        end,
    },
    {
        icon = Material( "failedprotocol/inventory/main/vest_outline.png", "smooth" ),
        inact_icon = Material( "failedprotocol/inventory/main/vest_outline.png", "smooth" ),
        check = function( self )
            if LocalPlayer().FPArmor.vest.name == nil or ( CLASSES[LocalPlayer():GetFPClass()] != nil and CLASSES[LocalPlayer():GetFPClass()].noarmordrop == true ) then
                return false
            end

            return true
        end,
        lmb = function( self )
            net.Start( "FPInvArmor" )
                net.WriteString( "vest" )
            net.SendToServer()
        end,
    },
    {
        icon = Material( "failedprotocol/inventory/main/special_outline.png", "smooth" ),
        inact_icon = Material( "failedprotocol/inventory/main/special_outline.png", "smooth" ),
        check = function( self ) return false end,
        lmb = function( self )
            net.Start( "FPInvArmor" )
                net.WriteString( "suit" )
            net.SendToServer()
        end,
    },
    {
        icon = Material( "failedprotocol/inventory/main/hand.png", "smooth" ),
        inact_icon = Material( "failedprotocol/inventory/main/hand_outline.png", "smooth" ),
        check = function( self ) return true end,
        lmb = function( self )
            local classdata = CLASSES[LocalPlayer():GetFPClass()] != nil and CLASSES[LocalPlayer():GetFPClass()] or {}
            local wep = LocalPlayer():FPTeam() == TEAM_SCP and LocalPlayer():GetWeapon( SCPS[LocalPlayer():GetFPClass()].swep ) or LocalPlayer():GetWeapon( classdata.hands_override or "fp_hands" )
            input.SelectWeapon( wep )
        end,
    },
}

local info_alpha = 0
hook.Add( "DrawOverlay", "FPItemInfo", function()
    local hovPan = vgui.GetHoveredPanel()

    if not IsValid( hovPan ) or not hovPan:IsEnabled() or not isfunction( hovPan.DrawInfo ) then
        info_alpha = 0
        return
    end

    hovPan.DrawInfo()
end )

hook.Add( "DrawOverlay", "FPItemMove", function()
    local hovPan = vgui.GetHoveredPanel()

    if not IsValid( hovPan ) or not hovPan:IsEnabled() or not isfunction( hovPan.DragCheck ) or hovPan.DragCheck() == nil or not input.IsMouseDown( MOUSE_FIRST ) then
        moving_item = nil
        return
    end
end )

local sizeW, sizeH = ScreenScale( 280 ), ScreenScale( 180 )

local mdlW, mdlH = sizeW / 3.5, sizeH - 80
local mdlPad = ( sizeH - mdlH )/2

local btPad = 24
local btSpace = sizeH - mdlPad*2 - ( #main_buttons - 1 )*btPad
local btW = btSpace / #main_buttons

local btItemPad = 0

local outline_size = 1

function CreateInventoryUI()
    local ply = LocalPlayer()
    if not ply:Alive() or not FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN ) or CONT_UI != nil then return end

    if LAST_CURSOR_POS != nil then
        input.SetCursorPos( LAST_CURSOR_POS.x, LAST_CURSOR_POS.y )
    end

    local frame = vgui.Create( "DPanel" )
    frame:SetSize( 0, sizeH )
    frame:SizeTo( sizeW, sizeH, .125, 0, -1 )
    frame:Center()
    frame:SetPos( frame:GetX() - sizeW/2, frame:GetY() )
    frame:MakePopup()
    frame:SetAlpha( 245 )
    --frame:AlphaTo( 245, .5, 0, function() end )
    frame:SetKeyboardInputEnabled( false )

    function frame:Paint( w, h )
        if not LocalPlayer():Alive() or not input.IsButtonDown( CL_SETTINGS.Get( "fp_inventory_button" ) ) or CONT_UI != nil then
            local x, y = input.GetCursorPos()
            LAST_CURSOR_POS = {
                x = x,
                y = y
            }
            self:Remove()
        end

        draw.RoundedBox( 0, 0, 0, w, h, Color( 5, 5, 5, 240 ) )
        surface.SetDrawColor( 45, 45, 45, 25 )

        draw.HAnimatedLines( "invmain", ScreenScale( 4 ), 10 )

        draw.SimpleTextOutlined( "["..LANG.Get( "MISC", "inventory" ).."]", "HUDMedium", w/2, ScreenScale( 6 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 ) )

        surface.SetDrawColor( color_white )
        local edle_len = ScreenScale( 8 )
        surface.DrawRect( 0, 0, outline_size, edle_len )
        surface.DrawRect( 0, 0, edle_len, outline_size )
        surface.DrawRect( 0, h - edle_len, outline_size, edle_len )
        surface.DrawRect( 0, h - outline_size, edle_len, outline_size )
        surface.DrawRect( w - outline_size, 0, outline_size, edle_len )
        surface.DrawRect( w - edle_len, 0, edle_len, outline_size )
        surface.DrawRect( w - outline_size, h - edle_len, outline_size, edle_len )
        surface.DrawRect( w - edle_len, h - outline_size, edle_len, outline_size )

        surface.SetDrawColor( color_white )
        surface.DrawLine( mdlPad + mdlW + btPad*2 + btW, mdlPad, mdlPad + mdlW + btPad*2 + btW, sizeH - mdlPad )
    end

    local mdl_frame = vgui.Create( "DPanel", frame )
    mdl_frame:SetPos( mdlPad, mdlPad )    
    mdl_frame:SetSize( mdlW, mdlH )

    function mdl_frame:Paint( w, h )
        draw.FramedBox( 0, 0, w, h, 1, 0, Color( 0, 0, 0, 215 ), self:GetChild( 0 ):IsHovered() and Color( 0, 215, 255 ) or color_white )
    end

    local v1, v2 = LocalPlayer():GetModelBounds()
    local mdl_height = v2.z - v1.z

    local mdl = vgui.Create( "DModelPanel", mdl_frame )
    mdl:SetPos( 1, 1 )
    mdl:SetSize( mdlW-2, mdlH-2 )
    mdl:SetModel( LocalPlayer():GetModel() )
    local height = mdl_height*.6
    mdl:SetCamPos( Vector( 65, 65, height ) )
    mdl:SetLookAt( Vector( 0, 0, height ) )
    mdl:SetFOV( 20 )

    mdl:SetDirectionalLight( BOX_TOP, Color( 75, 75, 75 ) )
    mdl:SetDirectionalLight( BOX_FRONT, Color( 175, 175, 175 ) )

    local clBMerges = {}
    function mdl:DrawModel()
        local ply = LocalPlayer()
        local curparent = self
        local leftx, topy = self:LocalToScreen( 0, 0 )
        local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
        while ( curparent:GetParent() != nil ) do
            curparent = curparent:GetParent()

            local x1, y1 = curparent:LocalToScreen( 0, 0 )
            local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

            leftx = math.max( leftx, x1 )
            topy = math.max( topy, y1 )
            rightx = math.min( rightx, x2 )
            bottomy = math.min( bottomy, y2 )
            previous = curparent
        end

        render.ClearDepth( false )

        render.SetScissorRect( leftx, topy, rightx, bottomy, true )

        local ret = self:PreDrawModel( self.Entity )
        if ( ret != false ) then
            for i, bm in ipairs( ply:GetChildren() ) do
                if not bm:IsDerived( "fp_bonemerge" ) then continue end

                if IsValid( mdl_ent ) then
                    mdl_ent:SetNoDraw( true )
                    mdl_ent:AddEffects( EF_BONEMERGE )
                    mdl_ent:SetParent( self.Entity )
                end
                clBMerges[#clBMerges + 1] = mdl_ent
            end

            self.Entity:DrawModel()
            self.Entity:SetSkin( ply:GetSkin() )
            
            if IsValid( self.WeaponModel ) then
                self.WeaponModel:DrawModel()
            end

            for i, mdl_ent in ipairs( clBMerges ) do
                mdl_ent:DrawModel()
                mdl_ent:Remove()
            end

            clBMerges = {}

            self:PostDrawModel( self.Entity )
        end

        render.SetScissorRect( 0, 0, 0, 0, false )
    end

    local mdlAng = Angle( 0, 45, 0 )
    local curDif = nil
    local lastCurPos = input.GetCursorPos()
    local doneOnce = false
    local mdlLerp = 0
    function mdl:LayoutEntity( ent )
        local lp = LocalPlayer()
        self:SetCursor( "sizewe" )

        if not self:IsDown() then
            mdlLerp = math.max( 0, mdlLerp - FrameTime()/5 )

            doneOnce = false

            ent:SetAngles( LerpAngle( math.ease.InCubic( mdlLerp ), Angle( 0, 45, 0 ), mdlAng ) )
            mdlAng = ent:GetAngles()
        else
            mdlLerp = 1

            if not doneOnce then
                lastCurPos = input.GetCursorPos()
                doneOnce = true
            end

            curDif = input.GetCursorPos() - lastCurPos
            
            mdlAng = Angle( 0, 45 + curDif % 360, 0 )
            ent:SetAngles( mdlAng )
        end

        if self:GetModel() != lp:GetModel() then
            self:SetModel( lp:GetModel() )
        end

        local amb_clr = lp:Alive() and FPTeams.GetColor( lp:FPTeam() ) or color_black
        self:SetAmbientLight( LerpColor( .5, amb_clr, color_black ) )

        ent:SetSequence( lp:SelectWeightedSequence( ACT_HL2MP_IDLE ) )

        self:RunAnimation()
    end

    function mdl:OnRemove()
        if vest_mdl != nil then
            vest_mdl:Remove()
            vest_mdl = nil
        end

        if helmet_mdl != nil then
            helmet_mdl:Remove()
            helmet_mdl = nil
        end
        
        -- Обязательно очищаем модель оружия при закрытии панели
        if IsValid( self.WeaponModel ) then
            self.WeaponModel:Remove()
            self.WeaponModel = nil
        end
    end

    local main_bt = {}

    local btY = mdlPad
    for i = 1, #main_buttons do
        main_bt[i] = vgui.Create( "DButton", frame )
        local bt = main_bt[i]
        bt:SetSize( btW, btW )
        bt:SetPos( mdlPad + mdlW + btPad, btY )
        bt:SetText( "" )

        if i == 4 then
            bt.SWEP = CLASSES[LocalPlayer():GetFPClass()] != nil and CLASSES[LocalPlayer():GetFPClass()].hands_override or "fp_hands"
        end
        bt.HoveredTime = 0

        function bt:Paint( w, h )
            self:SetEnabled( main_buttons[i].check( self ) )

            self:SetCursor( self:IsEnabled() and "hand" or "arrow" )

            local icon = main_buttons[i].icon
            local inact_icon = main_buttons[i].inact_icon
            if isfunction( icon ) then icon = icon( self ) end
            if isfunction( inact_icon ) then inact_icon = inact_icon( self ) end

            local clr = self:IsEnabled() and ( i == 4 and IsValid( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon():GetClass() == "fp_hands" and Color( 0, 125, 225 ) or self:IsHovered() and Color( 0, 255, 255 ) or color_white ) or Color( 55, 55, 55 )

            draw.FramedBox( 0, 0, w, h, 1, 0, Color( 0, 0, 0, 215 ), clr )

            surface.SetDrawColor( clr )
            surface.SetMaterial( self:IsEnabled() and icon or inact_icon )
            surface.DrawTexturedRect( w/8, h/8, w/8*6, h/8*6 )
        end

        local infoTbl = {
            [1] = function()
                local name = LANG.Get( "ARMOR", LocalPlayer().FPArmor.helmet.name ).." - "..math.Round( LocalPlayer().FPArmor.helmet.durability / REGISTERED_ARMOR[LocalPlayer().FPArmor.helmet.name].durability * 100, 1 ).."%"
                surface.SetFont( "ItemInfoNormal" )
                local nameW, nameH = surface.GetTextSize( name )

                local x, y = gui.MouseX() + 16, gui.MouseY() + 16
                local w, h = ( nameW + 16 ), nameH*2
                h = h + ( w / 356 )*470

                local eased = math.ease.OutCirc( info_alpha )

                if x + w > ScrW() then
                    x = ScrW() - w
                end

                if y + h > ScrH() then
                    y = ScrH() - h
                end

                info_alpha = math.Clamp( info_alpha + .01, 0, 1 )

                KMASKS.Start()
                    draw.RoundedBox( 0, x, y, w, h, Color( 5, 5, 5, 240 * info_alpha ) )

                    draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + nameH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                    for k, v in pairs( REGISTERED_ARMOR[LocalPlayer().FPArmor.helmet.name].resistance ) do
                        if k == 0 or k == 10 then continue end

                        surface.SetMaterial( Material( "failedprotocol/inventory/silhouette/"..k..".png" , "smooth" ) )
                        surface.SetDrawColor( HSVToColor( v*120, 1, 1 ) )
                        surface.DrawTexturedRect( x, y + nameH*1.5, w, ( w / 356 )*470 )
                    end

                    surface.SetMaterial( Material( "failedprotocol/inventory/silhouette/frame.png" , "smooth" ) )
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect( x, y + nameH*1.5, w, ( w / 356 )*470 )
                KMASKS.Source()
                    draw.RoundedBox( 0, x, y, w, h * eased, color_black )
                KMASKS.End()

                surface.SetDrawColor( color_white )
                surface.DrawLine( x, y, x + w, y )
                surface.DrawLine( x, y + h * eased, x + w, y + h * eased )
            end,
            [2] = function()
                local name = LANG.Get( "ARMOR", LocalPlayer().FPArmor.vest.name ).." - "..math.Round( LocalPlayer().FPArmor.vest.durability / REGISTERED_ARMOR[LocalPlayer().FPArmor.vest.name].durability * 100, 1 ).."%"
                surface.SetFont( "ItemInfoNormal" )
                local nameW, nameH = surface.GetTextSize( name )

                local x, y = gui.MouseX() + 16, gui.MouseY() + 16
                local w, h = ( nameW + 16 ), nameH*2
                h = h + ( w / 356 )*470

                local eased = math.ease.OutCirc( info_alpha )

                if x + w > ScrW() then
                    x = ScrW() - w
                end

                if y + h > ScrH() then
                    y = ScrH() - h
                end

                info_alpha = math.Clamp( info_alpha + .01, 0, 1 )

                KMASKS.Start()
                    draw.RoundedBox( 0, x, y, w, h, Color( 5, 5, 5, 240 * info_alpha ) )

                    draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + nameH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                    for k, v in pairs( REGISTERED_ARMOR[LocalPlayer().FPArmor.vest.name].resistance ) do
                        if k == 0 or k == 10 then continue end

                        surface.SetMaterial( Material( "failedprotocol/inventory/silhouette/"..k..".png" , "smooth" ) )
                        surface.SetDrawColor( HSVToColor( v*120, 1, 1 ) )
                        surface.DrawTexturedRect( x, y + nameH*1.5, w, ( w / 356 )*470 )
                    end

                    surface.SetMaterial( Material( "failedprotocol/inventory/silhouette/frame.png" , "smooth" ) )
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect( x, y + nameH*1.5, w, ( w / 356 )*470 )
                KMASKS.Source()
                    draw.RoundedBox( 0, x, y, w, h * eased, color_black )
                KMASKS.End()

                surface.SetDrawColor( color_white )
                surface.DrawLine( x, y, x + w, y )
                surface.DrawLine( x, y + h * eased, x + w, y + h * eased )
            end,
            [3] = function()
                --
            end,
            [4] = function()
                local wep = LocalPlayer():GetWeapon( bt.SWEP )
                local name, desc = wep.PrintName, wep.PrintDesc
                surface.SetFont( "ItemInfoNormal" )
                local nameW, nameH = surface.GetTextSize( name )

                surface.SetFont( "ItemInfoSmall" )
                local descW, descH = surface.GetTextSize( name )

                local desc_lines = {}
                local str_tbl = {}
                if desc != nil then
                    desc_lines = string.Wrap( "ItemInfoSmall", desc, ScrW()/6 )

                    str_tbl = table.Copy( desc_lines )
                    table.sort( str_tbl, function( a, b ) return surface.GetTextSize( a ) > surface.GetTextSize( b ) end )
                end

                local x, y = gui.MouseX() + 16, gui.MouseY() + 16
                local w, h = ( #desc_lines == 0 or surface.GetTextSize( name ) > surface.GetTextSize( desc ) ) and ( nameW + 16 ) or surface.GetTextSize( str_tbl[1] ) + 16, #desc_lines == 0 and nameH or nameH + descH + #desc_lines * descH
                local eased = math.ease.OutCirc( info_alpha )

                if x + w > ScrW() then
                    x = ScrW() - w
                end

                if y + h > ScrH() then
                    y = ScrH() - h
                end

                info_alpha = math.Clamp( info_alpha + .01, 0, 1 )

                KMASKS.Start()
                    draw.RoundedBox( 0, x, y, w, h, Color( 5, 5, 5, 240 * info_alpha ) )

                    draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + nameH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                    local desc_y = y + descH*2
                    for k, v in pairs( desc_lines ) do
                        draw.SimpleText( v, "ItemInfoSmall", x + w/2, desc_y + descH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        desc_y = desc_y + descH
                    end
                KMASKS.Source()
                    draw.RoundedBox( 0, x, y, w, h * eased, color_black )
                KMASKS.End()

                surface.SetDrawColor( color_white )
                surface.DrawLine( x, y, x + w, y )
                surface.DrawLine( x, y + h * eased, x + w, y + h * eased )
            end,
        }

        function bt:DrawInfo()
            if bt.HoveredTime < .5 then return end

            infoTbl[i]()
        end

        function bt:DoClick()
            if main_buttons[i].lmb then
                main_buttons[i].lmb( self )
            end
        end

        function bt:DoRightClick()
            if main_buttons[i].rmb then
                main_buttons[i].rmb( self )
            end
        end

        function bt:Think()
            if self:IsHovered() then
                self.HoveredTime = self.HoveredTime + FrameTime()
            else
                self.HoveredTime = 0
            end
        end

        btY = btY + btW + btPad
    end

    local item_bt = {}

    local btMaxRow = 3
    local btSpaceW = sizeW - ( mdlPad + mdlW + btPad*2 + btW )
    btItemPad = ( btSpaceW - ( btMaxRow * btW ) ) / ( btMaxRow + 1 )
    local btX, btY = 0, mdlPad

    local curRow = 0
    for i = 1, GetInvSlots() do
        item_bt[i] = vgui.Create( "DButton", frame )
        local item_bt = item_bt[i]
        item_bt:SetSize( btW, btW )
        item_bt:SetPos( mdlPad + mdlW + btPad*2 + btW + btItemPad + btX, btY )
        item_bt:SetText( "" )

        item_bt.SWEP = LocalInv.ITEMS[i] or nil
        item_bt.Index = i
        item_bt.HoveredTime = 0

        function item_bt:Paint( w, h )
            self:SetEnabled( item_bt.SWEP )

            self:SetCursor( self:IsEnabled() and "hand" or "arrow" )

            local clr = self:IsEnabled() and ( IsValid( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon() == self.SWEP and Color( 0, 125, 225 ) or self:IsHovered() and Color( 0, 255, 255 ) or color_white ) or Color( 55, 55, 55 )

            draw.FramedBox( 0, 0, w, h, 1, 0, Color( 0, 0, 0, 215 ), clr )

            if self.SWEP == nil then return end

            surface.SetDrawColor( clr )

            local icon = self.SWEP.WepSelectIcon or self.SWEP.SelectIcon or surface.GetTextureID( "weapons/swep" )
            if isnumber( icon ) then
                surface.SetTexture( icon )
            else
                surface.SetMaterial( icon )
            end
            surface.DrawTexturedRect( w/8, h/8, w/8*6, h/8*6 )
        end

        function item_bt:DrawInfo()
            if item_bt.HoveredTime < .5 or item_bt:IsDragging() then return end

            local name, desc = item_bt.SWEP.PrintName, item_bt.SWEP.PrintDesc
            surface.SetFont( "ItemInfoNormal" )
            local nameW, nameH = surface.GetTextSize( name )

            surface.SetFont( "ItemInfoSmall" )
            local descW, descH = surface.GetTextSize( name )

            local desc_lines = {}
            local str_tbl = {}
            if desc != nil then
                desc_lines = string.Wrap( "ItemInfoSmall", desc, ScrW()/6 )

                str_tbl = table.Copy( desc_lines )
                table.sort( str_tbl, function( a, b ) return surface.GetTextSize( a ) > surface.GetTextSize( b ) end )
            end

            local x, y = gui.MouseX() + 16, gui.MouseY() + 16
            local w, h = ( #desc_lines == 0 or surface.GetTextSize( name ) > surface.GetTextSize( desc ) ) and ( nameW + 16 ) or surface.GetTextSize( str_tbl[1] ) + 16, #desc_lines == 0 and nameH or nameH + descH + #desc_lines * descH
            local eased = math.ease.OutCirc( info_alpha )

            if x + w > ScrW() then
                x = ScrW() - w
            end

            if y + h > ScrH() then
                y = ScrH() - h
            end

            info_alpha = math.Clamp( info_alpha + .01, 0, 1 )

            KMASKS.Start()
                draw.RoundedBox( 0, x, y, w, h, Color( 5, 5, 5, 240 * info_alpha ) )

                draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + nameH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                local desc_y = y + descH*2
                for k, v in pairs( desc_lines ) do
                    draw.SimpleText( v, "ItemInfoSmall", x + w/2, desc_y + descH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    desc_y = desc_y + descH
                end
            KMASKS.Source()
                draw.RoundedBox( 0, x, y, w, h * eased, color_black )
            KMASKS.End()

            surface.SetDrawColor( color_white )
            surface.DrawLine( x, y, x + w, y )
            surface.DrawLine( x, y + h * eased, x + w, y + h * eased )
        end

        function item_bt:Think()
            if self:IsHovered() then
                self.HoveredTime = self.HoveredTime + FrameTime()
            else
                self.HoveredTime = 0
            end

            self.SWEP = LocalInv.ITEMS[i] or nil

            SyncInv()
        end

        function item_bt:DoClick()
            input.SelectWeapon( self.SWEP )
        end

        function item_bt:DoRightClick()
            local swep = self.SWEP
            self.SWEP = nil

            net.Start( "FPInv" )
                net.WriteEntity( swep )
            net.SendToServer()
        end

        function item_bt:Exchange( panel )
            local newWep = panel.SWEP

            LocalInv.ITEMS[panel.Index] = self.SWEP
            LocalInv.ITEMS[self.Index] = panel.SWEP
        end

        item_bt:Droppable( "FPItem" )

        item_bt:Receiver( "FPItem", function( self, panels, dropped, _, x, y )
            if dropped then
                self:Exchange( panels[1] )
            end
        end )

        curRow = curRow + 1

        if curRow == btMaxRow then
            curRow = 0
            btX = 0
            btY = btY + btW + btPad
        else
            btX = btX + btW + btItemPad
        end
    end

    return frame
end

hook.Add( "PlayerButtonDown", "FPInventoryOpen", function( ply, button )
    if CLIENT and button == CL_SETTINGS.Get( "fp_inventory_button" ) and IsFirstTimePredicted() then
        CreateInventoryUI()
    end
end )

net.ReceivePing( "FPInvSync", function()
    SyncInv()
end )

local container_gap = 20
local uninspected_mat = Material( "side_stripes.png", "noclamp", "smooth" )

function CreateContainerUI( ent )
    local ply = LocalPlayer()
    if not ply:Alive() or not FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN ) then return end

    local invFrame = CreateInventoryUI()
    if not IsValid( invFrame ) then return end

    invFrame.Paint = function( self, w, h )
        if not LocalPlayer():Alive() then
            self:Remove()
        end

        draw.RoundedBox( 0, 0, 0, w, h, Color( 5, 5, 5, 240 ) )
        surface.SetDrawColor( 45, 45, 45, 25 )
        draw.HAnimatedLines( "invmain", ScreenScale( 4 ), 10 )

        draw.SimpleTextOutlined( "["..LANG.Get( "MISC", "inventory" ).."]", "HUDMedium", w/2, ScreenScale( 6 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 ) )

        surface.SetDrawColor( color_white )
        local edle_len = ScreenScale( 8 )
        surface.DrawRect( 0, 0, outline_size, edle_len )
        surface.DrawRect( 0, 0, edle_len, outline_size )
        surface.DrawRect( 0, h - edle_len, outline_size, edle_len )
        surface.DrawRect( 0, h - outline_size, edle_len, outline_size )
        surface.DrawRect( w - outline_size, 0, outline_size, edle_len )
        surface.DrawRect( w - edle_len, 0, edle_len, outline_size )
        surface.DrawRect( w - outline_size, h - edle_len, outline_size, edle_len )
        surface.DrawRect( w - edle_len, h - outline_size, edle_len, outline_size )

        surface.DrawLine( mdlPad + mdlW + btPad*2 + btW, mdlPad, mdlPad + mdlW + btPad*2 + btW, sizeH - mdlPad )
    end

    local btMaxRow = 4
    local contW = ( btMaxRow - 1 ) * btItemPad + mdlPad * 2 + btMaxRow * btW
    local totalWidth = sizeW + container_gap + contW

    local startX = ( ScrW() - totalWidth ) / 2
    local startY = ( ScrH() - sizeH ) / 2

    invFrame:SetPos( startX, startY )

    local contFrame = vgui.Create( "DPanel" )
    contFrame:SetSize( 0, sizeH )
    contFrame:SizeTo( contW, sizeH, .125, 0, -1 )
    contFrame:SetPos( startX + sizeW + container_gap/2, startY )
    contFrame:MakePopup()
    contFrame:SetAlpha( 245 )
    contFrame:SetKeyboardInputEnabled( false )

    contFrame.ent = ent
    local ent = contFrame.ent

    local lootType = ent:GetType()

    contFrame.Lootable = {
        tbl = ent.LootTable,
        type = lootType,
        slots = LOOT_CFG[lootType].size
    }

    CONT_UI = contFrame

    invFrame.OnRemove = function() if IsValid( contFrame ) then contFrame:Remove() end end
    contFrame.OnRemove = function() if IsValid( invFrame ) then invFrame:Remove() end
        CONT_UI = nil
    end

    function contFrame:Paint( w, h )
        if not LocalPlayer():Alive() then self:Remove() end

        draw.RoundedBox( 0, 0, 0, w, h, Color( 5, 5, 5, 240 ) )
        surface.SetDrawColor( 45, 45, 45, 25 )
        draw.HAnimatedLines( "invmain", ScreenScale( 4 ), 10 )

        draw.SimpleTextOutlined( "["..LANG.Get( "LOOT", contFrame.Lootable.type ).."]", "HUDMedium", w/2, ScreenScale( 6 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 ) )

        surface.SetDrawColor( color_white )
        local edle_len = ScreenScale( 8 )
        surface.DrawRect( 0, 0, outline_size, edle_len )
        surface.DrawRect( 0, 0, edle_len, outline_size )
        surface.DrawRect( 0, h - edle_len, outline_size, edle_len )
        surface.DrawRect( 0, h - outline_size, edle_len, outline_size )
        surface.DrawRect( w - outline_size, 0, outline_size, edle_len )
        surface.DrawRect( w - edle_len, 0, edle_len, outline_size )
        surface.DrawRect( w - outline_size, h - edle_len, outline_size, edle_len )
        surface.DrawRect( w - edle_len, h - outline_size, edle_len, outline_size )
    end

    local closeBtn = vgui.Create( "DButton", contFrame )
    closeBtn:SetSize( 16, 16 )
    closeBtn:SetPos( contW - 24, 8 )
    closeBtn:SetText( "X" )
    closeBtn:SetFont( "ItemInfoSmall" )
    closeBtn:SetTextColor( Color( 150, 150, 150 ) )
    function closeBtn:Paint( w, h )
        if self:IsHovered() then self:SetTextColor( Color( 255, 50, 50 ) ) else self:SetTextColor( Color( 150, 150, 150 ) ) end
    end
    function closeBtn:DoClick()
        contFrame:Remove()
    end

    local cont_bt = {}
    local btX, btY = mdlPad, mdlPad

    for i = 1, contFrame.Lootable.slots do
        cont_bt[i] = vgui.Create( "DButton", contFrame )
        local slot = cont_bt[i]
        slot:SetSize( btW, btW )
        slot:SetPos( btX, btY )
        slot:SetText( "" )
        slot.Index = i
        slot.HoveredTime = 0

        slot.LootData = contFrame.Lootable.tbl[i] or nil

        if slot.LootData then
            slot.inspected = ent.LootTable[slot.Index].inspected or false
            slot.inspection = false
            slot.insp_progress = 0
        end

        function slot:Paint( w, h )
            if self.inspected == false then
                self:SetEnabled( self.LootData != nil )
                self:SetCursor( self:IsEnabled() and "hand" or "arrow" )

                surface.SetDrawColor( Color( 175, 175, 175, 45 ) )
                surface.DrawRect( 0, 0, w, h )

                local wepTable = weapons.Get( self.LootData.class )
                if wepTable then
                    local icon = wepTable.WepSelectIcon or wepTable.SelectIcon or surface.GetTextureID( "weapons/swep" )
                    surface.SetDrawColor( color_black )
                    if isnumber( icon ) then surface.SetTexture( icon ) else surface.SetMaterial( icon ) end
                    surface.DrawTexturedRect( w/8, h/8, w/8*6, h/8*6 )
                end

                surface.SetDrawColor( Color( 45, 45, 45 ) )
                surface.SetMaterial( uninspected_mat )
                surface.DrawTexturedRectUV( 0, 0, w, h, 0, 0, w/5, h/5 )

                local clr = self:IsEnabled() and ( self:IsHovered() and color_white or Color( 75, 75, 75 ) ) or Color( 35, 35, 35 )
                draw.FramedBox( 0, 0, w, h, 1, 0, Color( 0, 0, 0, 215 ), clr )

                surface.SetDrawColor( color_white )
                FPDrawRing( w/2, h/2, w/3.5, w/3.5, self.insp_progress )

                if self.inspection then
                    self.insp_progress = self.insp_progress + FrameTime()

                    if self.insp_progress >= 1 then
                        slot.inspected = true
                        ent.LootTable[slot.Index].inspected = true
                    end
                end

                return
            end

            self:SetEnabled( self.LootData != nil )
            self:SetCursor( self:IsEnabled() and "hand" or "arrow" )

            local clr = self:IsEnabled() and ( not canTakeLoot( ply, ent.LootTable[slot.Index] ) and Color( 125, 60, 60) or self:IsHovered() and Color( 0, 255, 255 ) or color_white ) or Color( 55, 55, 55 )
            draw.FramedBox( 0, 0, w, h, 1, 0, Color( 0, 0, 0, 215 ), clr )

            if not self.LootData then return end

            local wepTable = weapons.Get( self.LootData.class )
            if wepTable then
                local icon = wepTable.WepSelectIcon or wepTable.SelectIcon or surface.GetTextureID( "weapons/swep" )
                surface.SetDrawColor( clr )
                if isnumber( icon ) then surface.SetTexture( icon ) else surface.SetMaterial( icon ) end
                surface.DrawTexturedRect( w/8, h/8, w/8*6, h/8*6 )
            else
                draw.SimpleText( self.LootData.class, "ItemInfoSmall", w/2, h/2, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            if self.LootData.amount and self.LootData.amount > 1 then
                draw.SimpleText( "x" .. self.LootData.amount, "ItemInfoSmall", w - 6, h - 6, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
            end
        end

        function slot:Think()
            if self:IsHovered() then
                self.HoveredTime = self.HoveredTime + FrameTime()
            else
                self.HoveredTime = 0
            end
        end

        local loot_info_override = {
            ["fp_keycard"] = {
                name = function( lootData )
                    return LANG.Get( "WEP", "fp_keycard", "name" ).." - "..LANG.Get( "KEYCARDS", lootData.data.access )
                end
            }
        }

        function slot:DrawInfo()
            if slot.HoveredTime < .5 or slot.inspected == false or slot:IsDragging() then
                info_alpha = 0
                return
            end

            info_alpha = math.Clamp( info_alpha + .01, 0, 1 )
            local eased = math.ease.OutCirc( info_alpha )
            local name
            
            if loot_info_override[slot.LootData.class] != nil then
                name = loot_info_override[slot.LootData.class].name( slot.LootData )
            else
                local class = slot.LootData.class
                local wepTable = weapons.Get( class )
                name = wepTable and wepTable.PrintName or LANG.Get( "WEP", class )
            end
            
            surface.SetFont( "ItemInfoNormal" )
            local nameW, nameH = surface.GetTextSize( name )
            local x, y = gui.MouseX() + 16, gui.MouseY() + 16
            local w, h = nameW + 16, nameH * 1.5

            KMASKS.Start()
                draw.RoundedBox( 0, x, y, w, h * eased, Color( 5, 5, 5, 240 * info_alpha ) )
                draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            KMASKS.Source()
                draw.RoundedBox( 0, x, y, w, h * eased, color_black )
            KMASKS.End()

            surface.SetDrawColor( color_white )
            surface.DrawLine( x, y, x + w, y )
            surface.DrawLine( x, y + h * eased, x + w, y + h * eased )
        end

        function slot:DoClick()
            if not self.LootData then return end

            if not self.inspected then
                self.inspection = true
                return
            end

            if not canTakeLoot( ply, ent.LootTable[slot.Index] ) then return end

            net.Start( "FPLoot" )
                net.WriteEntity( ent )
                net.WriteFloat( self.Index )
            net.SendToServer()

            self.LootData = nil
        end

        if i % btMaxRow == 0 then
            btX = mdlPad
            btY = btY + btW + btPad
        else
            btX = btX + btW + btItemPad
        end
    end

    return contFrame
end

net.Receive( "FPLoot", function() CreateContainerUI( net.ReadEntity() ) end )