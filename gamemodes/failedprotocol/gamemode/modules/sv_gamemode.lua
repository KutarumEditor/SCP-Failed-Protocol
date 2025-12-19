local buttonEnts = {
	["func_button"] = true,
	["func_rot_button"] = true
}

function GM:PlayerUse( ply, ent )
	if istable( ENTITY_ACTIONS_OVERRIDE[ent:GetClass()] ) then return false end

	if ent:IsWeapon() and ply:EyePos():Distance( ent:GetPos() ) < 100 and ply:GetEyeTrace().Entity == ent and PickUpCheck( ply, ent ) then
		ply:TimedTask( "weapon_equip", 1, Color( 200, 155, 0 ),
	    function()
	        return IsValid( ent ) and IsValid( ply ) and
	            ply:EyePos():Distance( ent:GetPos() ) < 100 and ply:GetEyeTrace().Entity == ent
	    end, function()
	        ply:PickupWeapon( ent )
	    end )
	end

	local ent_id = ent:EntIndex()
	if buttonEnts[ent:GetClass()] and ACCESS.BUTTON_CACHE[ent_id] != nil then
		local kc = ply:GetActiveWeapon()
		if kc:GetClass() != "fp_keycard" then return false end

		if kc:GetState() == KEYCARD_USED then
			return ACCESS.CheckKeycardAccess( ent_id, kc:GetKeycard() )
		else
			kc:UseKeycard( ent )

			return false
		end
	end

	return true
end

local dmgCallback = {
	[DMG_BULLET] = function( ent, dmginfo )
		timer.Simple( 0, function()
			ent:EmitSound( "crimeville/humans/hit_sounds/hit"..FPRandom( 1, 3 )..".wav" )
		end )
	end,
	[DMG_NERVEGAS] = function( ent, dmginfo )
		timer.Simple( 0, function()
			ent:EmitSound( "crimeville/humans/cough/cough"..FPRandom( 1, 4 )..".wav" )
		end )
	end,
}

function GM:EntityTakeDamage( ent, dmginfo )
	if not ent:IsPlayer() then return end

	local dmgType = dmginfo:GetDamageType()
	if dmgCallback[dmgType] != nil then
		dmgCallback[dmgType]( ent, dmginfo )
	end

	dmginfo:SetDamageForce( Vector( 0, 0, 0 ) )

	ent:ViewPunch( Angle( 0, 0, FPRandom() > .5 and 2.5 or -2.5 ) )

	net.Start( "DamageBlur" )
		net.WriteFloat( dmginfo:GetDamage() )
	net.Send( ent )
end