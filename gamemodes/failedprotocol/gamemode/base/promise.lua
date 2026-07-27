--[[-------------------------------------------------------------------------
This library provides JS-like promise that allows you to create flat async code.
It follows MDN description of promise and guarantees:
	1. Cllback added with Then() will never be called faster than in the next tick
	2. Callbacks will be called even if they were added after promise was resolved or rejected
	3. Multiple callbacks can be added. They will be invoked one after another, in the order in which they were added
	4. IMPORTANT: All LUA errors inside promise ARE REDIRECTED to catch method and will produce no error!
	5. Returning promise in Finally, adds it to execution chain, but returned value is ignored

Promises support chaining and internal error catching.
For more info how to use promises, visit: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises
---------------------------------------------------------------------------]]

PROMISE_PENDING = 0
PROMISE_FULFILLED = 1
PROMISE_REJECTED = 2

FPPromise = {}
FPPromise.__index = FPPromise
FPPromise._STATUS = PROMISE_PENDING

function FPPromise:New( func )
	local tab = setmetatable( {
		Handler = {},
	}, FPPromise )

	if func then
		func( function( data )
			tab:Resolve( data )
		end, function( err )
			tab:Reject( err )
		end )
	end

	return tab
end

function FPPromise:Resolve( data )
	if self._STATUS != PROMISE_PENDING then return end

	self._STATUS = PROMISE_FULFILLED
	self._RESULT = data

	NextTick( function()
		for i, v in ipairs( self.Handler ) do
			v( true, data )
		end

		self.Handler = {}
	end )
end

function FPPromise:Reject( err )
	if self._STATUS != PROMISE_PENDING then return end
	self._STATUS = PROMISE_REJECTED
	self._RESULT = err

	NextTick( function()
		for i, v in ipairs( self.Handler ) do
			v( false, err )
		end

		self.Handler = {}
	end )
end

local function error_handler( err )
	print( "Error in promise:" )
	print( debug.traceback( err, 2 ) )
	print()
	
	return err
end

function FPPromise:Then( success, failure )
	local ret = FPPromise()

	local func = function( status, data )
		if status then
			if success then
				local pcall_status, then_return = xpcall( success, error_handler, data )
				if pcall_status then
					if ispromise( then_return ) then
						then_return:Then( function( new_data )
							ret:Resolve( new_data )
						end, function( err )
							ret:Reject( err )
						end )
					else
						ret:Resolve( then_return )
					end
				else
					ret:Reject( then_return )
				end
			else
				ret:Resolve( data )
			end
		else
			if failure then
				local pcall_status, then_return = xpcall( failure, error_handler, data )
				if pcall_status then
					if ispromise( then_return ) then
						then_return:Then( function( new_data )
							ret:Resolve( new_data )
						end, function( err )
							ret:Reject( err )
						end )
					else
						ret:Resolve( then_return )
					end
				else
					ret:Reject( then_return )
				end
			else
				ret:Reject( data )
			end
		end
	end

	if self._STATUS == PROMISE_PENDING then
		table.insert( self.Handler, func )
	elseif self._STATUS == PROMISE_FULFILLED then
		NextTick( func, true, self._RESULT )
	elseif self._STATUS == PROMISE_REJECTED then
		NextTick( func, false, self._RESULT )
	end

	return ret
end

function FPPromise:Catch( func )
	return self:Then( nil, func )
end

function FPPromise:Finally( func )
	local function fn( val )
		local ret = func( val )
		if !istable( ret ) or !ispromise( ret ) then
			return val
		end

		return FPPromise( function( resolve, reject )
			ret:Then( function()
				resolve( val )
			end, function()
				reject( val )
			end )
		end )
	end

	return self:Then( fn, fn )
end

function FPPromise:GetStatus()
	return self._STATUS
end

setmetatable( FPPromise, { __call = FPPromise.New } )

--[[-------------------------------------------------------------------------
Global functions
---------------------------------------------------------------------------]]
function ispromise( obj )
	return getmetatable( obj ) == FPPromise
end

function FPPromiseJoin( ... )
	local tab = { ... }
	local num = table.Count( tab )

	if num == 1 and istable( tab[1] ) and !ispromise( tab[1] ) then
		tab = tab[1]
		num = table.Count( tab )
	end

	local ret = {}
	local p = FPPromise()

	if num == 0 then
		p:Resolve( ret )
		return p
	end

	local remaining = num
	local rejected = false

	for i = 1, num do
		local v = tab[i]

		if ispromise( v ) then
			v:Then( function( data )
				if rejected then return end

				ret[i] = data
				remaining = remaining - 1

				if remaining <= 0 then
					p:Resolve( ret )
				end
			end, function( err )
				if rejected then return end

				rejected = true
				p:Reject( err )
			end )
		else
			ret[i] = v
			remaining = remaining - 1

			if remaining <= 0 then
				p:Resolve( ret )
			end
		end
	end

	return p
end

function FPPromiseAny( ... )
	local p = FPPromise()

	for i, v in pairs( { ... } ) do
		if !ispromise( v ) then continue end

		v:Then( function( data )
			p:Resolve( data )
		end )
	end

	return p
end

function FPToPromise( obj )
	if ispromise( obj ) then
		return obj
	else
		return FPPromise( function( resolve )
			resolve( obj )
		end )
	end
end

function FPPromisify( func )
	return function( ... )
		local tab = { ... }
		return FPPromise( function( resolve )
			func( tab[1], function( ... )
				if select( "#", ... ) <= 1 then
					resolve( ... )
				else
					resolve( { ... } )
				end
			end, unpack( tab, 2 ) )
		end )
	end
end

--[[-------------------------------------------------------------------------
Default promises
---------------------------------------------------------------------------]]
hook.Add( "FPFullyLoaded", "DefaultPromises", function()
	FPPromise.Resolved = FPPromise()
	FPPromise.Resolved:Resolve()

	FPPromise.Rejected = FPPromise()
	FPPromise.Rejected:Reject()
end )