

if SERVER then

function OpenStorage( ent, ply )
	ent:SyncStorage()

	net.Ping( "OpenStorage", ent:EntIndex(), ply )
end

net.ReceivePing( "TakeFromStorage", function( data, ply )
	local tbl = string.Split( data, " " )

	Entity( tbl[1] ):TakeOut( tonumber( tbl[2] ), ply )
end )

elseif CLIENT then

local sizeW, sizeH = ScrW() / 4, ScrH() / 2

local eased = 0

local container = nil
local items = {}

function OpenContainerUI( ent )
    if not LocalPlayer():Alive() then return end

    container = ent

    local frame = vgui.Create( "DPanel" )
    frame:SetSize( sizeW, sizeH )
    frame:Center()
    frame:MakePopup()
    frame:SetAlpha( 0 )
    frame:AlphaTo( 245, .5, 0, function() end )

    function frame:Paint( w, h )
        if not LocalPlayer():Alive() then self:Remove() end

        eased = math.ease.OutCirc( self:GetAlpha()/245 )

        render.SetStencilEnable( true )

        render.ClearStencil()
        
        render.SetStencilTestMask( 255 )
        render.SetStencilWriteMask( 255 )

        render.SetStencilPassOperation( STENCILOPERATION_KEEP )
        render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

        render.SetStencilReferenceValue( 9 )
        render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

        draw.RoundedBox( 0, 0 + ( w/2 ) * ( 1 - eased ), 0, w * eased, h, Color( 5, 5, 5, 240 ) )

        render.SetStencilFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

        draw.RoundedBox( 0, 0, 0, w, h, Color( 5, 5, 5, 240 ) )
        surface.SetDrawColor( 25, 25, 25, 55 )

        draw.SimpleText( LANG.Get( "ENT", container:GetClass() ), "HUDNormal", w/2, ScreenScale( 8 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        render.SetStencilEnable( false )

        surface.SetDrawColor( color_white )
    end

    function frame:OnRemove()
    	eased = 0
    end

   	local scroll = vgui.Create( "DScrollPanel", frame )
    scroll:SetSize( sizeW, sizeH - ScreenScale( 16 ) )
    scroll:SetPos( 0, ScreenScale( 16 ) )
    scroll:SetAlpha( 0 )
    scroll:AlphaTo( 245, .5, 0, function() end )

    function RebuildItems()
    	for k, v in pairs( items ) do
    		if IsValid( v.panel ) then
				v.panel:Remove()
				v.panel = nil
			end
		end

		items = ent.Items

	    for k, v in pairs( items ) do
	    	v.panel = scroll:Add( "DButton" )
	        local item = v.panel
	        item:SetText( "" )
	        item:SetSize( 0, ScreenScale( 24 ) )
	        item:Dock( TOP )
	        item:DockMargin( 0, 0, 0, ScreenScale( 2 ) )

	        function item:Paint( w, h )
	        	render.SetStencilEnable( true )

		        render.ClearStencil()
		        
		        render.SetStencilTestMask( 255 )
		        render.SetStencilWriteMask( 255 )

		        render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		        render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

		        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

		        render.SetStencilReferenceValue( 9 )
		        render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

		        draw.NoTexture()
	            surface.SetDrawColor( color_white )
		        surface.DrawRect( w/2 * ( 1 - eased ), 0, w * eased, h )

		        render.SetStencilFailOperation( STENCILOPERATION_KEEP )

        		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

	            draw.NoTexture()
	            surface.SetDrawColor( Color( 15, 15, 15 ) )
	            surface.DrawRect( 0, 0, w, h )

	            if istable( v ) then
	            	local wep_lang, ent_lang = LANG.Get( "WEP", v.class ), LANG.Get( "ENT", v.class )

	            	draw.SimpleText( wep_lang != "NULL_LANG" and wep_lang or ent_lang != "NULL_LANG" and ent_lang or v.name or v.class, "HUDNormal", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	            end

	            render.SetStencilEnable( false )
	        end

	        function item:DoClick()
		    	net.Ping( "TakeFromStorage", container:EntIndex().." "..k )

		    	timer.Simple( 0, function()
		    		RebuildItems()
		    	end )
		   	end
	    end
	end

	RebuildItems()

    local close_bt = vgui.Create( "DButton", frame )
    close_bt:SetSize( ScreenScale( 16 ), ScreenScale( 8 ) )
    close_bt:SetPos( sizeW - ScreenScale( 20 ), ScreenScale( 4 ) )
    close_bt:SetText( "" )
    close_bt:SetAlpha( 0 )
    close_bt:AlphaTo( 245, .5, 0, function() end )

    function close_bt:Paint( w, h )
    	draw.NoTexture()
        surface.SetDrawColor( Color( 55, 0, 0, 175 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    function close_bt:DoClick()
    	frame:Remove()
   	end
end

net.Receive( "StorageSync", function( len, ply )
	local ent = net.ReadEntity()
	local tbl = net.ReadTable()

	ent.Items = tbl
end )

net.ReceivePing( "OpenStorage", function( data )
	local ent = Entity( tonumber( data ) )
	OpenContainerUI( ent )
end )

end