--// Shared access check
local accessOk, allowedUserIds = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/ObsidianLua/fisher-scripts/main/AccessWhitelist.lua"))()
end)

if not accessOk or type(allowedUserIds) ~= "table" or not allowedUserIds[game:GetService("Players").LocalPlayer.UserId] then
	return
end

--// Fisher Hub
--// Credits: @ItzOnlyFisher

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--// Defaults
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local DEFAULT_FLYSPEED = 50

--// Settings
local noclipEnabled = false
local infiniteJumpEnabled = false
local flyEnabled = false

local walkSpeed = DEFAULT_WALKSPEED
local jumpPower = DEFAULT_JUMPPOWER
local flySpeed = DEFAULT_FLYSPEED

local flyKeys = {
	W = false, A = false, S = false, D = false, Space = false, LeftControl = false
}

local hideKey = Enum.KeyCode.RightShift
local waitingForKey = false
local destroyed = false

local Connections = {}

--// Midnight Ocean visual palette
local COLORS = {
	Background = Color3.fromRGB(8, 15, 24),
	Panel = Color3.fromRGB(13, 24, 36),
	Control = Color3.fromRGB(22, 38, 52),
	Accent = Color3.fromRGB(55, 180, 230),
	Enabled = Color3.fromRGB(40, 170, 130),
	Danger = Color3.fromRGB(180, 55, 65),
	Text = Color3.fromRGB(240, 248, 255),
	Muted = Color3.fromRGB(145, 170, 190),
}

--// Remove old GUI
local oldGui = CoreGui:FindFirstChild("FisherHub")

if oldGui then
	oldGui:Destroy()
end

--// Helpers
local function getHumanoid()
	local character = Player.Character

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function setWalkSpeed(value)
	walkSpeed = value

	local humanoid = getHumanoid()

	if humanoid then
		humanoid.WalkSpeed = value
	end
end

local function setJumpPower(value)
	jumpPower = value

	local humanoid = getHumanoid()

	if humanoid then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = value
	end
end

local function restoreCollision()
	local character = Player.Character

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CanCollide = true
		end
	end
end

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FisherHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 390, 0, 510)
Main.Position = UDim2.new(0.5, -195, 0.5, -255)
Main.BackgroundColor3 = COLORS.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local OceanLayer = Instance.new("Frame")
OceanLayer.Size = UDim2.fromScale(1, 1)
OceanLayer.BackgroundColor3 = COLORS.Panel
OceanLayer.BackgroundTransparency = 0.18
OceanLayer.BorderSizePixel = 0
OceanLayer.ZIndex = 0
OceanLayer.Parent = Main
Instance.new("UICorner", OceanLayer).CornerRadius = UDim.new(0, 10)

local OceanGradient = Instance.new("UIGradient")
OceanGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 35, 55)),
	ColorSequenceKeypoint.new(0.55, COLORS.Panel),
	ColorSequenceKeypoint.new(1, COLORS.Background),
})
OceanGradient.Rotation = 35
OceanGradient.Parent = OceanLayer

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 32)
Title.Position = UDim2.new(0, 18, 0, 12)
Title.BackgroundTransparency = 1
Title.Text = "🌊 Fisher Hub"
Title.TextColor3 = COLORS.Accent
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--// Credits
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, -70, 0, 18)
Credits.Position = UDim2.new(0, 20, 0, 42)
Credits.BackgroundTransparency = 1
Credits.Text = "by @ItzOnlyFisher"
Credits.TextColor3 = COLORS.Muted
Credits.TextSize = 11
Credits.Font = Enum.Font.Gotham
Credits.TextXAlignment = Enum.TextXAlignment.Left
Credits.Parent = Main

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -36, 0, 1)
Separator.Position = UDim2.new(0, 18, 0, 66)
Separator.BackgroundColor3 = COLORS.Accent
Separator.BackgroundTransparency = 0.55
Separator.BorderSizePixel = 0
Separator.Parent = Main

