local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Fractured.Config)

local Preloader = {}

local function isValidAssetId(id)
	return typeof(id) == "string" and id:match("^rbxassetid://%d+") ~= nil
end

local function waitSeconds(seconds)
	local t0 = os.clock()
	while os.clock() - t0 < seconds do
		RunService.Heartbeat:Wait()
	end
end

local function createPreloadBin()
	local root = ReplicatedStorage:FindFirstChild("Fractured") or Instance.new("Folder")
	root.Name = "Fractured"
	root.Parent = ReplicatedStorage
	local bin = root:FindFirstChild("PreloadBin")
	if not bin then
		bin = Instance.new("Folder")
		bin.Name = "PreloadBin"
		bin.Parent = root
	end
	bin:ClearAllChildren()
	return bin
end

local function preloadInstance(inst, timeout)
	local ok = false
	local finished = false
	local thread = task.spawn(function()
		local success = pcall(function()
			ContentProvider:PreloadAsync({ inst })
		end)
		ok = success
		finished = true
	end)
	local elapsed = 0
	while not finished and elapsed < timeout do
		local dt = RunService.Heartbeat:Wait()
		elapsed += dt or 0.016
	end
	return ok or finished
end

function Preloader.preloadAll(onProgress)
	local bin = createPreloadBin()
	local total = 0
	local queue = {}

	-- Prepare sounds
	for _, key in ipairs(Config.Preload.sounds) do
		local id = Config:getSoundId(key)
		if isValidAssetId(id) then
			local s = Instance.new("Sound")
			s.SoundId = id
			s.Volume = 0
			s.Parent = bin
			table.insert(queue, s)
		end
	end

	-- Prepare images
	for _, key in ipairs(Config.Preload.images) do
		local id = Config:getImageId(key)
		if isValidAssetId(id) then
			local img = Instance.new("ImageLabel")
			img.Image = id
			img.Size = UDim2.new(0, 10, 0, 10)
			img.BackgroundTransparency = 1
			img.Visible = false
			img.Parent = bin
			table.insert(queue, img)
		end
	end

	total = #queue
	local loaded = 0
	local function report()
		if onProgress then
			onProgress(math.clamp(loaded / math.max(total, 1), 0, 1))
		end
	end
	report()

	for _, inst in ipairs(queue) do
		preloadInstance(inst, 5)
		loaded += 1
		report()
		waitSeconds(math.random(1, 3) * 0.05) -- stagger for effect
	end

	return true
end

return Preloader


