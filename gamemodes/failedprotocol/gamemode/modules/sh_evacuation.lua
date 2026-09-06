if SERVER then

EVACUATION = {}

function EVACUATION.SetupTimers()
    print( "Light Containment Zone decontamination proccess will occur in T-minus 15 minutes" )

    TIMERS.Create( "LCZ_Decont15", 300, function()
        PA.Play( "scpfp/public_announcements/intercom_start.wav", "lcz_decont10" )

        TIMERS.Create( "LCZ_Decont10", 300, function()
            PA.Play( "scpfp/public_announcements/intercom_start.wav", "lcz_decont5" )

            TIMERS.Create( "LCZ_Decont_Track", 300 - 73.38, function()
                net.Ping( "LCZ_Decont_Track", "" )
            end, true )

            TIMERS.Create( "LCZ_Decont5", 240, function()
                PA.Play( "scpfp/public_announcements/intercom_start.wav", "lcz_decont1" )

                TIMERS.Create( "LCZ_Decont1", 60, function()
                    EVACUATION.LaunchLCZ()
                end )
            end )
        end )
    end )
end

function EVACUATION.LaunchLCZ()
    print( "Light Containment Zone decontamination proccess engaged" )

    net.Ping( "LCZ_Decont_Start", "" )
end

concommand.Add( "fp_debug_lcz_decont", function()
    net.Ping( "LCZ_Decont_Track", "" )

    TIMERS.Create( "LCZ_Decont5", 13.38, function()
        PA.Play( "scpfp/public_announcements/intercom_start.wav", "lcz_decont1" )

        TIMERS.Create( "LCZ_Decont1", 60, function()
            EVACUATION.LaunchLCZ()
        end )
    end )
end )

else

net.ReceivePing( "LCZ_Decont_Track", function()
    AMBIENT.Ban( 73.38 )

    AMBIENT.Restart( "sound/scpfp/ambience/lcz_decont.wav" )
end )

net.ReceivePing( "LCZ_Decont_Start", function()
    --
end )

end