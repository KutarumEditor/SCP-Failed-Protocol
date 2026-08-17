--[[-------------------------------------------------------------------------
Database config
---------------------------------------------------------------------------]]
local FPDatabaseConfig = {
	ENGINE = "SQLite", //"MySQL" for MySQL, anything else for SQLite
	HOST = "",
	PORT = "3306",
	USER = "",
	PASSWORD = "",
	DATABASE = "",
}

if FPDatabaseConfig.ENGINE == "MySQL" then
	FPDatabase:Connect( {
		host = FPDatabaseConfig.HOST,
		port = FPDatabaseConfig.PORT,
		username = FPDatabaseConfig.USER,
		password = FPDatabaseConfig.PASSWORD,
		database = FPDatabaseConfig.DATABASE,
	} )
end