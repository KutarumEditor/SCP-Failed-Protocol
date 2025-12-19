AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:SyncStorage()
	local tab = table.Copy( self.Items )
	net.Start( "StorageSync" )
		net.WriteEntity( self )
		net.WriteTable( tab )
	net.Broadcast()
end