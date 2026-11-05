SWEP.Base = "fp_swep_base"

SWEP.ViewModel = "models/kutarum/scpfp/medicine/c_vicodin.mdl"
SWEP.WorldModel = "models/kutarum/scpfp/w_walkie.mdl"
SWEP.ViewModelFOV = 90
SWEP.HoldType = "slam"

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 1, "Usages" )
	self:SetUsages( 3 )
end

function SWEP:CustomInit()
	if CLIENT then
		self.PrintName = LANG.Get( "WEP", self:GetClass(), "name" )
	end
end

function SWEP:PlayAnim( act )
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( act ) )
end

function SWEP:WepIsCur()
	local ply = self.Owner
	return ply:IsValid() and ply:Alive() and ply:GetActiveWeapon() == self
end

function SWEP:PrimaryAttack()
	local usages = self:GetUsages()
	local ply = self.Owner
	if not ply:IsValid() or not ply:Alive() then return end

	self:SetNextPrimaryFire( CurTime() + 1 )

	if usages > 1 and ply:GetFPClass() != "cbgpsycho" then
    	self:PlayAnim( ACT_VM_PRIMARYATTACK )

		self:EmitSound( "scpfp/pills/usage.wav" )

		timer.Simple( .4, function()
			if self:WepIsCur() then
				self:EmitSound( "scpfp/pills/deploy.wav" )
			end
		end )

		TIMERS.Create( ply:SteamID64().."_Pills_Consumption", .8, function()
			if self:WepIsCur() then
				ply:EmitSound( "scpfp/pills/swallow.wav" )

				if ply:HasEffect("narcosis") then
					ply:ApplyEffect("overdose")
				end
				ply:ApplyEffect("painblock")
				ply:ApplyEffect("narcosis")
				self:SetUsages( usages - 1 )
			end
		end, false )
	else
		self:PlayAnim( ACT_VM_SECONDARYATTACK )

		self:EmitSound( "scpfp/pills/usage.wav" )

		if CLIENT and LocalPlayer():GetFPClass() == "cbgpsycho" then
			PHRASES.PopUp( "cbgpsycho", table.Random( {
				"usage1",
				"usage2",
				"usage3",
			} ), 1.5 )
		end

		timer.Simple( .3, function()
			if self:WepIsCur() then
				self:EmitSound( "scpfp/pills/deploy.wav" )
			end
		end )

		TIMERS.Create( ply:SteamID64().."_Pills_Consumption", .8, function()
			if self:WepIsCur() then
				ply:EmitSound( "scpfp/pills/swallow.wav" )

				if ply:GetFPClass() == "cbgpsycho" then
					if SERVER then
						ply:RemoveEffect( "withdrawal" )
						ply:RemoveEffect( "calm" )
						ply:StartTrip( FPRandom( 3 ) == 3 and "horror" or table.Random( {
							"drumnbass",
						} ) )
					end
				else
					if ply:HasEffect("narcosis") then
						ply:ApplyEffect("overdose")
					end
				end
				
				ply:ApplyEffect("painblock")
				ply:ApplyEffect("narcosis")
				timer.Simple( .2, function()
					if SERVER then
						self:Remove()
					end
				end )
			end
		end, false )
	end
end

function SWEP:SecondaryAttack()
	--self:PlayAnim( ACT_VM_SECONDARYATTACK )
end

function SWEP:Reload()
	--
end

SWEP.TPIKForce = true
SWEP.TPIK_DisableLeftHand = false
SWEP.TPIKPos = Vector( 5, -3, 4 )
SWEP.TPIKHideBones = {"cap"}

function SWEP:Think()
    local ply = self.Owner
	local vm = ply:GetViewModel()

	if vm:IsSequenceFinished() then
		vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( ACT_VM_IDLE ) )
		vm:SetPlaybackRate( 1 )
	else
		local seq = vm:GetSequence()
		if seq != 0 then
			self.TPIK_DisableLeftHand = false
		else
			self.TPIK_DisableLeftHand = true
		end
	end
end

function SWEP:Deploy()
	if !self:IsValid() then return end

	self:SetNextPrimaryFire( CurTime() + 1 )

    self:PlayAnim( ACT_VM_DRAW )

	self:EmitSound( "scpfp/pills/deploy.wav" )

	timer.Simple( .3, function()
		if self:WepIsCur() then
			self:EmitSound( "scpfp/pills/open.wav" )
		end
	end )

	return true
end

function SWEP:Holster( wep )
	return true
end

if CLIENT then

local downedSeqs = {
	[0] = true,
	[3] = true
}

local downRatio = 1
function SWEP:GetViewModelPosition( EyePos, EyeAng )
	local ft = FrameTime()
	local vm = LocalPlayer():GetViewModel()
	if downedSeqs[vm:GetSequence()] == true then
		downRatio = math.min( 1, downRatio + ft/3 )
	else
		downRatio = math.max( 0, downRatio - ft/3 )
	end

	local newPos = EyePos + EyeAng:Up() * -3 * math.ease.InOutCirc( downRatio )

	return newPos, EyeAng
end

end