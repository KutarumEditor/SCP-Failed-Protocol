SPAWNGROUPS = {
	["classd"] = {
		weight = 40,
		spawn = CLASSD_SPAWN,
		roundtype = "default",
	},
	["personnel"] = {
		weight = 25,
		spawn = SCI_SPAWN,
		roundtype = "default",
	},
	["security"] = {
		weight = 25,
		spawn = SD_SPAWN,
		roundtype = "default",
	},

	-- Support

	["ntf"] = {
		weight = 60,
		spawn = MTF_SPAWN,
		roundtype = "default",
		support = true,
		maxplayers = 5,
		max = 2,
		check = function()
			local next_mtf = ROUNDPROP.Get( "next_mtf" )

			return next_mtf == nil or next_mtf <= 0
		end,
		callback = function( plys )
			ROUNDPROP.Set( "next_mtf", 2 )

			for i, ply in ipairs( plys ) do
				net.Ping( "MTFSpawn", nil, ply )
			end

			TIMERS.Create( "NTFAnnounce", 7, function()
				PA.Play( "scpfp/public_announcements/epsilon11_arrival.wav", "epsilon11" )

				local scps = SCPCount()
				if scps > 0 and scps < 4 then
					PA.Play( "scpfp/public_announcements/"..scps.."_scp.wav", "scp"..scps )
				else
					PA.Play( "scpfp/public_announcements/intercom_end.wav" )
				end
			end )
		end
	},
	["goc"] = {
		weight = 40,
		spawn = CI_SPAWN,
		roundtype = "default",
		support = true,
		maxplayers = 4,
		max = 1,
		check = function()
			local next_mtf = ROUNDPROP.Get( "next_mtf" )

			return next_mtf != nil and next_mtf > 0
		end,
		callback = function( plys )
			ROUNDPROP.Set( "next_mtf", ROUNDPROP.Get( "next_mtf" ) - 1 )
		end
	},
	["gru"] = {
		weight = 40,
		spawn = CI_SPAWN,
		roundtype = "default",
		support = true,
		maxplayers = 4,
		max = 1,
		check = function()
			return false
		end,
		callback = function( plys )
			ROUNDPROP.Set( "next_mtf", ROUNDPROP.Get( "next_mtf" ) - 1 )
			SetNextSupport( "spear" )
		end
	},
	["spear"] = {
		weight = 40,
		spawn = CI_SPAWN,
		roundtype = "default",
		support = true,
		maxplayers = 4,
		max = 1,
		check = function()
			local next_mtf = ROUNDPROP.Get( "next_mtf" )

			return next_mtf != nil and next_mtf > 0
		end,
		callback = function( plys )
			ROUNDPROP.Set( "next_mtf", ROUNDPROP.Get( "next_mtf" ) - 1 )
		end
	},
	["ci"] = {
		weight = 40,
		spawn = CI_SPAWN,
		roundtype = "default",
		support = true,
		maxplayers = 6,
		max = 1,
		check = function()
			local next_mtf = ROUNDPROP.Get( "next_mtf" )

			return next_mtf != nil and next_mtf > 0
		end,
		callback = function( plys )
			ROUNDPROP.Set( "next_mtf", ROUNDPROP.Get( "next_mtf" ) - 1 )
		end
	},
	["sh"] = {
		weight = 40,
		spawn = CI_SPAWN,
		roundtype = "default",
		support = true,
		maxplayers = 5,
		max = 1,
		check = function()
			local next_mtf = ROUNDPROP.Get( "next_mtf" )

			return next_mtf != nil and next_mtf > 0
		end,
		callback = function( plys )
			ROUNDPROP.Set( "next_mtf", ROUNDPROP.Get( "next_mtf" ) - 1 )
		end
	},
	["cbg"] = {
		weight = 40,
		spawn = CI_SPAWN,
		roundtype = "default",
		support = true,
		maxplayers = 7,
		max = 1,
		check = function()
			local next_mtf = ROUNDPROP.Get( "next_mtf" )

			return next_mtf != nil and next_mtf > 0
		end,
		callback = function( plys )
			ROUNDPROP.Set( "next_mtf", ROUNDPROP.Get( "next_mtf" ) - 1 )
		end
	},
}

