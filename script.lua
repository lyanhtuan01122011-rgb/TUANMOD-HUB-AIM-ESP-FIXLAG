-- TUANMOD HUB - Delta Universal ESP + AIM + Wall Check + Fix Lag Đồ Họa Siêu Mạnh

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if workspace.CurrentCamera then
		Camera = workspace.CurrentCamera
	end
end)

local GUI_NAME = "TuanModHub_UI"
for _, container in ipairs({CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}) do
	if container and container:FindFirstChild(GUI_NAME) then
		container[GUI_NAME]:Destroy()
	end
end

local Config = {
	-- ESP
	ESP_Enabled = true,
	ESP_Box = true,
	ESP_Line = true,
	ESP_Health = true,
	ESP_Distance = true,
	Team_Check = false,
	Force_Fallback_UI = true,
	Scan_Workspace_Models = true,

	-- AIM
	AIM_Enabled = false,
	AIM_Head = true,
	AIM_WallCheck = true,
	FOV_Enabled = true,
	FOV_Radius = 120,

	-- FIX LAG ĐỒ HỌA SIÊU MẠNH
	FixLag_Ultra = false,

	-- Màu sắc
	BoxColor = Color3.fromRGB(255, 65, 65),
	LineColor = Color3.fromRGB(255, 255, 255),
	DistanceColor = Color3.fromRGB(255, 220, 90),
	FOVColor = Color3.fromRGB(255, 50, 50),
	HealthHighColor = Color3.fromRGB(45, 235, 110),
	HealthLowColor = Color3.fromRGB(255, 45, 45),

	-- Màu UI
	UIAccent = Color3.fromRGB(220, 38, 38),
	UIBackground = Color3.fromRGB(16, 16, 20),
	UIPanel = Color3.fromRGB(26, 26, 32),
	UIText = Color3.fromRGB(245, 245, 250)
}

local ColorPresets = {
	{ Name = "Đỏ TuanMod", Color = Color3.fromRGB(220, 38, 38) },
	{ Name = "Xanh Neon", Color = Color3.fromRGB(0, 230, 140) },
	{ Name = "Tím Sữa", Color = Color3.fromRGB(190, 130, 255) },
	{ Name = "Xanh Dương", Color = Color3.fromRGB(56, 152, 255) },
	{ Name = "Vàng Kim", Color = Color3.fromRGB(250, 195, 45) },
	{ Name = "Trắng Sáng", Color = Color3.fromRGB(245, 245, 250) }
}

local function create(className, props, parent)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function getGuiParent()
	local ok, res = pcall(function()
		return gethui and gethui()
	end)
	if ok and res then
		return res
	end
	local cgOk = pcall(function()
		return CoreGui:GetChildren()
	end)
	if cgOk then
		return CoreGui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local DrawingAvailable = false
do
	local hasDrawing = (typeof(Drawing) == "table" or typeof(Drawing) == "userdata") and (typeof(Drawing.new) == "function")
	if hasDrawing then
		local testOk, testObj = pcall(function()
			local d = Drawing.new("Line")
			d.Visible = false
			d:Remove()
			return true
		end)
		DrawingAvailable = (testOk and testObj == true)
	end
end

local function safeDrawing(className, props)
	if not DrawingAvailable then
		return nil
	end
	local ok, obj = pcall(function()
		local d = Drawing.new(className)
		if props then
			for k, v in pairs(props) do
				d[k] = v
			end
		end
		return d
	end)
	return ok and obj or nil
end

-- ==========================================
-- HỆ THỐNG FIX LAG ĐỒ HỌA SIÊU MẠNH
-- ==========================================
local FixLagBackup = {
	Saved = false,
	Shadows = nil,
	Technology = nil,
	Parts = {},
	Effects = {},
	Textures = {}
}

local function isPlayerCharacterDescendant(inst)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and inst:IsDescendantOf(plr.Character) then
			return true
		end
	end
	return false
end

