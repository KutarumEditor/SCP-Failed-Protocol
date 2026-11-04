local PLAYER = FindMetaTable( "Player" )

local defTripPhrases = {
    start = {
        "ragestart1",
        "ragestart2",
        "ragestart3",
    },
    kill = {
        "ragekill1",
        "ragekill2",
        "ragekill3",
        "ragekill4",
        "ragekill5",
        "ragekill6",
    },
    crash = {
        "rageover",
    }
}

TRIP_CFG = {
    horror = {
        music = "scpfp/trips/bad_trip.mp3",
        duration = 60,
        act_time = 4,
        crash_time = 6,
        start_cb = function( ply )
        end,
        start_cb_cl = function( ply )
        end,
        act_cb = function( ply )
            ply:PushSpeed( 1.1, 1.25, 1, 1, "PsychoTrip", 1 )
        end,
        act_cb_cl = function( ply )
            --
        end,
        crash_cb = function( ply )
            ply:PopSpeed( "PsychoTrip" )
        end,
        crash_cb_cl = function( ply )
        end,
        end_cb = function( ply ) end,
        end_cb_cl = function( ply ) end,
        phrases = {
            start = {
                "badtripstart1",
                "badtripstart2",
                "badtripstart3",
            },
            kill = {
                "badtripkill1",
                "badtripkill2",
                "badtripkill3",
                "badtripkill4",
                "badtripkill5",
                "badtripkill6",
            },
            crash = {
                "badtripover",
            }
        }
    },
    drumnbass = {
        music = "scpfp/trips/drumnbass_trip.mp3",
        duration = 71.7,
        act_time = 3.88,
        crash_time = 8.94,
        start_cb = function( ply )
        end,
        start_cb_cl = function( ply )
        end,
        act_cb = function( ply )
            ply:PushSpeed( 1.1, 1.25, 1, 1, "PsychoTrip", 1 )
            ply:SetInfStamina( true )
        end,
        act_cb_cl = function( ply )
            ply:ScreenFade( SCREENFADE.IN, Color( 255, 0, 0 ), 1, 0 )
        end,
        crash_cb = function( ply )
            ply:PopSpeed( "PsychoTrip" )
            ply:SetInfStamina( false )
        end,
        crash_cb_cl = function( ply )
        end,
        end_cb = function( ply ) end,
        end_cb_cl = function( ply ) end,
        phrases = defTripPhrases
    }
}

if SERVER then

function PLAYER:SyncTrip()
    net.Start( "FPPsychoTrip" )
        net.WriteTable( self.FPTrip )
    net.Send( self )
end

function PLAYER:StartTrip( trip )
    local ct, cfg = CurTime(), TRIP_CFG[trip]
    self.FPTrip = {
        trip_type = trip,
        start_time = ct,
        action_time = ct + cfg.act_time,
        crash_time = ct + cfg.duration - cfg.crash_time,
        end_time = ct + cfg.duration,
    }

    self:ApplyEffect( "psycho_rage", cfg.duration )

    cfg.start_cb( self )
    local id64 = self:SteamID64()
    TIMERS.Create( id64.."_TripAction", cfg.act_time, function() if self:IsValid() and self:Alive() then cfg.act_cb( self ) end end, false )
    TIMERS.Create( id64.."_TripCrash", cfg.duration - cfg.crash_time, function() if self:IsValid() and self:Alive() then cfg.crash_cb( self ) end end, false )
    TIMERS.Create( id64.."_TripEnd", cfg.duration, function() if self:IsValid() and self:Alive() then cfg.end_cb( self ) end end, false )

    self:SyncTrip()
end

hook.Add( "PostPlayerDeath", "RemoveTripOnDeath", function( ply )
    if not ply.FPTrip then return end
    ply.FPTrip = {
        trip_type = nil,
        start_time = 0,
        action_time = 0,
        crash_time = 0,
        end_time = 0,
    }

	ply:SyncTrip()
end )

hook.Add( "PlayerSpawn", "TripTimersKill", function( ply )
    local id64 = ply:SteamID64()
	TIMERS.Destroy( id64.."_TripAction" )
    TIMERS.Destroy( id64.."_TripCrash" )
    TIMERS.Destroy( id64.."_TripEnd" )
end )

else

TRIPMUSIC = TRIPMUSIC or {
	CHANNEL = nil,
	SOUND = nil,
    TIME = 0,
    LOCKED = false,
    NEXT_CHECK = 0,
}

