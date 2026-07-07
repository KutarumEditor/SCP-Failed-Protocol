SPEEDS = {
    default = 1.3,
    run = 1.25,
    crouch = 0.75,
    walk = 1.15,
}

function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	local len = velocity:Length()
	local movement = 1.0

	if ( len > 0.2 ) then
		movement = ( len / maxseqgroundspeed )
	end

	local rate = math.min( movement, 2 )

    if ply:IsSprinting() then
        rate = math.min( movement, SPEEDS.run )
    elseif ply:Crouching() then
        rate = math.min( movement, SPEEDS.crouch )
    elseif ply:IsWalking() then
        rate = math.min( movement, SPEEDS.walk )
    elseif ply:OnGround() then
        rate = math.min( movement, SPEEDS.default )
    end

	if ( ply:WaterLevel() >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( !ply:IsOnGround() && len >= 1000 ) then
		rate = 0.1
	end

	ply:SetPlaybackRate( rate )

	if ( ply:InVehicle() ) then
		local Vehicle = ply:GetVehicle()
		local Velocity = Vehicle:GetVelocity()
		local fwd = Vehicle:GetUp()
		local dp = fwd:Dot( Vector( 0, 0, 1 ) )
		ply:SetPoseParameter( "vertical_velocity", ( dp < 0 && dp || 0 ) + fwd:Dot( Velocity ) * 0.005 )

		local steer = Vehicle:GetPoseParameter( "vehicle_steer" )

		if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then
			steer = 0

			ply:SetPoseParameter( "aim_yaw", math.NormalizeAngle( ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) )
		end

		if ( CLIENT ) then steer = steer * 2 - 1 end
		ply:SetPoseParameter( "vehicle_steer", steer )

	end

	GAMEMODE:GrabEarAnimation( ply )

	if ( CLIENT ) then
		GAMEMODE:MouthMoveAnimation( ply )
	end
end