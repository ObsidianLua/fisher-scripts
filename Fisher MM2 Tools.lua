--// Fisher MM2 Tools
--// Credits: @ItzOnlyFisher

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FisherMM2 = {}

--==================================================
-- CONFIG
--==================================================

local Config = {
	ToggleKey = Enum.KeyCode.RightControl,
	EspKey = Enum.KeyCode.F2,

	EspEnabled = false,
	ShowBoxes = true,
	ShowNames = true,
	ShowRoles = true,
	ShowDistance = true,
	MaxDistance = 1000,

	Colors = {
		Murderer = Color3.fromRGB(255, 70, 70),
		Sheriff = Color3.fromRGB(70, 140, 255),
		Innocent = Color3.fromRGB(80, 220, 120),
		Unknown = Color3.fromRGB(255, 255, 255)
	}
}

local Connections = {}
local EspObjects = {}

local Gui
local Main
local ToggleButton
local PlayerList
local StatusLabel
local EspButton

local destroyed = false

--==================================================
-- CONNECTION HELPER
--==================================================

local function Connect(signal, callback)
	local connection = signal:Connect(callback)

	table.insert(Connections, connection)

	return connection
end

--==================================================
-- ROLE DETECTION
--==================================================

local function HasTool(player, toolName)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")

	if character and character:FindFirstChild(toolName) then
		return true
	end

	if backpack and backpack:FindFirstChild(toolName) then
		return true
	end

	return false
end

function FisherMM2:GetRole(player)
	if not player then
		return "Unknown"
	end

	-- Attribute support
	local roleAttribute = player:GetAttribute("Role")

	if roleAttribute then
		return tostring(roleAttribute)
	end

	-- Value support
	local roleValue = player:FindFirstChild("Role")

	if roleValue and roleValue:IsA("StringValue") then
		return roleValue.Value
	end

	-- MM2-style tool detection
	if HasTool(player, "Knife") then
		return "Murderer"
	end

	if HasTool(player, "Gun") then
		return "Sheriff"
	end

	return "Innocent"
end

function FisherMM2:GetRoleColor(role)
	return Config.Colors[role] or Config.Colors.Unknown
end

--==================================================
-- UI HELPERS
--==================================================

local function CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")

	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent

	return corner
end

local function CreateButton(parent, text)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, 0, 0, 32)
	button.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)

	button.Text = text
	button.TextSize = 14
	button.Font = Enum.Font.GothamMedium

	button.BorderSizePixel = 0
	button.AutoButtonColor = true

	CreateCorner(button, 6)

	button.Parent = parent

	return button
end

local function SetToggleButton(button, state, prefix)
	button.Text = prefix .. ": " .. (state and "ON" or "OFF")

	if state then
		button.BackgroundColor3 = Color3.fromRGB(45, 120, 70)
	else
		button.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	end
end

--==================================================
-- TELEPORT
--==================================================

function FisherMM2:TeleportToPlayer(player)
	if not player then
		return
	end

	local localCharacter = LocalPlayer.Character
	local targetCharacter = player.Character

	if not localCharacter or not targetCharacter then
		StatusLabel.Text = "Character unavailable"
		return
	end

	local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

	if not localRoot or not targetRoot then
		StatusLabel.Text = "RootPart unavailable"
		return
	end

	localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 3)

	StatusLabel.Text = "Teleported to " .. player.Name

	local marker = Instance.new("Part")

	marker.Name = "FisherTeleportMarker"
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(1, 1, 1)
	marker.Anchored = true
	marker.CanCollide = false
	marker.Material = Enum.Material.Neon
	marker.Transparency = 0.4
	marker.Color = Color3.fromRGB(80, 180, 255)
	marker.CFrame = targetRoot.CFrame
	marker.Parent = workspace

	Debris:AddItem(marker, 1.5)
end

--==================================================
-- ESP
--==================================================

function FisherMM2:RemoveEsp(player)
	local data = EspObjects[player]

	if not data then
		return
	end

	for _, object in pairs(data) do
		if typeof(object) == "Instance" then
			object:Destroy()
		end
	end

	EspObjects[player] = nil
end

