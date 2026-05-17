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
		upgrade = data.upgrade or {},
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

local ENTITY = FindMetaTable( "Entity" )

local convertType = {
	["table"] = function( val )
		local total, outcomeTbl = 0, {}
		for i, v in ipairs( val ) do
			total = total + v
			outcomeTbl[#outcomeTbl + 1] = { i, v }
		end

		local target, outcome = FPRandom( total ), true
		repeat
			outcome = outcomeTbl[1][2]
			target = target - outcome
		until target <= 0

		return outcome
	end,
	["string"] = function( val )
		return val
	end,
	["bool"] = function( val )
		return val
	end,
	["function"] = function( val )
		return val()
	end,
}
local function calcUpgradeOutcome( tbl, mode )
	local val = tbl.mode or true

	if mode == "rough" then
		val = false
	end

	return convertType[type( val )]( val )
end

local entUpgradeOverride = {
	["fp_keycard"] = function( ent )
		return ACCESS.KEYCARDS_CACHE[ent:GetKeycard()].upgrade
	end,
}
local convertResult = {
	[true] = function( ent ) end,
	[false] = function( ent ) ent:Remove() return nil end,
}
function ENTITY:HandleUpgrade( mode )
	local tbl = entUpgradeOverride[self:GetClass()]( self ) or self.Upgrades

	local result = calcUpgradeOutcome( tbl, mode )

	if convertResult[result] != nil then
		convertResult[result]( self )
	else
		local ent = ents.Create( result )
		ent:SetPos( self:GetPos() )
		ent:SetAngles( self:GetAngles() )
		self:Remove()
		ent:Spawn()

		return ent
	end

	return self
end

ACCESS.RegisterAccess( "LOCKER_ROOM" )
ACCESS.RegisterAccess( "STORAGE" )
ACCESS.RegisterAccess( "LAB" )
ACCESS.RegisterAccess( "MEDBAY" )
ACCESS.RegisterAccess( "OFFICE" )
ACCESS.RegisterAccess( "SECURITY_ROOM" )
ACCESS.RegisterAccess( "DIRECTOR_OFFICE" )
ACCESS.RegisterAccess( "ELECTRICAL_CENTER" )
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
	upgrade = {
		["veryfine"] = {
			["engineer"] = 20,
			["res"] = 10,
			["it_spec"] = 10,
			["logist"] = 10,
			["medic"] = 10,
			["jr_res"] = 15,
			[true] = 30,
		},
		["fine"] = {
			["it_spec"] = 10,
			["logist"] = 10,
			["medic"] = 10,
			["jr_res"] = 15,
		},
		["1:1"] = "lab",
		["coarse"] = true,
	},
	skin = 0,
} )

ACCESS.RegisterKeycard( "lab", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_LAB,
	},
	upgrade = {
		["veryfine"] = {
			["engineer"] = 10,
			["researcher"] = 20,
			["it_spec"] = 5,
			["logist"] = 5,
			["medic"] = 5,
			["jr_res"] = 30,
			[true] = 30,
		},
		["fine"] = {
			["it_spec"] = 5,
			["logist"] = 5,
			["medic"] = 5,
			["jr_res"] = 30,
		},
		["1:1"] = "janitor",
		["coarse"] = true,
	},
	skin = 6,
} )

ACCESS.RegisterKeycard( "medic", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_MEDBAY,
	},
	upgrade = {
		["veryfine"] = {
			["sr_res"] = 20,
			["res"] = 10,
			[true] = 20,
		},
		["fine"] = "res",
		["1:1"] = {
			["jr_res"] = 5,
			["jr_sec"] = 5,
		},
		["coarse"] = {
			["lab"] = 5,
			["janitor"] = 10,
		},
	},
	skin = 1,
} )

ACCESS.RegisterKeycard( "logist", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_STORAGE,
		ACCESS_ELECTRICAL_CENTER,
	},
	upgrade = {
		["veryfine"] = {
			["cont_spec"] = 20,
			["engineer"] = 10,
			[true] = 20,
		},
		["fine"] = "engineer",
		["1:1"] = {
			["jr_res"] = 5,
			["jr_sec"] = 5,
		},
		["coarse"] = {
			["lab"] = 5,
			["janitor"] = 10,
		},
	},
	skin = 4,
} )

ACCESS.RegisterKeycard( "it_spec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_ELECTRICAL_CENTER,
	},
	upgrade = {
		["veryfine"] = {
			["cont_spec"] = 20,
			["sr_res"] = 10,
			["engineer"] = 10,
			["res"] = 5,
			[true] = 30,
		},
		["fine"] = {
			["engineer"] = 20,
			["res"] = 10,
		},
		["1:1"] = {
			["jr_res"] = 5,
			["jr_sec"] = 5,
		},
		["coarse"] = {
			["lab"] = 5,
			["janitor"] = 10,
		},
	},
	skin = 3,
} )

ACCESS.RegisterKeycard( "jr_res", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_SCP1,
	},
	upgrade = {
		["veryfine"] = {
			["sr_res"] = 20,
			["res"] = 10,
			[true] = 20,
		},
		["fine"] = "res",
		["1:1"] = {
			["medic"] = 5,
			["it_spec"] = 5,
			["logist"] = 5,
			["jr_sec"] = 15,
		},
		["coarse"] = {
			["lab"] = 10,
			["janitor"] = 5,
		},
	},
	skin = 7,
} )

