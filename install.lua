local libURL = "https://raw.githubusercontent.com/soverich/minecraft-reactor/main/f.lua"
local startupURL = "https://raw.githubusercontent.com/soverich/minecraft-reactor/main/reactor.lua"
local monitorURL = "https://raw.githubusercontent.com/soverich/minecraft-reactor/main/moni.lua"
local lib, startup, moni
local libFile, startupFile, moniFile
 
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

moni = http.get(monitorURL)
moniFile = startup.readAll()

local file3 = fs.open("moni", "w")
file3 = write(moniFile)
file3.close()