local function applyUltraFixLag(enable)
	if enable then
		pcall(function()
			local renderSettings = settings() and settings().Rendering
			if renderSettings then
				renderSettings.QualityLevel = Enum.QualityLevel.Level01
			end
		end)

		if not FixLagBackup.Saved then
			FixLagBackup.Saved = true
			FixLagBackup.Shadows = Lighting.GlobalShadows
			pcall(function()
				FixLagBackup.Technology = Lighting.Technology
			end)
		end

		pcall(function()
			Lighting.GlobalShadows = false
		end)
		pcall(function()
			Lighting.Technology = Enum.Technology.Compatibility
		end)

		for _, eff in ipairs(Lighting:GetChildren()) do
			if eff:IsA("PostEffect") or eff:IsA("Atmosphere") then
				if FixLagBackup.Effects[eff] == nil then
					FixLagBackup.Effects[eff] = eff.Enabled
				end
				pcall(function()
					eff.Enabled = false
				end)
			end
		end

		task.spawn(function()
			local desc = workspace:GetDescendants()
			for i, obj in ipairs(desc) do
				if not Config.FixLag_Ultra then
					break
				end
				if not isPlayerCharacterDescendant(obj) then
					if obj:IsA("BasePart") then
						if not FixLagBackup.Parts[obj] then
							FixLagBackup.Parts[obj] = {
								Material = obj.Material,
								CastShadow = obj.CastShadow
							}
						end
						pcall(function()
							obj.Material = Enum.Material.SmoothPlastic
							obj.CastShadow = false
						end)
					elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
						or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
						if FixLagBackup.Effects[obj] == nil then
							FixLagBackup.Effects[obj] = obj.Enabled
						end
						pcall(function()
							obj.Enabled = false
						end)
					elseif obj:IsA("Decal") or obj:IsA("Texture") then
						if FixLagBackup.Textures[obj] == nil then
							FixLagBackup.Textures[obj] = obj.Transparency
						end
						pcall(function()
							obj.Transparency = 1
						end)
					end
				end
				if i % 350 == 0 then
					task.wait()
				end
			end
		end)
	else
		pcall(function()
			local renderSettings = settings() and settings().Rendering
			if renderSettings then
				renderSettings.QualityLevel = Enum.QualityLevel.Automatic
			end
		end)

		if FixLagBackup.Saved then
			if FixLagBackup.Shadows ~= nil then
				pcall(function()
					Lighting.GlobalShadows = FixLagBackup.Shadows
				end)
			end
			if FixLagBackup.Technology ~= nil then
				pcall(function()
					Lighting.Technology = FixLagBackup.Technology
				end)
			end
		end

		for obj, state in pairs(FixLagBackup.Effects) do
			if obj and obj.Parent then
				pcall(function()
					obj.Enabled = state
				end)
			end
		end

		for obj, trans in pairs(FixLagBackup.Textures) do
			if obj and obj.Parent then
				pcall(function()
					obj.Transparency = trans
				end)
			end
		end

		for part, data in pairs(FixLagBackup.Parts) do
			if part and part.Parent then
				pcall(function()
					part.Material = data.Material
					part.CastShadow = data.CastShadow
				end)
			end
		end
	end
end

-- ==========================================
-- GIAO DIỆN CHÍNH & FOV
-- ==========================================
local ScreenGui = create("ScreenGui", {
	Name = GUI_NAME,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999
}, getGuiParent())

local FallbackLayer = create("Frame", {
	Name = "FallbackESPLayer",
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 1
}, ScreenGui)

local FOVCircleUI = create("Frame", {
	Name = "FOVCircleUI",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(Config.FOV_Radius * 2, Config.FOV_Radius * 2),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 3
}, ScreenGui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, FOVCircleUI)
local FOVCircleStroke = create("UIStroke", {
	Color = Config.FOVColor,
	Thickness = 1.6,
	Transparency = 0.1
}, FOVCircleUI)

-- LOGO TM
local LogoBtn = create("TextButton", {
	Name = "TMLogoButton",
	Size = UDim2.fromOffset(48, 48),
	Position = UDim2.new(1, -64, 1, -330),
	BackgroundColor3 = Color3.fromRGB(10, 10, 12),
	BorderSizePixel = 0,
	Text = "TM",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBlack,
	TextSize = 18,
	AutoButtonColor = true,
	Active = true,
	ZIndex = 20
}, ScreenGui)

create("UICorner", { CornerRadius = UDim.new(0, 8) }, LogoBtn)
local LogoStroke = create("UIStroke", {
	Color = Color3.fromRGB(235, 30, 30),
	Thickness = 2.2,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border
}, LogoBtn)

do
	local draggingLogo, dragStart, startPos = false
	LogoBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingLogo = true
			dragStart = input.Position
			startPos = LogoBtn.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingLogo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			LogoBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingLogo = false
		end
	end)
end

-- MENU CHÍNH
local MIN_W, MAX_W = 260, 440
local MIN_H, MAX_H = 215, 420

local MainFrame = create("Frame", {
	Name = "MainMenu",
	Size = UDim2.fromOffset(316, 265),
	Position = UDim2.new(1, -332, 1, -281),
	BackgroundColor3 = Config.UIBackground,
	BorderSizePixel = 0,
	Visible = false,
	Active = true,
	ClipsDescendants = true,
	ZIndex = 25
}, ScreenGui)

create("UICorner", { CornerRadius = UDim.new(0, 10) }, MainFrame)
local MainStroke = create("UIStroke", { Color = Config.UIAccent, Thickness = 1.8 }, MainFrame)

local WaveGradient = create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Config.UIAccent),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	}),
	Rotation = 0
}, MainStroke)

local TopBar = create("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 34),
	BackgroundColor3 = Config.UIPanel,
	BorderSizePixel = 0,
	ZIndex = 26
}, MainFrame)

local titleLbl = create("TextLabel", {
	Size = UDim2.new(1, -12, 1, 0),
	Position = UDim2.fromOffset(10, 0),
	BackgroundTransparency = 1,
	Text = "TUANMOD HUB",
	TextColor3 = Config.UIText,
	Font = Enum.Font.GothamBlack,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 27
}, TopBar)

local TitleWave = create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 80, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
}, titleLbl)

do
	local draggingMenu, dragStart, startPos = false
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingMenu = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingMenu and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingMenu = false
		end
	end)
end

local TabBar = create("Frame", {
	Name = "TabBar",
	Size = UDim2.new(1, -18, 0, 28),
	Position = UDim2.fromOffset(6, 38),
	BackgroundColor3 = Config.UIPanel,
	BorderSizePixel = 0,
	ZIndex = 26
}, MainFrame)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, TabBar)
create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, TabBar)
create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3) }, TabBar)

local ContentFrame = create("ScrollingFrame", {
	Name = "ContentArea",
	Size = UDim2.new(1, -24, 1, -74),
	Position = UDim2.fromOffset(6, 70),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	CanvasSize = UDim2.fromOffset(0, 420),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ZIndex = 26
}, MainFrame)
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, ContentFrame)

