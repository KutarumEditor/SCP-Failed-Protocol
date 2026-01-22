hook.Add("Think", "SomeMisc", function()
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

                surface.PlaySound( table.Random( horror_tbl ) )

                NextSeeSCPs = CurTime() + math.random( 30, 40 )
                AMBIENT.Ban(3)
                AMBIENT.Restart( table.Random( horror_ambient_tbl ) )
                break
            end
        end
    end
end)