--[[-------------------------------------------------------------------------
Global functions
---------------------------------------------------------------------------]]
//SQLite doesn't support ON DUPLICATE KEY
local sqlite_insert = "INSERT INTO scpfp_playerdata(sid, datakey, value) VALUES (?, ?, ?) ON CONFLICT(sid, datakey) DO UPDATE SET value = ?3;"
local mysql_insert = "INSERT INTO scpfp_playerdata(sid, datakey, value) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE value = ?3;"

function SetFPData( steamid, name, value )
	return FPDatabase:FormatQuery( FPDatabase.MySQL and mysql_insert or sqlite_insert, steamid, name, value )
end

function GetFPData( steamid, name, def )
	return FPDatabase:FormatQuery( "SELECT value FROM scpfp_playerdata WHERE sid = ? AND datakey = ?;", steamid, name ):Then( function( data )
		if !data or !data[1] then
			return def
		end

		return data[1].value or def
	end )
end

function RemoveFPData( steamid, name )
	return FPDatabase:FormatQuery( "DELETE FROM scpfp_playerdata WHERE sid = ? AND datakey = ?;", steamid, name )
end

--[[-------------------------------------------------------------------------
Helper functions
---------------------------------------------------------------------------]]
function FPDataNumericAdd( steamid, name, num )
	return GetFPData( steamid, name ):Then( function( res )
		return SetFPData( steamid, name, ( tonumber( res or 0 ) or 0 ) + num )
	end )
end

--[[-------------------------------------------------------------------------
Player Bindings
---------------------------------------------------------------------------]]
local PLAYER = FindMetaTable( "Player" )

function PLAYER:SetFPData( name, value )
	return SetFPData( self:SteamID64(), name, value )
end

function PLAYER:GetFPData( name, def )
	return GetFPData( self:SteamID64(), name, def )
end

function PLAYER:RemoveFPData( name )
	return RemoveFPData( self:SteamID64(), name )
end

--[[-------------------------------------------------------------------------
SQL Object
---------------------------------------------------------------------------]]
local function err_func( self, err, sql_q )
	MsgC( Color( 200, 0, 0 ), "MySQL query error! "..sql_q.."\n" )
	print( err )
end

function FPInitializeMySQL()
	if mysqloo then return end
	
	print( "Loading MySQL..." )

	require( "mysqloo" )

	if !mysqloo then
		MsgC( Color( 200, 0, 0 ), "Couldn't load mysqloo module!\n" )
	end
end

local SQL = {}

SQL.MySQL = false
SQL.MySQLConnected = false
SQL.MySQLDatabase = nil

function SQL:Connect( cfg )
	self.MySQL = true
	FPInitializeMySQL()

	if !mysqloo then
		MsgC( Color( 200, 0, 0 ), "MySQL is not loaded!\n" )
		return false
	end

	return FPPromise( function( resolve, reject )
		local db = mysqloo.connect( cfg.host, cfg.username, cfg.password, cfg.database, cfg.port or 3306, cfg.socket )

		function db.onConnected( this )
			MsgC( Color( 0, 150, 0 ), string.format( "MySQL successfully connected to %s [%s:%s]!\n", cfg.database, cfg.host, cfg.port or 3306 ) )

			self.MySQLDatabase = this
			self.MySQLConnected = true

			hook.Add( "ShutDown", "FPMySQL.Shutdown."..db:hostInfo(), function()
				this:disconnect( true )
			end )

			resolve( this )
		end

		function db.onConnectionFailed( this, err )
			MsgC( Color( 200, 0, 0 ), string.format( "MySQL failed to connected to %s [%s:%s]!\n", cfg.database, cfg.host, cfg.port or 3306 ) )
			print( err )
			reject( err )
		end

		db:connect()
		db:wait()
	end )
end

function SQL:Escape( str )
	str = tostring( str )

	if self.MySQL then
		return self.MySQLConnected and self.MySQLDatabase:escape( str ) or str
	else
		return SQLStr( str, true )
	end
end