local CollapseButton = Instance.new("TextButton")
CollapseButton.Size = UDim2.new(0, 30, 0, 28)
CollapseButton.Position = UDim2.new(1, -46, 0, 16)
CollapseButton.BackgroundColor3 = COLORS.Control
CollapseButton.TextColor3 = COLORS.Text
CollapseButton.Text = "—"
CollapseButton.TextSize = 18
CollapseButton.Font = Enum.Font.GothamBold
CollapseButton.Parent = Main
Instance.new("UICorner", CollapseButton).CornerRadius = UDim.new(0, 7)

local collapsed = false
local expandedSize = Main.Size
table.insert(Connections, CollapseButton.MouseButton1Click:Connect(function()
	collapsed = not collapsed
	Main.Size = collapsed and UDim2.new(0, 390, 0, 76) or expandedSize
	CollapseButton.Text = collapsed and "+" or "—"
	for _, child in ipairs(Main:GetChildren()) do
		if child ~= Title and child ~= Credits and child ~= CollapseButton and child ~= OceanLayer then
			child.Visible = not collapsed
		end
	end
end))

--// UI helpers
local function createLabel(text, y)
	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(0, 150, 0, 32)
	label.Position = UDim2.new(0, 20, 0, y)

	label.BackgroundTransparency = 1

	label.Text = text
	label.TextColor3 = COLORS.Text
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham

	label.Parent = Main

	return label
end

local function createButton(text, x, y, width)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(0, width or 120, 0, 32)
	button.Position = UDim2.new(0, x, 0, y)

	button.BackgroundColor3 = COLORS.Control
	button.TextColor3 = COLORS.Text

	button.Text = text
	button.TextSize = 14
	button.Font = Enum.Font.GothamMedium

	button.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	button.Parent = Main

	return button
end

local function createTextBox(text, x, y, width)
	local box = Instance.new("TextBox")

	box.Size = UDim2.new(0, width or 100, 0, 32)
	box.Position = UDim2.new(0, x, 0, y)

	box.BackgroundColor3 = COLORS.Control
	box.TextColor3 = COLORS.Text

	box.Text = text
	box.PlaceholderText = text

	box.TextSize = 14
	box.Font = Enum.Font.GothamMedium

	box.ClearTextOnFocus = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = box

	box.Parent = Main

	return box
end

--==================================================
--// NOCLIP
--==================================================

local MovementHeader = createLabel("MOVEMENT", 82)
MovementHeader.TextColor3 = COLORS.Accent
MovementHeader.TextSize = 12
MovementHeader.Font = Enum.Font.GothamBold

createLabel("Noclip", 108)

local NoclipButton = createButton("OFF", 240, 108, 130)

table.insert(Connections, NoclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled

	if noclipEnabled then
		NoclipButton.Text = "ON"
		NoclipButton.BackgroundColor3 = COLORS.Enabled
	else
		NoclipButton.Text = "OFF"
		NoclipButton.BackgroundColor3 = COLORS.Control

		restoreCollision()
	end
end))

--==================================================
--// WALKSPEED
--==================================================

createLabel("WalkSpeed", 150)

local WalkSpeedBox = createTextBox("16", 160, 150, 100)
local WalkSpeedReset = createButton("Reset", 270, 150, 100)

table.insert(Connections, WalkSpeedBox.FocusLost:Connect(function()
	local value = tonumber(WalkSpeedBox.Text)

	if value then
		setWalkSpeed(value)
		WalkSpeedBox.Text = tostring(value)
	else
		WalkSpeedBox.Text = tostring(walkSpeed)
	end
end))

table.insert(Connections, WalkSpeedReset.MouseButton1Click:Connect(function()
	setWalkSpeed(DEFAULT_WALKSPEED)
	WalkSpeedBox.Text = tostring(DEFAULT_WALKSPEED)
end))

--==================================================
--// JUMP POWER
--==================================================

createLabel("JumpPower", 192)

local JumpPowerBox = createTextBox("50", 160, 192, 100)
local JumpPowerReset = createButton("Reset", 270, 192, 100)

