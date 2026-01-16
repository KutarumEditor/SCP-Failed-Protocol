ACCESS = {
	REG = {},
	BUTTON_CACHE = {},
	KEYCARDS_CACHE = {}
}

local buttonEnts = {
	["func_button"] = true,
	["func_rot_button"] = true
}

function ACCESS.RecomputeButtons()
	local override = ACCESS_OVERRIDE or {}

	for _, ent in ents.Iterator() do
		if buttonEnts[ent:GetClass()] then
			for i, v in ipairs( override ) do
				if v.pos == ent:GetPos() or v.map_id == ent:MapCreationID() then
					ACCESS.BUTTON_CACHE[ent:EntIndex()] = {
						access = _G["ACCESS_"..v.access],
					}
					break
				end
			end
		end
	end
end

function ACCESS.RegisterAccess( name )
	local n = #ACCESS.REG + 1
	ACCESS.REG[n] = name

	_G["ACCESS_"..string.upper( name )] = n
end

function ACCESS.RegisterKeycard( name, data )
	ACCESS.KEYCARDS_CACHE[name] = {
		access = data.access,
		skin = data.skin or 0,
		uses = data.uses or -1
	}
end

function ACCESS.CheckAccess( ent_id, access )
	return ACCESS.BUTTON_CACHE[ent_id].access == access
end

function ACCESS.CheckKeycardAccess( ent_id, card )
	for _, v in pairs( ACCESS.KEYCARDS_CACHE[card].access ) do
		if ACCESS.CheckAccess( ent_id, v ) then
			return true
		end
	end

	return false
end

function ents.CreateKeycard( card )
	local kc = ents.Create( "fp_keycard" )
	kc:SetKeycard( card )

	return kc
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GiveKeycard( card )
	local kc = self:Give( "fp_keycard" )
	kc:SetKeycard( card )
end

ACCESS.RegisterAccess( "LOCKER_ROOM" )
ACCESS.RegisterAccess( "STORAGE" )
ACCESS.RegisterAccess( "LAB" )
ACCESS.RegisterAccess( "MEDBAY" )
ACCESS.RegisterAccess( "OFFICE" )
ACCESS.RegisterAccess( "SECURITY_ROOM" )
ACCESS.RegisterAccess( "DIRECTOR_OFFICE" )
ACCESS.RegisterAccess( "ELECTRICAL_CENTER" )
ACCESS.RegisterAccess( "TRAM" )
ACCESS.RegisterAccess( "ARMORY1" )
ACCESS.RegisterAccess( "ARMORY2" )
ACCESS.RegisterAccess( "ARMORY3" )
ACCESS.RegisterAccess( "SCP1" )
ACCESS.RegisterAccess( "SCP2" )
ACCESS.RegisterAccess( "SCP3" )
ACCESS.RegisterAccess( "SCP4" )
ACCESS.RegisterAccess( "LCZ_CHECKPOINT" )
ACCESS.RegisterAccess( "EZ_CHECKPOINT" )
ACCESS.RegisterAccess( "GATES" )

ACCESS.RegisterKeycard( "janitor", {
	access = {
		ACCESS_LOCKER_ROOM,
	},
	skin = 0,
} )

ACCESS.RegisterKeycard( "medic", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_MEDBAY,
	},
	skin = 1,
} )

ACCESS.RegisterKeycard( "zone_manager", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
	},
	skin = 2,
} )

ACCESS.RegisterKeycard( "it_spec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_ELECTRICAL_CENTER,
	},
	skin = 3,
} )

ACCESS.RegisterKeycard( "engineer", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_STORAGE,
		ACCESS_ELECTRICAL_CENTER,
	},
	skin = 4,
} )

ACCESS.RegisterKeycard( "cont_spec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_STORAGE,
		ACCESS_SCP1,
		ACCESS_SCP2,
	},
	skin = 5,
} )

ACCESS.RegisterKeycard( "lab", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_LAB,
	},
	skin = 6,
} )

