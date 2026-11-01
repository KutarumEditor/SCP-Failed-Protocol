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
        act_time = 24,
        crash_time = 6,
        start_cb = function( ply )
            --
        end,
        start_cb_cl = function( ply )
            --
        end,
        act_cb = function( ply )
            ply:PushSpeed( 1.1, 1.25, 1, 1, "PsychoTrip", 1 )
        end,
        act_cb_cl = function( ply )
            --
        end,
        crash_cb = function( ply )
            ply:PopSpeed( "PsychoTrip" )

            --
        end,
        crash_cb_cl = function( ply )
            --
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
            --
        end,
        start_cb_cl = function( ply )
            --
        end,
        act_cb = function( ply )
            ply:PushSpeed( 1.1, 1.25, 1, 1, "PsychoTrip", 1 )
        end,
        act_cb_cl = function( ply )
            --
        end,
        crash_cb = function( ply )
            ply:PopSpeed( "PsychoTrip" )

            --
        end,
        crash_cb_cl = function( ply )
            --
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

    cfg.start_cb( self )
    TIMERS.Create( self:SteamID64().."_TripAction", cfg.act_time, function() if self:IsValid() and self:Alive() then cfg.act_cb( self ) end end, false )
    TIMERS.Create( self:SteamID64().."_TripCrash", cfg.duration - cfg.crash_time, function() if self:IsValid() and self:Alive() then cfg.crash_cb( self ) end end, false )
    TIMERS.Create( self:SteamID64().."_TripEnd", cfg.duration, function() if self:IsValid() and self:Alive() then cfg.end_cb( self ) end end, false )

    self:SyncTrip()
end

else

net.Receive( "FPPsychoTrip", function()
    --
end )

end

function PLAYER:TripData()

end