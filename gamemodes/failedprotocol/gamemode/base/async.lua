local table_insert = table.insert
local table_remove = table.remove

--[[-------------------------------------------------------------------------
Async
---------------------------------------------------------------------------]]

local ASYNC_FUNCS = ASYNC_FUNCS or {}

function AsyncFunc( func )
	table_insert( ASYNC_FUNCS, func )
end

hook.Add( "Tick", "AsyncTasks", function()
	if #ASYNC_FUNCS > 0 then
		ASYNC_FUNCS[1]()

		table_remove( ASYNC_FUNCS, 1 )
	end
end )

--[[-------------------------------------------------------------------------
NextTick
---------------------------------------------------------------------------]]

_CallNextTick = _CallNextTick or {}

function NextTick( func, ... )
	table_insert( _CallNextTick, { func, { ... } } )
end

hook.Add( "Tick", "CallNextTick", function()
	local len = #_CallNextTick
	if len > 0 then
		for i = 1, len do
			local tab = table_remove( _CallNextTick )
			tab[1]( unpack( tab[2] ) )
		end
	end
end )