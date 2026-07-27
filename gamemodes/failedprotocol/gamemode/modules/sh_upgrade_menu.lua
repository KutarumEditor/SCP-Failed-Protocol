UPGRADES = {
    ["SCP457"] = {
        -- Health Aspect
        ["hpaspect1"] = {
            price = 1,
            x = -2,
            y = -7,
            exc = { "apaspect1" },
        },
        ["hpaspect2"] = {
            price = 1,
            x = -2,
            y = -4,
            req = { "hpaspect1" },
        },
        -- Armor Aspect
        ["apaspect1"] = {
            price = 1,
            x = 2,
            y = -7,
            exc = { "hpaspect1" },
        },
        ["apaspect2"] = {
            price = 1,
            x = 2,
            y = -4,
            req = { "apaspect1" },
        },
    },
}

if SERVER then

local PLAYER = FindMetaTable( "Player" )

function PLAYER:ActivateUpgrade( name )
    local wep = self:GetActiveWeapon()

    if !wep:IsValid() or wep.SCP_SWEP != true then return end


end

net.Receive( "FPUpgradeMenu", function( len, ply )
    ply:ActivateUpgrade( net.ReadString() )
end )

else

local UpgMenu = {
    w = ScrW() / 1.5,
    h = ScrH() / 1.5,
}

local info_alpha = 0
local outline_size = 1

