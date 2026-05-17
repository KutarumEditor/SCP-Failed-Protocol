GM.Name = "SCP: Failed Protocol"
GM.Author = "KUTARUM"
GM.Email = "masterkutarum@gmail.com"
GM.Website = "https://www.youtube.com/@kutarum"

FP_SERVER_COLOR, FP_SERVER_NAME = Color( 175, 25, 25 ), "SCP:FP" --BRICHEVSK

--\\ AUTOINCLUDE //

BASE_LUA_PATH = GM.FolderName
BASE_GAMEMODE_PATH = GM.FolderName.."/gamemode"

MODULES_PATH = BASE_GAMEMODE_PATH.."/modules"
BASE_PATH = BASE_GAMEMODE_PATH.."/base"
LANGUAGES_PATH = BASE_GAMEMODE_PATH.."/languages"
MAP_CONFIG_PATH = BASE_GAMEMODE_PATH.."/mapconfigs"

FPRandom = math.random

local function includeCommonModules()
	if SERVER then
		include( MODULES_PATH.."/sv_module.lua" )
		AddCSLuaFile( MODULES_PATH.."/sh_module.lua" )
		AddCSLuaFile( MODULES_PATH.."/cl_module.lua" )
		print( "||||| LOADED MAIN MODULES" )
	else
		include( MODULES_PATH.."/cl_module.lua" )
	end

	include( MODULES_PATH.."/sh_module.lua" )
end

local function includeByPath( path )
	local files, dirs = file.Find( path.."/*.lua", "LUA" )

	print( "\n|||||||||||||||||||||| SCP:FP | AUTOINCLUDE - "..path.."\n" )

	for k, v in pairs( files ) do
		if v == "sv_module.lua" or v == "sh_module.lua" or v == "cl_module.lua" then continue end

		local filepath = path.."/"..v

		if string.StartsWith( v, "sv_" ) then
			if SERVER then
				include( filepath )
				print( "||||| LOADED SERVER MODULE: "..filepath )
			end
		elseif string.StartsWith( v, "cl_" ) then
			if SERVER then
				AddCSLuaFile( filepath )
			else
				include( filepath )
			end
			print( "||||| LOADED CLIENT MODULE: "..filepath )
		else
			if SERVER then
				AddCSLuaFile( filepath )
			end
			print( "||||| LOADED SHARED MODULE: "..filepath )
			include( filepath )
		end
	end

	print( "\n|||||||||||||||||||||| SCP:FP | AUTOINCLUDE - "..path.."\n" )
end

function GetAllLanguages()
	return file.Find( LANGUAGES_PATH.."/*.lua", "LUA" )
end

local function loadLanguages()
	if not SERVER then return end

	local files, dirs = GetAllLanguages()

	for k, v in pairs( files ) do
		AddCSLuaFile( LANGUAGES_PATH.."/"..v )
		print( "Loaded: "..v )
	end

	print( "SCP:FP | LOADED LOCALIZATION FILES" )
end

-- Loading map config
if SERVER then
	AddCSLuaFile( MAP_CONFIG_PATH.."/"..game.GetMap()..".lua" )
	print( "SCP:FP | LOADED MAP CONFIG" )
end
include( MAP_CONFIG_PATH.."/"..game.GetMap()..".lua" )

-- Loading everything else
includeByPath( BASE_PATH )
includeCommonModules()
includeByPath( MODULES_PATH )

FPRandom = xoshiro128()

-- Loading languages
loadLanguages()