function SQL:Query( query )
	if self.MySQL then
		if !self.MySQLConnected then
			return FPPromise( function( resolve, reject )
				reject( "MySQL is not connected!" )
			end )
		end

		return FPPromise( function( resolve, reject )
			local q = self.MySQLDatabase:query( query )

			q.onSuccess = function( this, data )
				resolve( data )
			end

			q.onError = function( this, err, sql_q )
				MsgC( Color( 200, 0, 0 ), "MySQL query error! "..sql_q.."\n" )
				print( err )

				reject( err )
			end

			q:start()
		end )
	else
		return FPPromise( function( resolve, reject )
			local q = sql.Query( query )

			if q == false then
				MsgC( Color( 200, 0, 0 ), "SQLite query error! "..query.."\n" )
				print( sql.LastError() )

				reject( sql.LastError() )
				return
			end

			resolve( q )
		end )
	end
end

function SQL:SimpleQuery( query, cb, err, data, abort )
	if self.MySQL then
		if !self.MySQLConnected then
			return false
		end

		local q = self.MySQLDatabase:query( query )

		q.onError = err or err_func

		if cb then q.onSuccess = cb end
		if data then q.onData = data end
		if abort then q.onAborted = abort end

		q:start()
	else
		local q = sql.Query( query )

		if q == false then
			if err then
				err( nil, sql.LastError(), query )
			end
		else
			if cb then
				cb( nil, q )
			end
		end
	end

	return true
end

function SQL:SyncQuery( query )
	if self.MySQL then
		if !self.MySQLConnected then
			return false
		end

		local q = self.MySQLDatabase:query( query )

		q:start()
		q:wait( true )

		return q:getData(), q:error()
	else
		local q = sql.Query( query )
		return q, q == false and sql.LastError()
	end
end

function SQL:FormatQuery( ... )
	return self:Query( self:FormatQueryString( ... ) )
end

function SQL:FormatTable( ... )
	return self:Query( self:FormatTableString( ... ) )
end

function SQL:FullFormat( query, tab, ... )
	query = self:FormatTableString( query, tab )
	query = self:FormatQueryString( query, ... )

	return self:Query( query )
end

function SQL:FormatQueryString( query, ... )
	local orig = query
	local tab = { ... }
	local i = 0

	return string.gsub( query, "%?([%!%d]*)", function( num )
		local raw = false
		
		if num[1] == "!" then
			raw = true
			num = tonumber( string.sub( num, 2 ) )
		else
			num = tonumber( num )
		end

		if !num then
			i = i + 1
			num = i
		end

		local rep = tab[num]
		if !rep then
			error( "Missing value #"..num.." for SQL query: "..orig )
		end

		if isnumber( rep ) then
			return rep
		elseif isbool( rep ) then
			return rep and "TRUE" or "FALSE"
		elseif raw then
			return self:Escape( rep )
		else
			return "'"..self:Escape( rep ).."'" 
		end
	end )
end

function SQL:FormatTableString( query, tab )
	local key_list, value_list, set

	for k, v in pairs( tab ) do
		local key = self:Escape( k )
		local value = v
		
		if isbool( value ) then
			value = value and "TRUE" or "FALSE"
		elseif !isnumber( value ) then
			value = "'"..self:Escape( value ).."'"
		end

		key_list = key_list and key_list..", "..key or key
		value_list = value_list and value_list..","..value or value
		set = set and set..", "..key.." = "..value or key.." = "..value
	end

	if !key_list or !value_list or !set then return end

	query = string.gsub( query, "%?k", key_list )
	query = string.gsub( query, "%?v", value_list )
	query = string.gsub( query, "%?set", set )

	return query
end

setmetatable( SQL, {
	__call = function()
		return setmetatable( {}, {
			__index = SQL
		} )
	end
} )

hook.Add( "FPFullyLoaded", "SetupDatabase", function()
	--[[-------------------------------------------------------------------------
	Default Connections
	---------------------------------------------------------------------------]]
	FPDatabase = SQL()

	if SERVER then
		include( "base/_mysql.lua" )
	end

	--[[-------------------------------------------------------------------------
	Create tables
	---------------------------------------------------------------------------]]
	FPDatabase:Query( [[
		CREATE TABLE IF NOT EXISTS scpfp_playerdata (
			sid VARCHAR(22) NOT NULL,
			datakey VARCHAR(255) NOT NULL,
			value TEXT NOT NULL,
			PRIMARY KEY(sid, datakey)
		);
	]] )

	hook.Run( "FPDatabaseInit", FPDatabase )
end )