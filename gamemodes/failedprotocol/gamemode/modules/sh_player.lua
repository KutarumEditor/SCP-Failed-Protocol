------------------------
-- Class registration --
------------------------

local CLASS = {}

function CLASS:SetupDataTables()
	local ply = self.Player

	ply:NetworkVar( "Int", 0, "_FPTeam" )
	ply:NetworkVar( "Int", 1, "InvSlots" )

	ply:NetworkVar( "Float", 0, "Stamina" )
	ply:NetworkVar( "Float", 1, "MaxStamina" )

	ply:NetworkVar( "String", 0, "_FPClass" )
	ply:NetworkVar( "String", 1, "_Name" )
	ply:NetworkVar( "String", 2, "_Surname" )

	ply:NetworkVar( "Bool", 0, "Exhausted" )
	ply:NetworkVar( "Bool", 1, "Ready" )

	if SERVER then
		ply:Set_FPTeam( 0 )
		ply:SetInvSlots( 0 )

		ply:SetMaxStamina( 100 )
		ply:SetStamina( 100 )
		
		ply:SetExhausted( false )
		ply:SetReady( ply:IsBot() and true or false )
		ply:SetCanZoom( false )

		ply:Set_FPClass( "spectator" )
		ply:Set_Name( "John" )
		ply:Set_Surname( "Doe" )
	end
end

player_manager.RegisterClass( "fp_player", CLASS, "player_default" )

------------------
-- Player funcs --
------------------

local translateKeyToFunc = {
	[IN_ATTACK] = function( ply )
		ply:SpectatePlayerNext()
	end,
	[IN_ATTACK2] = function( ply )
		ply:SpectatePlayerPrev()
	end,
	[IN_RELOAD] = function( ply )
		ply:ChangeSpectateMode()
	end,
}

function GM:KeyPress( ply, key )
	if SERVER and !ply:IsBot() then
		if ply:FPTeam() == TEAM_SPEC then
			if translateKeyToFunc[key] != nil then
				translateKeyToFunc[key]( ply )
			end
		end
	end
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:DataTables()
	if !IsValid( self ) then return end

	player_manager.SetPlayerClass( self, "fp_player" )
	player_manager.RunClass( self, "SetupDataTables" )

	if SERVER then
		self.depressedUse = true
		self.FPArmor = {
			vest = {
				name = nil,
				durability = 0,
			},
			helmet = {
				name = nil,
				durability = 0,
			}
		}
		net.Start( "FPArmor" )
			net.WritePlayer( self )
			net.WriteTable( self.FPArmor )
		net.Broadcast()

		self.FPAbilities = {}
		net.Start( "FPAbilities" )
			net.WritePlayer( self )
			net.WriteTable( self.FPAbilities )
		net.Broadcast()
	end
end

function PLAYER:GetPlayerRagdoll()
	return self:GetNWEntity( "CorpseEnt" )
end

function PLAYER:IsReady()
	local ready = self:GetReady()

	if ready == nil then
		self:DataTables()
		ready = self:GetReady()
	end

	return ready
end

function PLAYER:IsAlly( ply )
	return self == ply and true or FPTeams.IsAlly( self:FPTeam(), ply:FPTeam() )
end

function PLAYER:IsNeutral( ply )
	return self == ply and false or FPTeams.IsNeutral( self:FPTeam(), ply:FPTeam() )
end

function PLAYER:IsEnemy( ply )
	return self == ply and false or FPTeams.IsEnemy( self:FPTeam(), ply:FPTeam() )
end

-----------------------
-- Player properties -- ( thx Danx )
-----------------------

function PLAYER:ResetProperties()
	self.FPProperties = {}
end

function PLAYER:SetProperty( key, value, sync )
	self.FPProperties = self.FPProperties or {}

	self.FPProperties[key] = value

	if SERVER and sync then
		net.Start( "FPPlayerProperty" )
			net.WritePlayer( self )
			net.WriteString( key )
			net.WriteTable( value )
		net.Broadcast()
	end

	return value
end

function PLAYER:GetProperty( key, def )
	if !self.FPProperties then self.FPProperties = {} end

	if !self.FPProperties[key] and def then
		self.FPProperties[key] = def
	end

	return self.FPProperties[key]
end

if CLIENT then
	net.Receive( "FPPlayerProperty", function()
		net.ReadPlayer():SetProperty( net.ReadString(), net.ReadTable() )
	end )
end