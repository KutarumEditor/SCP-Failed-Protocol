SWEP.Base = "fp_swep_base"

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/kutarum/scpfp/c_baton.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.ShouldDrawWM = false
SWEP.SwayScale = 2

SWEP.AutoSwitchTo = true
SWEP.Weight = 1

SWEP.Damage = { 20, 40 }
SWEP.DamageType = DMG_CLUB
SWEP.Cooldown = 2

SWEP.HoldType = "melee"

SWEP.Sounds = {
	Draw = "common_draw",
	Swing = "common_swing",
	HitWall = "common_hit",
	HitFlesh = "blunt_flesh_hit"
}

SWEP.AnimSpeed = {
	Draw = 1,
	Idle = 1,
	Attack = 1
}

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( ACT_VM_DRAW ) )
	vm:SetPlaybackRate( self.AnimSpeed.Draw )

	self:EmitSound( self.Sounds.Draw )

	local time = vm:SequenceDuration( vm:GetSequence() )

	self:SetNextPrimaryFire( CurTime() + time )
	self:SetNextSecondaryFire( CurTime() + time )
end

local anim_tbl = {
	[ACT_VM_PRIMARYATTACK_1] = {
		hit = ACT_VM_HITCENTER,
		miss = ACT_VM_MISSCENTER,
		punch = Angle( 0, 10, -5 )
	},
	[ACT_VM_PRIMARYATTACK_2] = {
		hit = ACT_VM_HITCENTER2,
		miss = ACT_VM_MISSCENTER2,
		punch = Angle( 0, -10, 0 )
	},
}

local flesh_mats = {
	[MAT_ANTLION] = true,
	[MAT_BLOODYFLESH] = true,
	[MAT_FLESH] = true,
	[MAT_ALIENFLESH] = true,
}

function SWEP:CalcHit()
	local ply = self.Owner
	local vm = ply:GetViewModel()
	local curanim = vm:GetSequenceActivity( vm:GetSequence() )
	local vector = ply:GetShootPos() + ply:GetAimVector() * 100
	local sound = self.Sounds.HitWall

	local tr = util.TraceLine( {
		start = ply:GetShootPos(),
		endpos = vector,
		filter = { ply }
	} )
	local hit = tr.Hit

	vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( hit and anim_tbl[curanim].hit or anim_tbl[curanim].miss ) )
	vm:SetPlaybackRate( self.AnimSpeed.Attack )

	local time = self.Cooldown

	self:SetNextPrimaryFire( CurTime() + time )
	self:SetNextSecondaryFire( CurTime() + time )

	if hit then
		local victim = tr.Entity
		if IsValid( victim ) then
			local oldvel = victim:GetVelocity()

			local dmg = FPRandom( self.Damage[1], self.Damage[2] )

			local d = DamageInfo()
			d:SetDamage( dmg )
			d:SetAttacker( ply )
			d:SetInflictor( self )
			d:SetDamageType( self.DamageType )
			d:SetDamagePosition( tr.HitPos )
			d:SetReportedPosition( tr.StartPos )
			d:SetDamageForce( ply:EyeAngles():Forward() * ( dmg * 25 ) )

			victim:TakeDamageInfo( d )

			local newvel = victim:GetVelocity()
			victim:SetVelocity( oldvel - newvel )

			if flesh_mats[tr.MatType] then
				sound = self.Sounds.HitFlesh
			end
		end
	else
		sound = nil
	end

	ply:ViewPunch( anim_tbl[curanim].punch )

	if sound != nil then
		EmitSound( sound, tr.HitPos )
	end

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	local vm = ply:GetViewModel()

	vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( FPRandom( 1, 100 ) > 50 and ACT_VM_PRIMARYATTACK_2 or ACT_VM_PRIMARYATTACK_1 ) )
	vm:SetPlaybackRate( self.AnimSpeed.Attack )

	local time = vm:SequenceDuration( vm:GetSequence() )

	self:SetNextPrimaryFire( CurTime() + time )
	self:SetNextSecondaryFire( CurTime() + time )

	timer.Simple( time/3, function()
		if IsValid( ply ) and ply:GetActiveWeapon() == self then
			self:EmitSound( self.Sounds.Swing )
		end
	end )
end

function SWEP:SecondaryAttack()

end

function SWEP:Think()
	local ply = self.Owner
	local vm = ply:GetViewModel()

	if vm:IsSequenceFinished() then
		if istable( anim_tbl[vm:GetSequenceActivity( vm:GetSequence() )] ) then
			self:CalcHit()
			return
		end

		vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( ACT_VM_IDLE ) )
		vm:SetPlaybackRate( self.AnimSpeed.Idle )
	end
end

function SWEP:DrawWorldModel( flags )
	self:DrawModel( flags )
end