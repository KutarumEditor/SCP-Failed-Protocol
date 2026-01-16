local PLAYER = FindMetaTable( "Player" )

if SERVER then

function PLAYER:CheckBody( body )
	net.Ping( "BodyLoot", tostring( body:EntIndex() ), self )
end

else

function OpenBodyInfo()
	
end

net.ReceivePing( "BodyLoot", function( data )
	local body = Entity( tonumber( data ) )
end )

end