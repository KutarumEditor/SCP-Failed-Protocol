function SetupFirstSupportTimer()
	local time = REGISTERED_ROUND_TYPES[ROUND.type].support_time.first
	TIMERS.Create( "TimerSupport", istable( time ) and FPRandom( time[1], time[2] ) or time, function()
		SpawnSupport( ROUNDPROP.Get( "next_support" ) )

		SetupSupportTimer()
	end )
end

function SetupSupportTimer( t )
	local time = REGISTERED_ROUND_TYPES[ROUND.type].support_time.repeating
	TIMERS.Create( "TimerSupport", IsValid( t ) and t or ( istable( time ) and FPRandom( time[1], time[2] ) or time ), function()
		SpawnSupport( ROUNDPROP.Get( "next_support" ) )

		SetupSupportTimer()
	end )
end

function SetNextSupport( name )
	ROUNDPROP.Set( "support_override", name )
end

local function _getSupportSpawngroups()
	local tbl = {}

	for k, v in pairs( SPAWNGROUPS ) do
		if v.support == true then
			tbl[#tbl + 1] = k
		end
	end

	return tbl
end

concommand.Add( "fp_force_support", function( ply, cmd, args, argStr )
	local support = args[1] or table.Random( _getSupportSpawngroups() )

	SpawnSupport( support )
end, function( cmd, args )
	return AutoComplete( cmd, args, _getSupportSpawngroups() )
end )