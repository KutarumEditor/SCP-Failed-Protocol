REGISTERED_EFFECTS = {
	/*["test"] = {
		icon = Material( "" ), -- effect icon
		color = Color( 0, 0, 0 ), -- effect color
		time = 1, -- time of the effect
		max_time = 2, -- max time that can be reached by stacking
		invisible = false, -- Should effect be displayed
		stacks = false, -- false - no stacking, true - time stacking
		think_freq = 2, -- think_func frequency ( in seconds )
		think_func = function( ply ) end, -- Do something once in *think_freq* seconds
		start_func = function( ply ) end, -- Do something just on time of applying effect
		end_check = function( ply ) end, -- A check to end effect instantly
		end_func = function( ply ) end -- Do something after effect wears off
	},*/
	["bleeding"] = {
		icon = Material( "failedprotocol/icons/bleeding.png", "noclamp" ),
		color = Color( 225, 0, 0 ),
		time = 10,
		max_time = 20,
		stacks = true,
		think_freq = 2,
		think_func = function( ply )
			ply:SetDeathReason( "bleed" )

			local dmg = DamageInfo()
			dmg:SetDamage( 3 )
			dmg:SetAttacker( ply )
			dmg:SetInflictor( ply )
			ply:TakeDamageInfo( dmg )
		end
	},
	["pain"] = {
		icon = Material( "failedprotocol/icons/pain.png", "noclamp" ),
		color = Color( 134, 58, 58),
		time = 30,
		max_time = 30,
		stacks = true,
		think_freq = 2,
		think_func = function( ply )
			ply:EmitSound( "scpfp/humans/pain/pain_"..FPRandom( 8 )..".mp3", 90 )
		end,
		start_func = function( ply )
			ply:SetFPWeaponBonus( "recoil", "pain", 1.75 )
			ply:SetFPWeaponBonus( "ergonomics", "pain", .75 )
		end,
		end_check = function( ply )
			return !ply:IsHuman() or ply:HasEffect( "painblock" )
		end,
		end_func = function( ply )
			ply:RemoveFPWeaponBonus( "recoil", "pain" )
			ply:RemoveFPWeaponBonus( "ergonomics", "pain" )
		end,
	},
	["painblock"] = {
		icon = Material( "failedprotocol/icons/painblock.png", "noclamp" ),
		color = Color( 39, 177, 231),
		time = 60,
		max_time = 60,
		stacks = true,
		end_check = function( ply )
			return !ply:IsHuman()
		end,
	},
	["narcosis"] = {
		icon = Material( "failedprotocol/icons/narcosis.png", "noclamp" ),
		color = Color( 85, 84, 107),
		time = 60,
		max_time = 120,
		stacks = true,
		start_func = function( ply )
			ply:SetFPWeaponBonus( "recoil", "narcosis", 1.25 )
			ply:SetFPWeaponBonus( "ergonomics", "narcosis", .9 )
		end,
		end_check = function( ply )
			return !ply:IsHuman()
		end,
		end_func = function( ply )
			ply:RemoveFPWeaponBonus( "recoil", "narcosis" )
			ply:RemoveFPWeaponBonus( "ergonomics", "narcosis" )
		end,
	},
	["overdose"] = {
		icon = Material( "failedprotocol/icons/overdose.png", "noclamp" ),
		color = Color( 49, 32, 32),
		time = 30,
		max_time = 30,
		stacks = false,
		think_freq = 1,
		think_func = function( ply )
			ply:SetDeathReason( "overdose" )

			local dmg = DamageInfo()
			dmg:SetDamage( 10 )
			dmg:SetAttacker( ply )
			dmg:SetInflictor( ply )
			ply:TakeDamageInfo( dmg )
		end,
		end_check = function( ply )
			return !ply:IsHuman()
		end,
	},
	["withdrawal"] = {
		icon = Material( "failedprotocol/icons/withdrawal.png", "noclamp" ),
		color = Color( 68, 68, 68),
		time = -1,
		max_time = -1,
		stacks = false,
		think_freq = 2,
		think_func = function( ply )
			ply:EmitSound( "scpfp/humans/pain/pain_"..FPRandom( 8 )..".mp3", 90 )
		end,
		end_check = function( ply )
			return ply:GetFPClass() != "cbgpsycho"
		end,
	},
	["calm"] = {
		icon = Material( "failedprotocol/icons/calm.png", "noclamp" ),
		color = Color( 146, 146, 146),
		time = 60,
		max_time = 999,
		stacks = false,
		think_freq = 1,
		end_check = function( ply )
			return ply:GetFPClass() != "cbgpsycho"
		end,
		end_func = function( ply )
			ply:ApplyEffect( "withdrawal", -1 )
		end,
	},
	["psycho_rage"] = {
		icon = Material( "failedprotocol/icons/psycho_rage.png", "noclamp" ),
		color = Color( 54, 8, 8),
		time = 999,
		max_time = 999,
		stacks = false,
		think_freq = 1,
		end_check = function( ply )
			return ply:GetFPClass() != "cbgpsycho"
		end,
		end_func = function( ply )
			ply:ApplyEffect( "calm", 150 )
		end,
	},
	["scp207"] = {
		icon = Material( "failedprotocol/icons/overdose.png", "noclamp" ),
		color = Color( 202, 204, 56),
		time = -1,
		max_time = -1,
		stacks = false,
		think_freq = 5,
		think_func = function( ply )
			ply:SetDeathReason( "internalbleeding" )

			local dmg = DamageInfo()
			dmg:SetDamage( 1 )
			dmg:SetDamageType( DMG_DIRECT )
			dmg:SetAttacker( ply )
			dmg:SetInflictor( ply )
			ply:TakeDamageInfo( dmg )
		end,
		start_func = function( ply )
			ply:SetFPWeaponBonus( "recoil", "scp207", .75 )
			ply:SetFPWeaponBonus( "ergonomics", "scp207", 1.5 )
		end,
		end_check = function( ply )
			return !ply:IsHuman()
		end,
		end_func = function( ply )
			ply:RemoveFPWeaponBonus( "recoil", "scp207" )
			ply:RemoveFPWeaponBonus( "ergonomics", "scp207" )
		end,
	},
}

