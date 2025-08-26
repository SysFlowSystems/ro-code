local Config = {}

-- Centralized configuration for lobby UI, audio, chapters, and assets.
-- Replace placeholder asset IDs with your own uploaded assets as needed.

Config.GameName = "Fractured Reality"

Config.Chapters = {
	{ id = 1, key = "Chapter1", title = "Chapter 1 – The Waking", accessible = true, placeId = nil, spawnName = "Chapter1Spawn" },
	{ id = 2, key = "Chapter2", title = "Chapter 2 – Hallways of Madness", accessible = false },
	{ id = 3, key = "Chapter3", title = "Chapter 3 – Whispering Rooms", accessible = false },
	{ id = 4, key = "Chapter4", title = "Chapter 4 – The Hollow Corridor", accessible = false },
	{ id = 5, key = "Chapter5", title = "Chapter 5 – Shattered Laboratories", accessible = false },
	{ id = 6, key = "Chapter6", title = "Chapter 6 – The Fractured Wing", accessible = false },
	{ id = 7, key = "Chapter7", title = "Chapter 7 – Crawling Darkness", accessible = false },
	{ id = 8, key = "Chapter8", title = "Chapter 8 – Final Convergence", accessible = false },
}

Config.UI = {
	font = Enum.Font.GothamMedium,
	primaryColor = Color3.fromRGB(230, 60, 60), -- red accent
	primaryGlow = Color3.fromRGB(255, 30, 30),
	textColor = Color3.fromRGB(220, 220, 220),
	mutedTextColor = Color3.fromRGB(130, 130, 130),
	backgroundColor = Color3.fromRGB(8, 8, 10),
	panelColor = Color3.fromRGB(18, 18, 22),
	progressFlickerMin = 0.75,
	progressFlickerMax = 1.0,
	progressFlickerInterval = NumberRange.new(0.08, 0.23),
	glitchInterval = NumberRange.new(4, 9),
	loreInterval = NumberRange.new(6, 12),
}

Config.Images = {
	glitch = "rbxassetid://1234567890", -- placeholder
	shadow = "rbxassetid://1234567891",
	cracks = "rbxassetid://1234567892",
	warning = "rbxassetid://1234567893",
	graffiti = "rbxassetid://1234567894",
}

Config.Audio = {
	ambientHum = "rbxassetid://1234567001",
	distantDrips = "rbxassetid://1234567002",
	creak = "rbxassetid://1234567003",
	whispers = "rbxassetid://1234567004",
	transitionRumble = "rbxassetid://1234567005",
	lockedChapterMurmur = {
		"rbxassetid://1234567011",
		"rbxassetid://1234567012",
		"rbxassetid://1234567013",
	},
}

Config.LoreSnippets = {
	"Your reflection blinks when you don’t.",
	"Some doors lead back to where you stood, but colder.",
	"If you see me, don’t look at me.",
	"Humming stops when it’s close. Silence isn’t safe.",
	"Pipes rattle from breath, not water.",
	"Follow the stains. They dry toward exits.",
	"Whispers come from your left. The answer is right.",
	"Shadows move to where light won’t.",
	"Fragments ease the noise, not the truth.",
	"It remembers the order you chose to run.",
}

Config.Preload = {
	sounds = {
		"ambientHum",
		"distantDrips",
		"creak",
		"whispers",
		"transitionRumble",
		-- locked murmurs
		unpack((function(list)
			local ids = {}
			for _, v in ipairs(list) do table.insert(ids, v) end
			return ids
		end)(Config.Audio.lockedChapterMurmur)),
	},
	images = {
		"glitch",
		"shadow",
		"cracks",
		"warning",
		"graffiti",
	},
}

function Config:getSoundId(keyOrId)
	if not keyOrId then return nil end
	if typeof(keyOrId) == "string" and self.Audio[keyOrId] then
		return self.Audio[keyOrId]
	end
	return keyOrId
end

function Config:getImageId(keyOrId)
	if not keyOrId then return nil end
	if typeof(keyOrId) == "string" and self.Images[keyOrId] then
		return self.Images[keyOrId]
	end
	return keyOrId
end

return Config


