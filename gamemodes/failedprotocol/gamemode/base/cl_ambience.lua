AMBIENT = AMBIENT or {
	CHANNEL = nil,
	SOUND = nil,
	TIME = nil,
	VOLUME = .5
}

function AMBIENT.Restart( name )
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

local ambThinkDelay = 0
hook.Add( "Think", "FPAmbience", function()
	if ambThinkDelay <= CurTime() then
		if AMBIENT.CHANNEL == nil or AMBIENT.CHANNEL:GetState() == 0 then
			if AMBIENT.CHANNEL != nil and math.floor( AMBIENT.CHANNEL:GetLength() ) <=  math.ceil( AMBIENT.TIME ) then
				AMBIENT.TIME = 0
				AMBIENT.SOUND = nil
			end

			AMBIENT.Restart( AMBIENT.SOUND != nil and AMBIENT.SOUND or "sound/scpfp/ambience/"..FPRandom( 1, 8 )..".mp3" )

			ambThinkDelay = CurTime() + FrameTime() * 2
		elseif AMBIENT.CHANNEL:IsValid() and AMBIENT.CHANNEL:GetState() != 0 then
			AMBIENT.TIME = AMBIENT.CHANNEL:GetTime()
		end
	end
end )