ACCESS.RegisterKeycard( "engineer", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_STORAGE,
		ACCESS_ELECTRICAL_CENTER,
	},
	upgrade = {
		["veryfine"] = {
			["mtf"] = 20,
			["cont_spec"] = 10,
			[true] = 20,
		},
		["fine"] = "cont_spec",
		["1:1"] = {
			["res"] = 5,
			["sec"] = 5,
		},
		["coarse"] = {
			["lab"] = 10,
			["janitor"] = 5,
		},
	},
	skin = 4,
} )

ACCESS.RegisterKeycard( "res", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_OFFICE,
		ACCESS_SCP1,
		ACCESS_SCP2,
	},
	upgrade = {
		["veryfine"] = {
			["head_res"] = 20,
			["sr_res"] = 10,
			[true] = 20,
		},
		["fine"] = "sr_res",
		["1:1"] = {
			["engineer"] = 5,
			["sec"] = 5,
		},
		["coarse"] = {
			["jr_res"] = 10,
			["medic"] = 5,
			["it_spec"] = 5,
		},
	},
	skin = 8,
} )

ACCESS.RegisterKeycard( "cont_spec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_STORAGE,
		ACCESS_SCP1,
		ACCESS_SCP2,
	},
	upgrade = {
		["veryfine"] = {
			["mtf_com"] = 20,
			["mtf"] = 10,
			[true] = 20,
		},
		["fine"] = "mtf",
		["1:1"] = "sr_res",
		["coarse"] = "engineer",
	},
	skin = 5,
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
	upgrade = {
		["veryfine"] = {
			["director"] = 20,
			["head_res"] = 10,
			[true] = 20,
		},
		["fine"] = "head_res",
		["1:1"] = "cont_spec",
		["coarse"] = "res",
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
	upgrade = {
		["veryfine"] = {
			["o5"] = 20,
			["director"] = 10,
			[true] = 20,
		},
		["fine"] = "director",
		["1:1"] = {
			["zone_manager"] = 5,
			["sr_sec"] = 5,
		},
		["coarse"] = "sr_res",
	},
	skin = 10,
} )

ACCESS.RegisterKeycard( "jr_sec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
	},
	upgrade = {
		["veryfine"] = {
			["sr_sec"] = 20,
			["sec"] = 10,
			[true] = 20,
		},
		["fine"] = "sec",
		["1:1"] = {
			["medic"] = 5,
			["it_spec"] = 5,
			["logist"] = 5,
			["jr_res"] = 15,
		},
		["coarse"] = true,
	},
	skin = 11,
} )

ACCESS.RegisterKeycard( "sec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_ARMORY1,
		ACCESS_OFFICE,
	},
	upgrade = {
		["veryfine"] = {
			["mtf"] = 20,
			["sr_sec"] = 10,
			[true] = 20,
		},
		["fine"] = "sr_sec",
		["1:1"] = {
			["engineer"] = 5,
			["res"] = 5,
		},
		["coarse"] = "jr_sec",
	},
	skin = 12,
} )

ACCESS.RegisterKeycard( "sr_sec", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
		ACCESS_ARMORY1,
		ACCESS_ARMORY2,
		ACCESS_OFFICE,
	},
	upgrade = {
		["veryfine"] = {
			["mtf_com"] = 20,
			["mtf"] = 10,
			[true] = 20,
		},
		["fine"] = "mtf",
		["1:1"] = {
			["head_res"] = 5,
			["zone_manager"] = 5,
		},
		["coarse"] = "sec",
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
	upgrade = {
		["veryfine"] = {
			["mtf_com"] = 20,
			["mtf"] = 10,
			[true] = 20,
		},
		["fine"] = "mtf",
		["coarse"] = true,
	},
	skin = 14,
} )

ACCESS.RegisterKeycard( "zone_manager", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_LCZ_CHECKPOINT,
		ACCESS_EZ_CHECKPOINT,
	},
	upgrade = {
		["veryfine"] = {
			["o5"] = 20,
			["director"] = 10,
			[true] = 20,
		},
		["fine"] = "director",
		["1:1"] = {
			["sr_sec"] = 5,
			["zone_manager"] = 5,
		},
		["coarse"] = true,
	},
	skin = 2,
} )

ACCESS.RegisterKeycard( "director", {
	access = {
		ACCESS_LOCKER_ROOM,
		ACCESS_SECURITY_ROOM,
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
	upgrade = {
		["veryfine"] = {
			["janitor"] = 20,
			["o5"] = 10,
			[true] = 20,
		},
		["fine"] = "o5",
		["coarse"] = {
			["zone_manager"] = 10,
			["head_res"] = 5,
		},
	},
	skin = 15,
} )

ACCESS.RegisterKeycard( "mtf", {
	access = {
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
	upgrade = {
		["veryfine"] = {
			["o5"] = 20,
			["mtf_com"] = 10,
			[true] = 20,
		},
		["fine"] = "mtf_com",
		["1:1"] = "goc",
		["coarse"] = {
			["sr_sec"] = 5,
			["int_sec"] = 5,
			["cont_spec"] = 10,
		},
	},
	skin = 16,
} )

ACCESS.RegisterKeycard( "mtf_com", {
	access = {
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
	upgrade = {
		["veryfine"] = {
			["janitor"] = 20,
			["o5"] = 10,
			[true] = 20,
		},
		["fine"] = "o5",
		["coarse"] = "mtf",
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
	upgrade = {
		["veryfine"] = {
			["janitor"] = 20,
			[true] = 20,
		},
		["fine"] = "janitor",
		["coarse"] = {
			["director"] = 10,
			["mtf_com"] = 10,
		},
	},
	skin = 18,
} )

ACCESS.RegisterKeycard( "goc", {
	access = {
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
	upgrade = {
		["1:1"] = "mtf",
		["coarse"] = true,
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