function FisherMM2:CreateEsp(player)
	if player == LocalPlayer then
		return
	end

	self:RemoveEsp(player)

	local character = player.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	-- Highlight / box style ESP
	local highlight = Instance.new("Highlight")

	highlight.Name = "FisherHighlight"
	highlight.Adornee = character
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.Parent = character

	-- Billboard
	local billboard = Instance.new("BillboardGui")

	billboard.Name = "FisherESP"
	billboard.Size = UDim2.new(0, 220, 0, 55)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = root
	billboard.Parent = root

	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1

	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.3
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

	label.TextSize = 14
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	EspObjects[player] = {
		Highlight = highlight,
		Billboard = billboard,
		Label = label
	}

	task.spawn(function()
		while
			not destroyed
			and Config.EspEnabled
			and player.Parent
			and EspObjects[player]
		do
			local currentCharacter = player.Character

			local currentRoot =
				currentCharacter
				and currentCharacter:FindFirstChild("HumanoidRootPart")

			if currentCharacter and currentRoot then
				local role = self:GetRole(player)
				local color = self:GetRoleColor(role)

				local distance =
					(Camera.CFrame.Position - currentRoot.Position).Magnitude

				local visible =
					distance <= Config.MaxDistance

				highlight.Adornee = currentCharacter
				highlight.FillColor = color
				highlight.OutlineColor = color

				highlight.Enabled =
					visible
					and Config.ShowBoxes

				billboard.Adornee = currentRoot

				billboard.Enabled =
					visible
					and (
						Config.ShowNames
						or Config.ShowRoles
					)

				local textParts = {}

				if Config.ShowNames then
					table.insert(textParts, player.Name)
				end

				if Config.ShowRoles then
					table.insert(textParts, "[" .. role .. "]")
				end

				if Config.ShowDistance then
					table.insert(
						textParts,
						math.floor(distance) .. "m"
					)
				end

				label.Text =
					table.concat(textParts, " ")

				label.TextColor3 = color
			else
				billboard.Enabled = false
				highlight.Enabled = false
			end

			task.wait(0.1)
		end
	end)
end

function FisherMM2:RefreshEsp()
	for player in pairs(EspObjects) do
		self:RemoveEsp(player)
	end

	if not Config.EspEnabled then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			self:CreateEsp(player)
		end
	end
end

--==================================================
-- PLAYER LIST
--==================================================

function FisherMM2:CreatePlayerEntry(player)
	local entry = Instance.new("Frame")

	entry.Name = player.Name .. "_Entry"
	entry.Size = UDim2.new(1, -6, 0, 46)
	entry.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	entry.BorderSizePixel = 0

	CreateCorner(entry, 6)

	-- Display name
	local nameLabel = Instance.new("TextLabel")

	nameLabel.Size = UDim2.new(0.55, 0, 0.5, 0)
	nameLabel.Position = UDim2.new(0, 10, 0, 2)
	nameLabel.BackgroundTransparency = 1

	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextSize = 13

	nameLabel.Parent = entry

	-- Username
	local usernameLabel = Instance.new("TextLabel")

	usernameLabel.Size = UDim2.new(0.55, 0, 0.4, 0)
	usernameLabel.Position = UDim2.new(0, 10, 0.5, 0)
	usernameLabel.BackgroundTransparency = 1

	usernameLabel.Text = "@" .. player.Name
	usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)

	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.Font = Enum.Font.Gotham
	usernameLabel.TextSize = 11

	usernameLabel.Parent = entry

	-- Role
	local roleLabel = Instance.new("TextLabel")

	roleLabel.Size = UDim2.new(0, 85, 0, 20)
	roleLabel.Position = UDim2.new(1, -145, 0.5, -10)
	roleLabel.BackgroundTransparency = 1

	roleLabel.Font = Enum.Font.GothamBold
	roleLabel.TextSize = 12

	roleLabel.Parent = entry

	-- Teleport button
	local tpButton = Instance.new("TextButton")

	tpButton.Size = UDim2.new(0, 50, 0, 28)
	tpButton.Position = UDim2.new(1, -55, 0.5, -14)

	tpButton.BackgroundColor3 = Color3.fromRGB(60, 110, 180)
	tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)

	tpButton.Text = "TP"
	tpButton.TextSize = 12
	tpButton.Font = Enum.Font.GothamBold

	tpButton.BorderSizePixel = 0

	tpButton.Parent = entry

	CreateCorner(tpButton, 5)

	Connect(tpButton.MouseButton1Click, function()
		self:TeleportToPlayer(player)
	end)

	task.spawn(function()
		while
			not destroyed
			and entry.Parent
			and player.Parent
		do
			local role = self:GetRole(player)

			roleLabel.Text = role
			roleLabel.TextColor3 =
				self:GetRoleColor(role)

			task.wait(0.5)
		end
	end)

	return entry
end

