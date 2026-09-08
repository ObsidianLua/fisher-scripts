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
Main.Size = UDim2.new(0, 350, 0, 450)
Main.Position = UDim2.new(0.5, -175, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.Position = UDim2.new(0, 0, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "Fisher Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

--// Credits
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 18)
Credits.Position = UDim2.new(0, 0, 0, 34)
Credits.BackgroundTransparency = 1
Credits.Text = "by @ItzOnlyFisher"
Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
Credits.TextSize = 11
Credits.Font = Enum.Font.Gotham
Credits.Parent = Main

--// UI helpers
local function createLabel(text, y)
	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(0, 125, 0, 35)
	label.Position = UDim2.new(0, 15, 0, y)

	label.BackgroundTransparency = 1

	label.Text = text
	label.TextColor3 = Color3.fromRGB(230, 230, 230)
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

	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)

	button.Text = text
	button.TextSize = 14
	button.Font = Enum.Font.GothamMedium

	button.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.Parent = Main

	return button
end

local function createTextBox(text, x, y, width)
	local box = Instance.new("TextBox")

	box.Size = UDim2.new(0, width or 100, 0, 32)
	box.Position = UDim2.new(0, x, 0, y)

	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)

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

createLabel("Noclip", 65)

local NoclipButton = createButton("OFF", 215, 65, 120)

table.insert(Connections, NoclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled

	if noclipEnabled then
		NoclipButton.Text = "ON"
		NoclipButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	else
		NoclipButton.Text = "OFF"
		NoclipButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

		restoreCollision()
	end
end))

--==================================================
--// WALKSPEED
--==================================================

createLabel("WalkSpeed", 110)

local WalkSpeedBox = createTextBox("16", 145, 110, 100)
local WalkSpeedReset = createButton("Reset", 255, 110, 80)

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

createLabel("JumpPower", 155)

local JumpPowerBox = createTextBox("50", 145, 155, 100)
local JumpPowerReset = createButton("Reset", 255, 155, 80)

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

createLabel("Infinite Jump", 200)

local InfiniteJumpButton = createButton("OFF", 215, 200, 120)

table.insert(Connections, InfiniteJumpButton.MouseButton1Click:Connect(function()
	infiniteJumpEnabled = not infiniteJumpEnabled

	if infiniteJumpEnabled then
		InfiniteJumpButton.Text = "ON"
		InfiniteJumpButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	else
		InfiniteJumpButton.Text = "OFF"
		InfiniteJumpButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	end
end))

--==================================================
--// FLY
--==================================================

createLabel("Fly", 245)
local FlyButton = createButton("OFF", 215, 245, 120)

local function setFlyEnabled(enabled)
	flyEnabled = enabled
	local humanoid = getHumanoid()
	if flyEnabled then
		FlyButton.Text = "ON"
		FlyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
		if humanoid then humanoid.AutoRotate = false end
	else
		FlyButton.Text = "OFF"
		FlyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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

createLabel("Fly Speed", 290)
local FlySpeedBox = createTextBox(tostring(DEFAULT_FLYSPEED), 145, 290, 100)
local FlySpeedReset = createButton("Reset", 255, 290, 80)

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

createLabel("Hide UI Key", 335)
local HideKeyButton = createButton(hideKey.Name, 215, 335, 120)

table.insert(Connections, HideKeyButton.MouseButton1Click:Connect(function()
	waitingForKey = true
	HideKeyButton.Text = "Press a key..."
end))

--==================================================
--// DESTROY GUI
--==================================================

local DestroyButton = createButton("DESTROY GUI", 15, 395, 320)
DestroyButton.BackgroundColor3 = Color3.fromRGB(130, 45, 45)

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
