local net = net
local player = player
local game = game
local TIMERS = TIMERS
local CLASSES = CLASSES
local timer = timer
local table = table
local player = player
local math = math

local used_roles = {}
local all_support = {}
local tried_support = {}
ROUND = ROUND or {
	type = "numb",
	aftermath = false,
	frozen = false,
	starttime = 0,
	finishtime = 0,
}

REGISTERED_ROUND_TYPES = {
	["numb"] = {
		chance = 0,
		callback = function()
			for _, ply in ipairs( player.GetAll() ) do
				ply:SetupSpectator( true )
			end
		end,
		endcheck = function() return false end,
	},
	["default"] = {
		chance = 75,
		hasscps = true,
		round_lenght = 1800,
		support_time = {
			first = 240,
			repeating = 300
		},
		max_supports = 5,
		callback = function()
			SpawnDefaultItems()

			SetupFirstSupportTimer()

			ClearPersonas()
			SetupPlayers( "default" )

			net.Ping( "ClearCSData", "" )
		end,
		endcheck = function()
			return BasicRoundFinishCheck()
		end,
	},
}

function RoundDataSync( ply )
	net.Start( "RoundDataSync" )
		net.WriteTable( ROUND )
	if IsValid( ply ) and ply:IsPlayer() then
		net.Send( ply )
	else
		net.Broadcast()
	end
end

function RoundStart( type )
	game.CleanUpMap( false, {}, function()
		local ct = CurTime()

		ROUND.type = type
		ROUND.aftermath = false
		ROUND.starttime = ct
		ROUND.finishtime = ct + REGISTERED_ROUND_TYPES[type].round_lenght

		used_roles = {}

		TIMERS.DestroyAll()

		AnnulScore()

		ROUNDPROP.Clear()

		FreezeRound()

		ACCESS.RecomputeButtons()

		REGISTERED_ROUND_TYPES[type].callback()

		FreezeRound( false )

		RoundDataSync()
	end )
end

function CurRound()
	return ROUND.type
end

function RestartRound()
	-- Make random round system here

	RoundStart( "default" )
end

function FinishRound()
	if TIMERS.Exists( "TimerSupport" ) then
		TIMERS.Destroy( "TimerSupport" )
	end

	ROUND.aftermath = true

	for _, ply in ipairs( player.GetAll() ) do
		--ply:PopupEndInfo()
	end

	RoundDataSync()

	TIMERS.Create( "RoundEnd", 20, function()
		for _, ply in ipairs( player.GetAll() ) do
			ply:ScreenFade( SCREENFADE.OUT, color_black, 10, .1)
		end

		TIMERS.Create( "RoundEnd", 10, function()
			RestartRound()
		end, true )
	end, true )

	print( "Preparing round end..." )
end

function FreezeRound( bool )
	local frz = true

	if bool != nil then
		frz = bool
	end

	ROUND.frozen = frz

	RoundDataSync()
end

function RoundEndCheck()
	if ROUND.aftermath then return end

	if REGISTERED_ROUND_TYPES[CurRound()].endcheck() then
		FinishRound()
	end
end

function BasicRoundFinishCheck()
	local alivePlys = {}

	for _, ply in ipairs( player.GetAll() ) do
		if ply:Alive() then
			table.insert( alivePlys, ply )
		end
	end

	local aliveTeams = {}

	for k, v in pairs( alivePlys ) do
		local team = v:FPTeam()

		if !table.HasValue( aliveTeams, team ) then
			table.insert( aliveTeams, team )
		end
	end

	for _, team in pairs( aliveTeams ) do
		for k, v in pairs( aliveTeams ) do
			if FPTeams.IsEnemy( team, v ) then return false end
		end
	end

	return !ROUND.frozen
end