local VerticalScrollbarTrack = create("Frame", {
	Name = "VerticalScrollbarTrack",
	Size = UDim2.new(0, 10, 1, -78),
	Position = UDim2.new(1, -14, 0, 70),
	BackgroundColor3 = Config.UIPanel,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 27
}, MainFrame)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, VerticalScrollbarTrack)

local VerticalScrollbarThumb = create("TextButton", {
	Name = "VerticalScrollbarThumb",
	Size = UDim2.new(1, 0, 0.4, 0),
	Position = UDim2.fromScale(0, 0),
	BackgroundColor3 = Config.UIAccent,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 28
}, VerticalScrollbarTrack)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, VerticalScrollbarThumb)

local function syncScrollbarThumb()
	local canvasY = ContentFrame.AbsoluteCanvasSize.Y
	local viewY = ContentFrame.AbsoluteWindowSize.Y
	if canvasY <= viewY or canvasY <= 0 then
		VerticalScrollbarThumb.Size = UDim2.new(1, 0, 1, 0)
		VerticalScrollbarThumb.Position = UDim2.fromScale(0, 0)
		return
	end
	local ratio = math.clamp(viewY / canvasY, 0.18, 1)
	local maxOffset = math.max(1, canvasY - viewY)
	local scrollRatio = math.clamp(ContentFrame.CanvasPosition.Y / maxOffset, 0, 1)
	VerticalScrollbarThumb.Size = UDim2.new(1, 0, ratio, 0)
	VerticalScrollbarThumb.Position = UDim2.new(0, 0, scrollRatio * (1 - ratio), 0)
end

ContentFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(syncScrollbarThumb)
ContentFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(syncScrollbarThumb)
ContentFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(syncScrollbarThumb)

do
	local draggingScroll = false
	local function updateScrollFromY(y)
		local trackAbsY = VerticalScrollbarTrack.AbsolutePosition.Y
		local trackAbsH = VerticalScrollbarTrack.AbsoluteSize.Y
		local rel = math.clamp((y - trackAbsY) / math.max(1, trackAbsH), 0, 1)
		local maxScroll = math.max(0, ContentFrame.AbsoluteCanvasSize.Y - ContentFrame.AbsoluteWindowSize.Y)
		ContentFrame.CanvasPosition = Vector2.new(0, rel * maxScroll)
	end
	VerticalScrollbarThumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingScroll = true
		end
	end)
	VerticalScrollbarTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			updateScrollFromY(input.Position.Y)
			draggingScroll = true
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingScroll and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateScrollFromY(input.Position.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingScroll = false
		end
	end)
end

local ResizeHandle = create("TextButton", {
	Name = "ResizeHandle",
	Size = UDim2.fromOffset(18, 18),
	Position = UDim2.new(1, -18, 1, -18),
	BackgroundColor3 = Config.UIPanel,
	BorderSizePixel = 0,
	Text = "◢",
	TextColor3 = Config.UIAccent,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	ZIndex = 30
}, MainFrame)
create("UICorner", { CornerRadius = UDim.new(0, 4) }, ResizeHandle)

do
	local resizing, startMouse, startSize = false
	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startMouse = input.Position
			startSize = MainFrame.Size
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startMouse
			MainFrame.Size = UDim2.fromOffset(
				math.clamp(startSize.X.Offset + delta.X, MIN_W, MAX_W),
				math.clamp(startSize.Y.Offset + delta.Y, MIN_H, MAX_H)
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)
end

LogoBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
	if MainFrame.Visible then
		task.defer(syncScrollbarThumb)
	end
end)

-- ==========================================
-- TABS: ESP, AIM, SETTING, INFO
-- ==========================================
local Tabs, TabButtons = {}, {}
local TAB_COUNT = 4

local function createTab(name, order)
	local container = create("Frame", {
		Name = "Tab_" .. name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 27
	}, ContentFrame)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, container)

	local btn = create("TextButton", {
		Name = "Btn_" .. name,
		LayoutOrder = order,
		Size = UDim2.new(1 / TAB_COUNT, -3, 1, 0),
		BackgroundColor3 = Config.UIBackground,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Config.UIText,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		ZIndex = 27
	}, TabBar)
	create("UICorner", { CornerRadius = UDim.new(0, 5) }, btn)

	Tabs[name] = container
	TabButtons[name] = btn

	btn.MouseButton1Click:Connect(function()
		for k, frame in pairs(Tabs) do frame.Visible = (k == name) end
		for k, tBtn in pairs(TabButtons) do tBtn.BackgroundColor3 = (k == name) and Config.UIAccent or Config.UIBackground end
		ContentFrame.CanvasPosition = Vector2.new(0, 0)
		task.defer(syncScrollbarThumb)
	end)
	return container
end

local TabESP = createTab("ESP", 1)
local TabAIM = createTab("AIM", 2)
local TabSetting = createTab("SETTING", 3)
local TabInfo = createTab("INFO", 4)

Tabs["ESP"].Visible = true
TabButtons["ESP"].BackgroundColor3 = Config.UIAccent

