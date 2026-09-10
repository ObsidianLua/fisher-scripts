-- Fisher Script Hub
-- Select a script below to fetch and run its public GitHub raw URL.

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local baseUrl = "https://raw.githubusercontent.com/ObsidianLua/fisher-scripts/main/"

local scriptGroups = {
    {
        name = "Sync Scripts",
        scripts = {
            {name = "Bang V2 - R6", file = "Bang%20V2%20-%20R6.lua"},
            {name = "Bang V2 - R15", file = "Bang%20V2%20-%20R15.lua"},
            {name = "Get Banged - R6", file = "Get%20Banged%20-%20R6.lua"},
            {name = "Get Banged - R15", file = "Get%20Banged%20-%20R15.lua"},
            {name = "Suck - R6", file = "Suck%20-%20R6.lua"},
            {name = "Suck - R15", file = "Suck%20-%20R15.lua"},
            {name = "Get Suc - R6", file = "Get%20Suc%20-%20R6.lua"},
            {name = "Get Suc - R15", file = "Get%20Suc%20-%20R15.lua"},
            {name = "Jerk - R6", file = "Jerk%20-%20R6.lua"},
            {name = "Jerk - R15", file = "Jerk%20-%20R15.lua"},
        },
    },
    {
        name = "Other Scripts",
        scripts = {
            {name = "Fisher Hub", file = "Fisher%20Hub.lua"},
            {name = "Fisher MM2 Tools", file = "Fisher%20MM2%20Tools.lua"},
            {name = "Fisher's Yeet GUI", file = "Fisher%27s%20Yeet%20GUI.lua"},
            {name = "Give Them Head", file = "Give%20Them%20Head.lua"},
            {name = "Break Your Bones Script", file = "Break%20Your%20Bones%20Script.lua"},
            {name = "Infinite Yield", file = "Infinite%20Yield.lua"},
            {name = "Vertex Hub", file = "Vertex%20Hub.lua"},
        },
    },
}

if CoreGui:FindFirstChild("FisherScriptHub") then
    CoreGui.FisherScriptHub:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "FisherScriptHub"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(440, 500)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(18, 24, 20)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -58, 0, 58)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "FISHER SCRIPT HUB"
title.TextColor3 = Color3.fromRGB(214, 255, 69)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(38, 38)
close.Position = UDim2.new(1, -48, 0, 10)
close.BackgroundColor3 = Color3.fromRGB(46, 60, 49)
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextColor3 = Color3.fromRGB(244, 241, 233)
close.TextSize = 24
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 28)
status.Position = UDim2.fromOffset(20, 52)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Choose a script to load"
status.TextColor3 = Color3.fromRGB(165, 172, 162)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -40, 1, -100)
list.Position = UDim2.fromOffset(20, 84)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.ScrollBarThickness = 5
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = list

local function loadScript(scriptInfo)
    status.Text = "Loading " .. scriptInfo.name .. "..."
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. scriptInfo.file))()
    end)
    status.Text = success and (scriptInfo.name .. " loaded") or ("Could not load " .. scriptInfo.name)
    if not success then
        warn("Fisher Script Hub:", result)
    end
end

for _, group in ipairs(scriptGroups) do
    local heading = Instance.new("TextLabel")
    heading.Size = UDim2.new(1, 0, 0, 28)
    heading.BackgroundTransparency = 1
    heading.Font = Enum.Font.GothamBold
    heading.Text = group.name:upper()
    heading.TextColor3 = Color3.fromRGB(214, 255, 69)
    heading.TextSize = 12
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = list

    for _, scriptInfo in ipairs(group.scripts) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 38)
        button.BackgroundColor3 = Color3.fromRGB(38, 50, 42)
        button.Font = Enum.Font.GothamMedium
        button.Text = scriptInfo.name
        button.TextColor3 = Color3.fromRGB(244, 241, 233)
        button.TextSize = 14
        button.Parent = list
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
        button.MouseButton1Click:Connect(function()
            loadScript(scriptInfo)
        end)
    end
end
