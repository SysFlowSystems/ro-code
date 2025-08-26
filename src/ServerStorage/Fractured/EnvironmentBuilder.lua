local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Fractured.Config)

local EnvironmentBuilder = {}

local function setLighting()
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)
	Lighting.Brightness = 1.5
	Lighting.ClockTime = 0.5
	Lighting.Ambient = Color3.fromRGB(10, 10, 12)
	Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 24)
	Lighting.FogColor = Color3.fromRGB(10, 10, 12)
	Lighting.FogStart = 20
	Lighting.FogEnd = 120

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "FracturedColor"
	cc.TintColor = Color3.fromRGB(210, 210, 220)
	cc.Contrast = 0.08
	cc.Saturation = -0.15
	cc.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.3
	bloom.Size = 8
	bloom.Threshold = 2
	bloom.Parent = Lighting

	local dof = Instance.new("DepthOfFieldEffect")
	dof.InFocusRadius = 10
	dof.FarIntensity = 0.25
	dof.NearIntensity = 0.1
	dof.FocusDistance = 15
	dof.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.35
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(200, 200, 210)
	atmosphere.Decay = Color3.fromRGB(60, 60, 70)
	atmosphere.Haze = 1
	atmosphere.Parent = Lighting
end

local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do p[k] = v end
	return p
end

local function cylinder(props)
	local p = part(props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function addDecal(surface, textureId)
	local d = Instance.new("Decal")
	d.Texture = textureId
	d.Face = surface
	return d
end

local function addFlickerLight(parent, color)
	local light = Instance.new("PointLight")
	light.Color = color or Color3.fromRGB(235, 240, 255)
	light.Range = 18
	light.Brightness = 2.2
	light.Shadows = true
	light.Parent = parent
	CollectionService:AddTag(light, "FlickerLight")
	return light
end

local function addShadowBillboard(parent)
	local att = Instance.new("Attachment")
	att.Parent = parent
	local bb = Instance.new("BillboardGui")
	bb.Name = "ShadowBillboard"
	bb.Size = UDim2.new(0, 90, 0, 120)
	bb.AlwaysOnTop = false
	bb.LightInfluence = 1
	bb.StudsOffset = Vector3.new(0, 0, -0.2)
	bb.Parent = att
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.Image = Config:getImageId("shadow")
	img.ImageTransparency = 0.7
	img.Size = UDim2.new(1, 0, 1, 0)
	img.Parent = bb
	CollectionService:AddTag(bb, "MovingShadow")
	return bb
end

local function addParticlesFog(partRef)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "FloorFog"
	emitter.Texture = "rbxassetid://241876061" -- soft smoke texture placeholder
	emitter.Rate = 6
	emitter.Lifetime = NumberRange.new(6, 12)
	emitter.Speed = NumberRange.new(0.1, 0.6)
	emitter.Rotation = NumberRange.new(-10, 10)
	emitter.RotSpeed = NumberRange.new(-2, 2)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 3),
		NumberSequenceKeypoint.new(0.5, 5),
		NumberSequenceKeypoint.new(1, 3)
	})
	emitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 210))
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.2, 0.6),
		NumberSequenceKeypoint.new(0.8, 0.85),
		NumberSequenceKeypoint.new(1, 1)
	})
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.SpreadAngle = Vector2.new(15, 15)
	emitter.LockedToPart = false
	emitter.Parent = partRef
	return emitter
end

local function addDust(partRef)
	local d = Instance.new("ParticleEmitter")
	d.Name = "Dust"
	d.Texture = "rbxassetid://258128463" -- dust mote texture placeholder
	d.Rate = 12
	d.Lifetime = NumberRange.new(3, 7)
	d.Speed = NumberRange.new(0.1, 0.3)
	d.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.5, 0.08),
		NumberSequenceKeypoint.new(1, 0.05)
	})
	d.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})
	d.Parent = partRef
	return d
end

