function BulletSupress( ignorant, traceStart, traceEnd )
	if not SERVER then return end

	local ents, plys = ents.FindAlongRay( traceStart, traceEnd, Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) ), {}

	for i, v in ipairs( ents ) do
		if v:IsPlayer() and v != ignorant then
			table.insert( plys, v )
		end
	end

	for i, ply in ipairs( plys ) do
		net.Start( "SuppressionSync" )
			net.WriteVector( traceStart )
			net.WriteVector( traceEnd )
		net.Send( ply )
	end
end

if not CLIENT then return end

local surface = surface
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local Material = Material

SUPPRESSION = 0

function Suppress( num )
	SUPPRESSION = math.Clamp( SUPPRESSION + num, 0, 1 )
end

net.Receive( "SuppressionSync", function()
	local sPos, ePos = net.ReadVector(), net.ReadVector()

	local BulPos = ClosestPointOnLine( LocalPlayer():EyePos(), sPos, ePos )
	local plyToBulDist = EyePos():Distance( BulPos )

	EmitSound( "weapons/bullet/flyby"..FPRandom( 1, 3 )..".wav", BulPos )

	if LocalPlayer():Alive() then
		Suppress( .75 )
	end
end )

local vignette_mat = Material( "crimeville/misc/suppression.png" )
hook.Add( "FPHUD", "DrawSuppression", function()
	if SUPPRESSION == 0 then return end

	surface.SetDrawColor( 0, 0, 0, 215 * SUPPRESSION )
	surface.SetMaterial( vignette_mat )
	surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )

	SUPPRESSION = math.max( 0, SUPPRESSION - .001 )
end )