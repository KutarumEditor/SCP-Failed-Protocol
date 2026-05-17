local render_GetScreenEffectTexture = render.GetScreenEffectTexture
local render_GetRenderTarget = render.GetRenderTarget
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local render_ClearStencil = render.ClearStencil
local render_SetStencilEnable = render.SetStencilEnable
local render_SuppressEngineLighting = render.SuppressEngineLighting
local render_SetStencilWriteMask = render.SetStencilWriteMask
local render_SetStencilTestMask = render.SetStencilTestMask
local render_SetStencilCompareFunction = render.SetStencilCompareFunction
local render_SetStencilFailOperation = render.SetStencilFailOperation
local render_SetBlend = render.SetBlend
local render_SetStencilReferenceValue = render.SetStencilReferenceValue
local render_SetStencilZFailOperation = render.SetStencilZFailOperation
local render_SetStencilPassOperation = render.SetStencilPassOperation
local render_Clear = render.Clear
local render_SetRenderTarget = render.SetRenderTarget
local render_SetMaterial = render.SetMaterial
local render_DrawScreenQuad = render.DrawScreenQuad
local render_DrawScreenQuadEx = render.DrawScreenQuadEx
local render_ClearDepth = render.ClearDepth

local cam_Start3D = cam.Start3D
local cam_End3D = cam.End3D
local cam_Start2D = cam.Start2D
local cam_End2D = cam.End2D

local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect

local hook_Run = hook.Run
local hook_Add = hook.Add

OUTLINE_MODE_BOTH		= 0		-- Render always
OUTLINE_MODE_NOTVISIBLE	= 1
OUTLINE_MODE_VISIBLE	= 2

OUTLINE_RENDERTYPE_BEFORE_VM	= 0		-- Render before drawing the view model
OUTLINE_RENDERTYPE_BEFORE_EF	= 1		-- Render before drawing all effects (after drawing the viewmodel)
OUTLINE_RENDERTYPE_AFTER_EF		= 2		-- Render after drawing all effects

module( "outline", package.seeall )

local List					= {}
local RenderEnt				= NULL
local RenderType			= OUTLINE_RENDERTYPE_AFTER_EF
local OutlineThickness		= 1

local StoreTexture			= render_GetScreenEffectTexture( 0 )
local DrawTexture			= render_GetScreenEffectTexture( 1 )

local OutlineMatSettings	= {
	[ "$basetexture" ]	= DrawTexture:GetName(),
	[ "$ignorez" ]		= 1,
	[ "$alphatest" ]	= 1
}

local CopyMat				= Material( "pp/copy" )
local OutlineMat			= CreateMaterial( "outline", "UnlitGeneric", OutlineMatSettings )

local ENTS, COLOR, MODE		= 1, 2, 3

