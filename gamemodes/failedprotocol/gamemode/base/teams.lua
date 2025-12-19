-- Mostly adapted SCP:LC code, cuz its already perfect, why i should try to make it better?

FPTeams = {
	ALL = {},
	REG = {},
	SCORE = {}
}

local info_num = 0
function FPTeams.AddTeamInfo( name )
	local key = "INFO_"..string.upper( name )

	if FPTeams[key] then
		return FPTeams[key]
	end

	if info_num > 31 then
		ErrorNoHalt( "Cannot add new TeamInfo! Maximum amount is 32\n" )
		return
	end

	local info = bit.lshift( 1, info_num )
	info_num = info_num + 1

	FPTeams[key] = info

	return info
end

function FPTeams.Register( name, info, clr, reward, can_escape )
	local n = table.insert( FPTeams.REG, {
		info = info or 0,
		color = clr, name = name,
		reward = math.floor( reward ),
		can_escape = can_escape,
		relations = {},
		escort = {},
		escorted_by = {},
	} )

	_G["TEAM_"..name] = n
	table.insert( FPTeams.ALL, n )
end

function FPTeams.GetAll()
	return FPTeams.ALL
end

function FPTeams.AddInfo( team, info )
	local t = FPTeams.REG[team]
	if t then
		t.info = bit.bor( t.info, info )
	end
end

function FPTeams.SetupAllies( tab, ally )
	if !istable( tab ) then
		tab = { tab }
	end

	if !ally then
		ally = tab
	elseif ally == true then
		ally = FPTeams.ALL
	elseif !istable( ally ) then
		ally = { ally }
	end

	for k, v in pairs( tab ) do
		local t = FPTeams.REG[v]

		for _k, _v in pairs( ally ) do
			if v != _v then
				t.relations[_v] = true
			end
		end
	end
end

function FPTeams.SetupNeutral( tab, neutral )
	if !istable( tab ) then
		tab = { tab }
	end

	if !neutral then
		neutral = tab
	elseif neutral == true then
		neutral = FPTeams.ALL
	elseif !istable( neutral ) then
		neutral = { neutral }
	end

	for k, v in pairs( tab ) do
		local t = FPTeams.REG[v]

		for _k, _v in pairs( neutral ) do
			if v != _v then
				t.relations[_v] = false
			end
		end
	end
end

function FPTeams.SetupEnemy( tab, enemy )
	if !istable( tab ) then
		tab = { tab }
	end

	if !enemy then
		enemy = tab
	elseif enemy == true then
		enemy = FPTeams.ALL
	elseif !istable( enemy ) then
		enemy = { enemy }
	end

	for k, v in pairs( tab ) do
		local t = FPTeams.REG[v]

		for _k, _v in pairs( enemy ) do
			if v != _v then
				t.relations[_v] = nil
			end
		end
	end
end

function FPTeams.SetupEscort( team, tab )
	tab = istable( tab ) and tab or { tab }

	local t = FPTeams.REG[team]
	if !t then return end

	for k, v in pairs( tab ) do
		t.escort[v] = true

		local t2 = FPTeams.REG[v]
		if !t2 then continue end

		t2.escorted_by[team] = true
	end
end

function FPTeams.IsEnemy( team1, team2 )
	if team1 == team2 then return false end

	local t = FPTeams.REG[team1]
	if t then
		return t.relations[team2] == nil
	end

	return true
end

function FPTeams.IsAlly( team1, team2 )
	if team1 == team2 then return true end

	local t = FPTeams.REG[team1]
	if t then
		return t.relations[team2] == true
	end

	return false
end

function FPTeams.IsNeutral( team1, team2 )
	if team1 == team2 then return true end

	local t = FPTeams.REG[team1]
	if t then
		return t.relations[team2] == false
	end

	return false
end

function FPTeams.GetAllies( team, include_self )
	local t = FPTeams.REG[team]

	if t then
		local allies = {}

		for k, v in pairs( t.relations ) do
			if v == true then
				table.insert( allies, k )
			end
		end

		if include_self then
			table.insert( allies, team )
		end

		return allies
	end
end

function FPTeams.CanEscort( team1, team2 )
	if !FPTeams.REG[team1] then return false end
	if !next( FPTeams.REG[team1].escort ) then return false end

	if team2 == true then
		return true
	end

	return FPTeams.REG[team1].escort[team2]
end

function FPTeams.CanBeEscorted( team1, team2 )
	if !FPTeams.REG[team1] then return false end
	if !next( FPTeams.REG[team1].escorted_by ) then return false end

	if team2 == true then
		return true
	end

	if !FPTeams.REG[team2] then return false end
	return FPTeams.REG[team2].escort[team1]
end

function FPTeams.GetEscort( team )
	if !FPTeams.REG[team] then return {} end
	if !next( FPTeams.REG[team].escort ) then return {} end

	local tab = {}

	for k, v in pairs( FPTeams.REG[team].escort ) do
		table.insert( tab, k )
	end

	return tab
end

