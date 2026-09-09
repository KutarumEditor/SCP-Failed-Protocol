SWEP.Base = "fp_melee_base"

SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/kutarum/scpfp/c_baton.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.ShouldDrawWM = false

SWEP.AutoSwitchTo = false
SWEP.Weight = 1

SWEP.Damage = { 20, 40 }
SWEP.DamageType = DMG_CLUB
SWEP.Cooldown = .25

SWEP.HoldType = "knife"

SWEP.Sounds = {
	Draw = "expbat_draw",
	Swing = "common_swing",
	HitWall = "common_hit",
	HitFlesh = "blunt_flesh_hit"
}

SWEP.AnimSpeed = {
	Draw = .75,
	Idle = .5,
	Attack = 1
}

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

hook.Add( "FPMeleeOnHit", "GuardBaton", function( attacker, victim, dmg )
	if victim:IsPlayer() and victim:Alive() and ( attacker:GetFPClass() == "guard_pacificator" or attacker:GetFPClass() == "cispy" ) then
		victim:DropWep( victim:GetActiveWeapon() )
	end
end )

SWEP.TPIKForce = true
SWEP.TPIKPos = Vector( 0, 0, 0 )
SWEP.TPIK_DisableLeftHand = true