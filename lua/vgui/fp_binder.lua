local PANEL = {}

AccessorFunc( PANEL, "m_iSelectedNumber", "SelectedNumber" )
AccessorFunc( PANEL, "m_iDefaultNumber", "DefaultNumber" )

Derma_Install_Convar_Functions( PANEL )

PANEL.Font = "DermaDefault"
PANEL.Text = ""
PANEL.LabelText = ""

function PANEL:Init()
	self.State = false

	self.Binder = vgui.Create( "DBinder", self )
	self.Binder:SetSize( ScreenScale( 24 ), ScreenScale( 12 ) )

	self.Label = vgui.Create( "DLabel", self )
	self.Label:Dock( FILL )
	self.Label:SetContentAlignment( 4 )
	self.Label:SetColor( Color( 255, 255, 255 ) )
	self.Label:SetFont( self.Font )
	self.Label:SetText( self.LabelText )

	self.Label.Think = function()
		self.Label:SetText( self.LabelText )
	end
end

function PANEL:PerformLayout( w, h )
	self.Binder:SetWide( h )
end

function PANEL:SizeToContents()
	self.Label:SizeToContents()

	local lw, lh = self.Label:GetSize()

	self:SetWide( self.Binder:GetWide() + lw + 16 )
	self:SetTall( lh )
end

function PANEL:Paint( w, h )
	
end

function PANEL:SetSelectedNumber( iNum )
	self.m_iSelectedNumber = iNum
	self:ConVarChanged( iNum )
	self:UpdateText()
	self:OnUpdate( iNum )
end

function PANEL:Think()
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

function PANEL:SetValue( iNumValue )
	self:SetSelectedNumber( iNumValue )
end

function PANEL:GetValue()
	return self:GetSelectedNumber()
end

function PANEL:SetText( text )
	self.Text = text
end

function PANEL:SetLabelText( text )
	self.LabelText = text
end

function PANEL:UpdateText()
	local str = input.GetKeyName( self:GetSelectedNumber() )
	if ( !str ) then str = "" end

	str = language.GetPhrase( str )

	self:SetText( str )
end

function PANEL:SetFont( font )
	self.Label:SetFont( font )
	self.Font = font

	self:InvalidateLayout()
end

function PANEL:OnUpdate( val )

end

vgui.Register( "FPBinder", PANEL, "Panel" )