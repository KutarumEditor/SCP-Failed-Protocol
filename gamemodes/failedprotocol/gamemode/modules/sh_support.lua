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