function EnvironmentBuilder.buildLobby()
	setLighting()
	local workspaceFolder = workspace:FindFirstChild("FracturedLobby")
	if workspaceFolder then workspaceFolder:Destroy() end
	workspaceFolder = Instance.new("Folder")
	workspaceFolder.Name = "FracturedLobby"
	workspaceFolder.Parent = workspace

	-- Floor area
	local floor = part({
		Name = "Floor",
		Size = Vector3.new(120, 1, 120),
		Material = Enum.Material.Concrete,
		Color = Color3.fromRGB(60, 60, 64),
		Position = Vector3.new(0, 0, 0),
		Parent = workspaceFolder,
	})
	addParticlesFog(floor)
	addDust(floor)

	-- Puddles
	for i = 1, 6 do
		local puddle = part({
			Name = "Puddle" .. i,
			Size = Vector3.new(math.random(4, 8), 0.05, math.random(3, 6)),
			Material = Enum.Material.Glass,
			Color = Color3.fromRGB(180, 190, 200),
			Transparency = 0.75,
			Reflectance = 0.15,
			Position = Vector3.new(math.random(-50, 50), 0.03, math.random(-50, 50)),
			Parent = workspaceFolder,
		})
	end

	-- Carpet patches
	for i = 1, 4 do
		local carpet = part({
			Name = "Carpet" .. i,
			Size = Vector3.new(math.random(10, 20), 0.1, math.random(10, 20)),
			Material = Enum.Material.Carpet,
			Color = Color3.fromRGB(40, 30, 30),
			Position = Vector3.new(math.random(-40, 40), 0.06, math.random(-40, 40)),
			Parent = workspaceFolder,
		})
	end

	-- Walls (simple square room)
	local walls = Instance.new("Folder")
	walls.Name = "Walls"
	walls.Parent = workspaceFolder

	local wallSize = 120
	local wallHeight = 24
	local wallThickness = 2
	local function makeWall(cx, cz, rot)
		local w = part({
			Name = "Wall",
			Size = Vector3.new(wallSize, wallHeight, wallThickness),
			Material = Enum.Material.Concrete,
			Color = Color3.fromRGB(70, 70, 75),
			Position = Vector3.new(cx, wallHeight / 2, cz),
			Parent = walls,
		})
		w.Orientation = Vector3.new(0, rot, 0)
		local warning = addDecal(Enum.NormalId.Front, Config:getImageId("warning"))
		warning.Transparency = 0.5
		warning.Parent = w
		local graffiti = addDecal(Enum.NormalId.Front, Config:getImageId("graffiti"))
		graffiti.Transparency = 0.4
		graffiti.Parent = w
		addShadowBillboard(w)
		return w
	end

	makeWall(0, -wallSize/2, 0)
	makeWall(0, wallSize/2, 0)
	makeWall(-wallSize/2, 0, 90)
	makeWall(wallSize/2, 0, 90)

	-- Ceiling grid & lights
	local ceiling = Instance.new("Folder")
	ceiling.Name = "Ceiling"
	ceiling.Parent = workspaceFolder
	for x = -50, 50, 20 do
		for z = -50, 50, 20 do
			local beam = part({
				Name = "Beam",
				Size = Vector3.new(20, 1, 2),
				Material = Enum.Material.Metal,
				Color = Color3.fromRGB(50, 50, 55),
				Position = Vector3.new(x, wallHeight - 1, z),
				Parent = ceiling,
			})
			beam.Orientation = Vector3.new(0, 90, 0)
			local fixture = part({
				Name = "LightFixture",
				Size = Vector3.new(2, 0.4, 2),
				Material = Enum.Material.Metal,
				Color = Color3.fromRGB(200, 200, 205),
				Position = beam.Position + Vector3.new(0, -0.8, 0),
				Parent = ceiling,
			})
			addFlickerLight(fixture, Color3.fromRGB(230, 235, 255))
		end
	end

	-- Pipes along walls
	local pipes = Instance.new("Folder")
	pipes.Name = "Pipes"
	pipes.Parent = workspaceFolder
	for z = -50, 50, 10 do
		local p1 = cylinder({
			Name = "PipeZ" .. z,
			Size = Vector3.new(1, 1, 10),
			Material = Enum.Material.Metal,
			Color = Color3.fromRGB(90, 90, 95),
			Position = Vector3.new(-wallSize/2 + 1, 8 + math.random(-2, 2), z),
			Parent = pipes,
		})
		p1.Orientation = Vector3.new(0, 90, 0)
	end

	-- Vents
	local vents = Instance.new("Folder")
	vents.Name = "Vents"
	vents.Parent = workspaceFolder
	for x = -40, 40, 20 do
		local v = part({
			Name = "Vent" .. x,
			Size = Vector3.new(6, 1, 6),
			Material = Enum.Material.Metal,
			Color = Color3.fromRGB(120, 120, 125),
			Position = Vector3.new(x, wallHeight - 2, -wallSize/2 + 2),
			Parent = vents,
		})
		addShadowBillboard(v)
	end

	-- Debris piles
	local debris = Instance.new("Folder")
	debris.Name = "Debris"
	debris.Parent = workspaceFolder
	for i = 1, 20 do
		local junk = part({
			Name = "Debris" .. i,
			Size = Vector3.new(math.random(1, 3), math.random(1, 2), math.random(1, 3)),
			Material = Enum.Material.Concrete,
			Color = Color3.fromRGB(50 + math.random(-5, 5), 50 + math.random(-5, 5), 52 + math.random(-5, 5)),
			Position = Vector3.new(math.random(-55, 55), 0.5, math.random(-55, 55)),
			Parent = debris,
		})
	end

	-- Spawns
	local lobbySpawn = Instance.new("SpawnLocation")
	lobbySpawn.Name = "LobbySpawn"
	lobbySpawn.Position = Vector3.new(0, 2, 0)
	lobbySpawn.Size = Vector3.new(6, 1, 6)
	lobbySpawn.Anchored = true
	lobbySpawn.Transparency = 1
	lobbySpawn.Neutral = true
	lobbySpawn.Parent = workspaceFolder

	local chapter1Spawn = Instance.new("Part")
	chapter1Spawn.Name = "Chapter1Spawn"
	chapter1Spawn.Position = Vector3.new(0, 2, 40)
	chapter1Spawn.Size = Vector3.new(4, 1, 4)
	chapter1Spawn.Anchored = true
	chapter1Spawn.Transparency = 1
	chapter1Spawn.Parent = workspaceFolder

	-- Safety floor: large, invisible, anchored, directly under the lobby spawn
	local safetyFloor = part({
		Name = "SafetyFloor",
		Size = Vector3.new(1000, 1, 1000),
		Position = Vector3.new(lobbySpawn.Position.X, 0, lobbySpawn.Position.Z),
		Material = Enum.Material.SmoothPlastic,
		Transparency = 1,
		CanCollide = true,
		Parent = workspace, -- must be parented to Workspace
	})

	return workspaceFolder
end

return EnvironmentBuilder


