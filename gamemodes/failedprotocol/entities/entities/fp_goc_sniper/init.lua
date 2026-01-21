AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:FindNewTarget()
	local tbl = {}

	for i, ent in ipairs( ents.FindInSphere( self:GetPos(), self.Radius ) ) do
		if ent:IsPlayer() and ent:Alive() and ent:FPTeam() != TEAM_GOC then
			table.insert( tbl, { ent, ent:GetPos():Distance( self:GetPos() ) } )
		end
	end

	if #tbl == 0 then return nil end

	table.sort( tbl, function( a, b ) return a[2] < b[2] end )

	return tbl[1][1]
end

function ENT:ShotEffects( tr )
	local ang = tr.Normal:Angle()

	ParticleEffect( "muzzleflash_m24", self:GetPos(), ang )

	net.Ping( "GOCSniperMuzzleflash", tostring( self:EntIndex() ) )
end

function ENT:Shoot( target )
	local lethal = self:GetAggressive()

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = target:GetPos() + target:OBBCenter(),
	} )

	self:EmitSound( "scpfp/gocsniper/shot.wav", 140, 100, 1, CHAN_AUTO )

	self:ShotEffects( tr )

	local dmg = DamageInfo()
	dmg:SetDamage( lethal and target:Health() or target:GetMaxHealth() / 4 )
	dmg:SetDamageType( DMG_BULLET )
	target:TakeDamageInfo( dmg )

	local newtar = self:FindNewTarget()
	if IsValid( newtar ) then
		self:SetTarget( newtar )
	end
end

local phraseTbl = {
	{ "scpfp/gocsniper/warning1.wav" },

}

function ENT:SpeakPhrase( snd, speaker, phrase )
	for i, v in ipairs( ents.FindInSphere( self:GetPos(), self.Radius * 3/2 ) ) do
		if v:IsPlayer() then
			PHRASES.Cast( v, snd, speaker, phrase )
		end
	end
end

function ENT:Think()
	local nextThink = 3
	local triggered = self:GetTriggered()
	local aggressive = self:GetAggressive()

	if not triggered then
		local newtar = self:FindNewTarget()

		if IsValid( newtar ) then
			nextThink = 5
			local n = FPRandom( 1, 2 )
			self:SpeakPhrase( "scpfp/gocsniper/warning"..n..".wav", "gocsniper", "warning"..n )
			self:SetTriggered( true )
			self:SetTarget( newtar )
		end
	else
		::shot::

		local newtar = self:FindNewTarget()
		local target = self:GetTarget()

		if IsValid( target ) and target == newtar then
			if aggressive then
				self:Shoot( target )
			else
				local n = FPRandom( 1, 2 )
				self:SpeakPhrase( "scpfp/gocsniper/fire"..n..".wav", "gocsniper", "fire"..n )
				self:Shoot( target )
				self:SetAggressive( true )
			end
		else
			if IsValid( newtar ) then
				self:SetTarget( newtar )
				goto shot
			else
				self:SetTarget( nil )
				self:SetTriggered( false )
				self:SetAggressive( false )
			end
		end
	end

	self:NextThink( CurTime() + nextThink )

	return true
end