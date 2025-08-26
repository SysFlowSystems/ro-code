local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = {}

local ROOT_NAME = "Fractured"
local REMOTES_NAME = "Remotes"

local function getRoot()
	local root = ReplicatedStorage:FindFirstChild(ROOT_NAME)
	if not root then
		root = Instance.new("Folder")
		root.Name = ROOT_NAME
		root.Parent = ReplicatedStorage
	end
	return root
end

local function getRemotes()
	local root = getRoot()
	local remotes = root:FindFirstChild(REMOTES_NAME)
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = REMOTES_NAME
		remotes.Parent = root
	end
	return remotes
end

function Net:getRemoteEvent(name)
	local remotes = getRemotes()
	local evt = remotes:FindFirstChild(name)
	if not evt then
		evt = Instance.new("RemoteEvent")
		evt.Name = name
		evt.Parent = remotes
	end
	return evt
end

return Net


