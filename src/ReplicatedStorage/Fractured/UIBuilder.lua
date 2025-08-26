local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Fractured.Config)

local UIBuilder = {}

local function new(instanceType, props)
	local inst = Instance.new(instanceType)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function createProgressBar(parent)
	local bar = new("Frame", {
		Name = "ProgressBar",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -20),
		Size = UDim2.new(0.5, 0, 0, 8),
		BackgroundColor3 = Color3.fromRGB(40, 0, 0),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = parent,
	})

	local glow = new("ImageLabel", {
		Name = "Glow",
		Image = "rbxassetid://5028857082", -- soft glow sprite
		ImageColor3 = Config.UI.primaryGlow,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 40, 1, 30),
		ZIndex = 0,
		Parent = bar,
	})

	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Config.UI.primaryColor,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = bar,
	})

	local uiCorner = new("UICorner", {
		CornerRadius = UDim.new(0, 2),
		Parent = bar,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = fill })

	return bar, fill, glow
end

local function createLoreOverlay(parent)
	local label = new("TextLabel", {
		Name = "LoreOverlay",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 24),
		Size = UDim2.new(0.8, 0, 0, 40),
		Text = "",
		Font = Config.UI.font,
		TextColor3 = Config.UI.textColor,
		TextTransparency = 0.2,
		TextScaled = true,
		BackgroundTransparency = 1,
		Parent = parent,
	})
	return label
end

local function createGlitchOverlay(parent)
	local img = new("ImageLabel", {
		Name = "Glitch",
		Image = Config.Images.glitch,
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 10,
		Parent = parent,
	})
	return img
end

local function createChapterPanel(parent)
	local panel = new("Frame", {
		Name = "ChapterPanel",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -32, 0.5, 0),
		Size = UDim2.new(0, 340, 0.8, 0),
		BackgroundColor3 = Config.UI.panelColor,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = parent,
	})

	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = panel })
	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = panel,
	})

	local header = new("TextLabel", {
		Name = "Header",
		Size = UDim2.new(1, -16, 0, 36),
		Position = UDim2.new(0, 8, 0, 8),
		BackgroundTransparency = 1,
		Text = "Select Chapter",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Config.UI.textColor,
		TextTransparency = 0.1,
		Font = Config.UI.font,
		TextScaled = true,
		LayoutOrder = 1,
		Parent = panel,
	})

	local container = new("Frame", {
		Name = "List",
		Size = UDim2.new(1, -16, 1, -60),
		Position = UDim2.new(0, 8, 0, 50),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = panel,
	})

	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = container,
	})

	return panel, container
end

local function createChapterButton(parent, chapter)
	local isLocked = not chapter.accessible
	local btn = new("TextButton", {
		Name = chapter.key,
		AutoButtonColor = false,
		Text = chapter.title,
		Font = Config.UI.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = isLocked and Config.UI.mutedTextColor or Config.UI.textColor,
		TextScaled = true,
		BackgroundColor3 = Color3.fromRGB(12, 12, 14),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = parent,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	new("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = btn })

	local glow = new("ImageLabel", {
		Name = "Glow",
		Image = "rbxassetid://5028857082",
		ImageColor3 = Config.UI.primaryGlow,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 16, 1, 16),
		ZIndex = 0,
		ImageTransparency = 1,
		Parent = btn,
	})

	if isLocked then
		local veil = new("Frame", {
			Name = "LockVeil",
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 3,
			Parent = btn,
		})
		local shadow = new("ImageLabel", {
			Name = "InnerShadow",
			Image = Config.Images.shadow,
			BackgroundTransparency = 1,
			ImageTransparency = 0.45,
			Size = UDim2.new(0, 80, 1, 0),
			Position = UDim2.new(-0.2, 0, 0, 0),
			ZIndex = 4,
			Parent = btn,
		})
		TweenService:Create(shadow, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.new(1.2, 0, 0, 0) }):Play()
	else
		btn.MouseEnter:Connect(function()
			TweenService:Create(glow, TweenInfo.new(0.18), { ImageTransparency = 0.3 }):Play()
			local h = UserInputService.VibrationMotor
			-- subtle screen vibration simulated via small size tween
			TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 42) }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(glow, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
			TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 40) }):Play()
		end)
	end

	return btn
end

function UIBuilder.build(playerGui, existingScreenGui)
	local screen = existingScreenGui or new("ScreenGui", {
		Name = "FracturedLobbyGui",
		IgnoreGuiInset = true,
		ResetOnSpawn = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	-- Ensure enabled and parented to PlayerGui at runtime
	screen.Enabled = true
	if not screen.Parent or not screen.Parent:IsDescendantOf(playerGui) then
		screen.Parent = playerGui
	end

	local darken = screen:FindFirstChild("Backdrop") or new("Frame", {
		Name = "Backdrop",
		BackgroundColor3 = Config.UI.backgroundColor,
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Parent = screen,
	})

	local progressBar, progressFill, progressGlow = createProgressBar(screen)
	local lore = createLoreOverlay(screen)
	local glitch = createGlitchOverlay(screen)
	local panel, list = createChapterPanel(screen)

	local chapterButtons = {}
	for _, chapter in ipairs(Config.Chapters) do
		local btn = createChapterButton(list, chapter)
		btn.LayoutOrder = chapter.id + 10
		chapterButtons[chapter.key] = btn
	end

	return {
		screen = screen,
		progressBar = progressBar,
		progressFill = progressFill,
		progressGlow = progressGlow,
		lore = lore,
		glitch = glitch,
		chapterButtons = chapterButtons,
		panel = panel,
	}
end

function UIBuilder.setProgress(ui, alpha)
	ui.progressFill.Size = UDim2.new(alpha, 0, 1, 0)
	local flick = math.random() < 0.2 and math.random() * 0.1 or 0
	ui.progressFill.BackgroundTransparency = 0.05 + flick
end

function UIBuilder.playGlitch(ui)
	local img = ui.glitch
	img.ImageTransparency = 0.85
	img.Position = UDim2.new(0, math.random(-10, 10), 0, math.random(-8, 8))
	TweenService:Create(img, TweenInfo.new(0.15), { ImageTransparency = 1 }):Play()
end

function UIBuilder.setLore(ui, text)
	ui.lore.Text = text
	ui.lore.TextTransparency = 0.35
	TweenService:Create(ui.lore, TweenInfo.new(0.3), { TextTransparency = 0.08 }):Play()
end

function UIBuilder.fadeToBlack(ui, duration)
	local veil = ui.screen:FindFirstChild("Fade")
	if not veil then
		veil = Instance.new("Frame")
		veil.Name = "Fade"
		veil.BackgroundColor3 = Color3.new(0, 0, 0)
		veil.BackgroundTransparency = 1
		veil.Size = UDim2.new(1, 0, 1, 0)
		veil.ZIndex = 20
		veil.Parent = ui.screen
	end
	TweenService:Create(veil, TweenInfo.new(duration or 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }):Play()
	return veil
end

return UIBuilder


