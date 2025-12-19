local net = net

if SERVER then

local PLAYER = FindMetaTable( "Player" )

function PLAYER:SendNavData( bool, name, data )
	local bool = isbool( bool ) and bool or true
	net.Start( "FPNavigatorPoint" )
		net.WriteBool( bool )
		net.WriteString( name )
		if istable( data ) then
			net.WriteTable( data )
		end
	net.Send( self )
end

else

NAVIGATOR = NAVIGATOR or {
	POINTS = {
		--[[nigga = {
			pos = Vector( 4822.4184570313, 1861.3367919922, 80.03125 ),
			color = Color( 255, 255, 0 )
		},]]
	}
}

function NAVIGATOR.GetPoints()
	return NAVIGATOR.POINTS
end

function NAVIGATOR.Get( name )
	return NAVIGATOR.POINTS[name]
end

function NAVIGATOR.Clear()
	NAVIGATOR.POINTS = {}
end

function NAVIGATOR.AddPoint( name, data )
	NAVIGATOR.POINTS[name] = data
end

function NAVIGATOR.RemovePoint( name )
	NAVIGATOR.POINTS[name] = nil
end

net.Receive( "FPNavigatorPoint", function()
	if net.ReadBool() then
		NAVIGATOR.AddPoint( name, data )
	else
		NAVIGATOR.RemovePoint( name )
	end
end )

hook.Add( "HUDPaint", "DisplayNavPoints", function()
	local ply = LocalPlayer()
	local pointsTbl = NAVIGATOR.POINTS
	
	for name, data in pairs( pointsTbl ) do
		local pos = data.pos
		local scr = pos:ToScreen()

		draw.SimpleText( LANG.Get( "NAVIGATOR", name ).." | "..math.Round( HUToMeters( pos:Distance( ply:EyePos() ) ) ).."m", "HUDSmall", scr.x, scr.y, data.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end )

hook.Add( "OnSpawn", "DeathNavigatorCleaner", function()
    NAVIGATOR.Clear()
end )

end