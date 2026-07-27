local endTime = 0
local endType = ""

local function GetEndingInfo( type )
    if ENDINGS[ROUND.type] == nil then return {} end

    for i, v in ipairs( ENDINGS[ROUND.type] ) do
        if v.lang == type then
            return v
        end
    end

    return {}
end

hook.Add( "FPHUD", "DrawEnding", function()
    local lply = LocalPlayer()
    local ct = CurTime()
    local info = GetEndingInfo( endType )

    if info != {} and ct < endTime then
        draw.SimpleText( info.lang, "HUDNormal", ScrW()/2, ScrH()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end )

net.ReceivePing( "ShowEnding", function( data )
    endType = data
    endTime = CurTime() + 30
end )