local function createToggle(parent, labelText, initialValue, onChanged)
	local row = create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Config.UIPanel, BorderSizePixel = 0, ZIndex = 27 }, parent)
	create("UICorner", { CornerRadius = UDim.new(0, 7) }, row)
	create("TextLabel", {
		Size = UDim2.new(1, -68, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
		Text = labelText, TextColor3 = Config.UIText, Font = Enum.Font.GothamBold, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 28
	}, row)

	local state = initialValue
	local btn = create("TextButton", {
		Size = UDim2.fromOffset(50, 22), Position = UDim2.new(1, -58, 0.5, -11),
		BackgroundColor3 = state and Config.UIAccent or Color3.fromRGB(55, 55, 68),
		BorderSizePixel = 0, Text = state and "ON" or "OFF",
		TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBlack, TextSize = 10, ZIndex = 28
	}, row)
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, btn)

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = state and "ON" or "OFF"
		btn.BackgroundColor3 = state and Config.UIAccent or Color3.fromRGB(55, 55, 68)
		if onChanged then onChanged(state) end
	end)
	return row
end

local function createSlider(parent, labelText, minVal, maxVal, initialVal, onChanged)
	local box = create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Config.UIPanel,
		BorderSizePixel = 0,
		ZIndex = 27
	}, parent)
	create("UICorner", { CornerRadius = UDim.new(0, 7) }, box)

	local valLabel = create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.fromOffset(10, 3),
		BackgroundTransparency = 1,
		Text = labelText .. ": " .. tostring(math.floor(initialVal)),
		TextColor3 = Config.UIText,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 28
	}, box)

	local track = create("Frame", {
		Size = UDim2.new(1, -24, 0, 10),
		Position = UDim2.fromOffset(12, 28),
		BackgroundColor3 = Config.UIBackground,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 28
	}, box)
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

	local initRatio = math.clamp((initialVal - minVal) / math.max(1, maxVal - minVal), 0, 1)
	local fill = create("Frame", {
		Size = UDim2.new(initRatio, 0, 1, 0),
		BackgroundColor3 = Config.UIAccent,
		BorderSizePixel = 0,
		ZIndex = 29
	}, track)
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

	local knob = create("TextButton", {
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(initRatio, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 30
	}, track)
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

	local currentVal = initialVal
	local function setByRatio(r)
		r = math.clamp(r, 0, 1)
		currentVal = math.floor(minVal + r * (maxVal - minVal) + 0.5)
		local realRatio = (currentVal - minVal) / math.max(1, maxVal - minVal)
		fill.Size = UDim2.new(realRatio, 0, 1, 0)
		knob.Position = UDim2.new(realRatio, 0, 0.5, 0)
		valLabel.Text = labelText .. ": " .. tostring(currentVal)
		if onChanged then
			onChanged(currentVal)
		end
	end

	local function updateFromX(x)
		local absX = track.AbsolutePosition.X
		local absW = track.AbsoluteSize.X
		setByRatio((x - absX) / math.max(1, absW))
	end

	local draggingSlider = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			updateFromX(input.Position.X)
		end
	end)
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
		end
	end)

	return box, fill
end

-- TAB 1: ESP + FIX LAG
createToggle(TabESP, "ESP : ON / OFF (ALL)", Config.ESP_Enabled, function(v) Config.ESP_Enabled = v end)
createToggle(TabESP, "ESP BOX (2D)", Config.ESP_Box, function(v) Config.ESP_Box = v end)
createToggle(TabESP, "ESP LINE (TOP CENTER)", Config.ESP_Line, function(v) Config.ESP_Line = v end)
createToggle(TabESP, "ESP HEALTH (VERTICAL)", Config.ESP_Health, function(v) Config.ESP_Health = v end)
createToggle(TabESP, "ESP DISTANCE (_m)", Config.ESP_Distance, function(v) Config.ESP_Distance = v end)
createToggle(TabESP, "FIX LAG ĐỒ HỌA SIÊU MẠNH", Config.FixLag_Ultra, function(v)
	Config.FixLag_Ultra = v
	applyUltraFixLag(v)
end)
createToggle(TabESP, "TEAM CHECK", Config.Team_Check, function(v) Config.Team_Check = v end)
createToggle(TabESP, "UI FALLBACK", Config.Force_Fallback_UI, function(v) Config.Force_Fallback_UI = v end)
createToggle(TabESP, "SCAN WORKSPACE", Config.Scan_Workspace_Models, function(v) Config.Scan_Workspace_Models = v end)

-- TAB 2: AIM
createToggle(TabAIM, "AIM : ON / OFF (ALL)", Config.AIM_Enabled, function(v) Config.AIM_Enabled = v end)
createToggle(TabAIM, "AIM HEAD : ON / OFF", Config.AIM_Head, function(v) Config.AIM_Head = v end)
createToggle(TabAIM, "AIM CHECK (NO WALL)", Config.AIM_WallCheck, function(v) Config.AIM_WallCheck = v end)
createToggle(TabAIM, "FOV AIM : ON / OFF", Config.FOV_Enabled, function(v) Config.FOV_Enabled = v end)
local _, fovSliderFill = createSlider(TabAIM, "FOV SIZE", 0, 360, Config.FOV_Radius, function(val)
	Config.FOV_Radius = val
end)

