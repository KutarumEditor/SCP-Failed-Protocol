local STEP = {
	gear = {
		walk = {
			right = {
				"scpfp/step/gear/walk/1.wav",
				"scpfp/step/gear/walk/2.wav",
				"scpfp/step/gear/walk/3.wav",
				"scpfp/step/gear/walk/4.wav",
				"scpfp/step/gear/walk/5.wav",
			},
			left = {
				"scpfp/step/gear/walk/6.wav",
				"scpfp/step/gear/walk/7.wav",
				"scpfp/step/gear/walk/8.wav",
				"scpfp/step/gear/walk/9.wav",
				"scpfp/step/gear/walk/10.wav",
			}
		},
		run = {
			right = {
				"scpfp/step/gear/sprint/1.wav",
				"scpfp/step/gear/sprint/2.wav",
				"scpfp/step/gear/sprint/3.wav",
				"scpfp/step/gear/sprint/4.wav",
				"scpfp/step/gear/sprint/5.wav",
			},
			left = {
				"scpfp/step/gear/sprint/6.wav",
				"scpfp/step/gear/sprint/7.wav",
				"scpfp/step/gear/sprint/8.wav",
				"scpfp/step/gear/sprint/9.wav",
				"scpfp/step/gear/sprint/10.wav",
			}
		},
	},
	suit = {
		right = {
			"scpfp/step/suit/1.wav",
			"scpfp/step/suit/2.wav",
			"scpfp/step/suit/3.wav",
			"scpfp/step/suit/4.wav",
			"scpfp/step/suit/5.wav",
			"scpfp/step/suit/6.wav",
			"scpfp/step/suit/7.wav",
			"scpfp/step/suit/8.wav",
		},
		left = {
			"scpfp/step/suit/9.wav",
			"scpfp/step/suit/10.wav",
			"scpfp/step/suit/11.wav",
			"scpfp/step/suit/12.wav",
			"scpfp/step/suit/13.wav",
			"scpfp/step/suit/14.wav",
			"scpfp/step/suit/15.wav",
			"scpfp/step/suit/16.wav",
		}
	}
}

STEPTYPE_NORMAL = 0
STEPTYPE_LADDER = 1
STEPTYPE_WATER = 2

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
	return true
end

function GM:FinishMove( ply, mv )
	local mvtype = ply:GetMoveType()
	if SERVER and ( ply:OnGround() and ( mvtype == MOVETYPE_WALK or mvtype == MOVETYPE_STEP ) or mvtype == MOVETYPE_LADDER ) then
		local vel = mv:GetVelocity()
		local len = vel:Length()

		if ply.fp_next_footstep then
			ply.fp_next_footstep = ply.fp_next_footstep - len * FrameTime()

			if ply.fp_next_footstep <= 0 then
				ply:PlayStepSound()
			end
		end

		if !ply.fp_next_footstep or ply.fp_next_footstep <= 0 then
			ply:UpdateStepTime()
		end
	end
	

	if ( drive.FinishMove( ply, mv ) ) then return true end
	if ( player_manager.RunClass( ply, "FinishMove", mv ) ) then return true end
end

function GM:FPPlayerFootstep( ply, foot, snd )

end

function GM:FPFootstepParams( ply, st, vel, crouch )
	if st == STEPTYPE_LADDER then
		return 100
	end

	local units = 45
	local len = vel:Length()

	if len > 125 then
		units = units + len / 10
	end

	if crouch then
		units = units - 15
	end

	if units < 25 then
		units = 25
	end

	return units
end

local PLAYER = FindMetaTable( "Player" )

local setp_off = Vector( 0, 0, 8 )
local step_trace = {}
step_trace.mins = Vector( -16, -16, -4 )
step_trace.maxs = Vector( 16, 16, 4 )
step_trace.mask = MASK_PLAYERSOLID
step_trace.output = step_trace

function PLAYER:PlayStepSound( no_update, force_loud )
	if not SERVER or !self:Alive() then return end

	local mv = self:GetMoveType()
	if mv != MOVETYPE_WALK and mv != MOVETYPE_STEP and mv != MOVETYPE_LADDER then return end
	
	local foot = self.fp_foot == 0 and 1 or 0
	local snd = foot == 0 and "Default.StepLeft" or "Default.StepRight"
	local add_snd, add_snd_vol = nil, .1

	if self.FPArmor.vest.name != nil then
		if self:IsSprinting() then
			add_snd = table.Random( foot == 0 and STEP.gear.run.right or STEP.gear.run.left )
			add_snd_vol = .2
		else
			add_snd = table.Random( foot == 0 and STEP.gear.walk.right or STEP.gear.walk.left )
		end
	else
		add_snd = table.Random( foot == 0 and STEP.suit.right or STEP.suit.left )
	end
	
	self.fp_foot = foot
	
	if mv == MOVETYPE_LADDER then
		snd = foot == 0 and "Ladder.StepLeft" or "Ladder.StepRight"
	else
		local pos = self:GetPos()

		step_trace.start = pos
		step_trace.endpos = pos - setp_off
		step_trace.filter = self

		util.TraceLine( step_trace )

		if !step_trace.Hit then
			util.TraceHull( step_trace )
		end

		if !step_trace.Hit then return end

		local surf = util.GetSurfaceData( step_trace.SurfaceProps )
		if surf then
			snd = self.fp_foot == 0 and surf.stepLeftSound or surf.stepRightSound
		end
	end

	if hook.Run( "FPPlayerFootstep", self, self.fp_foot, snd ) == true then return end

	if ( self:Crouching() or self:IsWalking() ) and force_loud != true then
		add_snd_vol = add_snd_vol * .5
	else
		EmitSound( snd, self:GetPos(), self:EntIndex(), CHAN_AUTO, 1, 60, 0, 100 )
	end

	timer.Simple( 0, function()
		EmitSound( add_snd, self:GetPos(), self:EntIndex(), CHAN_AUTO, add_snd_vol, 60, 0, 100 )
	end )

	if !no_update then
		self:UpdateStepTime()
	end
end

function PLAYER:UpdateStepTime()
	if not SERVER then return end

	local st = STEPTYPE_NORMAL

	if self:WaterLevel() > 0 then
		st = STEPTYPE_WATER
	elseif self:GetMoveType() == MOVETYPE_LADDER then
		st = STEPTYPE_LADDER
	end

	self.fp_next_footstep = hook.Run( "FPFootstepParams", self, st, self:GetVelocity(), self:Crouching() )
end