local modeExcTbl = {
	[OUTLINE_MODE_BOTH] = true,
	[OUTLINE_MODE_NOTVISIBLE] = true,
	[OUTLINE_MODE_VISIBLE] = true
}
function Add( ents, color, mode )
	if ( #List >= 255 ) then return end				--Maximum 255 reference values
	if ( !istable( ents ) ) then ents = { ents } end	--Support for passing Entity as first argument
	if ( ents[ 1 ] == nil ) then return end				--Do not pass empty tables
	
	if modeExcTbl[mode] == nil then
		mode = OUTLINE_MODE_BOTH
	end
	
	local numEnts = #ents
	for i = 1, numEnts do
		local ent = ents[i]
		if ent:IsPlayer() then
			local bonemerge = ent:LookupBonemerges()
			for obj = 1, #bonemerge do
				ents[#ents + 1] = bonemerge[obj]
			end
		end
	end

	local data = {
		[ ENTS ] = ents,
		[ COLOR ] = color,
		[ MODE ] = mode
	}

	List[#List + 1] = data
end

function RenderedEntity()
	return RenderEnt
end

local rtExcTbl = {
	[OUTLINE_RENDERTYPE_BEFORE_VM] = true,
	[OUTLINE_RENDERTYPE_BEFORE_EF] = true,
	[OUTLINE_RENDERTYPE_AFTER_EF] = true
}
function SetRenderType( render_type )
	if rtExcTbl[render_type] == nil then
		return
	end

	local old_type = RenderType
	RenderType = render_type
	
	return old_type
end

function GetRenderType()
	return RenderType
end

function SetDoubleThickness( thickness )
	local old_thickness = OutlineThickness == 2
	OutlineThickness = thickness && 2 || 1
	
	return old_thickness
end

function IsDoubleThickness()
	return OutlineThickness == 2
end

local function Render()
	local scene = render_GetRenderTarget()
	render_CopyRenderTargetToTexture( StoreTexture )
	
	local w, h = ScrW(), ScrH()
	
	render_ClearStencil()
	
	render_SetStencilEnable( true )
		render_SuppressEngineLighting( true )
		
		render_SetStencilWriteMask( 0xFF )
		render_SetStencilTestMask( 0xFF )
		
		render_SetStencilCompareFunction( STENCIL_GREATER )
		render_SetStencilFailOperation( STENCIL_KEEP )
		
		cam_Start3D()
			render_SetBlend(1)
			
			for i = 1, #List do
				local reference = 0xFF - ( i - 1 )
				
				local data = List[ i ]
				local mode = data[ MODE ]
				local ents = data[ ENTS ]
				
				render_SetStencilReferenceValue( reference )
				
				if ( mode == OUTLINE_MODE_BOTH || mode == OUTLINE_MODE_VISIBLE ) then
					render_SetStencilZFailOperation( mode == OUTLINE_MODE_BOTH && STENCIL_REPLACE || STENCIL_KEEP )
					render_SetStencilPassOperation( STENCIL_REPLACE )
					
					for j = 1, #ents do
						local ent = ents[ j ]
						
						if ( IsValid( ent ) ) then
							
							RenderEnt = ent
							ent:DrawModel()
						end
					end
				elseif ( mode == OUTLINE_MODE_NOTVISIBLE ) then
					render_SetStencilZFailOperation( STENCIL_REPLACE )
					render_SetStencilPassOperation( STENCIL_KEEP )
					
					for j = 1, #ents do
						local ent = ents[ j ]
						
						if ( IsValid( ent ) ) then
							RenderEnt = ent
							ent:DrawModel()
						end
					end
					
					render_SetStencilCompareFunction( STENCIL_EQUAL )
					render_SetStencilZFailOperation( STENCIL_KEEP )
					render_SetStencilPassOperation( STENCIL_ZERO )
					
					for j = 1, #ents do
						local ent = ents[ j ]
						
						if ( IsValid( ent ) ) then
							RenderEnt = ent
							ent:DrawModel()
						end
					end
					
					render_SetStencilCompareFunction( STENCIL_GREATER )
				end
			end
			
			RenderEnt = NULL
			
			render_SetBlend(1)
		cam_End3D()
		
		render_SetStencilCompareFunction( STENCIL_EQUAL )
		render_SetStencilZFailOperation( STENCIL_KEEP )
		render_SetStencilPassOperation( STENCIL_KEEP )
		
		render_Clear( 0, 0, 0, 0, false, false )
		
		cam_Start2D()
			for i = 1, #List do
				local reference = 0xFF - ( i - 1 )
				
				render_SetStencilReferenceValue( reference )
				
				surface_SetDrawColor( List[ i ][ COLOR ] )
				surface_DrawRect( 0, 0, w, h )
			end
		cam_End2D()
		
		render_SuppressEngineLighting( false )
	render_SetStencilEnable( false )
	
	render_CopyRenderTargetToTexture( DrawTexture )
	
	render_SetRenderTarget( scene )
	CopyMat:SetTexture( "$basetexture", StoreTexture )
	render_SetMaterial( CopyMat )
	render_DrawScreenQuad()
	
	render_SetStencilEnable( true )
		render_SetStencilReferenceValue( 0 )
		
		render_SetStencilCompareFunction( STENCIL_EQUAL )
		
		OutlineMat:SetTexture( "$basetexture", DrawTexture )
		render_SetMaterial( OutlineMat )
		
		render_DrawScreenQuadEx( -OutlineThickness, -OutlineThickness, w ,h )
		render_DrawScreenQuadEx( -OutlineThickness, 0, w, h )
		render_DrawScreenQuadEx( -OutlineThickness, OutlineThickness, w, h )
		render_DrawScreenQuadEx( 0, -OutlineThickness, w, h )
		render_DrawScreenQuadEx( 0, OutlineThickness, w, h )
		render_DrawScreenQuadEx( OutlineThickness, -OutlineThickness, w, h )
		render_DrawScreenQuadEx( OutlineThickness, 0, w, h )
		render_DrawScreenQuadEx( OutlineThickness, OutlineThickness, w, h )
	render_SetStencilEnable( false )
	
	render_ClearDepth()
end

local function RenderOutlines()
	hook_Run( "SetupOutlines", Add )
	
	if #List == 0 then return end
	
	Render()
	
	List = {}
end

hook_Add( "PreDrawViewModels", "RenderOutlines", function()
	if RenderType == OUTLINE_RENDERTYPE_BEFORE_VM then
		RenderOutlines()
	end
end )

hook_Add( "PreDrawEffects", "RenderOutlines", function()
	if RenderType == OUTLINE_RENDERTYPE_BEFORE_EF then
		RenderOutlines()
	end
end )

hook_Add( "PostDrawEffects", "RenderOutlines", function()
	if RenderType == OUTLINE_RENDERTYPE_AFTER_EF then
		RenderOutlines()
	end
end )