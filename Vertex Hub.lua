--// Shared access check
local accessOk, allowedUserIds = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/ObsidianLua/fisher-scripts/main/AccessWhitelist.lua"))()
end)

if not accessOk or type(allowedUserIds) ~= "table" or not allowedUserIds[game:GetService("Players").LocalPlayer.UserId] then
	return
end

loadstring(game:HttpGet('https://raw.smokingscripts.org/vertex.lua'))()
