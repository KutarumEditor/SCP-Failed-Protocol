SWEP.Base = "fp_swep_base"

SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/kutarum/scpfp/c_keycard.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/kutarum/scpfp/w_keycard.mdl"
SWEP.ShouldDrawWM = false

SWEP.AutoSwitchTo = true
SWEP.Weight = 1

KEYCARD_CALM = 0
KEYCARD_USED = 1

function SWEP:SetupDataTables()
	self:NetworkVar( "String", 0, "Keycard" )
	self:NetworkVar( "Int", 0, "State" )

	self:SetState( KEYCARD_CALM )
end

function SWEP:InitKeycardLang()
	if SERVER then return end

	self.PrintName = LANG.Get( "WEP", self:GetClass() ).name.." - "..LANG.Get( "KEYCARDS", self:GetKeycard() )
end

function SWEP:Initialize()
	self:InitKeycardLang()

	self:DrawShadow( false )

	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()

	vm:SetSkin( ACCESS.KEYCARDS_CACHE[self:GetKeycard()].skin )

	vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( ACT_VM_DRAW ) )
	vm:SetPlaybackRate( 1 )
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:UseKeycard( ent )
	local ply = self.Owner
	local vm = ply:GetViewModel()

	if vm:GetSequence() == 0 then
		vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( ACT_VM_PRIMARYATTACK ) )
		vm:SetPlaybackRate( 1 )

		self:SetState( KEYCARD_USED )

		TIMERS.Create( ply:SteamID64().."KeycardUse", vm:SequenceDuration( vm:GetSequence() ) / 2.5, function()
			local wep = ply:GetActiveWeapon()
			if IsValid( ply ) and IsValid( wep ) and wep == self then
				if ACCESS.CheckKeycardAccess( ent:EntIndex(), wep:GetKeycard() ) then
					ent:Input( "Use", ply, ply )

					ent:EmitSound( "scpfp/doors/granted.wav", 65, 100, 1, CHAN_ITEM )
				else
					ent:EmitSound( "scpfp/doors/denied.wav", 65, 100, 1, CHAN_ITEM )
				end
			end
		end )
	end
end

function SWEP:Think()
	local ply = self.Owner
	local vm = ply:GetViewModel()

	if vm:IsSequenceFinished() then
		vm:SendViewModelMatchingSequence( vm:SelectWeightedSequence( ACT_VM_IDLE ) )
		vm:SetPlaybackRate( 1 )

		self:SetState( KEYCARD_CALM )
	end
end

function SWEP:DrawWorldModel()
	self:DrawModel()

	self:SetSkin( ACCESS.KEYCARDS_CACHE[self:GetKeycard()].skin )
end