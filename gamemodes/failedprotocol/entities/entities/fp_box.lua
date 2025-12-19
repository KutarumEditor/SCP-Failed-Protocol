AddCSLuaFile()

ENT.Base = "fp_container_base"

ENT.Model = "models/props_junk/cardboard_box003a.mdl"

ENT.StoreSounds = {
    "physics/cardboard/cardboard_box_break1.wav",
    "physics/cardboard/cardboard_box_break2.wav",
    "physics/cardboard/cardboard_box_break3.wav"
}

ENT.TakeOutSounds = {
    "physics/cardboard/cardboard_box_break1.wav",
    "physics/cardboard/cardboard_box_break2.wav",
    "physics/cardboard/cardboard_box_break3.wav"
}

ENT.OpenInfo = {
   time = 3,
   lang = "box",
   clr = Color( 200, 155, 0 )
}

ENT.Actions = {
    [1] = {
        name = "open",
        func = function( ply, ent )
            ply:TimedTask( ent.OpenInfo.lang.."_opening", ent.OpenInfo.time, ent.OpenInfo.clr,
            function()
                return IsValid( ent ) and IsValid( ply ) and
                    ply:EyePos():Distance( ent:GetPos() ) < 100 and ply:GetEyeTrace().Entity == ent
            end, function()
                OpenStorage( ent, ply )
            end )
        end
    },
}