-- TAB 3: SETTING
local function createColorSelector(parent, title, applyColorFn)
	local box = create("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Config.UIPanel, BorderSizePixel = 0, ZIndex = 27 }, parent)
	create("UICorner", { CornerRadius = UDim.new(0, 7) }, box)
	create("TextLabel", {
		Size = UDim2.new(1, -12, 0, 20), Position = UDim2.fromOffset(10, 4), BackgroundTransparency = 1,
		Text = title, TextColor3 = Config.UIText, Font = Enum.Font.GothamBold, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 28
	}, box)

	local swatchesRow = create("Frame", { Size = UDim2.new(1, -20, 0, 22), Position = UDim2.fromOffset(10, 27), BackgroundTransparency = 1, ZIndex = 28 }, box)
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, swatchesRow)

	for idx, preset in ipairs(ColorPresets) do
		local swatch = create("TextButton", {
			LayoutOrder = idx, Size = UDim2.fromOffset(22, 22), BackgroundColor3 = preset.Color,
			BorderSizePixel = 0, Text = "", AutoButtonColor = true, ZIndex = 29
		}, swatchesRow)
		create("UICorner", { CornerRadius = UDim.new(0, 5) }, swatch)
		create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.5 }, swatch)
		swatch.MouseButton1Click:Connect(function() applyColorFn(preset.Color) end)
	end
end

local function applyThemeAccent(color)
	Config.UIAccent = color
	LogoStroke.Color = color
	MainStroke.Color = color
	VerticalScrollbarThumb.BackgroundColor3 = color
	ResizeHandle.TextColor3 = color
	if fovSliderFill then
		fovSliderFill.BackgroundColor3 = color
	end
	WaveGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, color),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
	for activeTabName, tBtn in pairs(TabButtons) do
		if Tabs[activeTabName] and Tabs[activeTabName].Visible then
			tBtn.BackgroundColor3 = color
		end
	end
end

createColorSelector(TabSetting, "Màu ESP BOX", function(c) Config.BoxColor = c end)
createColorSelector(TabSetting, "Màu ESP LINE", function(c) Config.LineColor = c end)
createColorSelector(TabSetting, "Màu ESP DISTANCE", function(c) Config.DistanceColor = c end)
createColorSelector(TabSetting, "Màu FOV", function(c)
	Config.FOVColor = c
	FOVCircleStroke.Color = c
end)
createColorSelector(TabSetting, "Màu UI (TUANMOD HUB)", function(c) applyThemeAccent(c) end)

-- TAB 4: INFO
local InfoCard = create("Frame", { Size = UDim2.new(1, 0, 0, 178), BackgroundColor3 = Config.UIPanel, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 27 }, TabInfo)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, InfoCard)
local InfoStroke = create("UIStroke", { Color = Config.UIAccent, Thickness = 1.6 }, InfoCard)
local InfoWaveGradient = create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 45)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 45, 45))
	})
}, InfoStroke)

local waveBars = {}
for i = 1, 5 do
	local bar = create("Frame", {
		Size = UDim2.new(1.4, 0, 0, 10), Position = UDim2.new(-0.2, 0, 0.15 * i, 0),
		BackgroundColor3 = Config.UIAccent, BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 28
	}, InfoCard)
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
	table.insert(waveBars, { frame = bar, phase = i * 1.1 })
end

create("TextLabel", {
	Size = UDim2.new(1, -16, 1, -12), Position = UDim2.fromOffset(8, 6), BackgroundTransparency = 1,
	TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 29,
	Text = "=== TUANMOD HUB INFO ===\n\nMENU BY : TUANMOD\nMAKE BY : TUANMOD\nEDITOR BY : TUANMOD\n\nTIKTOK : tiktok.com/@tuanmod.hub\n\nSupport: Blox Fruits & Shooter Games ESP + AIM + FIX LAG"
}, InfoCard)

-- ==========================================
-- DÒ TỌA ĐỘ, WALL CHECK TỐI ƯU, AIM & ESP
-- ==========================================
local function getAnchorPart(model)
	if not model then return nil end
	for _, name in ipairs({"HumanoidRootPart", "UpperTorso", "Torso", "Head"}) do
		local p = model:FindFirstChild(name)
		if p and p:IsA("BasePart") then return p end
	end
	if model:IsA("Model") and model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
		return model.PrimaryPart
	end
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then return desc end
	end
	return nil
end

local function getAimWorldPosition(model)
	if not model then return nil end
	if Config.AIM_Head then
		local head = model:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			return head.Position
		end
		local ok, cf, size = pcall(function()
			return model:GetBoundingBox()
		end)
		if ok and cf and size then
			return (cf * CFrame.new(0, size.Y * 0.36, 0)).Position
		end
	end

	local bodyPart = model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("UpperTorso")
		or model:FindFirstChild("Torso")
		or getAnchorPart(model)
	return bodyPart and bodyPart.Position or nil
end

local function isTargetVisible(targetModel, targetPos)
	if not Config.AIM_WallCheck or not Camera or not targetPos then
		return true
	end

	local origin = Camera.CFrame.Position
	local direction = targetPos - origin
	local distance = direction.Magnitude
	if distance <= 0.25 then
		return true
	end

	local filterList = { Camera }
	if LocalPlayer.Character then
		table.insert(filterList, LocalPlayer.Character)
	end
	if targetModel then
		table.insert(filterList, targetModel)
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = filterList
	params.IgnoreWater = true

	local currentOrigin = origin
	local remainingDist = distance
	local unitDir = direction.Unit

	for _ = 1, 4 do
		local result = workspace:Raycast(currentOrigin, unitDir * remainingDist, params)
		if not result then
			return true
		end
		if (result.Position - targetPos).Magnitude <= 2.5 then
			return true
		end

		local hitInst = result.Instance
		if hitInst and hitInst:IsA("BasePart") and ((not hitInst.CanCollide) or hitInst.Transparency >= 0.95) then
			table.insert(filterList, hitInst)
			params.FilterDescendantsInstances = filterList
			local step = math.max(0.1, result.Distance + 0.05)
			currentOrigin = currentOrigin + unitDir * step
			remainingDist = distance - (currentOrigin - origin).Magnitude
			if remainingDist <= 0.25 then
				return true
			end
		else
			return false
		end
	end

	return false
