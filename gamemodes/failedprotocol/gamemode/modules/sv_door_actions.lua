function BustDoor( ply, door )
    local state = door:GetInternalVariable( "m_eDoorState" )
    if state > 0 then return end

    ply:SetName( tostring( ply:EntIndex() ) )

    local isLocked = door:GetInternalVariable( "m_bLocked" )
    local oldDir = door:GetInternalVariable( "opendir" )
    local oldSpeed = door:GetInternalVariable( "speed" )
    local slaveName = door:GetInternalVariable( "slavename" )
    local slave = ents.FindByName( slaveName )[1]

    if isLocked and not isnumber( door.hitsUntilBreak ) then
        door.hitsUntilBreak = FPRandom( 0, 2 )
    end

    door:EmitSound( "ambient/materials/door_hit1.wav" )

    ply:ViewPunch( Angle( -10, 0, 10 ) )

    if !isLocked or door.hitsUntilBreak == 0 then
        if isLocked then
            door:Fire( "Unlock" )
        end

        if IsEntity( slave ) then
            slave:SetKeyValue( "opendir", 0 )
            slave:Fire( "SetSpeed", 750, 0 )
            slave:Fire( "OpenAwayFrom", tostring( ply:EntIndex() ), 0 )
            slave:Fire( "Lock" )
        end

        door:SetKeyValue( "opendir", 0 )
        door:Fire( "SetSpeed", 750, 0 )
        door:Fire( "OpenAwayFrom", tostring( ply:EntIndex() ), 0 )
        door:Fire( "Lock" )

        timer.Simple( 0.25, function()
            if IsEntity( slave ) then
                slave:Fire( "SetSpeed", oldSpeed, 0 )
                slave:SetKeyValue( "opendir", oldDir )
                slave:Fire( "Unlock" )
            end

            door:Fire( "SetSpeed", oldSpeed, 0 )
            door:SetKeyValue( "opendir", oldDir )
            door:Fire( "Unlock" )
        end )
    else
        door.hitsUntilBreak = door.hitsUntilBreak - 1
    end
end

function LockpickDoor( ply, door )
    door:EmitSound( "crimeville/lockpick/lp"..FPRandom( 1, 6 )..".wav" )
    timer.Create( ply:UserID().."lockpick", 1, 9, function()
        door:EmitSound( "crimeville/lockpick/lp"..FPRandom( 1, 6 )..".wav" )
    end )

    ply:TimedTask( "lockpicking", 10, Color( 255, 75, 0 ),
    function()
        local bool = IsValid( door ) and IsValid( ply ) and
            ply:EyePos():Distance( door:GetPos() ) < 105 and ply:GetEyeTrace().Entity == door

        if not bool then
            timer.Remove( ply:UserID().."lockpick" )
        end

        return bool
    end, function()
        door:EmitSound( "crimeville/lockpick/lp_finished.wav" )

        timer.Remove( ply:UserID().."lockpick" )
        
        door:Fire( "Unlock" )

        local slave = ents.FindByName( door:GetInternalVariable( "slavename" ) )[1]

        if IsEntity( slave ) then
            slave:Fire( "Unlock" )
        end
    end )
end