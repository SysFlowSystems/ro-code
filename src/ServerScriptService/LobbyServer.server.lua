local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Net = require(ReplicatedStorage.Fractured.Net)
local Config = require(ReplicatedStorage.Fractured.Config)

-- Defer require of ServerStorage module to runtime to avoid plugin errors
local EnvironmentBuilder = require(game:GetService("ServerStorage").Fractured.EnvironmentBuilder)

-- Build lobby environment once on server start
local lobbyFolder = EnvironmentBuilder.buildLobby()

-- Remote networking
local StartChapter = Net:getRemoteEvent("StartChapter")

StartChapter.OnServerEvent:Connect(function(player, chapterKey)
	local chosen
	for _, ch in ipairs(Config.Chapters) do
		if ch.key == chapterKey then
			chosen = ch
			break
		end
	end
	if not chosen then return end
	if not chosen.accessible then return end

	-- If using universe placeId for chapter, teleport. Otherwise move player to spawn.
	if chosen.placeId then
		pcall(function()
			TeleportService:TeleportAsync(chosen.placeId, { player })
		end)
	else
		local spawnPart = workspace:FindFirstChild("FracturedLobby") and workspace.FracturedLobby:FindFirstChild(chosen.spawnName or "Chapter1Spawn")
		if spawnPart then
			local char = player.Character or player.CharacterAdded:Wait()
			-- Ensure safe spawn height above the safety floor
			local offsetY = 4
			char:PivotTo(CFrame.new(spawnPart.Position + Vector3.new(0, offsetY, 0)))
		end
	end
end)


