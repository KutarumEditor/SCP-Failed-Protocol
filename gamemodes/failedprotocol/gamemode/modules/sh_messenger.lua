if SERVER then

net.Receive( "SendMsgCS", function( len, ply )
	local ply = net.ReadPlayer()
	local me = net.ReadPlayer()
	local txt = net.ReadString()

	if IsValid( ply ) then
		net.Start( "SendMsg" )
			net.WritePlayer( me )
			net.WriteString( txt )
		net.Send( ply )
	end
end )

elseif CLIENT then

function SendMessage( adr, text )
	local tbl = string.Explode( "_", adr )
	local ply = FindPlayerByPersona( tbl[1], tbl[2] )

	if IsValid( ply ) and ply:IsPlayer() then
		net.Start( "SendMsgCS" )
			net.WritePlayer( ply )
			net.WritePlayer( LocalPlayer() )
			net.WriteString( string.sub( text, 1, 128 ) )
		net.SendToServer()
	end
end

end