SWEP.Base = "fp_melee_base"

SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/kutarum/scpfp/c_034.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/kutarum/scpfp/w_034.mdl"
SWEP.ShouldDrawWM = false

SWEP.AutoSwitchTo = true
SWEP.Weight = 1

SWEP.Damage = { 33, 40 }
SWEP.DamageType = DMG_SLASH
SWEP.Cooldown = .25

SWEP.HoldType = "knife"

SWEP.Sounds = {
	Draw = "expbat_draw",
	Swing = "common_swing",
	HitWall = "common_hit",
	HitFlesh = "blunt_flesh_hit"
}

SWEP.AnimSpeed = {
	Draw = .5,
	Idle = 1,
	Attack = .75
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
		punch = Angle( 0, 5, 5 )
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

	if hit then
		local victim = tr.Entity
		if IsValid( victim ) then
			local oldvel = victim:GetVelocity()

			local dmg = math.random( self.Damage[1], self.Damage[2] )

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
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	local vm = ply:GetViewModel()

	vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( math.random( 1, 100 ) > 50 and ACT_VM_PRIMARYATTACK_2 or ACT_VM_PRIMARYATTACK_1 ) )
	vm:SetPlaybackRate( self.AnimSpeed.Attack )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local time = vm:SequenceDuration( vm:GetSequence() )

	self:SetNextPrimaryFire( CurTime() + time + self.Cooldown )
	self:SetNextSecondaryFire( CurTime() + time + self.Cooldown )

	timer.Simple( .01, function()
		if IsValid( ply ) and ply:GetActiveWeapon() == self then
			self:EmitSound( self.Sounds.Swing )
		end

		timer.Simple( .25, function()
			if IsValid( ply ) and ply:GetActiveWeapon() == self then
				if SERVER then
					self:CalcHit()
				end
			end
		end )
	end )
end

function SWEP:SecondaryAttack()

end

function SWEP:Think()
	local ply = self.Owner
	local vm = ply:GetViewModel()

	if vm:IsSequenceFinished() then
		if istable( anim_tbl[vm:GetSequenceActivity( vm:GetSequence() )] ) then
			return
		end

		vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( ACT_VM_IDLE ) )
		vm:SetPlaybackRate( self.AnimSpeed.Idle )
	end
end