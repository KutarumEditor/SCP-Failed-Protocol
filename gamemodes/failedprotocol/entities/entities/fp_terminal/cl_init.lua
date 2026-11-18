include( "shared.lua" )

ENT.Data = {
    -- {
    --     title = "Test message",
    --     sender = "Sender",
    --     text = [[Test text.Test text.Test text.Test text.]],
    -- }
}

local TEX_WIDTH, TEX_HEIGHT = 1140, 640

local Colors = {
    back = Color( 12, 14, 18, 245 ),
    panelBack = Color( 20, 24, 32, 200 ),
    main = Color( 70, 130, 180 ),
    highlight = Color( 100, 180, 220 ),
    pressed = Color( 40, 90, 130 ),
    text = Color( 200, 220, 240 ),
    textDim = Color( 100, 120, 140 ),
    error = Color( 220, 60, 60 ),
    success = Color( 60, 220, 100 ),
    border = Color( 50, 80, 110 )
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

function TerminalUI.DrawDecoratedBox( x, y, w, h, colBack, colBorder )
    surface.SetDrawColor( colBack )
    surface.DrawRect( x, y, w, h )
    
    surface.SetDrawColor( colBorder )

    local len = 6
    surface.DrawLine( x, y, x + len, y )
    surface.DrawLine( x, y, x, y + len )

    surface.DrawLine( x + w, y, x + w - len, y )
    surface.DrawLine( x + w, y, x + w, y + len )

    surface.DrawLine( x, y + h, x + len, y + h )
    surface.DrawLine( x, y + h, x, y + h - len )

    surface.DrawLine( x + w, y + h, x + w - len, y + h )
    surface.DrawLine( x + w, y + h, x + w, y + h - len )
end

function TerminalUI.Button( x, y, w, h, text, isSelected )
    local mx, my = TerminalUI.MX, TerminalUI.MY
    local isHovered = false

    if mx and mx >= x and mx <= x + w and my >= y and my <= y + h then
        isHovered = true
    end

    local clrBack = Colors.panelBack
    local clrBorder = Colors.border
    local clrText = Colors.text

    if isHovered then
        clrBack = Colors.pressed
        clrBorder = Colors.highlight
        clrText = color_white
    end

    if isSelected then
        clrBack = Colors.main
        clrBorder = Colors.highlight
        clrText = color_white
    end

    TerminalUI.DrawDecoratedBox( x, y, w, h, clrBack, clrBorder )
    draw.SimpleText( text, "HUDNormal", x + w / 2, y + h / 2, clrText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

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
    
    TerminalUI.DrawDecoratedBox( x, y, w, h, Colors.panelBack, clr )
    
    surface.SetDrawColor( clr )
    surface.SetMaterial( mat )
    surface.DrawTexturedRect( x + 8, y + 8, w - 16, h - 16 )

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

    surface.SetDrawColor( Colors.back )
    surface.DrawRect( -w/2, -h/2, w, h )

    TerminalUI.DrawDecoratedBox( -w/2 + 10, -h/2 + 10, w - 20, h - 20, Color( 0, 0, 0, 0 ), Colors.border )

    if self:GetActive() and self:GetUser() == lply then
        if TerminalUI.TexturedButton( w/2 - 60, -h/2 + 20, 40, 40, power_mat, Colors.textDim, Colors.error, Colors.pressed ) then
            surface.PlaySound( "buttons/lightswitch2.wav" )
            lply.Terminal = nil
            net.Ping( "FPStopTerminalUsage" )
        end

        draw.SimpleText( "SEC-TERMINAL v2.4", "HUDNormal", -w/2 + 30, -h/2 + 40, Colors.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        draw.SimpleText( os.date("%H:%M:%S"), "HUDNormal", w/2 - 160, -h/2 + 40, Colors.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

        surface.SetDrawColor( Colors.border )
        local linePos = -h/2 + 70
        surface.DrawLine( -w/2 + 20, linePos, w/2 - 20, linePos )
        
        if not self:GetShow() then
            TerminalUI.DrawDecoratedBox( -180, -120, 360, 260, Colors.panelBack, Colors.border )

            surface.SetDrawColor( Colors.text )
            surface.SetMaterial( user_mat )
            surface.DrawTexturedRect( -30, -100, 60, 60 )

            draw.SimpleText( "ТРЕБУЕТСЯ АВТОРИЗАЦИЯ", "HUDNormal", 0, -10, Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            local passBoxY = 25
            local isError = self.WrongPassword > ct
            TerminalUI.DrawDecoratedBox( -140, passBoxY, 280, 40, Color( 10, 12, 16 ), isError and Colors.error or Colors.border )

            local password = ENTERED_PASSWORD or ""
            local maskedPass = string.rep("*", string.len(password))
            if (CurTime() % 1) > 0.5 then maskedPass = maskedPass .. "_" end
            
            draw.SimpleText( maskedPass, "HUDNormal", 0, passBoxY + 20, isError and Colors.error or Colors.highlight, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            local text = isError and "НЕВЕРНЫЙ КОД ДОСТУПА" or "ВОЙТИ В СИСТЕМУ"
            if TerminalUI.Button( -140, 80, 280, 40, text, false ) then
                surface.PlaySound( "buttons/lightswitch2.wav" )
                net.Ping( "FPEnterTerminalPassword", password )
                timer.Simple( .1, function()
                    if self:IsValid() then
                        self.WrongPassword = ct + 2
                    end
                end )
            end
        else
            self.WrongPassword = 0
        
            surface.SetDrawColor( Colors.border )
            local splitX = -w/4 + 20
            surface.DrawLine( splitX, -h/2 + 90, splitX, h/2 - 30 )

            draw.SimpleText( "БАЗА ДАННЫХ", "HUDNormal", -w/2 + 35, -h/2 + 95, Colors.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

            for i = 1, #self.Data do
                local isSelected = (self.SelectedFile == i)
                if TerminalUI.Button( -w/2 + 25, -h/2 + 120 + ( i - 1 ) * 55, 260, 45, self.Data[i].title, isSelected ) then
                    surface.PlaySound( "buttons/lightswitch2.wav" )
                    if self.SelectedFile != i then
                        self.SelectedFile = i
                    else
                        self.SelectedFile = nil
                    end
                end
            end

            if self.SelectedFile != nil then
                local fileData = self.Data[self.SelectedFile]
                
                draw.SimpleText( "ДОКУМЕНТ: " .. fileData.title, "HUDNormal", splitX + 25, -h/2 + 95, Colors.highlight, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                draw.SimpleText( "АВТОР: " .. fileData.sender, "HUDNormal", w/2 - 40, -h/2 + 95, Colors.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                
                surface.SetDrawColor( Colors.border )
                surface.DrawLine( splitX + 20, -h/2 + 115, w/2 - 20, -h/2 + 115 )

                local boxX = splitX + 20
                local boxY = -h/2 + 130
                local boxW = (w/2 - 20) - boxX
                local boxH = math.min(h - 170, (h/2 - 20) - boxY)

                TerminalUI.DrawDecoratedBox( boxX, boxY, boxW, boxH, Colors.panelBack, Colors.border )

                local text = fileData.text
                local maxLineWidth = boxW - 30
                local lineHeight = 22
                local maxLines = math.floor((boxH - 45) / lineHeight)
                
                surface.SetFont( "HUDNormal" )
                local lines = {}
                
                -- Красивый и чистый перенос текста по словам (без разрыва букв)
                for _, paragraph in ipairs(string.Explode("\n", text)) do
                    local currentLine = ""
                    for word in string.gmatch(paragraph, "%S+") do
                        local testLine = currentLine == "" and word or (currentLine .. " " .. word)
                        local tw, _ = surface.GetTextSize(testLine)
                        
                        if tw > maxLineWidth then
                            if currentLine ~= "" then
                                table.insert(lines, currentLine)
                                currentLine = word
                            else
                                -- Если даже отдельное слово слишком длинное, помещаем его на новую строку целиком
                                table.insert(lines, word)
                                currentLine = ""
                            end
                        else
                            currentLine = testLine
                        end
                    end
                    if currentLine ~= "" then
                        table.insert(lines, currentLine)
                    end
                end

                for i = 1, math.min(#lines, maxLines) do
                    draw.SimpleText( lines[i], "HUDNormal", boxX + 15, boxY + 15 + ( i - 1 ) * lineHeight, Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
                end

                if #lines > maxLines then
                    draw.SimpleText( "-- ТЕКСТ СМЕЩЕН / ЕСТЬ ЕЩЕ СТРОКИ --", "HUDNormal", boxX + boxW / 2, boxY + boxH - 20, Colors.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                end
            else
                draw.SimpleText( "ВЫБЕРИТЕ ФАЙЛ", "HUDNormal", splitX + (w/2 - splitX)/2, 0, Colors.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
    else
        surface.SetDrawColor( Colors.highlight )
        surface.SetMaterial( logo_mat )
        surface.DrawTexturedRect( -h/6, -h/4, h/3, h/3 )

        draw.SimpleText( "ТЕРМИНАЛ ЗОНЫ // НАЖМИТЕ [E]", "HUDNormal", 0, h/6, Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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