function GM:ScaleNPCDamage( npc, hitgroup, dmginfo )
	-- HeadGib( npc, dmginfo:GetDamage() )
end

function GM:HandlePlayerArmorReduction( ply, dmginfo )
	if ( ply:Armor() <= 0 || bit.band( dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION ) != 0 ) then return end

	local pntr = dmginfo:GetDamage() - ply:Armor()

	ply:SetArmor( math.max( ply:Armor() - dmginfo:GetDamage(), 0 ) )

	if pntr > 0 then
		dmginfo:SetDamage( pntr )
	else
		dmginfo:SetDamage( 0 )
	end
end

function GM:PlayerDeathSound( ply )
	if FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN ) then
		ply:EmitSound( "crimeville/humans/death_screams/death"..FPRandom( 1, 38 )..".mp3" )
	end

	return true
end

local kill_overrides = {
	["maniac"] = function( killer, victim, mult )
		return 250 * mult
	end,
	["privinvest"] = function( killer, victim, mult )
		return -250 * mult
	end,
	["vigilante"] = function( killer, victim, mult )
		return ( victim:FPTeam() == TEAM_CRIM or victim:GetFPClass() == "maniac" ) and 250 * mult or -400 * mult
	end,
	["syndicalist"] = function( killer, victim, mult )
		return victim:FPTeam() == TEAM_CIV and -200 or ply:FPTeam() == TEAM_LAW and 400 * mult or ply:IsAlly( attacker ) and -400 * mult or 250 * mult
	end,
}

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	ply:ScreenFade( SCREENFADE.IN, color_white, .25, 0 )
	local wep = ply:GetActiveWeapon()

	if wep.Droppable then
        ply:DropWeapon( wep )
    end

	ply:RemoveEffect()
	
	ABILITIES.Clear( ply )

	timer.Simple( 5, function()
		if IsValid( ply ) and !ply:Alive() and ply:FPTeam() != TEAM_SPEC then
			ply:SetupSpectator()
		end
	end )

	if ( !dmginfo:IsDamageType( DMG_REMOVENORAGDOLL ) ) then
		local rag = ply:CreatePlayerRagdoll()

		local armor = ply.FPArmor
		rag:SetNWString( "vestType", armor.vest.name )
		rag:SetNWFloat( "vestDur", armor.vest.durability )
		rag:SetNWString( "helmetType", armor.helmet.name )
		rag:SetNWFloat( "helmetDur", armor.helmet.durability )

		ply:SetFPArmor( "vest", nil, 0 )
		ply:SetFPArmor( "helmet", nil, 0 )

		local bms = ents.FindByClassAndParent( "fp_bonemerge", ply )
		if istable( bms ) then
			for i, v in ipairs( bms ) do
				local bm = ents.Create( "fp_bonemerge" )
				bm:SetPos( rag:GetPos() )
				bm.Model = v.Model
				bm:SetParent( rag )
				bm.ID = v.ID
				bm:Spawn()

				v:SetOwner()
				v:Remove()
			end
		end
	end

	ply:SetDSP( FPRandom( 35, 37 ), false )

	ply:AddDeaths( 1 )

	ply:SetFPName( "John" )
	ply:SetFPSurname( "Doe" )

	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		local mult = FPTeams.GetReward( ply:FPTeam() )
		local score = isfunction( kill_overrides[attacker:GetFPClass()] ) and kill_overrides[attacker:GetFPClass()]( attacker, ply, mult ) or ply:IsAlly( attacker ) and -400 * mult or 250 * mult

		local scoreTeam = attacker:GetScoreTeam()
		if attacker == ply then
			if attacker:Frags() > 0 then
				attacker:AddFrags( -1 )
			end

			AddScore( scoreTeam, attacker, -250 )
		else
			attacker:AddFrags( 1 )

			AddScore( scoreTeam, attacker, score )

			if not ply:IsAlly( attacker ) then
				AddScore( ply:GetScoreTeam(), ply, -( score / 2 ) )
			end
		end
	end
end

function GM:PlayerDeathThink( ply )

end

function GM:PostPlayerDeath( ply )
	--RoundEndCheck()
end

function GM:PlayerCanPickupWeapon( ply, wep ) -- OBSOLETE, cuz of other pickup system
	return wep:GetPos():Distance( ply:GetPos() ) == 0