table.insert(Connections, JumpPowerBox.FocusLost:Connect(function()
	local value = tonumber(JumpPowerBox.Text)

	if value then
		setJumpPower(value)
		JumpPowerBox.Text = tostring(value)
	else
		JumpPowerBox.Text = tostring(jumpPower)
	end
end))

table.insert(Connections, JumpPowerReset.MouseButton1Click:Connect(function()
	setJumpPower(DEFAULT_JUMPPOWER)
	JumpPowerBox.Text = tostring(DEFAULT_JUMPPOWER)
end))

--==================================================
--// INFINITE JUMP
--==================================================

createLabel("Infinite Jump", 234)

local InfiniteJumpButton = createButton("OFF", 240, 234, 130)

table.insert(Connections, InfiniteJumpButton.MouseButton1Click:Connect(function()
	infiniteJumpEnabled = not infiniteJumpEnabled

	if infiniteJumpEnabled then
		InfiniteJumpButton.Text = "ON"
		InfiniteJumpButton.BackgroundColor3 = COLORS.Enabled
	else
		InfiniteJumpButton.Text = "OFF"
		InfiniteJumpButton.BackgroundColor3 = COLORS.Control
	end
end))

--==================================================
--// FLY
--==================================================

local FlightHeader = createLabel("FLIGHT", 278)
FlightHeader.TextColor3 = COLORS.Accent
FlightHeader.TextSize = 12
FlightHeader.Font = Enum.Font.GothamBold

createLabel("Fly", 302)
local FlyButton = createButton("OFF", 240, 302, 130)

local FlyInfoButton = createButton("ⓘ", 174, 302, 28)
FlyInfoButton.TextSize = 16

local FlyHelp = Instance.new("TextLabel")
FlyHelp.Size = UDim2.new(0, 190, 0, 78)
FlyHelp.Position = UDim2.new(0, 168, 0, 330)
FlyHelp.BackgroundColor3 = COLORS.Panel
FlyHelp.BackgroundTransparency = 0.05
FlyHelp.TextColor3 = COLORS.Text
FlyHelp.Text = "FLY CONTROLS\nW/A/S/D — Move\nSpace — Up\nLeft Ctrl — Down"
FlyHelp.TextSize = 11
FlyHelp.Font = Enum.Font.Gotham
FlyHelp.TextXAlignment = Enum.TextXAlignment.Left
FlyHelp.TextYAlignment = Enum.TextYAlignment.Center
FlyHelp.Visible = false
FlyHelp.ZIndex = 3
FlyHelp.Parent = Main
Instance.new("UICorner", FlyHelp).CornerRadius = UDim.new(0, 7)

table.insert(Connections, FlyInfoButton.MouseButton1Click:Connect(function()
	FlyHelp.Visible = not FlyHelp.Visible
end))

local function setFlyEnabled(enabled)
	flyEnabled = enabled
	local humanoid = getHumanoid()
	if flyEnabled then
		FlyButton.Text = "ON"
		FlyButton.BackgroundColor3 = COLORS.Enabled
		if humanoid then humanoid.AutoRotate = false end
	else
		FlyButton.Text = "OFF"
		FlyButton.BackgroundColor3 = COLORS.Control
		local character = Player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		if humanoid then humanoid.AutoRotate = true end
	end
end

table.insert(Connections, FlyButton.MouseButton1Click:Connect(function()
	setFlyEnabled(not flyEnabled)
end))

--==================================================
--// FLY SPEED
--==================================================

createLabel("Fly Speed", 344)
local FlySpeedBox = createTextBox(tostring(DEFAULT_FLYSPEED), 160, 344, 100)
local FlySpeedReset = createButton("Reset", 270, 344, 100)

table.insert(Connections, FlySpeedBox.FocusLost:Connect(function()
	local value = tonumber(FlySpeedBox.Text)
	if value and value >= 0 then
		flySpeed = value
		FlySpeedBox.Text = tostring(value)
	else
		FlySpeedBox.Text = tostring(flySpeed)
	end
end))

