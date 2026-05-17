SWEP.Base = "fp_swep_base"

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/xoma_x4_items/nh2_bandage.mdl"
SWEP.ShouldDrawWM = true

SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Pin"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(-30, -30, -30), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(-30, -30, -30), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["bandage"] = { type = "Model", model = "models/xoma_x4_items/nh2_bandage.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(1.557, -0.519, -1.558), angle = Angle(-61.949, 10.519, 180), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["bandage"] = { type = "Model", model = "models/xoma_x4_items/nh2_bandage.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.557, 2.596, -1.558), angle = Angle(-75.974, 0, 0), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.UseHands = true

SWEP.HoldType = "slam"

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	
	return true
end

function SWEP:PrimaryAttack()
	self:GetOwner():EmitSound( "scpfp/bandage/apply.mp3" )

	if SERVER then
		self:GetOwner():Heal( 15, { "bleeding" } )

		self:Remove()
	elseif CLIENT then
		input.SelectWeapon( LocalPlayer():GetWeapon( CLASSES[LocalPlayer():GetCVClass()].hands_override or "cv_hands" ) )
	end
end