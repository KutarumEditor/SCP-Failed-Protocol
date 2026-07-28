AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Password = 1488

function ENT:Think()
    local user = self:GetUser()
    if user == NULL then
        self:SetActive( false )
        self:SetShow( false )
    else
        if not user:IsValid() or not user:Alive() then
            if user:IsValid() then
                user:SetTerminal( nil )
            end

            self:SetUser( nil )
        else
            self:SetActive( true )
        end
    end
end

function ENT:Use( activator, caller )
    local user = self:GetUser()
    if user != activator then
        if not user:IsValid() then
            self:SetUser( activator )
            activator:SetTerminal( self )
        else
            activator:ChatPrint( "Терминал используется кем-то другим" )
        end
    end
end

function ENT:AddData( data, folder )
    self.Data[folder] = self.Data[folder] or {}
    self.Data[folder][#self.Data[folder] + 1] = data
end

function ENT:SyncData()
    local user = self:GetUser()
    if user == nil then return end
    
    net.Start( "SyncTerminalData" )
        net.WriteTable( self.Data )
        net.WriteEntity( self )
    net.Send( user )
end

net.ReceivePing( "FPStopTerminalUsage", function( data, ply )
    if ply.Terminal != nil and ply.Terminal:IsValid() then
        ply.Terminal:SetUser( nil )
        ply:SetTerminal( nil )
    end
end )

net.ReceivePing( "FPEnterTerminalPassword", function( data, ply )
    local term = ply.Terminal
    if term != nil and term:IsValid() and data == term.Password then
        term:SetShow( true )
    end
end )