local PLAYER = FindMetaTable( "Player" )

function PLAYER:SetupSpectator( roam )
	self:Cleanup()

	self:StripWeapons()

	self:SetFPTeam( TEAM_SPEC )
	self:SetFPClass( "spectator" )

	local plys = GetValidSpectateTargets()

	if roam or #plys < 1 then
		self:UnSpectate()
		self:Spectate( OBS_MODE_ROAMING )
	else
		self:Spectate( OBS_MODE_CHASE )
		self:SpectateEntity( plys[FPRandom( 1, #plys )] )
	end
end

function PLAYER:SpectatePlayerNext()
	if self:FPTeam() != TEAM_SPEC then return end

	local plys = GetValidSpectateTargets()
	if self:GetObserverMode() == OBS_MODE_ROAMING then
		if #plys > 0 then
			self:Spectate( OBS_MODE_CHASE )
		else
			return
		end
	end

	if #plys < 1 then
		self:UnSpectate()
		self:Spectate( OBS_MODE_ROAMING )
		return
	end

	local cur_target = self:GetObserverTarget()
	local index

	if !IsValid( cur_target ) then
		index = 1
	else
		for i, v in ipairs( plys ) do
			if v == cur_target then
				index = i + 1
				break
			end
		end
	end

	if !index then index = 1 end

	if index > #plys then
		index = 1
	end

	local target = plys[index]

	if target != cur_target then
		self:SpectateEntity( target )
	end
end

function PLAYER:SpectatePlayerPrev()
	if self:FPTeam() != TEAM_SPEC then return end

	local plys = GetValidSpectateTargets()

	if self:GetObserverMode() == OBS_MODE_ROAMING then
		if #plys > 0 then
			self:Spectate( OBS_MODE_CHASE )
		else
			return
		end
	end

	if #plys < 1 then
		self:UnSpectate()
		self:Spectate( OBS_MODE_ROAMING )
		return
	end

	local cur_target = self:GetObserverTarget()
	local index

	if !IsValid( cur_target ) then
		index = 1
	else
		for i, v in ipairs( plys ) do
			if v == cur_target then
				index = i - 1
				break
			end
		end
	end

	if !index then index = 1 end

	if index < 1 then
		index = #plys
	end

	local target = plys[index]

	if target != cur_target then
		self:SpectateEntity( target )
	end
end

function PLAYER:ChangeSpectateMode()
	if self:FPTeam() != TEAM_SPEC then return end

	local cur_mode = self:GetObserverMode()
	if #GetValidSpectateTargets() < 1 then
		if cur_mode != OBS_MODE_ROAMING then
			self:UnSpectate()
			self:Spectate( OBS_MODE_ROAMING )
		end

		return
	end

	if cur_mode == OBS_MODE_ROAMING then
		self:Spectate( OBS_MODE_CHASE )
		self:SpectatePlayerNext()
	elseif cur_mode == OBS_MODE_IN_EYE then
		self:Spectate( OBS_MODE_CHASE )
	elseif cur_mode == OBS_MODE_CHASE then
		self:UnSpectate()
		self:Spectate( OBS_MODE_ROAMING )
	end
end

function GetValidSpectateTargets()
	local plys = {}
	for _, ply in ipairs( player.GetAll() ) do
		if ply:Alive() then
			table.insert( plys, ply )
		end
	end

	return plys
end

hook.Add( "PostPlayerDeath", "ChangeSpectatingOnDeath", function( ply )
	for i, spec in ipairs( player.GetAll() ) do
		if ply == spec:GetObserverTarget() then
			spec:SpectatePlayerPrev()
		end
	end
end )