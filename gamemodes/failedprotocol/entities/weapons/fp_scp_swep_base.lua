SWEP.Base = "fp_swep_base"

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawWM = false
SWEP.SwayScale = 2
SWEP.BobScale = 2

SWEP.AutoSwitchTo = true
SWEP.Weight = 1

SWEP.Damage = 45
SWEP.DamageType = DMG_SLASH

SWEP.HoldType = "melee"

function SWEP:Animator()
	return true
end