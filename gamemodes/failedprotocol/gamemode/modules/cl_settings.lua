CLIENT_SETTINGS = {}
CL_SETTINGS = {
	REG = {}
}

function CL_SETTINGS.GetByName( name )
	for i, v in ipairs( CL_SETTINGS.REG ) do
		if v.name == name then
			return i
		end
	end

	return nil
end

function CL_SETTINGS.Get( name )
	local tbl = {
		["string"] = GetConVar( name ):GetString(),
		["bool"] = GetConVar( name ):GetBool(),
		["int"] = GetConVar( name ):GetInt(),
		["float"] = GetConVar( name ):GetFloat(),
		["bind"] = GetConVar( name ):GetInt(),
		["list"] = GetConVar( name ):GetString(),
	}

	return tbl[CL_SETTINGS.REG[CL_SETTINGS.GetByName( name )].type]
end

function CL_SETTINGS.Register( name, default, type )
	CreateClientConVar( name, tostring( default ), true, true )

	local i = table.insert( CL_SETTINGS.REG, {
		name = name,
		type = type
	} )

	CL_SETTINGS.REG[i].val = CL_SETTINGS.Get( name )
end

CL_SETTINGS.Register( "fp_disable_postfx", "0", "bool" )

CL_SETTINGS.Register( "fp_disable_vignette", "0", "bool" )

CL_SETTINGS.Register( "fp_disable_support", "0", "bool" )

CL_SETTINGS.Register( "fp_disable_scp", "0", "bool" )

CL_SETTINGS.Register( "fp_settings_button", "95", "bind" )

CL_SETTINGS.Register( "fp_inventory_button", "27", "bind" )

CL_SETTINGS.Register( "fp_scp_upgrades_button", "12", "bind" )

CL_SETTINGS.Register( "fp_drop_weapon", "17", "bind" )

CL_SETTINGS.Register( "fp_language", "english", "list" )

function CL_SETTINGS.Set( name, val )
	local tbl = {
		["string"] = function()
			GetConVar( name ):SetString( val )
		end,
		["bool"] = function()
			GetConVar( name ):SetBool( val )
		end,
		["int"] = function()
			GetConVar( name ):SetInt( val )
		end,
		["float"] = function()
			GetConVar( name ):SetFloat( val )
		end,
		["bind"] = function()
			GetConVar( name ):SetInt( val )
		end,
		["list"] = function()
			GetConVar( name ):SetString( val )
		end,
	}

	local stg = CL_SETTINGS.REG[CL_SETTINGS.GetByName( name )]
	local type = stg.type

	stg.val = val
	tbl[type]()
end

local stg_clr = {
	default = Color( 15, 15, 15, 225 ),
}