function TRIPMUSIC.Play( name )
    if TRIPMUSIC.SOUND == name and TRIPMUSIC.CHANNEL != nil and TRIPMUSIC.CHANNEL:IsValid() then
        if TRIPMUSIC.CHANNEL:GetState() == GMOD_CHANNEL_PLAYING then
            return
        end
    end

	TRIPMUSIC.RemoveInternal()
	TRIPMUSIC.SOUND = name
    TRIPMUSIC.LOCKED = true
	sound.PlayFile( "sound/"..name, "noblock", function( station, errCode, errStr )
		if ( IsValid( station ) ) then
            if TRIPMUSIC.SOUND != name then
                station:Stop()
                return
            end
			station:Play()
			TRIPMUSIC.CHANNEL = station
		else
			print( "Error playing trip music!", errCode, errStr )
		end
	end )
end

function TRIPMUSIC.Start()
	if TRIPMUSIC.CHANNEL != nil and TRIPMUSIC.CHANNEL:IsValid() then
		TRIPMUSIC.CHANNEL:Play()
	end
end

function TRIPMUSIC.Stop()
	if TRIPMUSIC.LOCKED then
		local lply = LocalPlayer()
		if IsValid(lply) and lply.FPTrip and lply.FPTrip.trip_type != nil and lply:Alive() and CurTime() <= lply.FPTrip.end_time then
			if TRIPMUSIC.CHANNEL != nil and TRIPMUSIC.CHANNEL:IsValid() then
				if TRIPMUSIC.CHANNEL:GetState() != GMOD_CHANNEL_PLAYING then
					TRIPMUSIC.CHANNEL:Play()
				end
			end
			return
		end
	end

	if TRIPMUSIC.CHANNEL != nil and TRIPMUSIC.CHANNEL:IsValid() then
		TRIPMUSIC.CHANNEL:Stop()
	end
end

function TRIPMUSIC.RemoveInternal()
	if TRIPMUSIC.CHANNEL != nil and TRIPMUSIC.CHANNEL:IsValid() then
		TRIPMUSIC.CHANNEL:Stop()
		TRIPMUSIC.CHANNEL = nil
	end
	TRIPMUSIC.SOUND = nil
	TRIPMUSIC.LOCKED = false
end

function TRIPMUSIC.Remove()
	local lply = LocalPlayer()
	if IsValid(lply) and lply.FPTrip and lply.FPTrip.trip_type != nil and lply:Alive() and CurTime() <= lply.FPTrip.end_time then
		if TRIPMUSIC.LOCKED then return end
	end
	TRIPMUSIC.RemoveInternal()
end

hook.Add( "Think", "FPTripMusic", function()
    local ct = CurTime()
    if ct < TRIPMUSIC.NEXT_CHECK then return end
    TRIPMUSIC.NEXT_CHECK = ct + 0.1

    local lply = LocalPlayer()
    if not IsValid(lply) then return end
    
    local trip = lply.FPTrip
    local isTripping = trip and trip.trip_type != nil and lply:Alive() and ct <= trip.end_time

    if isTripping then
        TRIPMUSIC.LOCKED = true
        if TRIPMUSIC.CHANNEL != nil and TRIPMUSIC.CHANNEL:IsValid() then
            if TRIPMUSIC.CHANNEL:GetState() != GMOD_CHANNEL_PLAYING then
                TRIPMUSIC.CHANNEL:Play()
            end
            TRIPMUSIC.CHANNEL:SetVolume( 1 )
            TRIPMUSIC.TIME = TRIPMUSIC.CHANNEL:GetTime()
        elseif TRIPMUSIC.SOUND and not TRIPMUSIC.LoadingSound then
            TRIPMUSIC.Play( TRIPMUSIC.SOUND )
        end
    else
        if TRIPMUSIC.LOCKED or (TRIPMUSIC.CHANNEL != nil and TRIPMUSIC.CHANNEL:IsValid()) then
            TRIPMUSIC.LOCKED = false
            TRIPMUSIC.RemoveInternal()
        end
    end
end )

local tab = {
    [ "$pp_colour_addr" ] = 0,
    [ "$pp_colour_addg" ] = 0,
    [ "$pp_colour_addb" ] = 0,
    [ "$pp_colour_brightness" ] = 0,
    [ "$pp_colour_contrast" ] = 1,
    [ "$pp_colour_colour" ] = 1,
    [ "$pp_colour_mulr" ] = 0,
    [ "$pp_colour_mulg" ] = 0,
    [ "$pp_colour_mulb" ] = 0
}

