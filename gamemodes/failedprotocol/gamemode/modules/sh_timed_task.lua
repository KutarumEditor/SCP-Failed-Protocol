local PLAYER = FindMetaTable( "Player" )

if SERVER then

FPTASKS = FPTASKS or {}

function PLAYER:TimedTask( name, duration, color, check, callback )
	if not IsValid( self ) or self.DoingTask then return end

	self.DoingTask = true

	local data = {
		n = name,
		d = duration,
		c = color
	}

	net.Start( "FPTask" )
		net.WriteString( data.n )
		net.WriteColor( data.c )
		net.WriteFloat( CurTime() )
		net.WriteFloat( data.d )
	net.Send( self )

	FPTASKS[self:Nick().."_"..name] = {
		player = self,
		endtime = CurTime() + duration,
		check = check,
		callback = callback,
	}
end

hook.Add( "Think", "FPTaskChecker", function()
	for k, v in pairs( FPTASKS ) do
		if not IsValid( v.player ) then
			FPTASKS[k] = nil
		elseif not v.check() then
			FPTASKS[k] = nil
			v.player.DoingTask = false
			net.Start( "FPTask" )
				net.WriteColor( Color( 0, 0, 0, 0 ) )
				net.WriteFloat( 1 )
				net.WriteFloat( 0 )
			net.Send( v.player )
		elseif CurTime() >= v.endtime then
			v.callback()
			FPTASKS[k] = nil
			v.player.DoingTask = false
			net.Start( "FPTask" )
				net.WriteColor( Color( 0, 0, 0, 0 ) )
				net.WriteFloat( 1 )
				net.WriteFloat( 0 )
			net.Send( v.player )
		end
	end
end )

end

if CLIENT then

local FPCurTask = nil
local FPTaskColor = color_white
local FPTaskStartTime = 0
local FPTaskEndTime = 0

local alpha = 0
local dotCount = 1
local maxDots = 3
local nextDotChange = CurTime() + 0.5
hook.Add( "HUDPaint", "FPTaskDrawer", function()
	if ( CurTime() - FPTaskStartTime ) > FPTaskEndTime or FPCurTask == nil then
		alpha = math.max( 0, alpha - .05 )
	else
		alpha = math.min( 1, alpha + .1 )
	end

	if alpha == 0 then return end

	local w, h = ScrW()/3, ScrW()/65

	render.SetStencilEnable( true )

    render.ClearStencil()
    
    render.SetStencilTestMask( 255 )
    render.SetStencilWriteMask( 255 )

    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

    render.SetStencilReferenceValue( 9 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

    surface.SetDrawColor( 0, 0, 0, 225 )
    surface.DrawRect( ScrW()/2 - w/2, ScrH()*5/7 - h/2 * alpha, w, h * alpha )

    render.SetStencilFailOperation( STENCILOPERATION_KEEP )

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

	surface.DrawRect( ScrW()/2 - w/2, ScrH()*5/7 - h/2 * alpha, w, h * alpha )
	surface.SetDrawColor( 0, 0, 0, 200 )

	render.SetStencilEnable( false )

    surface.SetDrawColor( FPTaskColor )
    surface.DrawRect( ScrW()/2 - w/2, ScrH()*5/7 - ( h/2 - 2 ) * alpha, w * ( math.Clamp( ( CurTime() - FPTaskStartTime )/FPTaskEndTime, 0, 1 ) ), ( h - 4 ) * alpha )

    local linw, linh = 5, ScrW()/65 + 5
    surface.SetDrawColor( color_white )
    surface.DrawRect( ScrW()/2 - w/2 - linw, ScrH()*5/7 - linh/2 * alpha, linw, linh * alpha )
    surface.DrawRect( ScrW()/2 + w/2, ScrH()*5/7 - linh/2 * alpha, linw, linh * alpha )

    local text = LANG.Get( "TASK", FPCurTask ) != "NULL_LANG" and LANG.Get( "TASK", FPCurTask ) or ""
    if text != "" then
    	text = text..string.rep( ".", dotCount )
    end

    if CurTime() >= nextDotChange then
        dotCount = (dotCount % maxDots) + 1
        nextDotChange = CurTime() + 0.5
    end

    surface.SetDrawColor( color_black )
    surface.SetFont( "HUDNormal" )
    local tx, ty = surface.GetTextSize( text )

    render.SetStencilEnable( true )

    render.ClearStencil()
    
    render.SetStencilTestMask( 255 )
    render.SetStencilWriteMask( 255 )

    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

    render.SetStencilReferenceValue( 9 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

    surface.DrawRect( ScrW()/2 - tx/2 - 3, ScrH()*5/7 - h/2 * alpha - h, tx + 6, h * alpha )

    render.SetStencilFailOperation( STENCILOPERATION_KEEP )

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

    draw.SimpleTextOutlined( text, "HUDNormal", ScrW()/2, ScrH()*5/7 - h, Color( 255, 255, 255, 255 * alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 * alpha ) )

    render.SetStencilEnable( false )
end )

net.Receive( "FPTask", function()
	FPCurTask = net.ReadString() or nil
	FPTaskColor = net.ReadColor()
	local timeStart = net.ReadFloat() or math.huge
	local timeReq = net.ReadFloat()
	FPTaskStartTime, FPTaskEndTime = timeStart, timeReq
end )

end