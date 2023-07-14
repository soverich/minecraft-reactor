local libURL = "https://raw.githubusercontent.com/soverich/minecraft-reactor/main/f.lua"
local startupURL = "https://raw.githubusercontent.com/soverich/minecraft-reactor/main/reactor.lua"
local lib, startup
local libFile, startupFile
 
fs.makeDir("lib")
 
lib = http.get(libURL)
libFile = lib.readAll()
 
local file1 = fs.open("lib/f", "w")
file1.write(libFile)
file1.close()
 
startup = http.get(startupURL)
startupFile = startup.readAll()
 
 
local file2 = fs.open("startup", "w")
file2.write(startupFile)
file2.close()
