ROUNDPROP = {
	CUR = {}
}

if SERVER then

function ROUNDPROP.Sync()
	net.Start( "FPRoundProperties" )
		net.WriteTable( ROUNDPROP.CUR )
	net.Broadcast()
end

else

net.Receive( "FPRoundProperties", function()
	ROUNDPROP.CUR = net.ReadTable()
end )

end

function ROUNDPROP.Get( name )
	return ROUNDPROP.CUR[name]
end

function ROUNDPROP.Set( name, value )
	ROUNDPROP.CUR[name] = value

	if SERVER then
		ROUNDPROP.Sync()
	end
end

function ROUNDPROP.Clear()
	ROUNDPROP.CUR = {}

	if SERVER then
		ROUNDPROP.Sync()
	end
end