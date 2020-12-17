component = require("component")
serialization = require("serialization")
filesystem = require("filesystem")
shell = require("shell")
term = require("term")
gpu = component.gpu
internet = nil
HasInternet = component.isAvailable("internet")
if HasInternet then internet = require("internet") end

local args, opts = shell.parse(...)

function onlineCheck()
  if not HasInternet then
    io.stderr:write("No internet connection. Please install an\nInternet Card\n")
    os.exit(false)
  end
end
BranchURL = "https://raw.githubusercontent.com/bakenNNN/TroReactors"
ReleaseVersionsFile = "/tror/ReleaseVersions.lua"
ReleaseVersions = nil


function createInstallDirectory()
  if not filesystem.isDirectory("/tror") then
    print("Creating \"/tror\" directory")
    local success, msg = filesystem.makeDirectory("/tror")
    if success == nil then
      io.stderr:write("Failed to create \"/tror\" directory, "..msg)
      os.exit(false)
    end
  end
end
function downloadManifestedFiles(program)
  for i,v in ipairs(program.manifest) do downloadFile(v) end
end
function downloadNeededFiles()
  print("Downloading Files, Please Wait...")
  downloadFile(ReleaseVersionsFile)
  local file = io.open(ReleaseVersionsFile)
  ReleaseVersions = serialization.unserialize(file:read("*a"))
  file:close()
  downloadManifestedFiles(ReleaseVersions.launcher)
  if opts.d then ReleaseVersions.launcher.dev = true end
end
function downloadFile(fileName)
  print("Downloading..."..fileName)
  local result = ""
  local response = internet.request(BranchURL..fileName)
  local isGood, err = pcall(function()
    local file, err = io.open(fileName, "w")
    if file == nil then error(err) end
    for chunk in response do
      file:write(chunk)
    end
    file:close()
  end)
  if not isGood then
    io.stderr:write("Unable to Download\n")
    io.stderr:write(err)
    forceExit(false)
  end
end
onlineCheck()
createInstallDirectory()

downloadNeededFiles()
for i,v in ipairs(ReleaseVersions.launcher.note) do print("  "..v) end
print([[
Installation complete!
Use the 'tro' command to run the launcher.
]])
