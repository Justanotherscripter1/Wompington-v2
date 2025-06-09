local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local size = 5
local enabled = false

-- Rebind on respawn
LP.CharacterAdded:Connect(function(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart")
end)

-- Get tool and remote event (from your previous code)
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

-- Table to store hitboxes for cleanup
local hitboxes = {}

-- Create or update hitboxes on enemies
local function updateHitboxes()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local char = plr.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local arena = char:FindFirstChild("isInArena")
			local hum = char:FindFirstChild("Humanoid")

			if hrp and arena and arena.Value and hum and hum.Health > 0 then
				local hitbox = hitboxes[plr]
				if not hitbox or not hitbox.Parent then
					hitbox = Instance.new("Part")
					hitbox.Name = "ExtendedHitbox"
					hitbox.Anchored = true
					hitbox.CanCollide = false
					hitbox.Transparency = 0.5
					hitbox.Material = Enum.Material.Neon
					hitbox.Color = Color3.new(0, 1, 0)
					hitbox.Parent = hrp
					hitboxes[plr] = hitbox

					hitbox.Touched:Connect(function(hit)
						if enabled and hit:IsDescendantOf(Character) then
							local tool = getFirstTool()
							local evt = getSlapEvent(tool)
							if evt then
								evt:FireServer(hrp)
							end
						end
					end)
				end
				hitbox.Size = Vector3.new(size, size, size)
				hitbox.CFrame = hrp.CFrame
			else
				-- Remove hitbox if player dead or out of arena
				if hitboxes[plr] then
					hitboxes[plr]:Destroy()
					hitboxes[plr] = nil
				end
			end
		end
	end
end

-- Visual range box attached to your HRP (optional, can comment out)
local visualRange = Instance.new("Part")
visualRange.Name = "VisualHitboxRange"
visualRange.Anchored = true
visualRange.CanCollide = false
visualRange.Transparency = 0.6
visualRange.Material = Enum.Material.Neon
visualRange.Color = Color3.new(0, 1, 0)
visualRange.Size = Vector3.new(size * 2, size * 2, size * 2)
visualRange.Parent = workspace

-- Update visual range position and size
RunService.RenderStepped:Connect(function()
	if HRP then
		visualRange.CFrame = HRP.CFrame
		visualRange.Size = Vector3.new(size * 2, size * 2, size * 2)
		visualRange.Transparency = enabled and 0.6 or 1
	end
	if enabled then
		updateHitboxes()
	else
		-- cleanup all hitboxes when disabled
		for plr, hb in pairs(hitboxes) do
			if hb then hb:Destroy() end
		end
		hitboxes = {}
	end
end)

-- Expose control functions
local exposed = {}

function exposed.setEnabled(state)
	enabled = state
	if not enabled then
		-- hide visual and remove hitboxes immediately
		visualRange.Transparency = 1
		for plr, hb in pairs(hitboxes) do
			if hb then hb:Destroy() end
		end
		hitboxes = {}
	end
end

function exposed.setSize(newSize)
	size = newSize
	visualRange.Size = Vector3.new(size * 2, size * 2, size * 2)
end

function exposed.stateswap()
	exposed.setEnabled(not enabled)
end

return exposed
