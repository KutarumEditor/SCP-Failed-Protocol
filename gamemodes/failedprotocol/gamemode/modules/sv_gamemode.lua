local buttonEnts = {
	["func_button"] = true,
	["func_rot_button"] = true
}

local ACCESS = ACCESS or {}

function GM:PlayerUse( ply, ent )
	ply.useRealBan = ply.useRealBan or 0
	local plyEyeTrace = ply:GetEyeTrace()

	if istable( ENTITY_ACTIONS_OVERRIDE[ent:GetClass()] ) then return false end

	if ent:IsWeapon() and ply:EyePos():Distance( plyEyeTrace.HitPos ) < 100 and plyEyeTrace.Entity == ent and ply:CanPickup( ent ) then
		ply:TimedTask( "weapon_equip", 1, Color( 200, 155, 0 ),
	    function()
	        return IsValid( ent ) and IsValid( ply ) and
	            ply:EyePos():Distance( ent:GetPos() ) < 100 and plyEyeTrace.Entity == ent
	    end, function()
	        ply:PickupWeapon( ent )
	    end )
	end

	local ent_id = ent:EntIndex()
	if buttonEnts[ent:GetClass()] then
		if ply.useRealBan > CurTime() or not ply.depressedUse then
			ply.useRealBan = CurTime() + FrameTime() * 2
			return false
		end

		ply.depressedUse = false
		ply.useRealBan = CurTime() + FrameTime() * 3

		if ACCESS.BUTTON_CACHE[ent_id] != nil then
			local kc = ply:GetActiveWeapon()
			if kc:GetClass() != "fp_keycard" then
				ent:EmitSound( "scpfp/doors/denied.wav", 55, 100, 1, CHAN_ITEM )
				return false
			end

			if kc:GetState() == KEYCARD_USED then
				return ACCESS.CheckKeycardAccess( ent_id, kc:GetKeycard() )
			else
				kc:UseKeycard( ent )

				return false
			end
		end
	end

	return true
end

hook.Add( "KeyRelease", "UseDepresser", function( ply, key )
    if key == IN_USE then
        ply.depressedUse = true
    end
end )

local dmgCallback = {
	[DMG_BULLET] = function( ent, dmginfo )
		timer.Simple( 0, function()
			ent:EmitSound( "scpfp/humans/hit_sounds/hit"..FPRandom( 1, 3 )..".wav" )
		end )
	end,
	[DMG_NERVEGAS] = function( ent, dmginfo )
		timer.Simple( 0, function()
			ent:EmitSound( "scpfp/humans/cough/cough"..FPRandom( 1, 4 )..".wav" )
		end )
	end,
}

function GM:EntityTakeDamage( ent, dmginfo )
	if not ent:IsPlayer() then return end

	local dmgType = dmginfo:GetDamageType()
	if dmgCallback[dmgType] != nil then
		dmgCallback[dmgType]( ent, dmginfo )
	end

	ent.nextArmorRegen = CurTime() + 10

	dmginfo:SetDamageForce( Vector( 0, 0, 0 ) )

	ent:ViewPunch( Angle( 0, 0, FPRandom() > .5 and 2.5 or -2.5 ) )

	net.Start( "DamageBlur" )
		net.WriteFloat( dmginfo:GetDamage() )
	net.Send( ent )
end

local ignore_tbl = {
	["SCP0492"] = true,
}

function SCPCount()
	local tbl = {}

	for i, ply in player.Iterator() do
		if ply:FPTeam() == TEAM_SCP and ignore_tbl[ply:GetFPClass()] != true then
			tbl[ply:GetFPClass()] = true
		end
	end

	return #table.GetKeys( tbl )
end