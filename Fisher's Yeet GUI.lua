--// Fisher Yeet GUI
--// Credits: @ItzOnlyFisher

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local yeeting = false
local activeThrust = nil
local activeConnection = nil

local ToggleKey = Enum.KeyCode.RightShift
local WaitingForToggleKey = false

--==================================================
-- REMOVE OLD GUI
--==================================================

local oldGui = CoreGui:FindFirstChild("FisherYeetGUI")

if oldGui then
	oldGui:Destroy()
end

--==================================================
-- NOTIFICATIONS
--==================================================

local function notify(text, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Fisher Yeet GUI",
			Text = text,
			Icon = "rbxassetid://2005276185",
			Duration = duration or 3
		})
	end)
end

notify("Loaded successfully! @ItzOnlyFisher", 5)

--==================================================
-- PLAYER SEARCH
--==================================================

local function findPlayers(input)
	local found = {}

	if not input or input == "" then
		return found
	end

	local search = input:lower()

	if search == "all" then
		for _, player in ipairs(Players:GetPlayers()) do
			table.insert(found, player)
		end

	elseif search == "others" then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(found, player)
			end
		end

	elseif search == "me" then
		table.insert(found, LocalPlayer)

	else
		for _, player in ipairs(Players:GetPlayers()) do
			local username = player.Name:lower()
			local displayName = player.DisplayName:lower()

			if username:sub(1, #search) == search
				or displayName:sub(1, #search) == search then

				table.insert(found, player)
			end
		end
	end

	return found
end

--==================================================
-- STOP ALL FLINGING
--==================================================

local function stopAllFlinging()
	yeeting = false

	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end

	if activeThrust then
		pcall(function()
			activeThrust:Destroy()
		end)

		activeThrust = nil
	end

	local character = LocalPlayer.Character

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BodyThrust")
			or object:IsA("BodyVelocity")
			or object:IsA("BodyAngularVelocity")
			or object:IsA("VectorForce")
			or object:IsA("AngularVelocity") then

			pcall(function()
				object:Destroy()
			end)
		end
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

--==================================================
-- YEET PLAYER
--==================================================

local function yeetPlayer(target)
	stopAllFlinging()

	if not target then
		notify("Invalid player")
		return
	end

	if target == LocalPlayer then
		notify("You selected yourself")
		return
	end

	local character = LocalPlayer.Character
	local targetCharacter = target.Character

	if not character or not targetCharacter then
		notify("Character not loaded")
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

	if not root or not humanoid or not targetRoot or not targetHumanoid then
		notify("Missing character parts")
		return
	end

	yeeting = true

	local thrust = Instance.new("BodyThrust")

	thrust.Name = "YeetForce"
	thrust.Force = Vector3.new(
		99999,
		99999,
		99999
	)

	thrust.Location = Vector3.zero
	thrust.Parent = root

	activeThrust = thrust

	notify("Yeeting " .. target.Name, 3)

	activeConnection = RunService.Heartbeat:Connect(function()
		if not yeeting then
			stopAllFlinging()
			return
		end

		character = LocalPlayer.Character
		targetCharacter = target.Character

		if not character
			or not targetCharacter
			or not target.Parent then

			stopAllFlinging()
			return
		end

		root = character:FindFirstChild("HumanoidRootPart")
		targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
		targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

		if not root
			or not targetRoot
			or not targetHumanoid
			or targetHumanoid.Health <= 0 then

			stopAllFlinging()
			return
		end

		root.CFrame =
			targetRoot.CFrame
			* CFrame.new(
				math.random(-2, 2),
				math.random(-1, 1),
				math.random(-2, 2)
			)

		thrust.Location = targetRoot.Position

		root.AssemblyAngularVelocity =
			Vector3.new(
				math.random(-9999, 9999),
				math.random(-9999, 9999),
				math.random(-9999, 9999)
			)
	end)
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "FisherYeetGUI"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")

Main.Name = "Main"
Main.Size = UDim2.new(0, 380, 0, 365)
Main.Position = UDim2.new(0.5, -190, 0.5, -182)

Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0

Main.Active = true
Main.Draggable = true

Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Color = Color3.fromRGB(90, 90, 90)
MainStroke.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, 0, 0, 38)
Title.Position = UDim2.new(0, 0, 0, 5)

Title.BackgroundTransparency = 1

Title.Text = "Fisher Yeet GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

Title.TextSize = 22
Title.Font = Enum.Font.GothamBold

Title.Parent = Main

--==================================================
-- CREDITS
--==================================================

local Credits = Instance.new("TextLabel")

Credits.Size = UDim2.new(1, 0, 0, 18)
Credits.Position = UDim2.new(0, 0, 0, 38)

Credits.BackgroundTransparency = 1

Credits.Text = "by @ItzOnlyFisher"
Credits.TextColor3 = Color3.fromRGB(145, 145, 145)

Credits.TextSize = 11
Credits.Font = Enum.Font.Gotham

Credits.Parent = Main

--==================================================
-- TARGET BOX
--==================================================

local TargetBox = Instance.new("TextBox")

TargetBox.Size = UDim2.new(1, -30, 0, 45)
TargetBox.Position = UDim2.new(0, 15, 0, 75)

TargetBox.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
TargetBox.BorderSizePixel = 0

TargetBox.Text = ""
TargetBox.PlaceholderText = "Player / display name / shortened username"

TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)

