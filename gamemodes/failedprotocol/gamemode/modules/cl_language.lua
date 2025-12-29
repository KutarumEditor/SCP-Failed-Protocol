LANG = {
	REG = {}
}

CUR_LANG = CUR_LANG or GetConVar( "fp_language" ) or "english"

function GetAllLanguages()
	return file.Find( LANGUAGES_PATH.."/*.lua", "LUA" )
end

local function includeLanguages()
	include( LANGUAGES_PATH.."/english.lua" ) -- we should load english first as we dont want to fuck up language system
	local files, dirs = GetAllLanguages()

	for k, v in pairs( files ) do
		if v == "english.lua" then continue end

		include( LANGUAGES_PATH.."/"..v )
	end
end

function LANG.Register( name, tbl )
	LANG.REG[name] = tbl

	if name != "english" then
		table.Inherit( LANG.REG[name], LANG.REG.english )
	end

	print( "Registered "..name.." language!" )
end

function LANG.Load( langName )
	CUR_LANG = langName

	print( string.upper( langName.." language set!" ) )
end

function LANG.Get( ... )
	local path = LANG.REG[CUR_LANG]
	local tbl = table.Pack( ... )

	for i, v in ipairs( tbl ) do
		path = path[v]
	end

	return path or "NULL_LANG"
end

function LANG.GetAllLangs()
	return table.GetKeys( LANG.REG )
end

includeLanguages()

cvars.AddChangeCallback( "fp_language", function( convar_name, value_old, value_new )
    LANG.Load( value_new )
end)