local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Config = require(ReplicatedStorage.Fractured.Config)
local UIBuilder = require(ReplicatedStorage.Fractured.UIBuilder)
local Preloader = require(ReplicatedStorage.Fractured.Preloader)
local AudioController = require(ReplicatedStorage.Fractured.AudioController)
local Net = require(ReplicatedStorage.Fractured.Net)

-- If a ScreenGui already exists in StarterGui and replicated to PlayerGui, use it
local existing = playerGui:FindFirstChild("FracturedLobbyGui")
local ui = UIBuilder.build(playerGui, existing)
AudioController.startAmbient()

-- Preload assets and update progress bar with flicker.
task.spawn(function()
	Preloader.preloadAll(function(alpha)
		UIBuilder.setProgress(ui, alpha)
	end)
	-- Start ambient glitch/lore loops
	local function loopLore()
		while ui.screen.Parent do
			UIBuilder.setLore(ui, Config.LoreSnippets[math.random(1, #Config.LoreSnippets)])
			task.wait(math.random(Config.UI.loreInterval.Min, Config.UI.loreInterval.Max))
		end
	end
	local function loopGlitch()
		while ui.screen.Parent do
			UIBuilder.playGlitch(ui)
			task.wait(math.random(Config.UI.glitchInterval.Min, Config.UI.glitchInterval.Max) * 0.35)
		end
	end
	coroutine.wrap(loopLore)()
	coroutine.wrap(loopGlitch)()
end)

-- Lighting flicker via tagged lights from server environment
local function animateFlicker()
	while ui.screen.Parent do
		for _, light in ipairs(workspace:GetDescendants()) do
			if light:IsA("PointLight") and light.Parent and light.Parent:IsA("BasePart") then
				-- random flicker with occasional color shift
				if math.random() < 0.08 then
					local origB = light.Brightness
					local origC = light.Color
					light.Brightness = origB * (0.2 + math.random())
					if math.random() < 0.2 then
						light.Color = Color3.fromRGB(200 + math.random(-30, 30), 200 + math.random(-30, 30), 255)
					end
					task.wait(0.05 + math.random() * 0.1)
					light.Brightness = origB
					light.Color = origC
				end
			end
		end
		RunService.Heartbeat:Wait()
	end
end
coroutine.wrap(animateFlicker)()

-- Moving wall shadows
local function animateShadows()
	while ui.screen.Parent do
		for _, bb in ipairs(workspace:GetDescendants()) do
			if bb:IsA("BillboardGui") and bb.Name == "ShadowBillboard" then
				local img = bb:FindFirstChildOfClass("ImageLabel")
				if img then
					img.ImageTransparency = 0.6 + math.noise(os.clock() * 0.7) * 0.2
					bb.StudsOffset = Vector3.new(0, 0, -0.2 + math.noise(os.clock() * 0.5) * 0.4)
				end
			end
		end
		RunService.RenderStepped:Wait()
	end
end
coroutine.wrap(animateShadows)()

-- Chapter buttons
local StartChapter = Net:getRemoteEvent("StartChapter")
for _, ch in ipairs(Config.Chapters) do
	local btn = ui.chapterButtons[ch.key]
	if btn then
		btn.MouseButton1Click:Connect(function()
			if ch.accessible then
				AudioController.playTransition()
				local veil = UIBuilder.fadeToBlack(ui, 1.2)
				StartChapter:FireServer(ch.key)
				task.wait(1.5)
				veil.BackgroundTransparency = 0
			else
				AudioController.playLockedHint()
				UIBuilder.playGlitch(ui)
			end
		end)

		if not ch.accessible then
			btn.MouseEnter:Connect(function()
				AudioController.playLockedHint()
			end)
		end
	end
end

-- Idle locked-chapter hints
task.spawn(function()
	while ui.screen.Parent do
		local waitTime = math.random(7, 14)
		task.wait(waitTime)
		AudioController.playLockedHint()
	end
end)