TargetBox.TextSize = 14
TargetBox.Font = Enum.Font.Gotham

TargetBox.ClearTextOnFocus = false

TargetBox.Parent = Main

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 6)
TargetCorner.Parent = TargetBox

--==================================================
-- YEET BUTTON
--==================================================

local YeetButton = Instance.new("TextButton")

YeetButton.Size = UDim2.new(1, -30, 0, 42)
YeetButton.Position = UDim2.new(0, 15, 0, 135)

YeetButton.BackgroundColor3 = Color3.fromRGB(60, 110, 180)
YeetButton.BorderSizePixel = 0

YeetButton.Text = "YEET PLAYER"
YeetButton.TextColor3 = Color3.fromRGB(255, 255, 255)

YeetButton.TextSize = 14
YeetButton.Font = Enum.Font.GothamBold

YeetButton.Parent = Main

local YeetCorner = Instance.new("UICorner")
YeetCorner.CornerRadius = UDim.new(0, 6)
YeetCorner.Parent = YeetButton

--==================================================
-- STOP BUTTON
--==================================================

local StopButton = Instance.new("TextButton")

StopButton.Size = UDim2.new(1, -30, 0, 42)
StopButton.Position = UDim2.new(0, 15, 0, 187)

StopButton.BackgroundColor3 = Color3.fromRGB(155, 75, 40)
StopButton.BorderSizePixel = 0

StopButton.Text = "STOP ALL FLINGING"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)

StopButton.TextSize = 14
StopButton.Font = Enum.Font.GothamBold

StopButton.Parent = Main

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 6)
StopCorner.Parent = StopButton

--==================================================
-- KEYBIND ROW
--==================================================

local KeybindLabel = Instance.new("TextLabel")

KeybindLabel.Size = UDim2.new(0, 135, 0, 35)
KeybindLabel.Position = UDim2.new(0, 15, 0, 239)

KeybindLabel.BackgroundTransparency = 1

KeybindLabel.Text = "Hide UI Key"
KeybindLabel.TextColor3 = Color3.fromRGB(230, 230, 230)

KeybindLabel.TextSize = 14
KeybindLabel.Font = Enum.Font.Gotham

KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

KeybindLabel.Parent = Main

local KeybindButton = Instance.new("TextButton")

KeybindButton.Size = UDim2.new(0, 205, 0, 35)
KeybindButton.Position = UDim2.new(1, -220, 0, 239)

KeybindButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeybindButton.BorderSizePixel = 0

KeybindButton.Text = ToggleKey.Name
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)

KeybindButton.TextSize = 13
KeybindButton.Font = Enum.Font.GothamMedium

KeybindButton.Parent = Main

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 6)
KeybindCorner.Parent = KeybindButton

--==================================================
-- DESTROY BUTTON
--==================================================

local DestroyButton = Instance.new("TextButton")

DestroyButton.Size = UDim2.new(1, -30, 0, 42)
DestroyButton.Position = UDim2.new(0, 15, 0, 292)

DestroyButton.BackgroundColor3 = Color3.fromRGB(130, 45, 45)
DestroyButton.BorderSizePixel = 0

DestroyButton.Text = "DESTROY GUI"
DestroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)

DestroyButton.TextSize = 14
DestroyButton.Font = Enum.Font.GothamBold

DestroyButton.Parent = Main

local DestroyCorner = Instance.new("UICorner")
DestroyCorner.CornerRadius = UDim.new(0, 6)
DestroyCorner.Parent = DestroyButton

--==================================================
-- BUTTON EVENTS
--==================================================

YeetButton.MouseButton1Click:Connect(function()
	local results = findPlayers(TargetBox.Text)

	if #results == 0 then
		notify("Invalid player")
		return
	end

	if #results > 1 then
		notify(
			"Multiple matches - using "
				.. results[1].Name
		)
	end

	yeetPlayer(results[1])
end)

StopButton.MouseButton1Click:Connect(function()
	stopAllFlinging()

	notify(
		"All flinging stopped",
		3
	)
end)

KeybindButton.MouseButton1Click:Connect(function()
	WaitingForToggleKey = true
	KeybindButton.Text = "Press a key..."
end)

DestroyButton.MouseButton1Click:Connect(function()
	stopAllFlinging()

	if Gui then
		Gui:Destroy()
	end

	notify(
		"Fisher Yeet GUI destroyed",
		3
	)
end)

--==================================================
-- KEYBIND HANDLER
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if WaitingForToggleKey
		and input.UserInputType == Enum.UserInputType.Keyboard then

		if input.KeyCode ~= Enum.KeyCode.Unknown then
			ToggleKey = input.KeyCode
			KeybindButton.Text = ToggleKey.Name
			WaitingForToggleKey = false

			notify(
				"Hide UI key changed to "
					.. ToggleKey.Name,
				3
			)
		end

		return
	end

	if input.KeyCode == ToggleKey then
		Main.Visible = not Main.Visible
	end
end)

--==================================================
-- RESPAWN CLEANUP
--==================================================

LocalPlayer.CharacterAdded:Connect(function()
	stopAllFlinging()
end)