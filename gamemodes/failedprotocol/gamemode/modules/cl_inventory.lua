LocalInv = LocalInv or {
    ITEMS = {},
}

function SyncInv()
    local tbl = LocalPlayer():GetWeapons()

    for _, v in pairs( LocalInv.ITEMS ) do
        if not IsValid( v ) or not table.HasValue( tbl, v ) then
            LocalInv.ITEMS[_] = nil
        end
    end

    for _, v in ipairs( tbl ) do
        if not IsValid( v ) or table.HasValue( LocalInv.ITEMS, v ) or LocalPlayer():FPTeam() != TEAM_SCP and ( v:GetClass() == CLASSES[LocalPlayer():GetFPClass()].hands_override or v:GetClass() == "fp_hands" ) or LocalPlayer():FPTeam() == TEAM_SCP and v:GetClass() == SCPS[LocalPlayer():GetFPClass()].swep then continue end

        for i = 1, LocalPlayer():GetInvSlots() do
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

local main_buttons = {
    {
        icon = Material( "failedprotocol/inventory/main/helmet_outline.png", "smooth" ),
        inact_icon = Material( "failedprotocol/inventory/main/helmet_outline.png", "smooth" ),
        check = function( self ) return LocalPlayer().FPArmor.helmet.name != nil end,
        lmb = function( self )
            net.Start( "FPInvArmor" )
                net.WriteString( "helmet" )
            net.SendToServer()
        end,
    },
    {
        icon = Material( "failedprotocol/inventory/main/vest_outline.png", "smooth" ),
        inact_icon = Material( "failedprotocol/inventory/main/vest_outline.png", "smooth" ),
        check = function( self ) return LocalPlayer().FPArmor.vest.name != nil end,
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
            local wep = LocalPlayer():FPTeam() == TEAM_SCP and LocalPlayer():GetWeapon( SCPS[LocalPlayer():GetFPClass()].swep ) or LocalPlayer():GetWeapon( CLASSES[LocalPlayer():GetFPClass()].hands_override or "fp_hands" )
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

local moving_item = nil
hook.Add( "DrawOverlay", "FPItemMove", function()
    local hovPan = vgui.GetHoveredPanel()

    if not IsValid( hovPan ) or not hovPan:IsEnabled() or not isfunction( hovPan.DragCheck ) or hovPan.DragCheck() == nil or not input.IsMouseDown( MOUSE_FIRST ) then
        moving_item = nil
        return
    end
end )

local sizeW, sizeH = ScrW() / 2, ScrH() / 2

local mdlW, mdlH = sizeW / 4, sizeH - 80
local mdlPad = ( sizeH - mdlH )/2

local btPad = 24
local btSpace = sizeH - mdlPad*2 - ( #main_buttons - 1 )*btPad
local btW = btSpace / #main_buttons

function CreateInventoryUI()
    local ply = LocalPlayer()
    if not ply:Alive() or not FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN ) then return end

    local frame = vgui.Create( "DPanel" )
    frame:SetSize( sizeW, sizeH )
    frame:Center()
    frame:MakePopup()
    frame:SetAlpha( 0 )
    frame:AlphaTo( 245, .5, 0, function() end )

    function frame:Paint( w, h )
        if not LocalPlayer():Alive() or not input.IsButtonDown( CL_SETTINGS.Get( "fp_inventory_button" ) ) then self:Remove() end

        local eased = math.ease.OutCirc( self:GetAlpha()/245 )

        render.SetStencilEnable( true )

        render.ClearStencil()
        
        render.SetStencilTestMask( 255 )
        render.SetStencilWriteMask( 255 )

        render.SetStencilPassOperation( STENCILOPERATION_KEEP )
        render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

        render.SetStencilReferenceValue( 9 )
        render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

        draw.RoundedBox( 0, 0 + ( w/2 ) * ( 1 - eased ), 0, w * eased, h, Color( 5, 5, 5, 240 ) )

        render.SetStencilFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

        draw.RoundedBox( 0, 0, 0, w, h, Color( 5, 5, 5, 240 ) )
        surface.SetDrawColor( 25, 25, 25, 55 )

        render.SetStencilEnable( false )

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
    mdl:SetCamPos( Vector( 65, 65, mdl_height/3*2 ) )
    mdl:SetLookAt( Vector( 0, 0, mdl_height/2.1 ) )
    mdl:SetFOV( 27.5 )

    local openTime = CurTime()
    local vest, helmet = vest or nil, helmet or nil
    local vest_mdl, helmet_mdl = vest_mdl or nil, helmet_mdl or nil
    function mdl:DrawModel()
        local eased = math.ease.OutCirc( frame:GetAlpha()/245 )
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

        if vest_mdl != nil then
            vest_mdl:Remove()
            vest_mdl = nil
        end

        if helmet_mdl != nil then
            helmet_mdl:Remove()
            helmet_mdl = nil
        end

        vest, helmet = LocalPlayer().FPArmor.vest.name, LocalPlayer().FPArmor.helmet.name

        render.ClearDepth( false )

        render.SetScissorRect( leftx, topy, rightx, bottomy, true )

        local ret = self:PreDrawModel( self.Entity )
        if ( ret != false ) then
            if vest != nil and REGISTERED_ARMOR[vest].model != "" then
                vest_mdl = ClientsideModel( REGISTERED_ARMOR[vest].model )
                if IsValid( vest_mdl ) then
                    vest_mdl:SetNoDraw( true )
                    vest_mdl:AddEffects( EF_BONEMERGE )
                    vest_mdl:SetParent( self.Entity )
                end
            end

            if helmet != nil and REGISTERED_ARMOR[helmet].model != "" then
                helmet_mdl = ClientsideModel( REGISTERED_ARMOR[helmet].model )
                if IsValid( helmet_mdl ) then
                    helmet_mdl:SetNoDraw( true )
                    helmet_mdl:AddEffects( EF_BONEMERGE )
                    helmet_mdl:SetParent( self.Entity )
                end
            end

            self.Entity:DrawModel()
            if vest_mdl != nil then
                vest_mdl:DrawModel()
            end

            if helmet_mdl != nil then
                helmet_mdl:DrawModel()
            end

            self:PostDrawModel( self.Entity )
        end

        render.SetScissorRect( 0, 0, 0, 0, false )
    end

    local mdlAng = Angle( 0, 45, 0 )
    local curDif = nil
    local lastCurPos = input.GetCursorPos()
    local doneOnce = false
    local mdlLerp = 0
    local look_ratio = 0
    function mdl:LayoutEntity( ent )
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

        if self:GetModel() != LocalPlayer():GetModel() then
            self:SetModel( LocalPlayer():GetModel() )
        end

        self:SetAmbientLight( LocalPlayer():Alive() and FPTeams.GetColor( LocalPlayer():FPTeam() ) or color_black )

        ent:SetSequence( LocalPlayer():SelectWeightedSequence( ACT_HL2MP_IDLE_SUITCASE ) )

        local look_on_left = math.cos( ( CurTime() - openTime ) / 3 ) > 0
        if look_on_left then
            look_ratio = math.min( 1, look_ratio + .005 )
        else
            look_ratio = math.max( 0, look_ratio - .005 )
        end

        if isnumber( ent:LookupBone( "ValveBiped.Bip01_Head1" ) ) then
            ent:ManipulateBoneAngles( ent:LookupBone( "ValveBiped.Bip01_Head1" ), Angle( 0, 0, math.ease.InOutQuart( look_ratio ) * -30 ) )
        end

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
            bt.SWEP = CLASSES[LocalPlayer():GetFPClass()].hands_override or "fp_hands"
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

                render.SetStencilEnable( true )

                render.ClearStencil()
                
                render.SetStencilTestMask( 255 )
                render.SetStencilWriteMask( 255 )

                render.SetStencilPassOperation( STENCILOPERATION_KEEP )
                render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

                render.SetStencilReferenceValue( 9 )
                render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

                draw.RoundedBox( 0, x, y, w, h * eased, color_black )

                render.SetStencilFailOperation( STENCILOPERATION_KEEP )

                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

                draw.RoundedBox( 0, x, y, w, h, Color( 25, 25, 25, 240 * info_alpha ) )

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

                render.SetStencilEnable( false )

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

                render.SetStencilEnable( true )

                render.ClearStencil()
                
                render.SetStencilTestMask( 255 )
                render.SetStencilWriteMask( 255 )

                render.SetStencilPassOperation( STENCILOPERATION_KEEP )
                render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

                render.SetStencilReferenceValue( 9 )
                render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

                draw.RoundedBox( 0, x, y, w, h * eased, color_black )

                render.SetStencilFailOperation( STENCILOPERATION_KEEP )

                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

                draw.RoundedBox( 0, x, y, w, h, Color( 25, 25, 25, 240 * info_alpha ) )

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

                render.SetStencilEnable( false )

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

                render.SetStencilEnable( true )

                render.ClearStencil()
                
                render.SetStencilTestMask( 255 )
                render.SetStencilWriteMask( 255 )

                render.SetStencilPassOperation( STENCILOPERATION_KEEP )
                render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

                render.SetStencilReferenceValue( 9 )
                render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

                draw.RoundedBox( 0, x, y, w, h * eased, color_black )

                render.SetStencilFailOperation( STENCILOPERATION_KEEP )

                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

                draw.RoundedBox( 0, x, y, w, h, Color( 25, 25, 25, 240 * info_alpha ) )

                draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + nameH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                local desc_y = y + descH*2
                for k, v in pairs( desc_lines ) do
                    draw.SimpleText( v, "ItemInfoSmall", x + w/2, desc_y + descH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    desc_y = desc_y + descH
                end

                render.SetStencilEnable( false )

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

    local btMaxRow = 4
    local btSpaceW = sizeW - ( mdlPad + mdlW + btPad*2 + btW )
    local btItemPad = ( btSpaceW - ( btMaxRow * btW ) ) / ( btMaxRow + 1 )
    local btX, btY = 0, mdlPad

    local curRow = 0
    for i = 1, LocalPlayer():GetInvSlots() do
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

            render.SetStencilEnable( true )

            render.ClearStencil()
            
            render.SetStencilTestMask( 255 )
            render.SetStencilWriteMask( 255 )

            render.SetStencilPassOperation( STENCILOPERATION_KEEP )
            render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

            render.SetStencilReferenceValue( 9 )
            render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

            draw.RoundedBox( 0, x, y, w, h * eased, color_black )

            render.SetStencilFailOperation( STENCILOPERATION_KEEP )

            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

            draw.RoundedBox( 0, x, y, w, h, Color( 25, 25, 25, 240 * info_alpha ) )

            draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + nameH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            local desc_y = y + descH*2
            for k, v in pairs( desc_lines ) do
                draw.SimpleText( v, "ItemInfoSmall", x + w/2, desc_y + descH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                desc_y = desc_y + descH
            end

            render.SetStencilEnable( false )

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

            --local wep = LocalPlayer():GetWeapon( CLASSES[LocalPlayer():GetFPClass()].hands_override or "fp_hands" )
            --input.SelectWeapon( wep )

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
        end)

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
    if button != CL_SETTINGS.Get( "fp_inventory_button" ) then return end

    if CLIENT and not IsFirstTimePredicted() then
        return
    end

    CreateInventoryUI()
end)