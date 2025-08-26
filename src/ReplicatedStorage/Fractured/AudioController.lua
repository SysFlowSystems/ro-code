local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Fractured.Config)

local AudioController = {}

local function makeSound(parent, soundId, props)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	for k, v in pairs(props or {}) do
		s[k] = v
	end
	s.Parent = parent
	return s
end

function AudioController.startAmbient()
	local root = SoundService:FindFirstChild("FracturedLobby")
	if not root then
		root = Instance.new("Folder")
		root.Name = "FracturedLobby"
		root.Parent = SoundService
	end
	root:ClearAllChildren()

	local ambient = makeSound(root, Config:getSoundId("ambientHum"), {
		Looped = true,
		Volume = 0.25,
		RollOffMaxDistance = 200,
		RollOffMinDistance = 30,
		PlaybackSpeed = 0.98,
	})
	local drips = makeSound(root, Config:getSoundId("distantDrips"), {
		Looped = true,
		Volume = 0.1,
		PlaybackSpeed = 1.02,
	})
	local creak = makeSound(root, Config:getSoundId("creak"), {
		Looped = true,
		Volume = 0.07,
		PlaybackSpeed = 0.95,
	})
	local whisper = makeSound(root, Config:getSoundId("whispers"), {
		Looped = true,
		Volume = 0.06,
		PlaybackSpeed = 1.05,
	})

	ambient:Play()
	drips:Play()
	creak:Play()
	whisper:Play()

	-- Subtle amplitude modulation for psychological unease
	task.spawn(function()
		while root.Parent do
			ambient.Volume = 0.22 + math.noise(os.clock() * 0.07) * 0.05
			drips.PlaybackSpeed = 1.0 + math.noise(os.clock() * 0.13) * 0.04
			whisper.Volume = 0.05 + math.noise(os.clock() * 0.09) * 0.03
			RunService.Heartbeat:Wait()
		end
	end)

	return root
end

function AudioController.playLockedHint()
	local root = SoundService:FindFirstChild("FracturedLobby") or AudioController.startAmbient()
	local id = Config.Audio.lockedChapterMurmur[math.random(1, #Config.Audio.lockedChapterMurmur)]
	local s = makeSound(root, id, { Volume = 0.1 })
	s.Ended:Connect(function()
		if s then s:Destroy() end
	end)
	s:Play()
end

function AudioController.playTransition()
	local root = SoundService:FindFirstChild("FracturedLobby") or AudioController.startAmbient()
	local rumble = makeSound(root, Config:getSoundId("transitionRumble"), { Volume = 0.8 })
	rumble.Ended:Connect(function()
		rumble:Destroy()
	end)
	rumble:Play()
end

return AudioController


