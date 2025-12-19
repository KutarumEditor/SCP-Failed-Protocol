net.Receive( "FPInv", function( len, ply )
    local wep = net.ReadEntity()

    if ply:HasWeapon( wep:GetClass() ) then
        if ply:GetActiveWeapon() == wep then
            local hands = ply:GetWeapon( CLASSES[ply:GetFPClass()].hands_override or "fp_hands" )
            ply:SelectWeapon( hands )
        end

        if wep.Droppable != false then
            ply:DropWeapon( wep )
        end
    end
end )

net.Receive( "FPInvArmor", function( len, ply )
    local act = net.ReadString()

    local possible_acts = {
        ["vest"] = function( ply )
            ply:DropArmor( "vest" )
        end,
        ["helmet"] = function( ply )
            ply:DropArmor( "helmet" )
        end,
        ["suit"] = function( ply )
            --
        end,
    }

    possible_acts[act]( ply )
end )