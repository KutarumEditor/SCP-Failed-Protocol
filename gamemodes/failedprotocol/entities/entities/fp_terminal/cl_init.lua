include( "shared.lua" )

local TEX_WIDTH, TEX_HEIGHT = 1140, 640

local Colors = {
    back = Color( 16, 16, 16 ),
    main = Color( 215, 215, 215 ),
    highlight = Color( 255, 255, 255),
    pressed = Color( 140, 140, 140 ),
}

local TerminalUI = {
    MX = 0,
    MY = 0,
    Pressed = false,
    LastFrame = 0,
    WasDown = false
}

function TerminalUI.UpdateInput( ent, pos, ang, scale )
    local mx, my = gui.MousePos()
    if mx == 0 and my == 0 then 
        TerminalUI.MX, TerminalUI.MY = nil, nil
        TerminalUI.Pressed = false
        return 
    end

    local rayOrigin = EyePos()
    local rayDir = gui.ScreenToVector( mx, my )
    local planeNormal = ang:Up()

    local hitPos = util.IntersectRayWithPlane( rayOrigin, rayDir, pos, planeNormal )
    
    if hitPos then
        local localHit = hitPos - pos

        TerminalUI.MX = localHit:Dot( ang:Forward() ) / scale
        TerminalUI.MY = localHit:Dot( ang:Right() ) / scale
    else
        TerminalUI.MX, TerminalUI.MY = nil, nil
    end

    local curFrame = FrameNumber()
    if curFrame ~= TerminalUI.LastFrame then
        local isDown = input.IsMouseDown( MOUSE_LEFT )
        TerminalUI.Pressed = isDown and not TerminalUI.WasDown
        TerminalUI.WasDown = isDown
        TerminalUI.LastFrame = curFrame
    end
end