end

function GM:PlayerCanSeePlayersChat( txt, team, l, s )
	if speaker == NULL then return true end

	return hook.Run( "PlayerCanHearPlayersVoice", l, s )
end

function GM:PlayerCanHearPlayersVoice( l, t )
	local override, ret2 = hook.Run( "PlayerSpeakOverride", t, l )
	if override != nil then
		return override, ret2
	end

	local t_lis, t_tal = l:FPTeam(), t:FPTeam()
	local c_lis, c_tal = l:GetFPClass(), t:GetFPClass()

	if t_tal == TEAM_SPEC then
		return t_lis == TEAM_SPEC
	elseif c_tal == "homeless" then
		return c_lis == "homeless"
	end

	return false
end

function PickUpCheck( ply, item )
	if item:IsDerived( "fp_hands" ) then
		return true
	end

	local tbl = ply:GetWeapons()

	for _, v in pairs( tbl ) do
		if item:IsDerived( "fp_hands" ) then
			tbl[_] = nil
		end
	end

	return #tbl < ply:GetInvSlots() and not ply:HasWeapon( item:GetClass() )
end

concommand.Add( "bot_full", function( ply, cmd, args, argStr )
	local t = 1
	repeat
		player.CreateNextBot( "Bot"..t )
		t = t + 1
	until #player.GetAll() == game.MaxPlayers()
end )

concommand.Add( "fp_spawn_as", function( ply, cmd, args, argStr )
	local pl = args[2] or ply:Nick()

	for _, v in pairs( player.GetAll() ) do
		if v:Nick() == pl then
			pl = v
		end
	end

	pl:Setup( args[1] )
	pl:PopupStartInfo()
end, function( cmd, args )
	local allPlys = {}
	for _, v in pairs( player.GetAll() ) do
		table.insert( allPlys, v:Nick() )
	end

	return AutoComplete( cmd, args, table.GetKeys( CLASSES ), allPlys )
end )

concommand.Add( "fp_spawn_as_scp", function( ply, cmd, args, argStr )
	local pl = args[2] or ply:Nick()

	for _, v in pairs( player.GetAll() ) do
		if v:Nick() == pl then
			pl = v
		end
	end

	pl:SetupSCP( args[1] )
	pl:PopupStartInfo()
end, function( cmd, args )
	local allPlys = {}
	for _, v in pairs( player.GetAll() ) do
		table.insert( allPlys, v:Nick() )
	end

	return AutoComplete( cmd, args, table.GetKeys( SCPS ), allPlys )
end )

concommand.Add( "fp_change_persona", function( ply, cmd, args, argStr )
	local pl = args[3] or ply:Nick()

	for _, v in pairs( player.GetAll() ) do
		if v:Nick() == pl then
			pl = v
		end
	end

	pl:ChangePersonaManually( args[1], args[2] )
end, function( cmd, args )
	local allPlys = {}
	for _, v in pairs( player.GetAll() ) do
		table.insert( allPlys, v:Nick() )
	end

	return AutoComplete( cmd, args, {}, {}, allPlys )
end )

concommand.Add( "fp_give_money", function( ply, cmd, args, argStr )
	local pl = args[2] or ply:Nick()

	for _, v in pairs( player.GetAll() ) do
		if v:Nick() == pl then
			pl = v
		end
	end

	pl:GiveMoney( args[1] )
end, function( cmd, args )
	local allPlys = {}
	for _, v in pairs( player.GetAll() ) do
		table.insert( allPlys, v:Nick() )
	end

	return AutoComplete( cmd, args, {}, allPlys )
end )

concommand.Add( "fp_test_armor_spawn", function( ply, cmd, args, argStr )
	local armor = ents.Create( "fp_armor" )
	armor:SetPos( ply:GetPos() )
	armor:SetAngles( ply:GetAngles() )
	armor:SetType( "test_vest" )
	armor:SetDurability( 200 )
	armor:Spawn()
end )

concommand.Add( "fp_test_enemy_spawn", function( ply, cmd, args, argStr )
	local s = ents.Create( "npc_combine_s" )

    s:SetPos( ply:GetEyeTrace().HitPos )
    s:Give( "tfa_ins2_akm" )
    s:Spawn()
end )