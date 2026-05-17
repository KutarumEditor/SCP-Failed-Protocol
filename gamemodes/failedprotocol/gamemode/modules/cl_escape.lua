local startTime, endTime = 0, 0
local name
local shownRatio = 0

local sizeW, sizeH = ScreenScale( 128 ), ScreenScale( 36 )

hook.Add( "FPHUD", "EscapeHUD", function()
    local ct, ft = CurTime(), FrameTime()
    if ct < endTime then
        shownRatio = math.min( 1, shownRatio + ft )
    else
        shownRatio = math.max( 0, shownRatio - ft )
    end

    if shownRatio == 0 then return end

    local eased = math.ease.InOutCubic( shownRatio )
    local clr = Color( 0, 0, 0, 225 * eased )
    local clr_add = 55 * math.sin( ct * 3 )
    local positive_clr = Color( 75, 175 + clr_add, 75, 255 * eased )

    local wCenter = ( ScrW() - sizeW ) / 2
    local hPos = 0 + sizeH * eased / 3
    draw.RoundedBox( 0, wCenter, hPos, sizeW, sizeH, clr )

    draw.SimpleText( LANG.Get( "MISC", "escaping" )..":", "HUDMedium", ScrW() / 2, hPos + ScreenScale( 2 ), positive_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    draw.SimpleText( "["..LANG.Get( "EXITS", name ).."]", "HUDNormal", ScrW() / 2, hPos + ScreenScale( 11 ), positive_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    draw.SimpleText( math.max( 0, math.Round( endTime - ct, 3 ) ), "HUDNormal", ScrW() / 2, hPos + ScreenScale( 22 ), positive_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    draw.RoundedBox( 0, wCenter, hPos, sizeW, ScreenScale( 1 ), positive_clr )
    draw.RoundedBox( 0, wCenter, hPos + sizeH - ScreenScale( 1 ), sizeW, ScreenScale( 1 ), positive_clr )
end )

net.ReceivePing( "FPStartEscape", function( data )
    local ct = CurTime()
    startTime, endTime, name = ct, ct + ( EXITS[data].time or 0 ), data
end )

net.ReceivePing( "FPAbortEscape", function( data )
    startTime, endTime = 0, 0
end )