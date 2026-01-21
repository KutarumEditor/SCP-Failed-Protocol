AMBIENT = AMBIENT or {
	CHANNEL = nil,
	SOUND = nil,
	BAN = 0,
	VOLUME = .5
}

function AMBIENT.Restart( name )
	AMBIENT.Remove()
	local name = name or "sound/scpfp/ambience/"..FPRandom( 1, 5 )..".mp3"
	AMBIENT.SOUND = name
	sound.PlayFile( name, "", function( station, errCode, errStr )
		if ( IsValid( station ) ) then
			station:Play()

			AMBIENT.CHANNEL = station
		else
			print( "Error playing ambience!", errCode, errStr )
		end
	end )
end

function AMBIENT.Pause()
	if AMBIENT.CHANNEL != nil then
		AMBIENT.CHANNEL:Pause()
	end
end

function AMBIENT.Start()
	if AMBIENT.CHANNEL != nil then
		AMBIENT.CHANNEL:Play()
	end
end

function AMBIENT.Stop()
	if AMBIENT.CHANNEL != nil then
		AMBIENT.CHANNEL:Stop()
	end
end

function AMBIENT.Remove()
	if AMBIENT.CHANNEL != nil then
		AMBIENT.CHANNEL:Stop()
		AMBIENT.CHANNEL = nil
	end
end

function AMBIENT.Ban( time )
	AMBIENT.BAN = CurTime() + time
end


local checkTime = 0
local ambThinkDelay = 1
hook.Add( "Think", "FPAmbience", function()
	if checkTime <= CurTime() then
		if AMBIENT.CHANNEL == nil or AMBIENT.CHANNEL:GetState() == 0 then
			if AMBIENT.CHANNEL != nil and math.floor( AMBIENT.CHANNEL:GetLength() ) <= math.ceil( AMBIENT.TIME ) then
				AMBIENT.SOUND = nil
			end

			if CurTime() > AMBIENT.BAN then
				AMBIENT.Restart()
			end

			checkTime = CurTime() + ambThinkDelay
		elseif AMBIENT.CHANNEL:IsValid() and AMBIENT.CHANNEL:GetState() != 0 then
			AMBIENT.TIME = AMBIENT.CHANNEL:GetTime()
		end
	end
end )