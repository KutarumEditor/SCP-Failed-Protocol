local PLAYER = FindMetaTable( "Player" )

function PLAYER:Disguise( model, time )
	local t = time != nil and CurTime() + time or -1
	self:SetProperty( "FPDisguise", {
		t,
		time
	}, true )

	self:SetModel( model )
end

function PLAYER:Undisguise()
	self:SetModel( self.FPOriginalModel )

	self:SetProperty( "FPDisguise", {
		0,
		0
	}, true )
end