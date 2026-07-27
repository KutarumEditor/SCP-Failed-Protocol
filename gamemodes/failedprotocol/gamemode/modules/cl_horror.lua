local NextSeeSCPs = 0
hook.Add( "Think", "Horror", function()
    local curTime = CurTime()
    local lply = LocalPlayer()

    if NextSeeSCPs < CurTime() and FPTeams.IsEnemy( lply:FPTeam(), TEAM_SCP ) then
        for _, ply in ipairs( ents.FindInSphere( EyePos(), 1024 ) ) do
            if not ply:IsPlayer() then continue end
            if ply == lply then continue end
            if ply:IsDormant() then continue end
            if ply:Team() ~= TEAM_SCP then continue end
            
            local tr = util.TraceLine( {
                start = EyePos(),
                endpos = ply:EyePos(),
                filter = { lply, ply }
            } )

            if tr.Fraction ~= 1 then continue end

            local aim_vector = lply:GetAimVector()
            local ent_vector = ply:GetPos() - lply:GetShootPos()
            if ( aim_vector:Dot( ent_vector ) / ent_vector:Length() > .5235987755983 ) then
                darken = true
                timer.Simple( 1, function() darken = false end )

                surface.PlaySound( horror_tbl[FPRandom( #horror_tbl )] )

                NextSeeSCPs = CurTime() + FPRandom( 30, 40 )
                AMBIENT.Ban(3)
                AMBIENT.Restart( horror_ambient_tbl[FPRandom( #horror_ambient_tbl )] )
                break
            end
        end
    end
end )

local horror_mat = Material( "failedprotocol/020_horror_face.png" )
local horror_scale = ScreenScale( 200 )
function Horror020Escape()
    local ply = LocalPlayer()
    local alpha = 1

    HideHUD( true, true )

    ply:ScreenFade( SCREENFADE.IN, color_black, 5, 3 )
    surface.PlaySound( "scpfp/020_horror_whisper.wav" )

    timer.Create( "020Horror", .05, 60, function()
        DrawSprite( {
            mat = horror_mat,
            clr = Color( 255, 255, 255, 5 * alpha ),
            time = .015,
            x = ( ScrW() - horror_scale ) / 2,
            y = ( ScrH() - horror_scale ) / 2,
            w = horror_scale,
            h = horror_scale
        } )
        alpha = alpha / 1.05
    end )

    timer.Simple( 3, function()
        HideHUD( false )
    end )
end

concommand.Add( "020horror", function( ply )
    Horror020Escape()
end )