end

local function getHealthData(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		local maxHp = math.max(1, hum.MaxHealth)
		local hp = math.max(0, hum.Health)
		return hp, maxHp, (hp > 0)
	end
	return 100, 100, true
end

local function getBounds3D(model)
	local anchor = getAnchorPart(model)
	if not anchor or not Camera then return nil end

	local cf, size
	local ok = pcall(function()
		cf, size = model:GetBoundingBox()
	end)
	if not ok or not cf or not size or size.Magnitude < 0.05 then
		cf = anchor.CFrame
		size = Vector3.new(3.8, 5.4, 2.2)
	end

	local hx = math.clamp(size.X * 0.5, 0.6, 8.0)
	local hy = math.clamp(size.Y * 0.5, 0.9, 10.0)
	local hz = math.clamp(size.Z * 0.5, 0.5, 6.0)

	local corners = {
		cf * Vector3.new(-hx, hy, -hz), cf * Vector3.new(hx, hy, -hz),
		cf * Vector3.new(-hx, -hy, -hz), cf * Vector3.new(hx, -hy, -hz),
		cf * Vector3.new(-hx, hy, hz), cf * Vector3.new(hx, hy, hz),
		cf * Vector3.new(-hx, -hy, hz), cf * Vector3.new(hx, -hy, hz)
	}

	local vp = Camera.ViewportSize
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local frontCount = 0

	for _, corner in ipairs(corners) do
		local sp = Camera:WorldToViewportPoint(corner)
		if sp.Z > 0.05 then
			frontCount += 1
			if sp.X < minX then minX = sp.X end
			if sp.Y < minY then minY = sp.Y end
			if sp.X > maxX then maxX = sp.X end
			if sp.Y > maxY then maxY = sp.Y end
		end
	end

	if frontCount == 0 or minX == math.huge then return nil end

	minX = math.clamp(minX, -300, vp.X + 300)
	maxX = math.clamp(maxX, -300, vp.X + 300)
	minY = math.clamp(minY, -300, vp.Y + 300)
	maxY = math.clamp(maxY, -300, vp.Y + 300)

	return {
		x = minX,
		y = minY,
		w = math.max(8, maxX - minX),
		h = math.max(14, maxY - minY),
		worldPos = cf.Position
	}
end

local function updateGuiLine(lineFrame, fromPt, toPt, color, thickness)
	local dx = toPt.X - fromPt.X
	local dy = toPt.Y - fromPt.Y
	local dist = math.sqrt(dx * dx + dy * dy)
	if dist < 1 then
		lineFrame.Visible = false
		return
	end
	lineFrame.Size = UDim2.fromOffset(dist, thickness or 1.4)
	lineFrame.Position = UDim2.fromOffset((fromPt.X + toPt.X) * 0.5, (fromPt.Y + toPt.Y) * 0.5)
	lineFrame.Rotation = math.deg(math.atan2(dy, dx))
	lineFrame.BackgroundColor3 = color
	lineFrame.Visible = true
end

local VisualPool = {}

local function getOrCreateVisual(key)
	if VisualPool[key] then return VisualPool[key] end

	local uiBox = create("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 2 }, FallbackLayer)
	local uiBoxStroke = create("UIStroke", { Color = Config.BoxColor, Thickness = 1.4 }, uiBox)
	local uiLine = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Config.LineColor, BorderSizePixel = 0, Visible = false, ZIndex = 2 }, FallbackLayer)
	local uiHpBg = create("Frame", { BackgroundColor3 = Color3.fromRGB(15, 15, 15), BorderSizePixel = 0, Visible = false, ZIndex = 2 }, FallbackLayer)
	local uiHpBar = create("Frame", { BackgroundColor3 = Config.HealthHighColor, BorderSizePixel = 0, Visible = false, ZIndex = 3 }, FallbackLayer)
	local uiDist = create("TextLabel", { BackgroundTransparency = 1, TextColor3 = Config.DistanceColor, TextStrokeTransparency = 0.2, Font = Enum.Font.GothamBold, TextSize = 12, Visible = false, ZIndex = 4 }, FallbackLayer)

	local v = {
		BoxOutline = safeDrawing("Square", { Thickness = 2.5, Color = Color3.fromRGB(0, 0, 0), Filled = false, Visible = false, ZIndex = 1 }),
		Box = safeDrawing("Square", { Thickness = 1.2, Color = Config.BoxColor, Filled = false, Visible = false, ZIndex = 2 }),
		Line = safeDrawing("Line", { Thickness = 1.4, Color = Config.LineColor, Visible = false, ZIndex = 2 }),
		HealthBg = safeDrawing("Square", { Thickness = 1, Color = Color3.fromRGB(15, 15, 15), Filled = true, Visible = false, ZIndex = 1 }),
		HealthBar = safeDrawing("Square", { Thickness = 1, Color = Config.HealthHighColor, Filled = true, Visible = false, ZIndex = 2 }),
		DistanceText = safeDrawing("Text", { Size = 13, Center = true, Outline = true, Color = Config.DistanceColor, Visible = false, ZIndex = 3 }),
		UIBox = uiBox, UIBoxStroke = uiBoxStroke, UILine = uiLine, UIHpBg = uiHpBg, UIHpBar = uiHpBar, UIDist = uiDist,
		Touched = true
	}
	VisualPool[key] = v
	return v
