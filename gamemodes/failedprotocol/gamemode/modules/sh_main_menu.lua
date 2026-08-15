if SERVER then

else

local MainMenu
local MenuOpen = false

local CloseCustomMenu = function() end

local COLORS = {
    Background = Color(18, 18, 20, 245),
    Panel      = Color(24, 24, 27, 255),
    Button     = Color(32, 32, 36, 255),
    ButtonHover= Color(45, 45, 50, 255),
    Text       = Color(235, 235, 235),
    SubText    = Color(145, 145, 150),
    Accent     = Color(180, 180, 180),
    Close      = Color(180, 65, 65),
    CloseHover = Color(215, 75, 75)
}

local function OpenCustomMenu()

    if IsValid(MainMenu) then
        MainMenu:Remove()
    end

    MenuOpen = true

    MainMenu = vgui.Create("DFrame")
    MainMenu:SetSize(ScrW(), ScrH())
    MainMenu:SetPos(0, 0)

    MainMenu:SetTitle("")
    MainMenu:SetDraggable(false)
    MainMenu:ShowCloseButton(false)
    MainMenu:MakePopup()

    MainMenu.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, COLORS.Background)

        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(0, 0, w, 1)

        draw.SimpleText(
            "MAIN MENU",
            "DermaLarge",
            80,
            60,
            COLORS.Text,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            "CUSTOM INTERFACE",
            "DermaDefault",
            82,
            90,
            COLORS.SubText,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            "v1.0",
            "DermaDefault",
            w - 40,
            h - 30,
            COLORS.SubText,
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER
        )
    end

    local MenuPanel = vgui.Create("DPanel", MainMenu)

    MenuPanel:SetSize(420, 470)
    MenuPanel:SetPos(80, 145)

    MenuPanel.Paint = function(self, w, h)
        draw.RoundedBox(
            0,
            0,
            0,
            w,
            h,
            COLORS.Panel
        )

        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local function CreateMenuButton(parent, text, y, callback, danger)
        local Button = vgui.Create("DButton", parent)

        Button:SetSize(380, 55)
        Button:SetPos(20, y)
        Button:SetText("")

        Button.Paint = function(self, w, h)
            local bg = COLORS.Button

            if self:IsHovered() then

                if danger then
                    bg = COLORS.CloseHover
                else
                    bg = COLORS.ButtonHover
                end

            end

            draw.RoundedBox(
                0,
                0,
                0,
                w,
                h,
                bg
            )

            draw.SimpleText(
                text,
                "DermaDefaultBold",
                20,
                h / 2,
                COLORS.Text,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )

            draw.SimpleText(
                "→",
                "DermaDefaultBold",
                w - 20,
                h / 2,
                COLORS.SubText,
                TEXT_ALIGN_RIGHT,
                TEXT_ALIGN_CENTER
            )
        end

        Button.DoClick = callback

        return Button
    end

    CreateMenuButton(
        MenuPanel,
        "ПРОДОЛЖИТЬ",
        20,
        function()
            CloseCustomMenu()
        end
    )

    CreateMenuButton(
        MenuPanel,
        "НАСТРОЙКИ",
        85,
        function()

            CloseCustomMenu()

            timer.Simple(0, function()
                RunConsoleCommand("gamemenucommand", "openoptionsdialog")
            end)

        end
    )

    CreateMenuButton(
        MenuPanel,
        "ОТКРЫТЬ СЕРВЕРНЫЙ СПИСОК",
        150,
        function()

            CloseCustomMenu()

            timer.Simple(0, function()
                RunConsoleCommand("gamemenucommand", "openserverbrowser")
            end)

        end
    )

    CreateMenuButton(
        MenuPanel,
        "ОТКЛЮЧИТЬСЯ",
        215,
        function()

            CloseCustomMenu()

            timer.Simple(0, function()
                RunConsoleCommand("disconnect")
            end)

        end
    )

    CreateMenuButton(
        MenuPanel,
        "ВЫЙТИ ИЗ ИГРЫ",
        280,
        function()

            Derma_Query(
                "Вы действительно хотите выйти из Garry's Mod?",
                "Выход",
                "Выйти",
                function()
                    RunConsoleCommand("quit")
                end,
                "Отмена"
            )

        end,
        true
    )

    local Info = vgui.Create("DLabel", MainMenu)

    Info:SetPos(80, 650)
    Info:SetSize(500, 40)

    Info:SetText("Нажмите ESC, чтобы закрыть меню")
    Info:SetFont("DermaDefault")
    Info:SetTextColor(COLORS.SubText)

end

function CloseCustomMenu()

    if IsValid(MainMenu) then
        MainMenu:Remove()
    end

    MenuOpen = false

end

hook.Add("OnPauseMenuShow", "CustomPauseMenu", function()
    if MenuOpen then
        CloseCustomMenu()
        return false
    end

    OpenCustomMenu()

    return false
end)

hook.Add("ShutDown", "CustomPauseMenuShutdown", function()
    if IsValid(MainMenu) then
        MainMenu:Remove()
    end
end)

end