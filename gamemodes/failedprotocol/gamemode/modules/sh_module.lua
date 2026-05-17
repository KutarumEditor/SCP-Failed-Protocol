local math = math

function GM:Initialize()
	print( "SCP: FAILED PROTOCOL loaded!" )

	if SERVER then
		RunConsoleCommand( "sv_airaccelerate", "1" )
	end
end

local headGibbingAmmoTypes = {
	["SniperPenetratedRound"] = true,
	["buckshot"] = true,
	["357"] = true,
}
function HeadGib( ent, dmg )
	ent:ManipulateBoneScale( ent:LookupBone( "ValveBiped.Bip01_Head1" ), Vector( .01, .01, .01 ) )
	if CLIENT then
		local effectdata = EffectData()
		effectdata:SetOrigin( ent:GetBonePosition( ent:LookupBone( "ValveBiped.Bip01_Head1" ) ) )
		util.Effect( "HL1Gib", effectdata )
	end
end

local hitGroupDamage = {
	[HITGROUP_HEAD] = 4,
	[HITGROUP_LEFTARM] = .45,
	[HITGROUP_RIGHTARM] = .45,
	[HITGROUP_LEFTLEG] = .6,
	[HITGROUP_RIGHTLEG] = .6,
}

local function GetPartArmor( ply, hg )
	local armorTbl = {}
	
	for k, v in pairs( ply.FPArmor ) do
		if v.name == nil then continue end

		if REGISTERED_ARMOR[v.name].resistance[hg] != nil then
			armorTbl[#armorTbl + 1] = v
		end
	end

	return armorTbl
end

function DoImpactEffect( hitpos, attacker )
	local normal = hitpos - attacker:GetPos()
	normal:Normalize()

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetNormal( normal )
	util.Effect( "MetalSpark", effectdata )
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if not SERVER then return end

	if FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN ) then
		local armortbl = GetPartArmor( ply, hitgroup )
		local armorClass, bulletClass = 0, GetFPAmmoPiercing( game.GetAmmoName( dmginfo:GetAmmoType() ) )
		local defendedAtLeastBySomeShit = false

		for i, armor in ipairs( armortbl ) do
			if armor != nil and armor.durability != 0 then
				local regTbl = REGISTERED_ARMOR[armor.name]
				armorClass = regTbl.class
				local start_dmg = dmginfo:GetDamage()
				if bulletClass <= armorClass then
					dmginfo:ScaleDamage( ( 1 - regTbl.resistance[hitgroup] ) * math.min( 1, bulletClass / armorClass )  )
				end

				if armor.durability != -1 then
					armor.durability = armor.durability - ( start_dmg - dmginfo:GetDamage() )
				end

				if armor.durability == -1 or armor.durability > 0 then
					defendedAtLeastBySomeShit = true
				else
					dmginfo:SetDamage( dmginfo:GetDamage() - armor.durability )

					armor.durability = 0
				end

				DoImpactEffect( dmginfo:GetDamagePosition(), dmginfo:GetAttacker() )
			end
		end

		dmginfo:ScaleDamage( hitGroupDamage[hitgroup] or 1 )

		if hitgroup == HITGROUP_HEAD and ( !defendedAtLeastBySomeShit or bulletClass > armorClass ) then
			dmginfo:ScaleDamage( 3 )
		end

		dmginfo:SetDamage( math.ceil( dmginfo:GetDamage() ) )

		net.Start( "FPArmor" )
			net.WritePlayer( ply )
			net.WriteTable( ply.FPArmor )
		net.Broadcast()
	else
		dmginfo:ScaleDamage( .5 )
	end
end

function GM:ShouldCollide( ent1, ent2 )
	return true
end

hook.Add( "CanArmorRegen", "SCPArmorRegen", function( ply )
	return ply:FPTeam() == TEAM_SCP
end )

function GM:PlayerPostThink( ply )
	if SERVER then
		local active = ply:GetActiveWeapon()
		for k, v in ipairs( ply:GetWeapons() ) do
			if IsValid( v ) and v != active then
				if v.EnableHolsterThink and v.HolsterThink then
					v:HolsterThink()
				end
			end
		end

		if hook.Run( "CanArmorRegen", ply ) then
			ply.nextArmorRegen = ply.nextArmorRegen or 0

			local ct, arm, maxarm = CurTime(), ply:Armor(), ply:GetMaxArmor()
			if arm < maxarm and ply.nextArmorRegen < ct then
				ply:SetArmor( math.min( arm + 1, maxarm ) )
				ply.nextArmorRegen = ct + .025
			end
		end

		local et = ply:GetProperty( "FPDisguise", {
			0,
			0
		} )
		if et[1] != -1 and et[1] != 0 and CurTime() > et[1] then
			ply:Undisguise()
		end
	end
end

function GetDeadPlayers()
	local tbl = {}

	for i, ply in ipairs( player.GetAll() ) do
		if not ply:Alive() then
			table.insert( tbl, ply )
		end
	end

	return tbl
end

function AutoComplete( cmd, args, ... )
	local possibleArgs = { ... }
	local autoCompletes = {}

	local arg = string.Split( args:TrimLeft(), " " )

	local lastItem = nil
	for i, str in pairs( arg ) do
		if ( str == "" && ( lastItem && lastItem == "" ) ) then table.remove( arg, i ) end
		lastItem = str
	end

	local numArgs = #arg
	local lastArg = table.remove( arg, numArgs )
	local prevArgs = table.concat( arg, " " )
	if ( #prevArgs > 0 ) then prevArgs = " " .. prevArgs end

	local possibilities = possibleArgs[ numArgs ] or { lastArg }
	for _, acStr in pairs( possibilities ) do
		if ( !acStr:StartsWith( lastArg ) ) then continue end
		table.insert( autoCompletes, cmd .. prevArgs .. " " .. acStr )
	end
		
	return autoCompletes
end