function FisherMM2:RefreshPlayerList()
	if not PlayerList then
		return
	end

	for _, child in ipairs(PlayerList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local count = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local entry =
			self:CreatePlayerEntry(player)

		entry.Parent = PlayerList

		count += 1
	end

	PlayerList.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			count * 52
		)

	StatusLabel.Text =
		tostring(count) .. " players"
end

--==================================================
-- GUI
--==================================================

function FisherMM2:CreateGui()
	local existing =
		LocalPlayer.PlayerGui:FindFirstChild("FisherMM2")

	if existing then
		existing:Destroy()
	end

	Gui = Instance.new("ScreenGui")

	Gui.Name = "FisherMM2"
	Gui.ResetOnSpawn = false
	Gui.Parent = LocalPlayer.PlayerGui

	--==================================================
	-- FLOATING TOGGLE BUTTON
	--==================================================

	ToggleButton = Instance.new("TextButton")

	ToggleButton.Name = "FisherToggleButton"

	ToggleButton.Size =
		UDim2.new(0, 52, 0, 52)

	ToggleButton.Position =
		UDim2.new(0, 15, 0.5, -26)

	ToggleButton.BackgroundColor3 =
		Color3.fromRGB(30, 30, 30)

	ToggleButton.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	ToggleButton.Text = "F"
	ToggleButton.TextSize = 22
	ToggleButton.Font = Enum.Font.GothamBold

	ToggleButton.BorderSizePixel = 0

	ToggleButton.Active = true
	ToggleButton.Draggable = true
	ToggleButton.AutoButtonColor = true

	ToggleButton.Parent = Gui

	local ToggleCorner =
		Instance.new("UICorner")

	ToggleCorner.CornerRadius =
		UDim.new(1, 0)

	ToggleCorner.Parent =
		ToggleButton

	local ToggleStroke =
		Instance.new("UIStroke")

	ToggleStroke.Thickness = 1.5
	ToggleStroke.Transparency = 0.25
	ToggleStroke.Color =
		Color3.fromRGB(100, 100, 100)

	ToggleStroke.Parent =
		ToggleButton

	--==================================================
	-- MAIN WINDOW
	--==================================================

	Main = Instance.new("Frame")

	Main.Size =
		UDim2.new(0, 340, 0, 500)

	Main.Position =
		UDim2.new(
			1,
			-355,
			0.5,
			-250
		)

	Main.BackgroundColor3 =
		Color3.fromRGB(24, 24, 24)

	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true

	Main.Parent = Gui

	CreateCorner(Main, 10)

	local title =
		Instance.new("TextLabel")

	title.Size =
		UDim2.new(1, 0, 0, 35)

	title.Position =
		UDim2.new(0, 0, 0, 5)

	title.BackgroundTransparency = 1

	title.Text = "Fisher MM2 Tools"

	title.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	title.TextSize = 20
	title.Font = Enum.Font.GothamBold

	title.Parent = Main

	-- Credits
	local credits =
		Instance.new("TextLabel")

	credits.Size =
		UDim2.new(1, 0, 0, 18)

	credits.Position =
		UDim2.new(0, 0, 0, 34)

	credits.BackgroundTransparency = 1

	credits.Text =
		"by @ItzOnlyFisher"

	credits.TextColor3 =
		Color3.fromRGB(140, 140, 140)

	credits.TextSize = 11
	credits.Font = Enum.Font.Gotham

	credits.Parent = Main

	-- Status
	StatusLabel =
		Instance.new("TextLabel")

	StatusLabel.Size =
		UDim2.new(1, -20, 0, 25)

	StatusLabel.Position =
		UDim2.new(0, 10, 0, 58)

	StatusLabel.BackgroundColor3 =
		Color3.fromRGB(35, 35, 35)

	StatusLabel.TextColor3 =
		Color3.fromRGB(120, 220, 150)

	StatusLabel.Text = "Ready"

	StatusLabel.TextSize = 12
	StatusLabel.Font = Enum.Font.Gotham

	StatusLabel.Parent = Main

	CreateCorner(StatusLabel, 5)

	-- Player list
	PlayerList =
		Instance.new("ScrollingFrame")

	PlayerList.Size =
		UDim2.new(1, -20, 0, 275)

	PlayerList.Position =
		UDim2.new(0, 10, 0, 95)

	PlayerList.BackgroundColor3 =
		Color3.fromRGB(30, 30, 30)

	PlayerList.BorderSizePixel = 0
	PlayerList.ScrollBarThickness = 5

	PlayerList.CanvasSize =
		UDim2.new()

	PlayerList.Parent = Main

	CreateCorner(PlayerList, 7)

	local listLayout =
		Instance.new("UIListLayout")

	listLayout.Padding =
		UDim.new(0, 5)

	listLayout.SortOrder =
		Enum.SortOrder.Name

	listLayout.Parent =
		PlayerList

	-- Controls
	local controls =
		Instance.new("Frame")

	controls.Size =
		UDim2.new(1, -20, 0, 105)

	controls.Position =
		UDim2.new(0, 10, 0, 382)

	controls.BackgroundTransparency = 1
	controls.Parent = Main

	local layout =
		Instance.new("UIListLayout")

	layout.Padding =
		UDim.new(0, 5)

	layout.Parent =
		controls

	EspButton =
		CreateButton(
			controls,
			"ESP: OFF"
		)

	local refreshButton =
		CreateButton(
			controls,
			"Refresh Players"
		)

	local destroyButton =
		CreateButton(
			controls,
			"DESTROY GUI"
		)

	destroyButton.BackgroundColor3 =
		Color3.fromRGB(135, 45, 45)

	--==================================================
	-- BUTTON CONNECTIONS
	--==================================================

	Connect(
		ToggleButton.MouseButton1Click,
		function()
			Main.Visible =
				not Main.Visible
		end
	)

	Connect(
		EspButton.MouseButton1Click,
		function()
			Config.EspEnabled =
				not Config.EspEnabled

			SetToggleButton(
				EspButton,
				Config.EspEnabled,
				"ESP"
			)

			self:RefreshEsp()

			StatusLabel.Text =
				Config.EspEnabled
					and "ESP enabled"
					or "ESP disabled"
		end
	)

	Connect(
		refreshButton.MouseButton1Click,
		function()
			self:RefreshPlayerList()

			if Config.EspEnabled then
				self:RefreshEsp()
			end
		end
	)

	Connect(
		destroyButton.MouseButton1Click,
		function()
			self:Destroy()
		end
	)

	self:RefreshPlayerList()
