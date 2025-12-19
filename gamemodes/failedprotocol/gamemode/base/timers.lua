-- Timers callbacks are working only on server side. Clients only have info about their start time and end time

TIMERS = TIMERS or {
	ongoing = {}
}

if SERVER then

function TIMERS.Sync( endTime, name )
	net.Start( "FPTimerSync" )
		net.WriteString( name )
		net.WriteFloat( CurTime() )
		net.WriteFloat( endTime )
	net.Broadcast()
end

end

function TIMERS.Exists( name )
	return TIMERS.ongoing[name] != nil
end

function TIMERS.Create( name, duration, callback, sync )
	TIMERS.ongoing[name] = {
		st = CurTime(),
		et = CurTime() + duration,
		cb = callback
	}

	local syn = true
	if sync != nil then
		syn = sync
	end

	if SERVER and syn then
		TIMERS.Sync( CurTime() + duration, name )
	end
end

function TIMERS.Destroy( name, sync )
	TIMERS.ongoing[name] = nil

	local syn = true
	if sync != nil then
		syn = sync
	end

	if SERVER and syn then
		TIMERS.Sync( 0, name )
	end
end

function TIMERS.DestroyAll()
	for name, timer in pairs( TIMERS.ongoing ) do
		timer = nil

		TIMERS.Sync( 0, name )
	end
end

function TIMERS.DestroyAllExcluding( tbl )
	for name, timer in pairs( TIMERS.ongoing ) do
		if not table.HasValue( tbl, name ) then
			timer = nil

			TIMERS.Sync( 0, name )
		end
	end
end

hook.Add( "Think", "FPTimersThink", function()
	for name, v in pairs( TIMERS.ongoing ) do
		if v.et <= CurTime() then
			local cb = v.cb

			TIMERS.Destroy( name )

			if SERVER then
				cb()
			end
		end
	end
end )

if not CLIENT then return end

net.Receive( "FPTimerSync", function()
	local name = net.ReadString()
	local startTime = net.ReadFloat()
	local endTime = net.ReadFloat()
	TIMERS.ongoing[name] = {
		st = startTime,
		et = endTime
	}
end )