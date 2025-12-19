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

hook.Add( "HUDPaint", "DrawSuppression", function()
	surface.SetDrawColor( 0, 0, 0, 215 * SUPPRESSION )
	surface.SetMaterial( Material( "crimeville/misc/suppression.png" ) )
	surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )

	SUPPRESSION = SUPPRESSION - .001
end )