end

--==================================================
-- PLAYER CONNECTIONS
--==================================================

function FisherMM2:SetupConnections()
	Connect(
		Players.PlayerAdded,
		function(player)
			task.wait(0.5)

			if destroyed then
				return
			end

			self:RefreshPlayerList()

			if Config.EspEnabled then
				self:CreateEsp(player)
			end

			Connect(
				player.CharacterAdded,
				function()
					task.wait(0.5)

					if Config.EspEnabled then
						self:CreateEsp(player)
					end
				end
			)
		end
	)

	Connect(
		Players.PlayerRemoving,
		function(player)
			self:RemoveEsp(player)

			task.defer(function()
				if not destroyed then
					self:RefreshPlayerList()
				end
			end)
		end
	)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			Connect(
				player.CharacterAdded,
				function()
					task.wait(0.5)

					if Config.EspEnabled then
						self:CreateEsp(player)
					end
				end
			)
		end
	end

	-- Keyboard controls
	Connect(
		UserInputService.InputBegan,
		function(input, processed)
			if processed or destroyed then
				return
			end

			if input.KeyCode == Config.ToggleKey then
				Main.Visible =
					not Main.Visible

			elseif input.KeyCode == Config.EspKey then
				Config.EspEnabled =
					not Config.EspEnabled

				SetToggleButton(
					EspButton,
					Config.EspEnabled,
					"ESP"
				)

				self:RefreshEsp()
			end
		end
	)
end

--==================================================
-- DESTROY
--==================================================

function FisherMM2:Destroy()
	if destroyed then
		return
	end

	destroyed = true

	Config.EspEnabled = false

	-- Remove ESP
	for player in pairs(EspObjects) do
		self:RemoveEsp(player)
	end

	-- Disconnect events
	for _, connection in ipairs(Connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(Connections)

	-- Remove GUI + floating button
	if Gui then
		Gui:Destroy()
	end

	print("Fisher MM2 Tools destroyed")
end

--==================================================
-- INIT
--==================================================

function FisherMM2:Initialize()
	self:CreateGui()
	self:SetupConnections()

	print("================================")
	print("Fisher MM2 Tools")
	print("Credits: @ItzOnlyFisher")
	print("RightControl = Toggle GUI")
	print("F2 = Toggle ESP")
	print("Floating F button = Toggle GUI")
	print("================================")

	return self
end

FisherMM2:Initialize()

return FisherMM2