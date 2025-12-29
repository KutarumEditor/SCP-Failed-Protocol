function GM:Initialize()
	print( "SCP: FAILED PROTOCOL loaded!" )

	if SERVER then
		RunConsoleCommand( "sv_airaccelerate", "1" )
	end
end

/*hook.Add( "StartCommand", "BotTDM (Funny AF)", function( ply, cmd )
	if !ply:IsBot() then return end

	cmd:ClearMovement() 
	cmd:ClearButtons()

	if !IsValid( ply.CustomEnemy ) then
		for id, pl in ipairs( player.GetAll() ) do
			if !pl:Alive() or pl == ply or FPTeams.IsAlly( pl:FPTeam(), ply:FPTeam() ) then continue end
			ply.CustomEnemy = pl
		end
	end

	if !IsValid( ply.CustomEnemy ) then return end

	cmd:SetForwardMove( ply:GetRunSpeed() )

	if ply.CustomEnemy:IsPlayer() then
		cmd:SetViewAngles( ( ply.CustomEnemy:GetShootPos() - ply:GetShootPos() ):GetNormalized():Angle() )
		ply:SetEyeAngles( ( ply.CustomEnemy:GetShootPos() - ply:GetShootPos() ):GetNormalized():Angle() )
	else
		cmd:SetViewAngles( ( ply.CustomEnemy:GetPos() - ply:GetShootPos() ):GetNormalized():Angle() )
		ply:SetEyeAngles( ( ply.CustomEnemy:GetPos() - ply:GetShootPos() ):GetNormalized():Angle() )
	end

	if SERVER then
		if ply:Alive() and !ply:HasWeapon( "weapon_crowbar" ) then
			ply:Give( "weapon_crowbar" )
		elseif !ply:Alive() then
			ply:StripWeapon( "weapon_crowbar" )
		end
	end

	if ply:HasWeapon( "weapon_crowbar" ) then
		cmd:SelectWeapon( ply:GetWeapon( "weapon_crowbar" ) )
	end

	local buttons = { IN_SPEED }

	local tr = ply:GetEyeTrace()
	if tr.HitPos:Distance( ply:EyePos() ) < 90 and tr.Entity == ply.CustomEnemy then table.insert( buttons, IN_ATTACK ) end

	cmd:SetButtons( bit.bor( unpack( buttons ) ) )

	if !ply.CustomEnemy:Alive() then
		ply.CustomEnemy = nil
	end

end )*/

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
	[HITGROUP_HEAD] = 3,
	[HITGROUP_LEFTARM] = .45,
	[HITGROUP_RIGHTARM] = .45,
	[HITGROUP_LEFTLEG] = .6,
	[HITGROUP_RIGHTLEG] = .6,
}

local ammoPenetration = {
	[3] = 2, --pistol
	[7] = 1, --buckshot
	[5] = 3, --smg1
	[1] = 3, --ar2
	[5] = 4, --357
	[13] = 4, --SniperRound
	[14] = 4, --SniperPenetratedRound
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

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if not SERVER then return end

	if FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN ) then
		local armortbl = GetPartArmor( ply, hitgroup )
		local armorClass, bulletClass = 0, ammoPenetration[dmginfo:GetAmmoType()]
		local defendedAtLeastBySomeShit = false

		for i, armor in ipairs( armortbl ) do
			if armor != nil and armor.durability != 0 then
				local regTbl = REGISTERED_ARMOR[armor.name]
				armorClass = regTbl.class
				local start_dmg = dmginfo:GetDamage()

				dmginfo:ScaleDamage( ( 1 - regTbl.resistance[hitgroup] ) * math.min( 1, bulletClass / armorClass )  )

				if armor.durability != -1 then
					armor.durability = armor.durability - ( start_dmg - dmginfo:GetDamage() )
				end

				if armor.durability == -1 or armor.durability > 0 then
					defendedAtLeastBySomeShit = true
				else
					dmginfo:SetDamage( dmginfo:GetDamage() - armor.durability )

					armor.durability = 0
				end
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
	end
end

function GM:ShouldCollide( ent1, ent2 )
	return true
end

function GM:PlayerPostThink( ply )
	if SERVER then
		local active = ply:GetActiveWeapon()
		for k, v in pairs( ply:GetWeapons() ) do
			if IsValid( v ) and v != active then
				if v.EnableHolsterThink and v.HolsterThink then
					v:HolsterThink()
				end
			end
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