function TerminalUI.Button( x, y, w, h, text, color, hoverColor, pressedColor )
    local mx, my = TerminalUI.MX, TerminalUI.MY
    local isHovered = false

    if mx and mx >= x and mx <= x + w and my >= y and my <= y + h then
        isHovered = true
    end

    local clr = color
    if isHovered then
        clr = TerminalUI.Pressed and pressedColor or hoverColor
    end
    surface.SetDrawColor( clr )
    surface.DrawOutlinedRect( x, y, w, h, 1 )
    draw.SimpleText( text, "HUDNormal", x + w / 2, y + h / 2, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return isHovered and TerminalUI.Pressed
end

function TerminalUI.TexturedButton( x, y, w, h, mat, color, hoverColor, pressedColor )
    local mx, my = TerminalUI.MX, TerminalUI.MY
    local isHovered = false

    if mx and mx >= x and mx <= x + w and my >= y and my <= y + h then
        isHovered = true
    end

    local clr = color
    if isHovered then
        clr = TerminalUI.Pressed and pressedColor or hoverColor
    end
    surface.SetDrawColor( clr )
    surface.SetMaterial( mat )
    surface.DrawTexturedRect( x, y, w, h )

    return isHovered and TerminalUI.Pressed
end

function TerminalUI.File( x, y, w, h, text, color, hoverColor, pressedColor )
    local mx, my = TerminalUI.MX, TerminalUI.MY
    local isHovered = false

    if mx and mx >= x and mx <= x + w and my >= y and my <= y + h then
        isHovered = true
    end

    local clr = color
    if isHovered then
        clr = TerminalUI.Pressed and pressedColor or hoverColor
    end
    surface.SetDrawColor( clr )
    surface.DrawOutlinedRect( x, y, w, h, 1 )
    draw.SimpleText( text, "HUDNormal", x + w / 2, y + h / 2, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return isHovered and TerminalUI.Pressed
end

ENT.WrongPassword = 0
ENT.SelectedFile = nil

local user_mat = Material( "failedprotocol/terminal/user.png" )
local logo_mat = Material( "failedprotocol/scp_logo.png" )
local power_mat = Material( "failedprotocol/terminal/power.png" )
function ENT:RenderScreen( w, h, pos, ang, scale )
    local lply = LocalPlayer()
    local ct = CurTime()

    TerminalUI.UpdateInput( self, pos, ang, scale )

    draw.RoundedBox( 0, -w/2, -h/2, w, h, Colors.back )

    if self:GetActive() then
        if TerminalUI.TexturedButton( TEX_WIDTH/2 - 50, -TEX_HEIGHT/2 + 5, 40, 40, power_mat, Colors.main, Colors.highlight, Colors.pressed ) then
            surface.PlaySound( "buttons/lightswitch2.wav" )
            lply.Terminal = nil
            net.Ping( "FPStopTerminalUsage" )
        end

        draw.SimpleText( "ТЕРМИНАЛ", "HUDNormal", 0, -h/2 + 25, Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        surface.SetDrawColor( color_white )
        local linePos = -h/2 + 50
        surface.DrawLine( -TEX_WIDTH/2, linePos, TEX_WIDTH/2, linePos )
        
        if not self:GetShow() then
            surface.SetDrawColor( color_white )
            surface.SetMaterial( user_mat )
            surface.DrawTexturedRect( -TEX_HEIGHT/6, -TEX_HEIGHT/3, TEX_HEIGHT/3, TEX_HEIGHT/3 )

            local linePos = 125
            surface.DrawLine( -125, linePos, 125, linePos )

            local password = ENTERED_PASSWORD or ""
            draw.SimpleText( password, "HUDNormal", 0, 125, Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

            local text = self.WrongPassword > ct and "НЕВЕРНЫЙ ПАРОЛЬ" or "АВТОРИЗОВАТЬСЯ"
            if TerminalUI.Button( -150, 150, 300, 50, text, Colors.main, Colors.highlight, Colors.pressed ) then
                surface.PlaySound( "buttons/lightswitch2.wav" )
                net.Ping( "FPEnterTerminalPassword", password )
                timer.Simple( .1, function()
                    if self:IsValid() then
                        self.WrongPassword = ct + 3
                    end
                end )
            end
        else
            self.WrongPassword = 0
            --draw.SimpleText( "ДОСТУП РАЗРЕШЕН. РЕЖИМ ПРОСМОТРА.", "HUDNormal", 0, 0, Color( 0, 255, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
            surface.SetDrawColor( color_white )
            local linePos = -TEX_WIDTH/4
            surface.DrawLine( linePos, -270, linePos, 320 )

            self.Data = {
                {
                    title = "СОСТАВ ПЕРСОНАЛА",
                    sender = "gandon",
                    text = [[Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?
Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?
Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?]],
                },
                {
                    title = "СОСАЛ ПЕРСОНАЛА",
                    sender = "админ",
                    text = [[qwkdpfoq[fvinw[epvoinw[ovnw[onvwlknvq[oinv[oiqwnrvbqlknocd[lq][c;cs,mvds
bheripovqwedSosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?
Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?
Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?Sosal?]],
                },
            }

            for i = 1, #self.Data do
                if TerminalUI.File( -TEX_WIDTH/2 + 10, -TEX_HEIGHT/2 + 58 + ( i - 1 ) * 55, 269, 50, self.Data[i].title, Colors.main, Colors.highlight, Colors.pressed ) then
                    surface.PlaySound( "buttons/lightswitch2.wav" )
                    if self.SelectedFile != i then
                        self.SelectedFile = i
                    else
                        self.SelectedFile = nil
                    end
                end
            end

            if self.SelectedFile != nil then
                local text = self.Data[self.SelectedFile].text
                local textTbl = string.Explode( "\n", text )

                for i, v in ipairs( textTbl ) do
                    draw.SimpleText( v, "HUDNormal", -256, -220 + ( i - 1 ) * 50, clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
                end
            else
                draw.SimpleText( "ВЫБЕРИТЕ ФАЙЛ", "HUDBig", 150, 0, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
    else
        surface.SetDrawColor( color_white )
        surface.SetMaterial( logo_mat )
        surface.DrawTexturedRect( -TEX_HEIGHT/6, -TEX_HEIGHT/6, TEX_HEIGHT/3, TEX_HEIGHT/3 )
    end
end

function ENT:Draw()
    self:DrawModel()

    local ang = self:GetAngles()
    local pos = self:GetPos()

    local scale = 0.025

    pos = pos + ang:Forward() * 1.65 + ang:Right() * 0 + ang:Up() * 12.75

    ang:RotateAroundAxis( ang:Forward(), 90 )
    ang:RotateAroundAxis( Vector( 0, 0, 1 ), 90 )

    cam.Start3D2D( pos, ang, scale )
        self:RenderScreen( TEX_WIDTH, TEX_HEIGHT, pos, ang, scale )
    cam.End3D2D()
end

ENTERED_PASSWORD = ""

hook.Add( "PlayerButtonDown", "FPTerminalPasswordInput", function( ply, button )
    local lply = LocalPlayer()
    if lply.Terminal != nil and CurTime() > ply.LastUseTime + .1 then
        local char = input.GetKeyName( button )

        if char == "BACKSPACE" then
            ENTERED_PASSWORD = string.sub( ENTERED_PASSWORD, 1, #ENTERED_PASSWORD - 1 )
        elseif AVAILABLE_CHARS[char] == true and #ENTERED_PASSWORD < MAX_PASSWORD_LENGHT then
	        ENTERED_PASSWORD = ENTERED_PASSWORD .. char
        end
    end
end)