local convertTypes = {
	["bool"] = function( scrl, tbl )
		local cb = scrl:Add( "FPCheckbox" )
		cb:SetSize( ScreenScale( 12 ), ScreenScale( 12 ) )
		cb:Dock( TOP )
		cb:DockMargin( 0, 0, 0, 5 )
		cb:SetFont( "HUDNormal" )
		cb:SetText( LANG.Get( "SETTINGS", tbl.name ) )
		cb:SetState( CL_SETTINGS.Get( tbl.name ) )

		cb.OnUpdate = function( this, new )
			CL_SETTINGS.Set( tbl.name, new )
		end
	end,
	["bind"] = function( scrl, tbl )
		local bp = scrl:Add( "DPanel" )
		bp:SetSize( ScreenScale( 24 ), ScreenScale( 12 ) )
		bp:Dock( TOP )
		bp:DockMargin( 0, 0, 0, 5 )
		bp:InvalidateParent( true )

		function bp:Paint( w, h ) end

		local bb = vgui.Create( "DBinder", bp )
		bb:SetSize( ScreenScale( 28 ), ScreenScale( 12 ) )
		bb:SetPos( 0, 0 )
		bb:Dock( LEFT )
		bb:DockMargin( 0, 0, 16, 0 )

		function bb:Init()

		end

		function bb:Paint( pw, ph )
			if self.Trapping then
				surface.SetDrawColor( 215, 215, 0 )
			else
				surface.SetDrawColor( color_white )
			end

			surface.DrawOutlinedRect( 0, 0, pw, ph )

			if self.b_State then
				surface.DrawRect( 3, 3, pw - 6, ph - 6 )
			end

			draw.SimpleText( "["..self:GetText().."]", "HUDMedium", pw/2, ph/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			return true
		end

		function bb:DoClick()
			self:SetText( "> <" )
			input.StartKeyTrapping()
			self.Trapping = true
		end

		function bb:Think()
			if ( input.IsKeyTrapping() and self.Trapping ) then
				local code = input.CheckKeyTrapping()
				if ( code ) then
					if ( code == KEY_ESCAPE ) then
						self:SetValue( self:GetSelectedNumber() )
					else
						self:SetValue( code )
					end

					self.Trapping = false
				end
			end
			self:ConVarNumberThink()
		end

		function bb:SetSelectedNumber( iNum )
			self.m_iSelectedNumber = iNum
			CL_SETTINGS.Set( tbl.name, iNum )
			self:UpdateText()
			self:OnChange( iNum )
		end

		function bb:UpdateText()
			local str = input.GetKeyName( self:GetSelectedNumber() )
			if ( !str ) then str = " " end

			str = language.GetPhrase( str )

			self:SetText( string.upper( str ) )
		end

		function bb:SetValue( iNumValue )
			self:SetSelectedNumber( iNumValue )
		end

		function bb:GetValue()
			return self:GetSelectedNumber()
		end

		bb:SetValue( CL_SETTINGS.Get( tbl.name ) )

		bl = vgui.Create( "DLabel", bp )
		bl:Dock( FILL )
		bl:SetContentAlignment( 4 )
		bl:SetColor( Color( 255, 255, 255 ) )
		bl:SetFont( "HUDNormal" )
		bl:SetText( LANG.Get( "SETTINGS", tbl.name ) )
	end,
	["list"] = function( scrl, tbl )
		local lp = scrl:Add( "DPanel" )
		lp:SetSize( ScreenScale( 24 ), ScreenScale( 12 ) )
		lp:Dock( TOP )
		lp:DockMargin( 0, 0, 0, 5 )
		lp:InvalidateParent( true )

		local cb = vgui.Create( "DComboBox", lp )
		cb:SetSize( ScreenScale( 12 ), ScreenScale( 12 ) )
		cb:Dock( TOP )
		cb:DockMargin( 0, 0, 0, 5 )
		cb:SetValue( CL_SETTINGS.Get( tbl.name ) )

		for i, v in ipairs( LANG.GetAllLangs() ) do
			cb:AddChoice( v )
		end

		cb.OnSelect = function( self, index, value )
			CL_SETTINGS.Set( tbl.name, value )

			CLIENT_SETTINGS.Rebuild()
		end
	end,
}

function CLIENT_SETTINGS.Open()
	local frame = vgui.Create( "DFrame" )
	CLIENT_SETTINGS.MENU = frame

	frame:SetSize( ScreenScale( 170 ), ScreenScale( 170 ) )
	frame:Center()
	frame:MakePopup()
	frame:SetTitle( "" )
	frame:ShowCloseButton( false )
	function frame:Paint( w, h )
		draw.NoTexture()
		surface.SetDrawColor( stg_clr.default )
		surface.DrawRect( 0, 0, w, h )

		draw.SimpleText( LANG.Get( "SETTINGS", "title" ), "HUDSmall", ScreenScale( 85 ), ScreenScale( 1 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	local close = vgui.Create( "DButton", frame )
	close:SetPos( ScreenScale( 162 ), 0 )
	close:SetSize( ScreenScale( 8 ), ScreenScale( 8 ) )
	close:SetText( "" )
	function close:Paint( w, h )
		draw.SimpleText( "X", "HUDNormal", w - ScreenScale( 4 ), -ScreenScale( 2 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	function close:DoClick()
		frame:Remove()
	end

	local scrl = vgui.Create( "DScrollPanel", frame )
	scrl:Dock( FILL )

	local reg = CL_SETTINGS.REG

	for i = 1, #reg do
		convertTypes[reg[i].type]( scrl, reg[i] )
	end
end

function CLIENT_SETTINGS.Close()
	CLIENT_SETTINGS.MENU:Remove()
end

function CLIENT_SETTINGS.Rebuild()
	if IsValid( CLIENT_SETTINGS.MENU ) then
		CLIENT_SETTINGS.MENU:Remove()
	end

	CLIENT_SETTINGS.Open()
end

local function _settingsDecide()
	if IsValid( CLIENT_SETTINGS.MENU ) then
		CLIENT_SETTINGS.MENU:Remove()
	else
		CLIENT_SETTINGS.Open()
	end
end

hook.Add( "OnPlayerChat", "HelloCommand", function( ply, strText, bTeam, bDead ) 
    if ( ply != LocalPlayer() ) then return end

	strText = string.lower( strText )

	if ( strText == "!settings" ) then
		_settingsDecide()

		return true
	end
end )

hook.Add( "PlayerButtonDown", "FPSettingsOpen", function( ply, button )
    if button != CL_SETTINGS.Get( "fp_settings_button" ) then return end

    if CLIENT and not IsFirstTimePredicted() then
        return
    end

    _settingsDecide()
end)