function FPTeams.GetEscortedBy( team )
	if !FPTeams.REG[team] then return {} end
	if !next( FPTeams.REG[team].escorted_by ) then return {} end

	local tab = {}

	for k, v in pairs( FPTeams.REG[team].escorted_by ) do
		table.insert( tab, k )
	end

	return tab
end

function FPTeams.CanEscape( team )
	if !FPTeams.REG[team] then return false end

	return FPTeams.REG[team].can_escape
end

function FPTeams.GetName( team )
	if !FPTeams.REG[team] then return end

	return FPTeams.REG[team].name
end

function FPTeams.GetColor( team )
	if !FPTeams.REG[team] then return end

	return FPTeams.REG[team].color
end

function FPTeams.GetReward( team )
	if !FPTeams.REG[team] then return end

	return FPTeams.REG[team].reward
end

function FPTeams.HighestScore()
	local score = 0
	local team

	for k, v in pairs( FPTeams.SCORE ) do
		if v > score then
			score = v
			team = { k }
		elseif v > 0 and v == score then
			table.insert( team, k )
		end
	end

	if !team then
		return
	end

	return #team == 1 and team[1] or team
end

function FPTeams.ResetScore()
	for k, v in pairs( FPTeams.SCORE ) do
		FPTeams.SCORE[k] = 0
	end
end

function FPTeams.HasInfo( team, info )
	local t = FPTeams.REG[team]

	if t then
		if !t.info then
			t.info = 0
		end

		return bit.band( t.info, info ) == info
	end
end

function FPTeams.GetPlayersByTeam( team )
	local plys = {}

	for i, v in ipairs( player.GetAll() ) do
		if v:FPTeam() == team then
			table.insert( plys, v )
		end
	end

	return plys
end

function FPTeams.GetPlayersByInfo( info, alive )
	local plys = {}

	for i, v in ipairs( player.GetAll() ) do
		if FPTeams.HasInfo( v:FPTeam(), info ) and ( !alive or v:Alive() ) then
			table.insert( plys, v )
		end
	end

	return plys
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:FPTeam()
	if !self.Get_FPTeam then
		self:DataTables()
	end

	return self:Get_FPTeam()
end

function PLAYER:SetFPTeam( team )
	if !self.Set_FPTeam then
		self:DataTables()
	end

	self:Set_FPTeam( team )
end

FPTeams.AddTeamInfo( "ALIVE" )
FPTeams.AddTeamInfo( "HUMAN" )
FPTeams.AddTeamInfo( "SCP" )
FPTeams.AddTeamInfo( "STAFF" )

FPTeams.Register( "SPEC", 0, Color( 150, 150, 150 ), 0 )
FPTeams.Register( "CLASSD", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN ), Color( 242, 106, 25 ), 1, true )
FPTeams.Register( "SCI", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN, FPTeams.INFO_STAFF ), Color( 0, 155, 255 ), 2, true )
FPTeams.Register( "SD", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN, FPTeams.INFO_STAFF ), Color( 0, 90, 222 ), 3, true )
FPTeams.Register( "MTF", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN, FPTeams.INFO_STAFF ), Color( 0, 0, 255 ), 4, false )
FPTeams.Register( "GOC", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN ), Color( 97, 132, 149 ), 4, false )
FPTeams.Register( "SPEAR", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN ), Color( 0, 25, 48 ), 4, false )
FPTeams.Register( "GRU", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN ), Color( 158, 145, 99 ), 4, false )
FPTeams.Register( "CI", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN ), Color( 13, 59, 20 ), 4, false )
FPTeams.Register( "CBG", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN ), Color( 59, 45, 105 ), 4, false )
FPTeams.Register( "SH", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_HUMAN ), Color( 0, 133, 77 ), 4, false )
FPTeams.Register( "SCP", bit.bor( FPTeams.INFO_ALIVE, FPTeams.INFO_SCP ), Color( 52, 7, 7 ), 10, true )

FPTeams.SetupNeutral( { TEAM_CLASSD, TEAM_SCI, TEAM_SH } )
FPTeams.SetupNeutral( TEAM_CLASSD, TEAM_CI )
FPTeams.SetupNeutral( TEAM_GRU, true )

FPTeams.SetupNeutral( TEAM_SPEAR, true )
FPTeams.SetupEnemy( TEAM_SPEAR, TEAM_GRU )
FPTeams.SetupEnemy( TEAM_SPEAR, TEAM_CLASSD )

FPTeams.SetupAllies( { TEAM_SCI, TEAM_SD, TEAM_MTF } )

FPTeams.SetupNeutral( TEAM_GOC, true )
FPTeams.SetupAllies( TEAM_GOC, TEAM_SCI )

FPTeams.SetupEnemy( TEAM_SCP, true )
FPTeams.SetupAllies( TEAM_SCP, TEAM_SH )

FPTeams.SetupEscort( TEAM_MTF, TEAM_SCI )
FPTeams.SetupEscort( TEAM_SD, TEAM_SCI )