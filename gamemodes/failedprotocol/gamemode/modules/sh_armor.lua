REGISTERED_ARMOR = {
	["test_vest"] = {
		type = "vest",
		floor_model = "models/kutarum/scpfp/vests/security_vest_heavy.mdl",
		model = "models/kutarum/scpfp/vests/security_vest_heavy.mdl",
		durability = 200,
		resistance = {
			[HITGROUP_CHEST] = .65,
			[HITGROUP_STOMACH] = .65,
			[HITGROUP_GENERIC] = 1,
		},
		class = 2,
	},
	["test_helmet"] = {
		type = "helmet",
		floor_model = "models/kutarum/scpfp/helmets/security_helmet_heavy.mdl",
		model = "models/kutarum/scpfp/helmets/security_helmet_heavy.mdl",
		durability = 100,
		resistance = {
			[HITGROUP_HEAD] = .35,
		},
		class = 2,
	},
	["security_cap"] = {
		type = "helmet",
		floor_model = "models/kutarum/scpfp/helmets/security_cap.mdl",
		model = "models/kutarum/scpfp/helmets/security_cap.mdl",
		durability = 100,
		resistance = {},
		class = 0,
	},
	["security_light_helmet"] = {
		type = "helmet",
		floor_model = "models/kutarum/scpfp/helmets/security_helmet_light.mdl",
		model = "models/kutarum/scpfp/helmets/security_helmet_light.mdl",
		durability = 50,
		resistance = {
			[HITGROUP_HEAD] = .15,
		},
		class = 2,
	},
	["security_heavy_helmet"] = {
		type = "helmet",
		floor_model = "models/kutarum/scpfp/helmets/security_helmet_heavy.mdl",
		model = "models/kutarum/scpfp/helmets/security_helmet_heavy.mdl",
		durability = 75,
		resistance = {
			[HITGROUP_HEAD] = .3,
		},
		class = 2,
	},
	["sigma_helmet"] = {
		type = "helmet",
		floor_model = "models/kutarum/scpfp/helmets/security_helmet_heavy.mdl",
		model = "models/kutarum/scpfp/helmets/security_helmet_heavy.mdl",
		durability = 300,
		resistance = {
			[HITGROUP_HEAD] = .5,
		},
		class = 5,
	},
	["security_light_vest"] = {
		type = "vest",
		floor_model = "models/kutarum/scpfp/vests/security_vest_light.mdl",
		model = "models/kutarum/scpfp/vests/security_vest_light.mdl",
		durability = 150,
		resistance = {
			[HITGROUP_CHEST] = .3,
			[HITGROUP_STOMACH] = .3,
			[HITGROUP_GENERIC] = 1,
		},
		class = 2,
	},
	["security_medium_vest"] = {
		type = "vest",
		floor_model = "models/kutarum/scpfp/vests/security_vest_medium.mdl",
		model = "models/kutarum/scpfp/vests/security_vest_medium.mdl",
		durability = 200,
		resistance = {
			[HITGROUP_CHEST] = .3,
			[HITGROUP_STOMACH] = .3,
			[HITGROUP_RIGHTARM] = .5,
			[HITGROUP_LEFTARM] = .5,
			[HITGROUP_GENERIC] = 1,
		},
		class = 2,
	},
	["security_heavy_vest"] = {
		type = "vest",
		floor_model = "models/kutarum/scpfp/vests/security_vest_heavy.mdl",
		model = "models/kutarum/scpfp/vests/security_vest_heavy.mdl",
		durability = 250,
		resistance = {
			[HITGROUP_CHEST] = .3,
			[HITGROUP_STOMACH] = .45,
			[HITGROUP_RIGHTARM] = .5,
			[HITGROUP_LEFTARM] = .5,
			[HITGROUP_RIGHTLEG] = .5,
			[HITGROUP_LEFTLEG] = .5,
			[HITGROUP_GENERIC] = 1,
		},
		class = 3,
	},
	["sigma_vest"] = {
		type = "vest",
		floor_model = "models/kutarum/scpfp/vests/security_vest_heavy.mdl",
		model = "models/kutarum/scpfp/vests/security_vest_heavy.mdl",
		durability = 300,
		resistance = {
			[HITGROUP_CHEST] = .5,
			[HITGROUP_STOMACH] = .5,
			[HITGROUP_RIGHTARM] = .5,
			[HITGROUP_LEFTARM] = .5,
			[HITGROUP_RIGHTLEG] = .5,
			[HITGROUP_LEFTLEG] = .5,
			[HITGROUP_GENERIC] = 1,
		},
		class = 5,
	},
}

local PLAYER = FindMetaTable( "Player" )

if SERVER then

function PLAYER:SetFPArmor( type, id, dur )
	self.FPArmor[type] = { 
		name = id,
		durability = dur,
	}
	net.Start( "FPArmor" )
		net.WritePlayer( self )
		net.WriteTable( self.FPArmor )
	net.Broadcast()

	if id != nil and REGISTERED_ARMOR[id].model != "" then
		local bm = ents.Create( "fp_bonemerge" )
		bm:SetPos( self:GetPos() )
		bm:SetParent( self )
		bm.ID = id
		bm.Model = REGISTERED_ARMOR[id].model
		bm:Spawn()
	else
		local bms = ents.FindByClassAndParent( "fp_bonemerge", self )
		if istable( bms ) then
			for k, v in pairs( bms ) do
				if v.ID == self.FPArmor[type].name then
					v:SetOwner()
					v:Remove()
				end
			end
		end
	end
end

function PLAYER:DropArmor( type, silent )
	if self.FPArmor[type].name == nil then return end

	local bms = ents.FindByClassAndParent( "fp_bonemerge", self )
	if istable( bms ) then
		for k, v in pairs( bms ) do
			if v.ID == self.FPArmor[type].name then
				v:SetOwner()
				v:Remove()
			end
		end
	end

	if not silent then
		self:EmitSound( "crimeville/armor/armor_drop.wav" )
	end

	local armor = ents.Create( "fp_armor" )
	armor:SetPos( self:GetPos() )
	armor:SetAngles( Angle( 0, self:GetAngles().y, 0 ) )
	armor:SetType( self.FPArmor[type].name )
	armor:SetDurability( self.FPArmor[type].durability )
	armor.ArmorType = type
	armor:Spawn()


	self.FPArmor[type] = {
		name = nil,
		durability = 0,
	}
	net.Start( "FPArmor" )
		net.WritePlayer( self )
		net.WriteTable( self.FPArmor )
	net.Broadcast()
end

concommand.Add( "fp_test_armor_spawn", function( ply )
	if not SERVER then return end

	local armor = ents.Create( "fp_armor" )
	armor:SetPos( ply:GetPos() )
	armor:SetAngles( Angle( 0, ply:GetAngles().y, 0 ) )
	--armor:SetFPArmor( "test_vest", 200 )
	armor:SetType( "test_vest" )
	armor:SetDurability( 200 )
	armor:Spawn()
end )

elseif CLIENT then

net.Receive( "FPArmor", function()
	net.ReadPlayer().FPArmor = net.ReadTable()
end )

end