table.insert(Connections, FlySpeedReset.MouseButton1Click:Connect(function()
	flySpeed = DEFAULT_FLYSPEED
	FlySpeedBox.Text = tostring(DEFAULT_FLYSPEED)
end))

--==================================================
--// HIDE UI KEY
--==================================================

local SettingsHeader = createLabel("SETTINGS", 390)
SettingsHeader.TextColor3 = COLORS.Accent
SettingsHeader.TextSize = 12
SettingsHeader.Font = Enum.Font.GothamBold

createLabel("Hide UI Key", 414)
local HideKeyButton = createButton(hideKey.Name, 240, 414, 130)

table.insert(Connections, HideKeyButton.MouseButton1Click:Connect(function()
	waitingForKey = true
	HideKeyButton.Text = "Press a key..."
end))

--==================================================
--// DESTROY GUI
--==================================================

local DestroyButton = createButton("DESTROY GUI", 20, 462, 350)
DestroyButton.BackgroundColor3 = COLORS.Danger

--==================================================
--// NOCLIP LOOP
--==================================================

table.insert(Connections, RunService.Stepped:Connect(function()
	if destroyed then
		return
	end

	if noclipEnabled then
		local character = Player.Character

		if character then
			for _, object in ipairs(character:GetDescendants()) do
				if object:IsA("BasePart") then
					object.CanCollide = false
				end
			end
		end
	end
end))

--==================================================
--// INFINITE JUMP
--==================================================

table.insert(Connections, UserInputService.JumpRequest:Connect(function()
	if destroyed then
		return
	end

	if infiniteJumpEnabled then
		local humanoid = getHumanoid()

		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end))

--==================================================
--// FLY LOOP
--==================================================

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if destroyed or not flyEnabled then return end
	local character = Player.Character
	local humanoid = getHumanoid()
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not character or not humanoid or not root or not camera then return end
	humanoid.AutoRotate = false
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	local flatRight = Vector3.new(right.X, 0, right.Z)
	if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
	if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
	local direction = Vector3.zero
	if flyKeys.W then direction += flatLook end
	if flyKeys.S then direction -= flatLook end
	if flyKeys.D then direction += flatRight end
	if flyKeys.A then direction -= flatRight end
	if flyKeys.Space then direction += Vector3.new(0, 1, 0) end
	if flyKeys.LeftControl then direction -= Vector3.new(0, 1, 0) end
	if direction.Magnitude > 0 then direction = direction.Unit end
	root.AssemblyLinearVelocity = direction * flySpeed
	root.AssemblyAngularVelocity = Vector3.zero
end))

--==================================================
--// KEYBIND
--==================================================

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if destroyed then return end
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
		elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
		elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
		elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true
		elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true
		elseif input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.LeftControl = true end
	end

	if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
		hideKey = input.KeyCode
		HideKeyButton.Text = hideKey.Name
		waitingForKey = false
		return
	end

	if input.KeyCode == hideKey then
		Main.Visible = not Main.Visible
	end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
	elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
	elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
	elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false
	elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.LeftControl = false end
end))

--==================================================
--// RESPAWN
--==================================================

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	if destroyed then
		return
	end

	humanoid.WalkSpeed = walkSpeed
	humanoid.UseJumpPower = true
	humanoid.JumpPower = jumpPower
	humanoid.AutoRotate = not flyEnabled
end

if Player.Character then
	task.spawn(setupCharacter, Player.Character)
end

table.insert(Connections, Player.CharacterAdded:Connect(setupCharacter))

--==================================================
--// DESTROY / CLEANUP
--==================================================

table.insert(Connections, DestroyButton.MouseButton1Click:Connect(function()
	noclipEnabled = false
	infiniteJumpEnabled = false
	setFlyEnabled(false)
	waitingForKey = false

	setWalkSpeed(DEFAULT_WALKSPEED)
	setJumpPower(DEFAULT_JUMPPOWER)

	restoreCollision()

	destroyed = true

	for _, connection in ipairs(Connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	ScreenGui:Destroy()
end))
