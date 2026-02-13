local PLAYER = FindMetaTable( "Player" )

if SERVER then

function PLAYER:RevealRussian( ply )
	net.Ping( "BecameRussian", tostring( ply:UserID() ), self )

	self:SetFPClass( "gruagent" )
	self:SetFPTeam( TEAM_GRU )
end

else

UncheckedD = UncheckedD or {}


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

function RussianEffect()
	RussianAntiAmnestic = 1

	util.ScreenShake( EyePos(), 7.5, 7.5, 3.5, 10000, true )

	hook.Add( "Think", "RussianAntiAmnestic", function()
		if RussianAntiAmnestic <= 0 then
			hook.Remove( "Think", "RussianAntiAmnestic" )
		else
			RussianAntiAmnestic = RussianAntiAmnestic - FrameTime() * .5
		end
	end )

	surface.PlaySound( "scpfp/gruspy/mnestic.wav" )
end

concommand.Add( "fp_become_russian", function()
	RussianEffect()
end )

local unchecked_clr = Color( 125, 125, 125 )
local time = 0
hook.Add( "PreDrawOutlines", "GRULocator", function()
	if LocalPlayer():FPTeam() != TEAM_GRU then return end

	if time == 0 then return end

	time = math.max( 0, time - FrameTime() )

	outline.Add( UncheckedD, unchecked_clr, OUTLINE_MODE_BOTH )
end )

net.ReceivePing( "BecameRussian", function( data )
	local ply = Player( tonumber( data ) )
	ply.known = true

	RussianEffect()
end )

net.ReceivePing( "FoundRussian", function( data )
	local ply = Player( tonumber( data ) )
	ply.known = true
end )

net.ReceivePing( "RemoveForGRULocator", function( data )
	local ply = Player( tonumber( data ) )
	ply.grulocated = true
end )

net.ReceivePing( "RussianLocator", function()
	UncheckedD = {}

	for _, ply in player.Iterator() do
		if ply:FPTeam() == TEAM_CLASSD and ply.grulocated != true then
			UncheckedD[#UncheckedD + 1] = ply
		end
	end

	time = 5
end )

end