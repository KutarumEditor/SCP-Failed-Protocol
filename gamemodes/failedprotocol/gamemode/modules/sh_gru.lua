local PLAYER = FindMetaTable( "Player" )

if SERVER then

function PLAYER:RevealRussian( ply )
	net.Ping( "BecameRussian", tostring( ply:UserID() ), self )

	self:SetFPClass( "gruagent" )
	self:SetFPTeam( TEAM_GRU )
end

else

local RussianAntiAmnestic = 0

function CalcRussianScreenEffects( br, col )
	local brightness = br + 1 * math.ease.InBack( RussianAntiAmnestic )
	local color = col + 1 * math.ease.InBack( RussianAntiAmnestic )

	return brightness, color
end

function CalcRussianFOV( fov )
	local fov = fov

	fov = fov + 60 * math.ease.InBack( RussianAntiAmnestic )

	return fov
end

net.ReceivePing( "BecameRussian", function( data )
	local ply = Player( tonumber( data ) )
	ply.known = true

	RussianAntiAmnestic = 1

	hook.Add( "Think", "RussianAntiAmnestic", function()
		if RussianAntiAmnestic <= 0 then
			hook.Remove( "Think", "RussianAntiAmnestic" )
		else
			RussianAntiAmnestic = RussianAntiAmnestic - FrameTime() * .5
		end
	end )

	surface.PlaySound( "scpfp/gruspy/antiamnestic.wav" )
end )

net.ReceivePing( "FoundRussian", function( data )
	local ply = Player( tonumber( data ) )
	ply.known = true
end )

end