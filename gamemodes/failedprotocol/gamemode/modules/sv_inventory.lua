local PLAYER = FindMetaTable( "Player" )

function PLAYER:SyncInv()
    net.Ping( "FPInvSync", "", self )
end

function PLAYER:GetInvSlots()
    return self:Get_InvSlots()
end

function PLAYER:SetInvSlots( num )
    local num = tonumber( num )
    self:Set_InvSlots( num )

    local weps = self:GetWeapons()
    local hands = self:GetWeapon( CLASSES[self:GetFPClass()].hands_override or "fp_hands" )

    table.RemoveByValue( weps, hands )

    PrintTable( weps )

    if #weps > num then
        repeat
            self:DropWep( table.remove( weps, #weps ) )
        until #weps == num
    end

    --[[local dropWepTbl = {}
    print( self:Nick() )]]
    for i, wep in ipairs( self:GetWeapons() ) do
        print( wep, wep.Droppable )
    end

    self:SyncInv()
end

net.Receive( "FPInv", function( len, ply )
    local wep = net.ReadEntity()
    if ply:HasWeapon( wep:GetClass() ) then
        if wep.Droppable != false then
            if ply:GetActiveWeapon() == wep then
                local hands = ply:GetWeapon( CLASSES[ply:GetFPClass()].hands_override or "fp_hands" )
                timer.Simple( .01, function()
                    if IsValid( hands ) then
                        ply:SelectWeapon( hands )
                    end
                end )
            end

            ply:DropWep( wep )
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

concommand.Add( "fp_set_inv", function( ply, cmd, args, argStr )
    ply:SetInvSlots( args[1] )
end )