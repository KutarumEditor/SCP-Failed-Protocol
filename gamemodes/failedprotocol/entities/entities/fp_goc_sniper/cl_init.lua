include( "shared.lua" )

local lerp = 0
local addvec

local wiremat = Material( "models/wireframe" )
function ENT:Draw()
	--
end

net.ReceivePing( "GOCSniperMuzzleflash", function( data )
	local id = tonumber( data )
	local ent = Entity( id )
	local dlight = DynamicLight( id )
	if ( dlight ) then
		dlight.Pos = ent:GetPos()
		dlight.r = 255
		dlight.g = 135
		dlight.b = 25
		dlight.brightness = 5
		dlight.Decay = 400
		dlight.Size = 1024
		dlight.DieTime = CurTime() + .025
	end

	local t = ent:GetTarget()
	local hitpos = t:GetPos() + ( ent:GetAggressive() and t:OBBCenter() or Vector() )
	--util.ParticleTracerEx( "AR2Tracer", ent:GetPos(), t:GetPos() + ( ent:GetAggressive() and t:OBBCenter() or Vector() ), true, ent:EntIndex(), -1 )

	local eff = EffectData()
	eff:SetStart( ent:GetPos() )
	eff:SetOrigin( hitpos )
	util.Effect( "tfa_tracer_goc_sniper", eff )
end )