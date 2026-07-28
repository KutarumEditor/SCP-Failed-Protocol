if SERVER then

function WarheadLaunch()
    print( "Warhead launched!" )

    net.Ping( "WarheadCrank" )

    util.ScreenShake( Vector(), 3, 10, 10, 99999999, true )

    TIMERS.Create( "CrankShake", 7.5, function()
        util.ScreenShake( Vector(), 5, 15, 5, 99999999, true )
    end )

	TIMERS.Create( "WarheadNuke", 10, function()
        TransmitSound( "warhead.alarm", false, 1 )

        ROUNDPROP.Set( "WarheadDetonated", true )

        net.Ping( "WarheadNuke" )

		for i, v in ipairs( player.GetAlive() ) do
			v:KillSilent()
		end
	end )
end

function WarheadStart()
	print( "Warhead has been activated!" )

	TransmitSound( "warhead.alarm", true, 1 )

    net.Ping( "WarheadStart" )

	TIMERS.Create( "WarheadAnnouncement", 2, function()
		PA.Play( "scpfp/public_announcements/warheads.wav" )

		TIMERS.Create( "WarheadSiren", 2, function()
			TransmitSound( "warhead.siren", true, 1 )

			TIMERS.Create( "WarheadCrank", 170, function()
				WarheadLaunch()
			end )
		end )
	end )
end

else

WARHEAD_SIREN = false
WARHEAD_SIREN_RATIO = 0
local warhead_clr = Color( 125, 0, 0, 215)

hook.Add( "PreFPHUD", "WarheadSiren", function()
    if WARHEAD_SIREN then
        WARHEAD_SIREN_RATIO = math.min( WARHEAD_SIREN_RATIO + FrameTime() / 3, 1 )
    else
        WARHEAD_SIREN_RATIO = math.max( WARHEAD_SIREN_RATIO - FrameTime() / 3, 0 )
    end
    
    if WARHEAD_SIREN_RATIO > 0 then
        local clr = warhead_clr:Copy()
        clr.a = 125 * ( math.cos( CurTime() ) / 2 + .5 ) * WARHEAD_SIREN_RATIO
        surface.SetDrawColor( clr )
        surface.DrawRect( 0, 0, ScrW(), ScrH() )
    end
end )

net.ReceivePing( "WarheadStart", function()
    local ply = LocalPlayer()

    ply:ScreenFade( SCREENFADE.IN, warhead_clr, .75, 1.5 )
    TIMERS.Create( "WarheadAlarm", 1.84, function()
        ply:ScreenFade( SCREENFADE.IN, warhead_clr, .75, 1.5 )
    end )

    TIMERS.Create( "WarheadSirenVisual", 4, function()
        WARHEAD_SIREN = true
    end )

    TIMERS.Create( "WarheadMusic", 4, function()
        AMBIENT.Restart( "sound/scpfp/ambience/warhead.wav" )
    end )
end )

net.ReceivePing( "WarheadCrank", function()
    print( "Pizdets Vam..." )
    local ply = LocalPlayer()

    WARHEAD_SIREN = false

    AMBIENT.Ban( 30 )

    surface.PlaySound( "scpfp/warheads/crank.wav" )

    TIMERS.Create( "CrankAlarm", 1.2, function()
        ply:ScreenFade( SCREENFADE.IN, warhead_clr, .75, .5 )
        for i = 1, 5 do
            TIMERS.Create( "CrankAlarm"..i, 1.3 * i, function()
                ply:ScreenFade( SCREENFADE.IN, warhead_clr, .75, .5 )
            end )
        end
    end )
end )

net.ReceivePing( "WarheadNuke", function()
    local ply = LocalPlayer()

    RunConsoleCommand( "stopsound" )
    ExplosionFadeOut = CurTime() + 3.5
    timer.Simple( FrameTime()*3, function()
        surface.PlaySound( "scpfp/warheads/nuke.wav" )
    end )

    TIMERS.Create( "PostNukePhrase1", 8.5, function()
        PHRASES.Cast( ply, "scpfp/warheads/phrase1.wav", "unkoper", "first" )

        TIMERS.Create( "PostNukePhrase2", 7, function()
            PHRASES.Cast( ply, "scpfp/warheads/phrase2.wav", "unkoper", "second" )
        end )
    end )
end )

end