function OpenUpgradeMenu()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not wep:IsValid() or wep.SCP_SWEP != true or not ply:Alive() or not wep.FPUpgrades then return end

    if LAST_CURSOR_POS != nil then
        input.SetCursorPos( LAST_CURSOR_POS.x, LAST_CURSOR_POS.y )
    end

    local frame = vgui.Create( "DPanel" )
    
    frame:SetSize( 0, UpgMenu.h )
    frame:SetPos( ScrW() / 2 - UpgMenu.w / 2, ScrH() / 2 - UpgMenu.h / 2 )
    frame:SizeTo( UpgMenu.w, UpgMenu.h, .125, 0, -1 )
    
    frame:MakePopup()
    frame:SetAlpha( 245 )
    frame:SetKeyboardInputEnabled( false )

    local btns = {}
    local node_size = ScreenScale( 22 )
    local center_x, center_y = UpgMenu.w / 2, UpgMenu.h / 2 + ScreenScale( 10 )
    local scale = ScreenScale( 14 ) 

    function frame:Paint( w, h )
        if not ply:Alive() or not input.IsButtonDown( CL_SETTINGS.Get( "fp_upgrade_menu" ) ) or wep.SCP_SWEP != true or not wep.FPUpgrades then
            local x, y = input.GetCursorPos()
            LAST_CURSOR_POS = {
                x = x,
                y = y
            }
            self:Remove()
        end

        draw.RoundedBox( 0, 0, 0, w, h, Color( 5, 5, 5, 240 ) ) 
        surface.SetDrawColor( 45, 45, 45, 25 )

        if draw.HAnimatedLines then
            draw.HAnimatedLines( "invupgrades", ScreenScale( 4 ), 10 ) 
        end

        local title = LANG.Get( "MISC", "upgrades" )
        draw.SimpleTextOutlined( title, "HUDMedium", w/2, ScreenScale( 6 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 ) )

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

        for id, node in pairs( wep.FPUpgrades ) do
            if node.req then
                for _, req_id in ipairs( node.req ) do
                    local req_btn = btns[req_id]
                    local btn_node = btns[id]
                    
                    if IsValid( req_btn ) and IsValid( btn_node ) then
                        local x1, y1 = req_btn:GetX() + node_size/2, req_btn:GetY() + node_size/2
                        local x2, y2 = btn_node:GetX() + node_size/2, btn_node:GetY() + node_size/2

                        surface.SetDrawColor( Color( 55, 55, 55, 200 ) )
                        surface.DrawLine( x1, y1, x2, y2 )
                    end
                end
            end

            if node.exc then
                for _, exc_id in ipairs( node.exc ) do
                    local exc_btn = btns[exc_id]
                    local btn_node = btns[id]
                    
                    if IsValid( exc_btn ) and IsValid( btn_node ) then
                        local x1, y1 = exc_btn:GetX() + node_size/2, exc_btn:GetY() + node_size/2
                        local x2, y2 = btn_node:GetX() + node_size/2, btn_node:GetY() + node_size/2

                        surface.SetDrawColor( Color( 158, 64, 64, 200) )
                        surface.DrawLine( x1, y1, x2, y2 )
                    end
                end
            end
        end
    end

    local UpTab = {}

    for id, node in pairs( wep.FPUpgrades ) do
        PrintTable( { id, node } )
        local btn = vgui.Create( "DButton", frame )
        btn:SetSize( node_size, node_size )
        btn:SetPos( center_x + (node.x * scale) - node_size/2, center_y + (node.y * scale) - node_size/2 ) 
        btn:SetText( "" )
        btn.Node = node 
        btn.HoveredTime = 0
        btns[id] = btn
        btn.UpgradeProgress = 0
        btn.reqsMet = false

        function btn:Paint( w, h )
            UpTab[id] = btn.Activated or false

            btn:SetCursor( "hand" )

            if node.req != nil and #node.req != 0 then
                for _, req_id in ipairs( node.req ) do
                    if UpTab[req_id] then
                        btn.reqsMet = true
                    else
                        btn.reqsMet = false
                        break
                    end
                end
            else
                btn.reqsMet = true
            end

            if node.exc != nil and #node.exc != 0 then
                for _, exc_id in ipairs( node.exc ) do
                    if UpTab[exc_id] then
                        btn.reqsMet = false
                        break
                    end
                end
            end

            local clr = btn.Activated and Color( 69, 146, 62) or !btn.reqsMet and Color( 51, 51, 51) or ( btn:IsHovered() and ( input.IsMouseDown( MOUSE_LEFT ) and Color( 255, 225, 0 ) or Color( 0, 255, 255 ) ) or color_white )

            surface.SetDrawColor( Color( 0, 0, 0, 245 ) )
            surface.DrawRect( 0, 0, w, h )

            if btn.reqsMet then
                if btn.Activated != true then
                    local eased = math.ease.OutCubic( btn.UpgradeProgress )
                    surface.SetDrawColor( Color( 196, 129, 41, 245 ) )
                    surface.DrawRect( 0, h - h * eased, w, h )
                else
                    surface.SetDrawColor( LerpColor( 1 - btn.UpgradeProgress, Color( 96, 165, 82, 245 ), Color( 96, 165, 82, 0 ) ) )
                    surface.DrawRect( 0, 0, w, h )
                end
            end

            surface.SetDrawColor( clr )
            surface.DrawOutlinedRect( 0, 0, w, h, 1 )
        end

        function btn:DrawInfo()
            if btn.HoveredTime < .5 then return end 

            local name = id 
            local price_text = "Цена: " .. btn.Node.price 
            
            surface.SetFont( "ItemInfoNormal" )
            local nameW, nameH = surface.GetTextSize( name )
            
            surface.SetFont( "ItemInfoSmall" )
            local priceW, priceH = surface.GetTextSize( price_text )

            local x, y = gui.MouseX() + 16, gui.MouseY() + 16
            local w, h = math.max(nameW, priceW) + 16, nameH + priceH + 12

            local eased = math.ease.OutCirc( info_alpha )

            if x + w > ScrW() then x = ScrW() - w end
            if y + h > ScrH() then y = ScrH() - h end

            info_alpha = math.Clamp( info_alpha + .01, 0, 1 ) 

            if KMASKS then
                KMASKS.Start()
                    draw.RoundedBox( 0, x, y, w, h, Color( 5, 5, 5, 240 * info_alpha ) ) 
                    draw.SimpleText( name, "ItemInfoNormal", x + w/2, y + nameH/2 + 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    draw.SimpleText( price_text, "ItemInfoSmall", x + w/2, y + nameH + priceH/2 + 4, Color( 200, 200, 200, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                KMASKS.Source()
                    draw.RoundedBox( 0, x, y, w, h * eased, color_black ) 
                KMASKS.End()
            end

            surface.SetDrawColor( color_white )
            surface.DrawLine( x, y, x + w, y ) 
            surface.DrawLine( x, y + h * eased, x + w, y + h * eased ) 
        end

        function btn:Think()
            if btn:IsHovered() then
                if input.IsMouseDown( MOUSE_LEFT ) and btn.Activated != true and btn.reqsMet == true then
                    btn.UpgradeProgress = math.min( 1, btn.UpgradeProgress + FrameTime() * 3 )

                    if btn.UpgradeProgress == 1 then
                        net.Start( "FPUpgradeMenu" )
                            net.WriteString( id )
                        net.SendToServer()

                        btn.Activated = true
                    end
                else
                    btn.UpgradeProgress = math.max( 0, btn.UpgradeProgress - FrameTime() * 5 )
                end

                btn.HoveredTime = btn.HoveredTime + FrameTime()
            else
                btn.UpgradeProgress = math.max( 0, btn.UpgradeProgress - FrameTime() * 5 )

                btn.HoveredTime = 0
            end
        end

        function btn:OnCursorExited()
            info_alpha = 0
        end
    end

    local closeBtn = vgui.Create( "DButton", frame )
    closeBtn:SetSize( 16, 16 )
    closeBtn:SetPos( UpgMenu.w - 24, 8 )
    closeBtn:SetText( "X" )
    closeBtn:SetFont( "ItemInfoSmall" )
    closeBtn:SetTextColor( Color( 150, 150, 150 ) )
    
    function closeBtn:Paint( w, h )
        if closeBtn:IsHovered() then 
            closeBtn:SetTextColor( Color( 255, 50, 50 ) ) 
        else 
            closeBtn:SetTextColor( Color( 150, 150, 150 ) ) 
        end
    end
    
    function closeBtn:DoClick()
        frame:Remove()
    end
end

hook.Add( "PlayerButtonDown", "FPUpgradesOpen", function( ply, button )
    if CLIENT and button == CL_SETTINGS.Get( "fp_upgrade_menu" ) and IsFirstTimePredicted() then
        OpenUpgradeMenu()
    end
end )

end