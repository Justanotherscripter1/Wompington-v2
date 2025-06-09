local size = 5
local enabled = false

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Respawn rebinder
LP.CharacterAdded:Connect(function(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart")
end)

-- Get current tool
local function getFirstTool()
	for _, tool in ipairs(Character:GetChildren()) do
		if tool:IsA("Tool") then return tool end
	end
	for _, tool in ipairs(LP.Backpack:GetChildren()) do
		if tool:IsA("Tool") then return tool end
	end
	return nil
end

-- Get RemoteEvent based on tool
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

-- Main runtime
RunService.RenderStepped:Connect(function()
	if not enabled then return end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local char = plr.Character
			local enemyHRP = char:FindFirstChild("HumanoidRootPart")
			local arena = char:FindFirstChild("isInArena")
			local hum = char:FindFirstChild("Humanoid")

			if enemyHRP and arena and arena.Value == true and hum and hum.Health > 0 then
				if not enemyHRP:FindFirstChild("SlapHitbox") then
					local hitbox = Instance.new("Part")
					hitbox.Name = "SlapHitbox"
					hitbox.Size = Vector3.new(size, size, size)
					hitbox.Transparency = 1
					hitbox.Anchored = true
					hitbox.CanCollide = false
					hitbox.CFrame = enemyHRP.CFrame
					hitbox.Parent = enemyHRP

					hitbox.Touched:Connect(function(hit)
						if not enabled then return end
						if hit:IsDescendantOf(Character) then
							local tool = getFirstTool()
							local evt = getSlapEvent(tool)
							if evt then
								evt:FireServer(enemyHRP)
							end
						end
					end)
				else
					-- Sync position and size if needed
					local hitbox = enemyHRP:FindFirstChild("SlapHitbox")
					hitbox.CFrame = enemyHRP.CFrame
					if hitbox.Size.X ~= size then
						hitbox.Size = Vector3.new(size, size, size)
					end
				end
			end
		end
	end
end)

-- Exposed API
local module = {}

function module.setEnabled(state)
	enabled = state
end

function module.setSize(newSize)
	size = newSize
end

function module.stateswap()
	enabled = not enabled
end

return module
