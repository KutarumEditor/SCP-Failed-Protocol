hook.Add( "StartCommand", "FPSprint", function( ply, cmd )
	if ply:IsBot() then return end
	if ply:GetMoveType() != MOVETYPE_WALK then return end
	if ply:GetWalkSpeed() >= ply:GetRunSpeed() then return end
	local exhausted = ply:GetExhausted()

	if exhausted or ply:GetSatiety() <= 25 then
		cmd:RemoveKey( IN_JUMP )
		cmd:RemoveKey( IN_SPEED )
	elseif cmd:KeyDown( IN_JUMP ) and IsFirstTimePredicted() then
		if !ply.WasJumpDown and ply:OnGround() and !ply:InVehicle() then
			local stamina = ply:GetStamina()

			ply.StaminaRegen = CurTime() + 1.5

			stamina = math.max( stamina - 10, 0 )
			
			ply:SetStamina( stamina )
		else
			cmd:RemoveKey( IN_JUMP )
		end

		ply.WasJumpDown = true
	elseif ply:OnGround() then
		ply.WasJumpDown = false
	end
end )

hook.Add( "OnPlayerHitGround", "FPBHop", function( ply, water, floater, speed )
	ply.JumpPenalty = CurTime() + 0.3
end )

hook.Add( "Move", "FPBHop", function( ply, mv )
	if ply.JumpPenalty and ply.JumpPenalty >= CurTime() then
		local vel = mv:GetVelocity()

		local new = vel * 0.98
		new.z = vel.z

		mv:SetVelocity( new )
	end
end )

local function CalcStamina( ply )
	if ply:IsBot() then return end
	if ply:GetMoveType() != MOVETYPE_WALK then return end
	if ply:GetWalkSpeed() >= ply:GetRunSpeed() then return end
	
	if !ply.Stamina then
		ply.Stamina = true
		ply.StaminaRegen = 0
	end

	if !ply.Stamina then return end

	local ct = CurTime()
	local exhausted = ply:GetExhausted()
	local stamina = ply:GetStamina()
	local max_stamina = ply:GetMaxStamina()

	if ply:IsSprinting() and ply:OnGround() and ( ply:KeyDown( IN_FORWARD ) or ply:KeyDown( IN_BACK ) or ply:KeyDown( IN_MOVELEFT ) or ply:KeyDown( IN_MOVERIGHT ) ) then
		ply.StaminaRegen = CurTime() + .3
		stamina = math.Clamp( stamina - .075, 0, max_stamina )
	elseif ply.StaminaRegen < CurTime() then
		stamina = math.Clamp( stamina + ply:GetMaxStamina()/1000, 0, max_stamina )
	end

	if stamina == 0 then
		ply:SetExhausted( true )
	elseif stamina > 25 then
		ply:SetExhausted( false )
	end

	ply:SetStamina( math.Clamp( stamina, 0, max_stamina ) )
end

hook.Add( "Tick", "FPStaminaCalc", function()
	if SERVER then
		for i, v in ipairs( player.GetAll() ) do
			CalcStamina( v )
		end
	else
		if IsValid( LocalPlayer() ) then
			CalcStamina( LocalPlayer() )
		end
	end
end )