local PLAYER = FindMetaTable( "Player" )

function PLAYER:HasEffect( name )
	local eff_tbl = self:GetProperty( "Effects", {} )

	return istable( eff_tbl[name] )
end

function PLAYER:ApplyEffect( name, time )
	if not SERVER then return end

	local ct = CurTime()
	local eff_data = REGISTERED_EFFECTS[name]
	if eff_data == nil then
		print( "Effect '"..name.."' doesn't exist" )	
	return end

	local eff_tbl = self:GetProperty( "Effects", {} )

	eff_tbl[name] = eff_tbl[name] or {}

	local realTime = isnumber( eff_tbl[name].time )	and eff_data.stacks == true and math.min( ct + ( eff_data.max_time or math.huge ), eff_tbl[name].time + eff_data.time ) or ct + eff_data.time
	if time == -1 then
		realTime = -1
	elseif time != nil then
		realTime = ct + time
	end

	eff_tbl[name].time = realTime
	eff_tbl[name].nextThink = eff_tbl[name].nextThink or isnumber( eff_data.think_freq ) and ct + eff_data.think_freq or 0

	self:SetProperty( "Effects", eff_tbl, true )

	if isfunction( eff_data.start_func ) then
		eff_data.start_func( self )
	end
end

function PLAYER:RemoveEffect( name )
	if not SERVER or not self:HasEffect( name ) then return end

	local eff_tbl = self:GetProperty( "Effects", {} )

	if isstring( name ) then
		eff_tbl[name] = nil
	else
		eff_tbl = {}
	end

	self:SetProperty( "Effects", eff_tbl, true )
end

function PLAYER:CleanEffects( name )
	if not SERVER then return end

	self:SetProperty( "Effects", {}, true )
end

if SERVER then

hook.Add( "Tick", "FPEffectsCalc", function()
	local ct = CurTime()
	for _, ply in player.Iterator() do
		ply.FPProperties = ply.FPProperties or {}
		ply.FPProperties.Effects = ply.FPProperties.Effects or {}

		for k, v in pairs( ply.FPProperties.Effects ) do
			local eff_data = REGISTERED_EFFECTS[k]
			if eff_data.end_check != nil and eff_data.end_check( ply ) == true or not ply:Alive() then
				if isfunction( eff_data.end_func ) then
					eff_data.end_func( ply )
				end

				ply.FPProperties.Effects[k] = nil

				ply:SetProperty( "Effects", ply.FPProperties.Effects, true )
			end

			if ct > v.nextThink then
				if isfunction( eff_data.think_func ) then
					eff_data.think_func( ply )
				end

				v.nextThink = ct + ( eff_data.think_freq or FrameTime() )
			end

			if eff_data.time != -1 and v.time != -1 and ct > v.time then
				if isfunction( eff_data.end_func ) then
					eff_data.end_func( ply )
				end

				ply.FPProperties.Effects[k] = nil

				ply:SetProperty( "Effects", ply.FPProperties.Effects, true )
			end
		end
	end
end )

end