local StarterGui = game:GetService("StarterGui")

-- Ensure a ScreenGui exists with the correct properties so clients receive it.
local screen = StarterGui:FindFirstChild("FracturedLobbyGui")
if not screen then
	screen = Instance.new("ScreenGui")
	screen.Name = "FracturedLobbyGui"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = true
	screen.Enabled = true
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = StarterGui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	backdrop.BackgroundTransparency = 0
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.Position = UDim2.new(0, 0, 0, 0)
	backdrop.Parent = screen
end


