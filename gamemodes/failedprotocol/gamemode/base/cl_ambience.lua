AMBIENT = AMBIENT or {
	CHANNEL = nil,
	SOUND = nil,
	TIME = nil,
	BAN = 0,
	VOLUME = .5
}

PrintTable( AMBIENT )

function AMBIENT.Restart( name )
	local name = name or "sound/scpfp/ambience/"..FPRandom( 1, 8 )..".mp3"
	AMBIENT.SOUND = name
	AMBIENT.TIME = AMBIENT.TIME or 0
	sound.PlayFile( name, "", function( station, errCode, errStr )
		if ( IsValid( station ) ) then
			station:Play()
			station:SetTime( AMBIENT.TIME )

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

function AMBIENT.Ban( time )
	AMBIENT.BAN = time
end

local ambThinkDelay = 0
hook.Add( "Think", "FPAmbience", function()
	if ambThinkDelay <= CurTime() then
		if AMBIENT.CHANNEL == nil or AMBIENT.CHANNEL:GetState() == 0 then
			if AMBIENT.CHANNEL != nil and math.floor( AMBIENT.CHANNEL:GetLength() ) <=  math.ceil( AMBIENT.TIME ) then
				AMBIENT.TIME = 0
				AMBIENT.SOUND = nil
			end

			if AMBIENT.SOUND != nil then
				AMBIENT.Restart( AMBIENT.SOUND )
			else
				if AMBIENT.BAN == 0 then
					AMBIENT.Restart( "sound/scpfp/ambience/"..FPRandom( 1, 8 )..".mp3" )
				else
					AMBIENT.BAN = math.max( 0, AMBIENT.BAN - FrameTime() * 2 )
				end
			end

			ambThinkDelay = CurTime() + FrameTime() * 2
		elseif AMBIENT.CHANNEL:IsValid() and AMBIENT.CHANNEL:GetState() != 0 then
			AMBIENT.TIME = AMBIENT.CHANNEL:GetTime()
		end
	end
end )