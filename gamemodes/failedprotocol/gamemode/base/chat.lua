if SERVER then

local PLAYER = FindMetaTable( "Player" )

function PLAYER:FPChat( ... )
	net.Start( "FPChat" )
		net.WriteTable( { ... } )
	net.Send( self )
end

function PLAYER:FPServerMessage( ... )
	self:FPChat( FP_SERVER_COLOR, "["..FP_SERVER_NAME.."] ", ... )
end

else

net.Receive( "FPChat", function()
	local tbl = net.ReadTable()

	for _, v in ipairs( tbl ) do
		if isstring( v ) and string.StartsWith( v, "$" ) then
			local str_tbl = string.Explode( ".", string.Right( v, #v - 1 ) )

			local new_str = lang

			for i, txt in ipairs( str_tbl ) do
				new_str = new_str[txt]
			end

			tbl[_] = new_str
		end
	end

	chat.AddText( unpack( tbl ) )
end )

end