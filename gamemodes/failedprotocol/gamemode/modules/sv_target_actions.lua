local PLAYER = FindMetaTable( "Player" )

function PLAYER:CommitAction( ent, act )
	local actTbl = istable( ent.Actions ) and ent.Actions or ENTITY_ACTIONS_OVERRIDE[ent:GetClass()]

	self.actionCooldown = CurTime() + ( actTbl[act].cooldown or 1 )

	actTbl[act].func( self, ent )
end

net.Receive( "FPEntityActions", function( len, ply )
	if not ply:Alive() then return end

	ply.actionCooldown = ply.actionCooldown or 0

	if ply.actionCooldown > CurTime() then return end

	local ent = net.ReadEntity()
	local action = net.ReadString()

	if not IsValid( ent ) or not IsEntity( ent ) or ply:EyePos():Distance( ent:GetPos() ) > 105 then return end

	local actionNum = nil
	local actions = istable( ent.Actions ) and ent.Actions or ENTITY_ACTIONS_OVERRIDE[ent:GetClass()] or {}
	for i, act in ipairs( actions ) do
		if act.name == action then
			actionNum = i
		end
	end

	if actionNum != nil then
		if isfunction( actions[actionNum].check ) and actions[actionNum].check( ply, ent ) == false then return end

		ply:CommitAction( ent, actionNum )
	end
end )