local function CalcSpawnGroupsWeight( plys, type )
    local plys_to_assign = table.Copy( plys )
    local sg_tbl = {}

    local globalweight = 0
    for k, v in pairs( SPAWNGROUPS ) do
        if v.roundtype == type and not v.support then
            table.insert( sg_tbl, { k, v.weight } )
            globalweight = globalweight + v.weight
        end
    end

    table.sort( sg_tbl, function( a, b ) return a[2] > b[2] end )

    local assigned_plys = {}

    for k, v in pairs( sg_tbl ) do
        local group_coef = v[2] / globalweight
        local num = math.floor( #plys * group_coef )

        assigned_plys[v[1]] = {}
        for i = 1, num do
            table.insert( assigned_plys[v[1]], table.remove( plys_to_assign, FPRandom( 1, #plys_to_assign ) ) or plys_to_assign[1] )
        end
    end

    if #plys_to_assign > 0 then
        for i = 1, #plys_to_assign do
            table.insert( assigned_plys[sg_tbl[i][1]], table.remove( plys_to_assign, FPRandom( 1, #plys_to_assign ) ) or plys_to_assign[1] )
        end
    end

    return assigned_plys
end

local function GetRandomClass( sg )
	local possible_classes = {}
	local selected_class

	local global_weight = 0
	for k, v in pairs( CLASSES ) do
		if v.spawngroup == sg and not v.dynamicspawn then
			local weight = v.weight or 1
			possible_classes[#possible_classes + 1] = { k, weight }
			global_weight = global_weight + weight
			used_roles[k] = used_roles[k] or 0
		end
	end

	repeat
		local tmp_selected_class

		local target_weight = FPRandom( 1, global_weight )
		for i, v in ipairs( possible_classes ) do
			target_weight = target_weight - v[2]

			if target_weight <= 0 then
				tmp_selected_class = v[1]

				goto after
			end
		end

		::after::

		if !isnumber( CLASSES[tmp_selected_class].max ) or used_roles[tmp_selected_class] < CLASSES[tmp_selected_class].max then
			used_roles[tmp_selected_class] = used_roles[tmp_selected_class] + 1
			selected_class = tmp_selected_class
		end
	until selected_class != nil

	return selected_class
end

local function GetRandomSCP()
	local possible_classes = {}
	local selected_class

	for k, v in pairs( SCPS ) do
		if not v.dynamicspawn then
			table.insert( possible_classes, k )
			used_roles[k] = used_roles[k] or 0
		end
	end

	repeat
		local tmp_selected_class = table.Random( possible_classes )

		if !isnumber( SCPS[tmp_selected_class].max ) or used_roles[tmp_selected_class] < SCPS[tmp_selected_class].max then
			used_roles[tmp_selected_class] = used_roles[tmp_selected_class] + 1
			selected_class = tmp_selected_class
		end
	until isstring( selected_class )

	return selected_class
end

function SetupPlayers( type )
	local all_players = player.GetAll()

	local scps = 0

	--Assigning SCP's
	if REGISTERED_ROUND_TYPES[type].hasscps then
		local scps

		if #all_players > 14 then
			scps = 2
		elseif #all_players > 7 then
			scps = 1
		else
			scps = 0
		end

		local possible_scps = table.GetKeys( SCPS )

		for i = 1, scps do
			local selected_ply = table.remove( all_players, math.random( 1, #all_players ) )
			local selected_scp = table.remove( possible_scps, math.random( 1, #possible_scps ) )
			selected_ply:SetFrags( 0 )
			selected_ply:SetupSCP( selected_scp, false )
			selected_ply:PopupStartInfo()
			selected_ply:ScreenFade( SCREENFADE.IN, color_black, 2, 3 )
		end
	end

	--Assigning others
	timer.Simple( FrameTime() * ( scps + 1 ), function()
		local assign_tab = CalcSpawnGroupsWeight( all_players, type )

		for k, v in pairs( assign_tab ) do
			local pl_count = #v
			local possible_spawns = table.Copy( SPAWNGROUPS[k].spawn )
			local available_spawns = {}
			local unique_spawns = {}

			local coef = math.ceil( pl_count / #possible_spawns )
			for i = 1, coef do
				table.Add( available_spawns, possible_spawns )
			end

			for i, pl in ipairs( v ) do
				AsyncFunc( function()
					local selected_class = GetRandomClass( k )

					if istable( CLASSES[selected_class].spawn ) or isvector( CLASSES[selected_class].spawn ) then
						unique_spawns[selected_class] = istable( CLASSES[selected_class].spawn ) and table.Copy( CLASSES[selected_class].spawn ) or CLASSES[selected_class].spawn
					end

					if IsValid( pl ) then
						pl:SetFrags( 0 )
						pl:Setup( selected_class, istable( unique_spawns[selected_class] ) and table.remove( unique_spawns[selected_class], FPRandom( 1, #unique_spawns[selected_class] ) ) or isvector( unique_spawns[selected_class] ) and unique_spawns[selected_class] or table.remove( available_spawns, FPRandom( 1, #available_spawns ) ), false )
						pl:PopupStartInfo()
						pl:ScreenFade( SCREENFADE.IN, color_black, 2, 3 )
					end
				end )
			end
		end

		AsyncFunc( function() hook.Run( "PostPlayerClassAssignation" ) end )
	end )
end

hook.Add( "PostPlayerClassAssignation", "SelectSecretRussian", function()
	local ply = table.Random( FPTeams.GetPlayersByTeam( TEAM_CLASSD ) )
	
	ply.amnesicrussian = true
	print( ply:Name().." is selected as amnestic gru agent!" )
end )

function SpawnSupport( custom_group )
	print( "--Spawning support--" )

	ROUNDPROP.Set( "next_support", nil )

	local group

	if custom_group then
		group = custom_group
	else
		local potential_groups = {}
		for k, v in pairs( SPAWNGROUPS ) do
			local sup_spawned = ROUNDPROP.Get( "support_spawned_"..k )
			if v.support and v.check() == true and ( v.max == nil or sup_spawned == nil or sup_spawned < v.max ) then
				potential_groups[k] = v.weight
			end
		end

		local absolute_weight = 0
		for k, w in pairs( potential_groups ) do
			absolute_weight = absolute_weight + w
		end

		local i_used_to_roll_the_dice = FPRandom( absolute_weight )

		local sel_weight = 0
		for k, w in pairs( potential_groups ) do
			sel_weight = sel_weight + w
			
			if sel_weight >= i_used_to_roll_the_dice then
				group = k
				break
			end
		end
	end

	if group == nil then
		print( "Failed to spawn support! Reason: No groups" )
		SetupSupportTimer()
		return
	end

	print( group.." selected..." )

	local specs = FPTeams.GetPlayersByTeam( TEAM_SPEC )

	local selected_plys = {}

	local possible_spawns = table.Copy( SPAWNGROUPS[group].spawn )
	local available_spawns = {}
	local unique_spawns = {}

	local coef = math.ceil( #specs / #possible_spawns )
	for i = 1, coef do
		table.Add( available_spawns, possible_spawns )
	end

	if #specs == 0 then
		print( "Failed to spawn support! Reason: No spectators" )
		SetupSupportTimer()
		return
	end

	repeat
		local ply = table.remove( specs, FPRandom( #specs ) )
		local sel_class = GetRandomClass( group )

		if istable( CLASSES[sel_class].spawn ) or isvector( CLASSES[sel_class].spawn ) then
			unique_spawns[sel_class] = istable( CLASSES[sel_class].spawn ) and table.Copy( CLASSES[sel_class].spawn ) or CLASSES[sel_class].spawn
		end

		table.insert( selected_plys, { ply, sel_class } )
	until #selected_plys == SPAWNGROUPS[group].maxplayers or #selected_plys == 5 or #specs == 0

	if #selected_plys == 0 then
		print( "Failed to spawn support! Reason: No candidates" )
		SetupSupportTimer()
		return
	end

	for i, v in ipairs( selected_plys ) do
		timer.Simple( FrameTime() * i, function()
			local ply, sel_class = v[1], v[2]

			if IsValid( ply ) then
				ply:SetFrags( 0 )
				ply:Setup( sel_class, istable( unique_spawns[sel_class] ) and table.remove( unique_spawns[sel_class], FPRandom( 1, #unique_spawns[sel_class] ) ) or isvector( unique_spawns[sel_class] ) and unique_spawns[sel_class] or table.remove( available_spawns, FPRandom( 1, #available_spawns ) ), false )
				ply:PopupStartInfo()
				ply:ScreenFade( SCREENFADE.IN, color_black, 2, 3 )
			end
		end )
	end
end

hook.Add( "Think", "FPRoundThink", function()
	if CurTime() >= ROUND.finishtime and not ROUND.frozen and not ROUND.aftermath and ROUND.type != "numb" then
		FinishRound()
	end
end )

concommand.Add( "fp_test_round", function( ply, cmd, args, argStr )
	RestartRound( args[1] )
end, function( cmd, args )
	return AutoComplete( cmd, args, table.GetKeys( REGISTERED_ROUND_TYPES ) )
end )