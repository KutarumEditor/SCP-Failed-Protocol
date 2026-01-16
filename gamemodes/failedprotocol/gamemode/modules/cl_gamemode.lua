local horror_mat = Material( "failedprotocol/020_horror_face.png" )
local horror_scale = ScreenScale( 200 )
function Horror020Escape()
	local ply = LocalPlayer()

	HideHUD( true, true )

	ply:ScreenFade( SCREENFADE.IN, color_black, 5, 3 )
	surface.PlaySound( "scpfp/020_horror_whisper.wav" )

	timer.Create( "020Horror", .1, 15, function()
		DrawSprite( {
			mat = Material( "failedprotocol/020_horror_face.png" ),
			clr = Color( 255, 255, 255, 5 ),
			time = .01,
			x = ( ScrW() - horror_scale ) / 2,
			y = ( ScrH() - horror_scale ) / 2,
			w = horror_scale,
			h = horror_scale
		} )
	end )

	timer.Simple( 3, function()
		HideHUD( false )
	end )
end

function RoundStartCutscene()
	local ply = LocalPlayer()

	HideHUD( true, true )

	ply:ScreenFade( SCREENFADE.IN, color_black, 5, 3 )
	AMBIENT.TIME = .001
	AMBIENT.Restart( "sound/scpfp/ambience/blue_feather.mp3" )

	timer.Simple( 3, function()
		HideHUD( false )
	end )
end

concommand.Add( "020horror", function( ply )
	Horror020Escape()
end )