end

local function hideVisual(v)
	if not v then return end
	if v.BoxOutline then v.BoxOutline.Visible = false end
	if v.Box then v.Box.Visible = false end
	if v.Line then v.Line.Visible = false end
	if v.HealthBg then v.HealthBg.Visible = false end
	if v.HealthBar then v.HealthBar.Visible = false end
	if v.DistanceText then v.DistanceText.Visible = false end
	if v.UIBox then v.UIBox.Visible = false end
	if v.UILine then v.UILine.Visible = false end
	if v.UIHpBg then v.UIHpBg.Visible = false end
	if v.UIHpBar then v.UIHpBar.Visible = false end
	if v.UIDist then v.UIDist.Visible = false end
end

-- Cache quét workspace model mỗi 0.45s để giảm lag nặng
local CachedWorkspaceModels = {}
local lastWorkspaceScan = 0

local function refreshWorkspaceCache()
	local list = {}
	local myChar = LocalPlayer.Character
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= myChar and obj ~= Camera then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local anchor = getAnchorPart(obj)
			if hum and anchor and hum.Health > 0 then
				table.insert(list, { key = "mdl_" .. tostring(obj:GetDebugId()), model = obj })
			end
		end
	end
	CachedWorkspaceModels = list
end

local function collectTargets(now)
	local targets = {}
	local seenModels = {}
	local myChar = LocalPlayer.Character
	if myChar then seenModels[myChar] = true end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local skipTeam = Config.Team_Check and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team
			if not skipTeam and plr.Character then
				seenModels[plr.Character] = true
				table.insert(targets, { key = "plr_" .. plr.Name, model = plr.Character })
			end
		end
	end

	if Config.Scan_Workspace_Models then
		if now - lastWorkspaceScan >= 0.45 then
			lastWorkspaceScan = now
			refreshWorkspaceCache()
		end
		for _, entry in ipairs(CachedWorkspaceModels) do
			if entry.model and entry.model.Parent and not seenModels[entry.model] and entry.model ~= myChar then
				seenModels[entry.model] = true
				table.insert(targets, entry)
			end
		end
	end

	return targets
end

local function getClosestAimTarget(targets, screenCenter)
	local bestWorldPos = nil
	local bestDist = math.huge

	for _, item in ipairs(targets) do
		local _, _, isAlive = getHealthData(item.model)
		if isAlive then
			local aimPos = getAimWorldPosition(item.model)
			if aimPos then
				local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
				if sp.Z > 0.05 and onScreen then
					local screenPt = Vector2.new(sp.X, sp.Y)
					local dCenter = (screenPt - screenCenter).Magnitude
					local withinFov = (not Config.FOV_Enabled) or (dCenter <= Config.FOV_Radius)
					if withinFov and dCenter < bestDist and isTargetVisible(item.model, aimPos) then
						bestDist = dCenter
						bestWorldPos = aimPos
					end
				end
			end
		end
	end

	return bestWorldPos
end

local waveClock = 0

