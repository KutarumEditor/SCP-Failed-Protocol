local PLAYER = FindMetaTable( "Player" )

if SERVER then

function PLAYER:RevealRussian( ply )
	net.Ping( "BecameRussian", tostring( ply:UserID() ), self )

	self:SetFPClass( "gruagent" )
	self:SetFPTeam( TEAM_GRU )
end

concommand.Add( "fp_become_russian", function( ply )
	ply:RevealRussian( ply )
end )

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

concommand.Add( "fp_mnestic_effect", function()
	RussianEffect()
end )

local function removeDRender()
	hook.Remove( "SetupOutlines", "GRULocator" )
end

local time = 0
function GRULocator()
	if LocalPlayer():FPTeam() != TEAM_GRU then removeDRender() end
	if CurTime() > time then removeDRender() end

	outline.SetRenderType( OUTLINE_RENDERTYPE_BEFORE_VM )
	outline.Add( UncheckedD, color_white, OUTLINE_MODE_BOTH )
end

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

	hook.Add( "SetupOutlines", "GRULocator", GRULocator )

	time = CurTime() + 20
end )

end