CLASSES = {
	/*["yournamehere"] = {
		team = TEAM_SPEC,
		model = "your/model/path.mdl",
		max = 999, -- Must be a higher number than 0
		weps = { "first_weapon", "second_weapon" },
		ammo = { ["357"] = 10 },
		armor = "test_vest",
		inv_slots = 8,
		maxhp = 100,
		hp = 100,
		maxstamina = 100,
		stamina = 100,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
		spawn = Vector( 0, 0, 0 ), -- Overrides spawn
		dynamicspawn = true,
		hands_override = "fp_hands",
		callback = function( ply )
			-- something here
		end,
	},*/
	["classd"] = {
		spawngroup = "classd",
		team = TEAM_CLASSD,
		model = "models/kutarum/scpfp/playermodels/classd.mdl",
		weps = {},
		ammo = {},
		maxhp = 100,
		hp = 100,
		maxstamina = 100,
		stamina = 100,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
	},
	["guard_pacificator"] = {
		spawngroup = "security",
		team = TEAM_SD,
		model = "models/kutarum/scpfp/playermodels/security.mdl",
		weps = { "fp_melee_baton" },
		ammo = {},
		helmet = "security_cap",
		vest = "security_light_vest",
		maxhp = 100,
		hp = 100,
		maxstamina = 100,
		stamina = 100,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
	},
	["cispy"] = {
		spawngroup = "security",
		team = TEAM_CI,
		model = "models/kutarum/scpfp/playermodels/security.mdl",
		max = 1,
		weps = { "fp_melee_baton" },
		ammo = {},
		helmet = "security_cap",
		vest = "security_light_vest",
		maxhp = 120,
		hp = 120,
		maxstamina = 100,
		stamina = 100,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
	},
	["guard"] = {
		spawngroup = "security",
		team = TEAM_SD,
		model = "models/kutarum/scpfp/playermodels/security.mdl",
		helmet = "security_light_helmet",
		vest = "security_medium_vest",
		maxhp = 110,
		hp = 110,
		maxstamina = 100,
		stamina = 100,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "sec" )
		end,
	},
	["guard_storm"] = {
		spawngroup = "security",
		team = TEAM_SD,
		model = "models/kutarum/scpfp/playermodels/security.mdl",
		helmet = "security_heavy_helmet",
		vest = "security_heavy_vest",
		maxhp = 120,
		hp = 120,
		maxstamina = 100,
		stamina = 100,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "sec" )
		end,
	},
	["researcher"] = {
		spawngroup = "personnel",
		team = TEAM_SCI,
		model = "models/kutarum/brichevsk/personnel_models/scientist.mdl",
		weps = {},
		ammo = {},
		maxhp = 100,
		hp = 100,
		maxstamina = 100,
		stamina = 100,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "res" )
		end,
	},
	["gruspy"] = {
		spawngroup = "personnel",
		team = TEAM_GRU,
		model = "models/kutarum/brichevsk/personnel_models/scientist.mdl",
		max = 1,
		weight = 3,
		weps = { "tfa_ins2_wpn_makarovpistol" },
		ammo = {},
		maxhp = 125,
		hp = 125,
		maxstamina = 120,
		stamina = 120,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 225,
		jumppower = 175,
		callback = function( ply )
			ABILITIES.Setup( ply, "gruspycheck" )
			ABILITIES.Setup( ply, "gruspylocate" )

			ply:GiveKeycard( "res" )

			local wep = ply:GetWeapon( "tfa_ins2_wpn_makarovpistol" )

			wep:SetClip1( wep:GetMaxClip1() )
			wep:Attach( "ins2_br_supp" )

			ply:HideHUD( true, true )

			timer.Simple( 3, function()
				ply:HideHUD( false )
			end )
		end,
	},
	["medic"] = {
		spawngroup = "personnel",
		team = TEAM_SCI,
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = {},
		ammo = {},
		maxhp = 100,
		hp = 100,
		maxstamina = 120,
		stamina = 120,
		walkspeed = 135,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 240,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "medic" )
		end,
	},

	----------------------------------------------------
	----------------[[ SUPPORT UNITS ]] ----------------
	----------------------------------------------------

	["ntfsoldier"] = {
		spawngroup = "ntf",
		team = TEAM_MTF,
		model = "models/kutarum/scpfp/playermodels/ntf.mdl",
		weps = { "tfa_ins2_wpn_coltm4a1" },
		ammo = { ["ar2"] = 120 },
		helmet = "ntf_helmet",
		vest = "ntf_vest",
		maxhp = 120,
		hp = 120,
		maxstamina = 140,
		stamina = 140,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 235,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "mtf" )
		end,
	},
	["gocsoldier"] = {
		spawngroup = "goc",
		team = TEAM_GOC,
		model = "models/kutarum/scpfp/playermodels/goc.mdl",
		weps = { "tfa_ins2_wpn_scarhssr" },
		ammo = { ["SniperPenetratedRound"] = 80 },
		helmet = "goc_helmet",
		vest = "goc_vest",
		inv_slots = 12,
		maxhp = 120,
		hp = 120,
		maxstamina = 130,
		stamina = 130,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 230,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "goc" )
		end,
	},
	["grusoldier"] = {
		spawngroup = "gru",
		team = TEAM_GRU,
		model = "models/kutarum/scpfp/playermodels/gru.mdl",
		weps = { "tfa_ins2_wpn_ak9" },
		ammo = { ["ar2"] = 100 },
		helmet = "gru_helmet",
		vest = "gru_vest",
		inv_slots = 12,
		maxhp = 125,
		hp = 125,
		maxstamina = 130,
		stamina = 130,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 230,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "mtf" )
		end,
	},
	["spearsoldier"] = {
		spawngroup = "spear",
		team = TEAM_SPEAR,
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = { "tfa_ins2_wpn_mk14ebr" },
		ammo = { ["ar2"] = 100 },
		helmet = "ntf_helmet",
		vest = "ntf_vest",
		inv_slots = 12,
		maxhp = 125,
		hp = 125,
		maxstamina = 130,
		stamina = 130,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 230,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "mtf" )
		end,
	},
	["cisoldier"] = {
		spawngroup = "ci",
		team = TEAM_CI,
		model = "models/kutarum/scpfp/playermodels/ci.mdl",
		weps = { "tfa_ins2_wpn_mk18cqbr" },
		ammo = { ["ar2"] = 120 },
		helmet = "ci_helmet",
		vest = "ci_vest",
		inv_slots = 12,
		maxhp = 130,
		hp = 130,
		maxstamina = 130,
		stamina = 130,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 230,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "mtf" )
		end,
	},
	["shsoldier"] = {
		spawngroup = "sh",
		team = TEAM_SH,
		model = "models/kutarum/scpfp/playermodels/sh.mdl",
		weps = { "tfa_ins2_wpn_imigalilsar" },
		ammo = { ["ar2"] = 120 },
		helmet = "sh_helmet",
		vest = "sh_vest",
		inv_slots = 12,
		maxhp = 120,
		hp = 120,
		maxstamina = 130,
		stamina = 130,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 230,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "mtf" )

			ABILITIES.Setup( ply, "shmobilize" )
		end,
	},
	["cbgsoldier"] = {
		spawngroup = "cbg",
		team = TEAM_CBG,
		model = "models/kutarum/scpfp/playermodels/cbg.mdl",
		weps = { "tfa_ins2_wpn_hkump45" },
		ammo = { ["pistol"] = 120 },
		helmet = "cbg_mask",
		vest = "cbg_plate_holder",
		inv_slots = 12,
		maxhp = 120,
		hp = 120,
		maxstamina = 130,
		stamina = 130,
		walkspeed = 125,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 230,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "mtf" )
		end,
	},
}

function GetAllClasses()
	return CLASSES
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetFPClass()
	if !self.Get_FPClass then
		self:DataTables()
	end

	return self:Get_FPClass()
end 

function PLAYER:SetFPClass( class )
	if !self.Set_FPClass then
		self:DataTables()
	end

	self:Set_FPClass( class )
end 