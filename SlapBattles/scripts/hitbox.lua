local size = 5
local enabled = false

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

LP.CharacterAdded:Connect(function(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart")
end)

local function getFirstTool()
	for _, tool in ipairs(Character:GetChildren()) do
		if tool:IsA("Tool") then return tool end
	end
	for _, tool in ipairs(LP.Backpack:GetChildren()) do
		if tool:IsA("Tool") then return tool end
	end
	return nil
end

local function getSlapEvent(tool)
	if not tool then return nil end
	local name = tool.Name
	local candidates = {
		RS:FindFirstChild(name .. "Hit"),
		RS:FindFirstChild("_" .. name .. "Hit")
	}
	for _, evt in ipairs(candidates) do
		if evt and evt:IsA("RemoteEvent") then
			return evt
		end
	end
	return nil
end

-- Visualizer sphere
local visual = Instance.new("Part")
visual.Shape = Enum.PartType.Ball
visual.Anchored = true
visual.CanCollide = false
visual.Transparency = 1 -- start hidden
visual.Color = Color3.fromRGB(0, 255, 0)
visual.Material = Enum.Material.Neon
visual.Name = "SlapRangeVisual"
visual.Size = Vector3.new(size * 2, size * 2, size * 2)
visual.Parent = workspace

RunService.RenderStepped:Connect(function()
	if not HRP then return end
	visual.Position = HRP.Position
	visual.Size = Vector3.new(size * 2, size * 2, size * 2)
	visual.Transparency = enabled and 0.7 or 1
	if not enabled then return end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local char = plr.Character
			local enemyHRP = char:FindFirstChild("HumanoidRootPart")
			local arena = char:FindFirstChild("isInArena")
			local hum = char:FindFirstChild("Humanoid")

			if enemyHRP and arena and arena.Value and hum and hum.Health > 0 then
				local dist = (HRP.Position - enemyHRP.Position).Magnitude
				if dist < size then
					local tool = getFirstTool()
					local evt = getSlapEvent(tool)
					if evt then
						evt:FireServer(enemyHRP)
					end
				end
			end
		end
	end
end)

return {
	setEnabled = function(state)
		enabled = state
	end,
	setSize = function(s)
		size = s
		visual.Size = Vector3.new(s * 2, s * 2, s * 2)
	end,
}
