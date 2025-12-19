local table = table

local ASYNC_FUNCS = ASYNC_FUNCS or {}

function AsyncFunc( func )
	table.insert( ASYNC_FUNCS, func )
end

hook.Add( "Tick", "AsyncTasks", function()
	if #ASYNC_FUNCS > 0 then
		ASYNC_FUNCS[1]()

		table.remove( ASYNC_FUNCS, 1 )
	end
end )