local function DrawPsychedelicRage()
    local lply = LocalPlayer()
    if not IsValid(lply) or not lply:Alive() then return end
    
    local trip = lply.FPTrip
    if not trip then return end

    local ct = CurTime()
    if ct > trip.end_time or ct < trip.start_time then return end

    local intensityFactor = 0
    
    if ct <= trip.action_time then
        local duration = trip.action_time - trip.start_time
        if duration > 0 then
            intensityFactor = math.Clamp((ct - trip.start_time) / duration, 0, 1)
        else
            intensityFactor = 1
        end
    elseif ct < trip.crash_time then
        intensityFactor = 1
    else
        local duration = trip.end_time - trip.crash_time
        if duration > 0 then
            intensityFactor = math.Clamp(1 - ((ct - trip.crash_time) / duration), 0, 1)
        else
            intensityFactor = 0
        end
    end

    if intensityFactor <= 0 then return end

    local time = CurTime()
    local pulse = math.sin(time * 4) * 0.5 + 0.5
    local scrW, scrH = ScrW(), ScrH()

    tab[ "$pp_colour_brightness" ] = (math.sin(time * 2) * 0.04) * intensityFactor
    tab[ "$pp_colour_contrast" ]   = 1 + ((1.2 + (math.cos(time * 3) * 0.3) - 1) * intensityFactor)
    tab[ "$pp_colour_colour" ]     = 1 + ((1.8 + (math.sin(time * 5) * 0.7) - 1) * intensityFactor)
    tab[ "$pp_colour_addr" ]       = (pulse * 0.15) * intensityFactor
    tab[ "$pp_colour_addb" ]       = ((1 - pulse) * 0.05) * intensityFactor

    DrawColorModify( tab )
    DrawMotionBlur( 0.15 * intensityFactor, 0.75 * intensityFactor, 0.03 * intensityFactor )

    cam.Start2D()
        local noiseCount = math.floor(35 * intensityFactor)
        for i = 1, noiseCount do
            local rx = FPRandom( 0, scrW )
            local ry = FPRandom( 0, scrH )
            local rw = FPRandom( 2, 6 )
            local rh = FPRandom( 1, 3 )
            
            local alpha = FPRandom(155, 215) * intensityFactor
            surface.SetDrawColor( 0, 174, 255, alpha )
            surface.DrawRect( rx, ry, rw, rh )
        end
    cam.End2D()
end

hook.Add( "RenderScreenspaceEffects", "PsychedelicRageEffect", DrawPsychedelicRage )

net.Receive( "FPPsychoTrip", function()
    local lply = LocalPlayer()
    if lply == nil then return end
    local id64 = lply:SteamID64()
    lply.FPTrip = net.ReadTable()

    if lply.FPTrip.trip_type == nil then
        TRIPMUSIC.LOCKED = false
        TRIPMUSIC.RemoveInternal()
        return
    end

    local cfg = TRIP_CFG[lply.FPTrip.trip_type]

    TRIPMUSIC.Play( cfg.music )

    cfg.start_cb_cl()
    TIMERS.Create( id64.."_TripAction_CL", cfg.act_time, function() if lply:IsValid() and lply:Alive() then
        PHRASES.PopUp( "cbgpsycho", table.Random( cfg.phrases.start ), 1.5 )
        cfg.act_cb_cl( lply )
    end end, false )
    TIMERS.Create( id64.."_TripCrash_CL", cfg.duration - cfg.crash_time, function() if lply:IsValid() and lply:Alive() then
        PHRASES.PopUp( "cbgpsycho", table.Random( cfg.phrases.crash ), 1.5 )
        cfg.crash_cb_cl( lply )
    end end, false )
    TIMERS.Create( id64.."_TripEnd_CL", cfg.duration, function() if lply:IsValid() and lply:Alive() then cfg.end_cb_cl( lply ) end end, false )
end )

hook.Add( "OnSpawn", "TripTimersKillCL", function()
    local id64 = LocalPlayer():SteamID64()
	TIMERS.Destroy( id64.."_TripAction_CL" )
    TIMERS.Destroy( id64.."_TripCrash_CL" )
    TIMERS.Destroy( id64.."_TripEnd_CL" )
end )

end

function PLAYER:TripData()
    return self.FPTrip
end