RunService.RenderStepped:Connect(function(dt)
	waveClock += dt
	if not Camera and workspace.CurrentCamera then
		Camera = workspace.CurrentCamera
	end

	-- Chỉ cập nhật hiệu ứng sóng khi menu đang mở để tiết kiệm tài nguyên
	if MainFrame.Visible then
		if TitleWave then TitleWave.Offset = Vector2.new(math.sin(waveClock * 3.2) * 0.65, 0) end
		WaveGradient.Rotation = (waveClock * 55) % 360
		InfoWaveGradient.Offset = Vector2.new(math.sin(waveClock * 2.8) * 0.7, 0)
		for _, w in ipairs(waveBars) do
			w.frame.Position = UDim2.new(-0.2, 0, (0.12 + (w.phase * 0.14) % 0.75), math.sin(waveClock * 3.5 + w.phase) * 5)
		end
	end

	if not Camera then return end

	local vp = Camera.ViewportSize
	local screenCenter = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local radius = math.max(0, Config.FOV_Radius)
	local showFov = Config.AIM_Enabled and Config.FOV_Enabled and (radius > 0)

	FOVCircleUI.Position = UDim2.fromOffset(screenCenter.X, screenCenter.Y)
	FOVCircleUI.Size = UDim2.fromOffset(radius * 2, radius * 2)
	FOVCircleStroke.Color = Config.FOVColor
	FOVCircleUI.Visible = showFov

	local targets = collectTargets(waveClock)

	if Config.AIM_Enabled then
		local targetWorldPos = getClosestAimTarget(targets, screenCenter)
		if targetWorldPos then
			local camPos = Camera.CFrame.Position
			local lookCF = CFrame.lookAt(camPos, targetWorldPos)
			Camera.CFrame = Camera.CFrame:Lerp(lookCF, math.clamp(dt * 18, 0.15, 1))
		end
	end

	for _, v in pairs(VisualPool) do
		v.Touched = false
	end

	if not Config.ESP_Enabled then
		for _, v in pairs(VisualPool) do hideVisual(v) end
		return
	end

	local useUI = Config.Force_Fallback_UI or (not DrawingAvailable)
	local myAnchor = getAnchorPart(LocalPlayer.Character)
	local myPos = myAnchor and myAnchor.Position or Camera.CFrame.Position
	local topCenter = Vector2.new(vp.X * 0.5, 0)

	for _, item in ipairs(targets) do
		local v = getOrCreateVisual(item.key)
		v.Touched = true

		local hp, maxHp, isAlive = getHealthData(item.model)
		local bounds = isAlive and getBounds3D(item.model) or nil

		if not bounds then
			hideVisual(v)
		else
			local boxX, boxY, boxW, boxH = bounds.x, bounds.y, bounds.w, bounds.h
			local centerBottom = Vector2.new(boxX + boxW * 0.5, boxY + boxH)
			local hpRatio = math.clamp(hp / math.max(1, maxHp), 0, 1)
			local hpColor = Config.HealthLowColor:Lerp(Config.HealthHighColor, hpRatio)
			local distMeters = math.floor((bounds.worldPos - myPos).Magnitude + 0.5)

			if not useUI then
				if v.UIBox then v.UIBox.Visible = false end
				if v.UILine then v.UILine.Visible = false end
				if v.UIHpBg then v.UIHpBg.Visible = false end
				if v.UIHpBar then v.UIHpBar.Visible = false end
				if v.UIDist then v.UIDist.Visible = false end

				if Config.ESP_Box and v.Box and v.BoxOutline then
					v.BoxOutline.Size = Vector2.new(boxW, boxH); v.BoxOutline.Position = Vector2.new(boxX, boxY); v.BoxOutline.Visible = true
					v.Box.Size = Vector2.new(boxW, boxH); v.Box.Position = Vector2.new(boxX, boxY); v.Box.Color = Config.BoxColor; v.Box.Visible = true
				elseif v.Box and v.BoxOutline then
					v.Box.Visible = false; v.BoxOutline.Visible = false
				end

				if Config.ESP_Line and v.Line then
					v.Line.From = topCenter; v.Line.To = centerBottom; v.Line.Color = Config.LineColor; v.Line.Visible = true
				elseif v.Line then
					v.Line.Visible = false
				end

				if Config.ESP_Health and v.HealthBg and v.HealthBar then
					local barW, barX, barY, barH = 4, boxX + boxW + 3, boxY, boxH
					v.HealthBg.Size = Vector2.new(barW, barH); v.HealthBg.Position = Vector2.new(barX, barY); v.HealthBg.Visible = true
					local fillH = math.max(1, barH * hpRatio)
					v.HealthBar.Size = Vector2.new(barW, fillH); v.HealthBar.Position = Vector2.new(barX, barY + (barH - fillH)); v.HealthBar.Color = hpColor; v.HealthBar.Visible = true
				elseif v.HealthBg and v.HealthBar then
					v.HealthBg.Visible = false; v.HealthBar.Visible = false
				end

				if Config.ESP_Distance and v.DistanceText then
					v.DistanceText.Text = tostring(distMeters) .. "m"
					v.DistanceText.Position = Vector2.new(boxX + boxW * 0.5, boxY + boxH + 3)
					v.DistanceText.Color = Config.DistanceColor; v.DistanceText.Visible = true
				elseif v.DistanceText then
					v.DistanceText.Visible = false
				end
			else
				if v.BoxOutline then v.BoxOutline.Visible = false end
				if v.Box then v.Box.Visible = false end
				if v.Line then v.Line.Visible = false end
				if v.HealthBg then v.HealthBg.Visible = false end
				if v.HealthBar then v.HealthBar.Visible = false end
				if v.DistanceText then v.DistanceText.Visible = false end

				if Config.ESP_Box then
					v.UIBox.Size = UDim2.fromOffset(boxW, boxH); v.UIBox.Position = UDim2.fromOffset(boxX, boxY)
					v.UIBoxStroke.Color = Config.BoxColor; v.UIBox.Visible = true
				else
					v.UIBox.Visible = false
				end

				if Config.ESP_Line then
					updateGuiLine(v.UILine, topCenter, centerBottom, Config.LineColor, 1.4)
				else
					v.UILine.Visible = false
				end

				if Config.ESP_Health then
					local barW, barX, barY, barH = 4, boxX + boxW + 3, boxY, boxH
					v.UIHpBg.Size = UDim2.fromOffset(barW, barH); v.UIHpBg.Position = UDim2.fromOffset(barX, barY); v.UIHpBg.Visible = true
					local fillH = math.max(1, barH * hpRatio)
					v.UIHpBar.Size = UDim2.fromOffset(barW, fillH); v.UIHpBar.Position = UDim2.fromOffset(barX, barY + (barH - fillH)); v.UIHpBar.BackgroundColor3 = hpColor; v.UIHpBar.Visible = true
				else
					v.UIHpBg.Visible = false; v.UIHpBar.Visible = false
				end

				if Config.ESP_Distance then
					v.UIDist.Text = tostring(distMeters) .. "m"
					v.UIDist.Size = UDim2.fromOffset(90, 16)
					v.UIDist.Position = UDim2.fromOffset(boxX + boxW * 0.5 - 45, boxY + boxH + 2)
					v.UIDist.TextColor3 = Config.DistanceColor; v.UIDist.Visible = true
				else
					v.UIDist.Visible = false
				end
			end
		end
	end

	for _, v in pairs(VisualPool) do
		if not v.Touched then
			hideVisual(v)
		end
	end
end)
