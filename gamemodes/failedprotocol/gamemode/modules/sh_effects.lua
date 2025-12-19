REGISTERED_EFFECTS = {
	/*["test"] = {
		icon = Material( "" ), -- effect icon
		color = Color( 0, 0, 0 ), -- effect color
		time = 1, -- time of the effect
		max_time = 2, -- max time that can be reached by stacking
		invisible = false, -- Should effect be displayed
		stacks = false, -- false - no stacking, true - time stacking
		think_freq = 2, -- think_func frequency ( in seconds )
		think_func = function( ply ) end, -- Do something once in *think_freq* seconds
		start_func = function( ply ) end, -- Do something just on time of applying effect
		end_check = function( ply ) end, -- A check to end effect instantly
		end_func = function( ply ) end -- Do something after effect wears off
	},*/
	["bleeding"] = {
		icon = Material( "crimeville/icons/bleeding.png", "noclamp" ),
		color = Color( 225, 0, 0 ),
		time = 7,
		max_time = 20,
		stacks = true,
		think_freq = 2,
		think_func = function( ply )
			ply:SetDeathReason( "bleed", true )

			local dmg = DamageInfo()
			dmg:SetDamage( FPRandom( 3, 5 ) )
			dmg:SetAttacker( ply )
			dmg:SetInflictor( ply )
			ply:TakeDamageInfo( dmg )
		end,
		end_check = function( ply )
			return !ply:Alive()
		end,
		end_func = function( ply )

		end
	},
	["acetone"] = {
		icon = Material( "crimeville/icons/bleeding.png", "noclamp" ),
		color = Color( 75, 0, 175 ),
		time = 60,
		stacks = false,
		think_freq = 1,
		think_func = function( ply )
			ply:SetDeathReason( "acetone", true )

			local dmg = DamageInfo()
			dmg:SetDamage( 2 )
			dmg:SetAttacker( Player( ply.AcetonedBy ) or ply )
			dmg:SetInflictor( ply )
			ply:TakeDamageInfo( dmg )
		end,
		end_check = function( ply )
			return !ply:Alive()
		end,
		end_func = function( ply )

		end
	},
}

local PLAYER = FindMetaTable( "Player" )

function PLAYER:HasEffect( name )
	local eff_tbl = self:GetProperty( "Effects", {} )

	return istable( eff_tbl[name] )
end

function PLAYER:ApplyEffect( name )
	if not SERVER then return end

	local eff_tbl = self:GetProperty( "Effects", {} )

	eff_tbl[name] = eff_tbl[name] or {}
	eff_tbl[name].time = isnumber( eff_tbl[name].time ) and REGISTERED_EFFECTS[name].stacks == true and math.min( CurTime() + ( REGISTERED_EFFECTS[name].max_time or math.huge ), eff_tbl[name].time + REGISTERED_EFFECTS[name].time ) or CurTime() + REGISTERED_EFFECTS[name].time
	eff_tbl[name].nextThink = eff_tbl[name].nextThink or isnumber( REGISTERED_EFFECTS[name].think_freq ) and CurTime() + REGISTERED_EFFECTS[name].think_freq or 0

	self:SetProperty( "Effects", eff_tbl, true )

	if isfunction( REGISTERED_EFFECTS[name].start_func ) then
		REGISTERED_EFFECTS[name].start_func( self )
	end
end

function PLAYER:RemoveEffect( name )
	if not SERVER or not self:HasEffect( name ) then return end

	local eff_tbl = self:GetProperty( "Effects", {} )

	if isstring( name ) then
		eff_tbl[name] = nil
	else
		eff_tbl = {}
	end

	self:SetProperty( "Effects", eff_tbl, true )
end

if SERVER then

hook.Add( "Tick", "FPEffectsCalc", function()
	for i, ply in ipairs( player.GetAll() ) do
		ply.FPProperties = ply.FPProperties or {}
		ply.FPProperties.Effects = ply.FPProperties.Effects or {}

		for k, v in pairs( ply.FPProperties.Effects ) do
			if REGISTERED_EFFECTS[k].end_check( ply ) == true then
				if isfunction( REGISTERED_EFFECTS[k].end_func ) then
					REGISTERED_EFFECTS[k].end_func( ply )
				end

				ply.FPProperties.Effects[k] = nil

				ply:SetProperty( "Effects", ply.FPProperties.Effects, true )
			end

			if CurTime() > v.nextThink then
				if isfunction( REGISTERED_EFFECTS[k].think_func ) then
					REGISTERED_EFFECTS[k].think_func( ply )
				end

				v.nextThink = CurTime() + ( REGISTERED_EFFECTS[k].think_freq or FrameTime() )
			end

			if CurTime() > v.time then
				if isfunction( REGISTERED_EFFECTS[k].end_func ) then
					REGISTERED_EFFECTS[k].end_func( ply )
				end

				ply.FPProperties.Effects[k] = nil

				ply:SetProperty( "Effects", ply.FPProperties.Effects, true )
			end
		end
	end
end )

elseif CLIENT then

hook.Add( "HUDPaint", "HUDActiveEffects", function()
	local ply = LocalPlayer()
	local effs = ply:GetProperty( "Effects", {} )

	local size = ScreenScale( 16 )
	local gap = ScreenScale( 4 )
	local total_space = #effs * size + ( #effs - 1 ) * gap
	local start_pos = ( ScrH() - total_space )/2

	for k, v in pairs( effs ) do
		render.SetStencilEnable( true )

	    render.ClearStencil()
	    
	    render.SetStencilTestMask( 255 )
	    render.SetStencilWriteMask( 255 )

	    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
	    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

	    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

	    render.SetStencilReferenceValue( 9 )
	    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

		draw.RoundedBox( 0, gap, start_pos, size, size, color_white )
		
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )

		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

		local clr = LerpColor( .9, REGISTERED_EFFECTS[k].color, Color( 15, 15, 15 ) )
		clr.a = 225
		draw.RoundedBox( 0, gap, start_pos, size, size, clr )

		surface.SetDrawColor( Color( 0, 0, 0, 125 ) )

		surface.SetDrawColor( REGISTERED_EFFECTS[k].color )
		surface.SetMaterial( REGISTERED_EFFECTS[k].icon )
		--draw.RoundedBox( 0, gap + ScreenScale( 2 ), start_pos + ScreenScale( 2 ), size - ScreenScale( 4 ),  - ScreenScale( 4 ), REGISTERED_EFFECTS[k].color )
		surface.DrawTexturedRect( gap + ScreenScale( 2 ), start_pos + ScreenScale( 2 ), size - ScreenScale( 4 ), size - ScreenScale( 4 ) )

		render.SetStencilEnable( false )

		start_pos = start_pos + ( size + gap )
	end
end )

end