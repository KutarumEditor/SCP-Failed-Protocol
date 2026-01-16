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
		callback = function()
			ROUNDPROP.Set( "next_mtf", 2 )
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
		callback = function()
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
			local next_mtf = ROUNDPROP.Get( "next_mtf" )

			return next_mtf != nil and next_mtf > 0
		end,
		callback = function()
			ROUNDPROP.Set( "next_mtf", ROUNDPROP.Get( "next_mtf" ) - 1 )
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
		callback = function()
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
		callback = function()
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
		callback = function()
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
		callback = function()
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
		start_balance = 0,
		maxhp = 100,
		hp = 100,
		maxsatiety = 100,
		satiety = 100,
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
		model = "models/kutarum/brichevsk/classd_models/classd.mdl",
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
	["guard"] = {
		spawngroup = "security",
		team = TEAM_SD,
		model = "models/kutarum/scpfp/playermodels/security.mdl",
		weps = { "tfa_ins2_wpn_berettam9" },
		ammo = { ["pistol"] = 75 },
		helmet = "security_light_helmet",
		vest = "security_medium_vest",
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
			local wep = ply:GetWeapon( "tfa_ins2_wpn_berettam9" )

			wep:SetClip1( wep:GetMaxClip1() )

			ply:GiveKeycard( "sec" )
		end,
	},
	["guard_storm"] = {
		spawngroup = "security",
		team = TEAM_SD,
		model = "models/kutarum/scpfp/playermodels/security.mdl",
		weps = { "tfa_ins2_wpn_berettam9" },
		ammo = { ["pistol"] = 75 },
		helmet = "security_heavy_helmet",
		vest = "security_heavy_vest",
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
			local wep = ply:GetWeapon( "tfa_ins2_wpn_berettam9" )

			wep:SetClip1( wep:GetMaxClip1() )

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
			ABILITIES.Setup( ply, "grucheck" )
			ABILITIES.Setup( ply, "grulocate" )

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
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = { "tfa_ins2_wpn_coltm4a1" },
		ammo = { ["ar2"] = 120 },
		vest = "test_vest",
		maxhp = 140,
		hp = 140,
		maxstamina = 150,
		stamina = 150,
		walkspeed = 130,
		crouchspeed = 0.5,
		slowwalkspeed = 85,
		runspeed = 240,
		jumppower = 175,
		callback = function( ply )
			ply:GiveKeycard( "mtf" )
		end,
	},
	["gocsoldier"] = {
		spawngroup = "goc",
		team = TEAM_GOC,
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = { "tfa_ins2_wpn_scarhssr" },
		ammo = { ["SniperPenetratedRound"] = 60 },
		armor = "test_vest",
		inv_slots = 12,
		maxhp = 150,
		hp = 150,
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
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = { "tfa_ins2_wpn_ak74izh" },
		ammo = { ["ar2"] = 120 },
		armor = "test_vest",
		inv_slots = 12,
		maxhp = 150,
		hp = 150,
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
		weps = {},
		ammo = {},
		helmet = "sigma_helmet",
		vest = "sigma_vest",
		inv_slots = 12,
		maxhp = 150,
		hp = 150,
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
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = {},
		ammo = {},
		armor = "test_vest",
		inv_slots = 12,
		maxhp = 150,
		hp = 150,
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
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = {},
		ammo = {},
		armor = "test_vest",
		inv_slots = 12,
		maxhp = 150,
		hp = 150,
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
	["cbgsoldier"] = {
		spawngroup = "cbg",
		team = TEAM_CBG,
		model = "models/kutarum/brichevsk/personnel_models/medic.mdl",
		weps = {},
		ammo = {},
		armor = "test_vest",
		inv_slots = 12,
		maxhp = 150,
		hp = 150,
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