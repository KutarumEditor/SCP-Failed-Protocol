local net = net
local os = os
local util = util

if SERVER then

util.AddNetworkString( "FPPing" )

local nextlog = 0

local whitelist = {
	["FPEntityActions"] = true,
}

function net.Incoming( len, client )
	local i = net.ReadHeader()
	local strName = util.NetworkIDToString( i )

	if ( !strName ) or ( strName == "editvariable" ) then return end

	local func = net.Receivers[ strName:lower() ]
	if ( !func ) then return end

	len = len - 16

	if IsValid( client ) then 
		if not whitelist[strName] then
			client.netcache = ( client.netcache or 0 ) + 1
			timer.Simple( 3, function()
				if IsValid( client ) then
					client.netcache = ( client.netcache or 0 ) - 1
				end
			end )

			if client.netcache > 60 then
				if CurTime() > nextlog then
					local Timestamp = os.time()
					local TimeString = os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp )

					if not file.Exists( "netlogs.txt", "DATA" ) then
						file.Write( "netlogs.txt", client:Name().." ("..client:SteamID()..") - "..TimeString.."  NET: "..strName.."\n" )
					else
						file.Append( "netlogs.txt", client:Name().." ("..client:SteamID()..") - "..TimeString.."  NET: "..strName.."\n" )
					end
					nextlog = CurTime() + 15
				end
				client:Kick( "Вы отправляете слишком много NET сообщений" )	
			end
		end

		func( len, client )
	end
end

end

--[[-------------------------------------------------------------------------
Ping
---------------------------------------------------------------------------]]
net.PingReceivers = net.PingReceivers or {}

function net.Ping( name, data, ply )
	net.Start( "FPPing" )
		net.WriteString( tostring( name ) )
		net.WriteString( tostring( data ) )

	if SERVER then
		if ply == nil then
			net.Broadcast()
		else
			net.Send( ply )
		end
	elseif CLIENT then
		net.SendToServer()
	end
end

net.Receive( "FPPing", function( len, ply )
	local name = net.ReadString()
	local data = net.ReadString()

	if net.PingReceivers[name] then
		if isfunction( net.PingReceivers[name] ) then
			net.PingReceivers[name]( data, ply )
		end
	end
end )

function net.ReceivePing( name, func )
	if !net.PingReceivers[name] then
		net.PingReceivers[name] = {}
	end

	//table.insert( receivers[name], func )
	net.PingReceivers[name] = func
end