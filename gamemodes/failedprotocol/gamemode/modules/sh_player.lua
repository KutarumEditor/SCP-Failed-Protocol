local PLAYER = FindMetaTable( "Player" )

------------------------
-- Class registration --
------------------------

local CLASS = {}

function CLASS:SetupDataTables()
	local ply = self.Player

	ply:NetworkVar( "Int", 0, "_FPTeam" )
	ply:NetworkVar( "Int", 1, "_InvSlots" )

	ply:NetworkVar( "Int", 2, "_PlayerLevel" )
	ply:NetworkVar( "Int", 3, "_PlayerXP" )
	ply:NetworkVar( "Int", 4, "_PlayerKarma" )
	ply:NetworkVar( "Int", 5, "_ClassPoints" )

	ply:NetworkVar( "Float", 0, "Stamina" )
	ply:NetworkVar( "Float", 1, "MaxStamina" )

	ply:NetworkVar( "String", 0, "_FPClass" )
	ply:NetworkVar( "String", 1, "_Name" )
	ply:NetworkVar( "String", 2, "_Surname" )

	ply:NetworkVar( "Bool", 0, "Exhausted" )
	ply:NetworkVar( "Bool", 1, "Ready" )

	if SERVER then
		ply:Set_FPTeam( 0 )
		ply:Set_InvSlots( 0 )

		ply:SetMaxStamina( 100 )
		ply:SetStamina( 100 )
		
		ply:SetExhausted( false )
		ply:SetReady( ply:IsBot() and true or false )
		ply:SetCanZoom( false )

		ply:Set_FPClass( "spectator" )
		ply:Set_Name( "John" )
		ply:Set_Surname( "Doe" )

		FPPromiseJoin(
			ply:GetFPData( "level", 0 ),
			ply:GetFPData( "xp", 0 ),
			ply:GetFPData( "class_points", 0 ),
			ply:GetFPData( "scp_karma", 100 )
		):Then( function( data )
			ply:Set_PlayerLevel( tonumber( data[1] ) )
			ply:Set_PlayerXP( tonumber( data[2] ) )
			ply:Set_ClassPoints( tonumber( data[3] ) )
			ply:Set_PlayerKarma( tonumber( data[4] ) )
		end )
	end
end

player_manager.RegisterClass( "fp_player", CLASS, "player_default" )

--[[-------------------------------------------------------------------------
Accessors
---------------------------------------------------------------------------]]

function FPAccessor( func, data )
	data = data or {}

	local getter = "Get"..(data.internal or "_"..func)
	local setter = "Set"..(data.internal or "_"..func)
	local db_key = data.db_key
	local db_client = data.db_client
	local ignore_dt = data.ignore_dt

	PLAYER[data.getter or "Get"..func] = function( self )
		if !ignore_dt and !self[getter] then
			self:DataTables()
		end

		return self[getter]( self )
	end

	PLAYER[data.setter or "Set"..func] = function( self, val )
		if !ignore_dt and !self[setter] then
			self:DataTables()
		end

		self[setter]( self, val )

		if db_key and ( db_client or SERVER ) then
			self:SetFPData( db_key, val )
		end
	end
end

FPDatabaseProperties = FPDatabaseProperties or {}

function FPDatabaseProperty( func, key, def, db, sync )
	local db_key = db or key

	FPDatabaseProperties[key] = { db_key = db_key, def = def, sync = sync }

	BindPlayerProperty( "_"..func, key, def, { sync = sync, keep = PROPERTY_KEEP_ALWAYS } )
	FPAccessor( func, { db_key = db_key, ignore_dt = true } )
end

hook.Add( "PlayerInitialSpawn", "FPDatabaseProperties", function( ply )
	for key, data in pairs( FPDatabaseProperties ) do
		ply:GetFPData( data.db_key, data.def ):Then( function( val )
			if !IsValid( ply ) then return end
			ply:SetProperty( key, val, data.sync )
		end )
	end
end )

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

function PLAYER:LookupBonemerges()
	return ents.FindByClassAndParent( "fp_bonemerge", self ) or {}
end

function PLAYER:CanPickup( ent )
    if ent:IsDerived( "fp_hands" ) then
		return true
	end

	local tbl = self:GetWeapons()

	for _, v in pairs( tbl ) do
		if v:IsDerived( "fp_hands" ) then
			table.remove( tbl, _ )
		end
	end

	return #tbl < self:GetInvSlots() and not self:HasWeapon( ent:GetClass() )
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

function PLAYER:IsSCP()
	return self:FPTeam() == TEAM_SCP
end

function PLAYER:IsSentient()
	return FPTeams.HasInfo( self:FPTeam(), FPTeams.INFO_HUMAN ) or self:IsSCP() and SCPS[self:GetFPClass()].sentient == true
end

function PLAYER:IsHuman()
	return FPTeams.HasInfo( self:FPTeam(), FPTeams.INFO_HUMAN ) or self:IsSCP() and SCPS[self:GetFPClass()].human == true
end

-----------------------
-- Player properties --
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

FPAccessor( "PlayerLevel", { db_key = "level", getter = "PlayerLevel" } )
FPAccessor( "PlayerXP", { db_key = "xp", getter = "PlayerXP" } )
FPAccessor( "ClassPoints", { db_key = "class_points", getter = "ClassPoints" } )
FPAccessor( "SCPPenalty", { db_key = "scp_penalty" } )
FPAccessor( "PlayerKarma", { db_key = "scp_karma" } )