ACCESS.RegisterKeycard( "jr_res", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_SCP1,
	},
	skin = 7,
} )

ACCESS.RegisterKeycard( "res", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_SCP1,
		ACCESS_SCP2,
	},
	skin = 8,
} )

ACCESS.RegisterKeycard( "sr_res", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_LAB,
		ACCESS_SCP1,
		ACCESS_SCP2,
		ACCESS_SCP3,
	},
	skin = 9,
} )

ACCESS.RegisterKeycard( "head_res", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_LAB,
		ACCESS_SCP1,
		ACCESS_SCP2,
		ACCESS_SCP3,
		ACCESS_SCP4,
	},
	skin = 10,
} )

ACCESS.RegisterKeycard( "jr_sec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
	},
	skin = 11,
} )

ACCESS.RegisterKeycard( "sec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_ARMORY1,
		ACCESS_OFFICE,
	},
	skin = 12,
} )

ACCESS.RegisterKeycard( "sr_sec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_ARMORY1,
		ACCESS_ARMORY2,
		ACCESS_OFFICE,
	},
	skin = 13,
} )

ACCESS.RegisterKeycard( "int_sec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_OFFICE,
		ACCESS_DIRECTOR_OFFICE,
	},
	skin = 14,
} )

ACCESS.RegisterKeycard( "director", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_LAB,
		ACCESS_MEDBAY,
		ACCESS_STORAGE,
		ACCESS_OFFICE,
		ACCESS_DIRECTOR_OFFICE,
		ACCESS_ELECTRICAL_CENTER,
		ACCESS_SCP1,
		ACCESS_SCP2,
		ACCESS_SCP3,
		ACCESS_SCP4,
		ACCESS_GATES,
	},
	skin = 15,
} )

ACCESS.RegisterKeycard( "mtf", {
	access = {
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_MEDBAY,
		ACCESS_ELECTRICAL_CENTER,
		ACCESS_SCP1,
		ACCESS_SCP2,
		ACCESS_SCP3,
		ACCESS_GATES,
		ACCESS_ARMORY1,
		ACCESS_ARMORY2,
	},
	skin = 16,
} )

ACCESS.RegisterKeycard( "mtf_com", {
	access = {
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_MEDBAY,
		ACCESS_ELECTRICAL_CENTER,
		ACCESS_SCP1,
		ACCESS_SCP2,
		ACCESS_SCP3,
		ACCESS_SCP4,
		ACCESS_GATES,
		ACCESS_ARMORY1,
		ACCESS_ARMORY2,
		ACCESS_ARMORY3,
	},
	skin = 17,
} )

ACCESS.RegisterKeycard( "o5", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_STORAGE,
		ACCESS_LAB,
		ACCESS_MEDBAY,
		ACCESS_OFFICE,
		ACCESS_SECURITY_ROOM,
		ACCESS_DIRECTOR_OFFICE,
		ACCESS_ELECTRICAL_CENTER,
		ACCESS_TRAM,
		ACCESS_ARMORY1,
		ACCESS_ARMORY2,
		ACCESS_ARMORY3,
		ACCESS_SCP1,
		ACCESS_SCP2,
		ACCESS_SCP3,
		ACCESS_SCP4,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_GATES,
	},
	skin = 18,
} )

ACCESS.RegisterKeycard( "goc", {
	access = {
		ACCESS_TRAM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_SCP1,
		ACCESS_SCP2,
		ACCESS_SCP3,
		ACCESS_SCP4,
		ACCESS_GATES,
		ACCESS_ARMORY1,
		ACCESS_ARMORY2,
	},
	skin = 19,
} )

ACCESS.RecomputeButtons()

if SERVER then

concommand.Add( "fp_test_keycard_spawn", function( ply )
	if not SERVER then return end

	local armor = ents.CreateKeycard( "janitor" )
	armor:SetPos( ply:EyePos() )
	armor:SetAngles( Angle( 0, 0, 0 ) )
	armor:Spawn()
end )

end