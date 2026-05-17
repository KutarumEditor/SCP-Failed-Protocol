local vignette_mat = Material( "vignette/vignette.png" )
function BreachAction()
	local ply = LocalPlayer()
	if not ply:Alive() then return end

	AMBIENT.Restart( "sound/scpfp/ambience/breach_ambience.wav" )
	surface.PlaySound( "scpfp/breach_action.wav" )

	timer.Simple( 1.3, function()
		timer.Create( "BreachSirenRepeat", 1.4, 6, function()
			DrawSprite( {
	            mat = vignette_mat,
	            clr = color_white,
	            time = .75,
	            fade = .5,
	            x = -1,
	            y = -1,
	            w = ScrW() + 2,
	            h = ScrH() + 2
	        } )

	        ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 100 ), .5, .65 )
		end )
	end )

	timer.Simple( 9.5, function()
		ply:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 200 ), .3, 4.2 )

		util.ScreenShake( EyePos(), 7.5, 7.5, 5.5, 10000, true )

		timer.Simple( 4.2 - FrameTime(), function()
			ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 200 ), .45, 0 )
		end )
	end )

	TIMERS.Create( "PAMalfunction", 3, function()
		PA.Play( "scpfp/public_announcements/malfunction.wav", "malfunction" )
	end )

	TIMERS.Create( "PABreach", 15, function()
		PA.Play( "scpfp/public_announcements/breach.wav", "breach" )
	end )
end

function RoundStartCutscene()
	local ply = LocalPlayer()

	HideHUD( true, true )

	ply:ScreenFade( SCREENFADE.IN, color_black, 5, 3 )
	AMBIENT.Ban( 189 )
	AMBIENT.Restart( "sound/scpfp/ambience/blue_feather.mp3" )
	TIMERS.Create( "ClientBreachStart", 46, function()
		BreachAction()
	end )

	timer.Simple( 3, function()
		HideHUD( false )
	end )
end

local logo_scale = ScreenScale( 100 )

local mtf_mat = Material( "failedprotocol/emblems/ntf.png" )
function MTFCutscene()
	local ply = LocalPlayer()

	RunConsoleCommand( "stopsound" )
	AMBIENT.Ban( 1 )

	timer.Simple( .01, function()
		AMBIENT.Restart( "sound/scpfp/support_themes/mtf.mp3" )
		ClearInfoPopup()
	end )

	HideHUD( true, true )

	ply:ScreenFade( SCREENFADE.IN, color_black, 5, 9.1 )

	TIMERS.Create( "MTFLogo", 5.1, function()
		DrawSprite( {
            mat = mtf_mat,
            clr = color_white,
            time = 4,
            fade = 3,
            x = ( ScrW() - logo_scale ) / 2,
            y = ( ScrH() - logo_scale ) / 2,
            w = logo_scale,
            h = logo_scale
        } )

		TIMERS.Create( "GetMyHUDBack", 5, function()
			PopupInfo( 15, {
				{
					text = { LANG.Get( "CLASSES", ply:GetFPClass() ) },
					font = "RoundStartInfoBig",
					color = FPTeams.GetColor( ply:FPTeam() ),
					ugap = -8,
					lgap = 4
				},
				{
					text = { LANG.Get( "DESC", ply:GetFPClass() ) },
					font = "RoundStartInfoExtraSmall",
					color = color_white,
					ugap = -8,
					lgap = 4
				},
			} )

			HideHUD( false )
		end )
	end )
end

local gru_mat = Material( "failedprotocol/emblems/gru.png" )
function GRUCutscene()
	local ply = LocalPlayer()

	RunConsoleCommand( "stopsound" )
	AMBIENT.Ban( 1 )

	timer.Simple( .1, function()
		AMBIENT.Restart( "sound/scpfp/support_themes/gru.mp3" )
	end )

	ClearInfoPopup()

	HideHUD( true, true )

	ply:ScreenFade( SCREENFADE.IN, color_black, 5, 9 )

	TIMERS.Create( "GRULogo", 8.4, function()
		DrawSprite( {
            mat = gru_mat,
            clr = color_white,
            time = 4,
            fade = 3,
            x = ( ScrW() - logo_scale ) / 2,
            y = ( ScrH() - logo_scale ) / 2,
            w = logo_scale,
            h = logo_scale
        } )

		TIMERS.Create( "GetMyHUDBack", 5, function()
			PopupInfo( 15, {
				{
					text = { LANG.Get( "CLASSES", ply:GetFPClass() ) },
					font = "RoundStartInfoBig",
					color = FPTeams.GetColor( ply:FPTeam() ),
					ugap = -8,
					lgap = 4
				},
				{
					text = { LANG.Get( "DESC", ply:GetFPClass() ) },
					font = "RoundStartInfoExtraSmall",
					color = color_white,
					ugap = -8,
					lgap = 4
				},
			} )

			HideHUD( false )
		end )
	end )
end

net.ReceivePing( "MTFSpawn", function()
	MTFCutscene()
end )

concommand.Add( "ntf_test", MTFCutscene )

concommand.Add( "gru_test", GRUCutscene )

concommand.Add( "breach_test", BreachAction )

hook.Add( "PlayerButtonDown", "FPThrowWeapon", function( ply, button )
    if CLIENT and button == CL_SETTINGS.Get( "fp_drop_weapon" ) and IsFirstTimePredicted() then
        net.Start( "FPDrop" )
        	net.WriteEntity( ply:GetActiveWeapon() )
       	net.SendToServer()
    end
end )