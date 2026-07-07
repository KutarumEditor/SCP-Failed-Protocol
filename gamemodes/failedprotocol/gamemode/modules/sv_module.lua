function GM:ScaleNPCDamage( npc, hitgroup, dmginfo )
	-- HeadGib( npc, dmginfo:GetDamage() )
end

function GM:HandlePlayerArmorReduction( ply, dmginfo )
	local armor = ply:Armor()
	if ( armor <= 0 || bit.band( dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION ) != 0 ) then return end

	local dmg = dmginfo:GetDamage()
	local pntr = dmg - armor

	ply:SetArmor( math.max( armor - dmg, 0 ) )

	if pntr > 0 then
		dmginfo:SetDamage( pntr )
		ply:EmitSound( "scpfp/scp/shield_break.wav" )
	else
		dmginfo:SetDamage( 0 )
	end
end

function GM:PlayerDeathSound( ply )
	if FPTeams.HasInfo( ply:FPTeam(), FPTeams.INFO_HUMAN ) and ply:LastHitGroup() != HITGROUP_HEAD then
		ply:EmitSound( "scpfp/humans/new_death/"..FPRandom( 1, 25 )..".wav" )
	end

	return true
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	ply:ScreenFade( SCREENFADE.IN, color_white, .25, 0 )
	ply:ScreenFade( SCREENFADE.OUT, color_black, 4, 1.1 )
	local wep = ply:GetActiveWeapon()

	if wep.Droppable then
        ply:DropWep( wep )
    end

	ply:RemoveEffect()
	
	ABILITIES.Clear( ply )

	timer.Simple( 5, function()
		if IsValid( ply ) and !ply:Alive() and ply:FPTeam() != TEAM_SPEC then
			ply:SetupSpectator()
			ply:ScreenFade( SCREENFADE.IN, color_black, 5, 0 )
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

	ply:SetDSP( FPRandom( 32, 34 ), false )

	ply:AddDeaths( 1 )

	ply:SetFPName( "John" )
	ply:SetFPSurname( "Doe" )

	net.Ping( "ClientDeath", nil, ply )
end

function GM:PlayerDeath( ply, inf, att )
	local reason = "suicide"
	if att != nil and att != ply then
		reason = "default"
	end

	net.Start( "FPKillfeed" )
		net.WritePlayer( att )
		net.WritePlayer( ply )
		net.WriteEntity( inf )
		net.WriteString( reason )
	net.Broadcast()

	if ply:FPTeam() == TEAM_SCP then return end

	if inf:IsValid() and inf:GetClass() == "fp_melee_034" then
		att:Disguise( ply:GetModel(), 180 )
	end
end

function GM:PlayerDeathThink( ply )

end

function GM:PostPlayerDeath( ply )
	RoundEndCheck()
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
		if v:IsDerived( "fp_hands" ) then
			table.remove( tbl, _ )
		end
	end

	return #tbl < ply:GetInvSlots() and not ply:HasWeapon( item:GetClass() )
end

concommand.Add( "bot_full", function( ply, cmd, args, argStr )
	for i = 1, game.MaxPlayers() - #player.GetAll() do
		AsyncFunc(
			function()
				if SERVER then
					player.CreateNextBot( "Bot"..i )
				end 
			end
		)
	end
end )

concommand.Add( "fp_spawn_as", function( ply, cmd, args, argStr )
	local pl = args[2] or ply:Nick()

	for _, v in pairs( player.GetAll() ) do
		if v:Nick() == pl then
			pl = v
		end
	end

	if not pl:IsReady() then
		print( "Player is not active!" )
		return
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

	if not pl:IsReady() then
		print( "Player is not active!" )
		return
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
    s:Give( "weapon_smg1" )
    s:Spawn()
end )

concommand.Add( "fp_become_serpent", function( ply, cmd, args, argStr )
	ply:SerpentMobilize()
end )

concommand.Add( "fp_detain", function( ply, cmd, args, argStr )
	ply:Detain( ply )
end )

concommand.Add( "fp_undetain", function( ply, cmd, args, argStr )
	ply:Undetain()
end )