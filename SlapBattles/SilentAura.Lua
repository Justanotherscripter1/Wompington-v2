--doesnt even work on half the gloves

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Respawn handler
LP.CharacterAdded:Connect(function(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart")
end)

local enabled = false

-- Get first tool from character or backpack
local function getFirstTool()
	for _, tool in ipairs(Character:GetChildren()) do
		if tool:IsA("Tool") then return tool end
	end
	for _, tool in ipairs(LP.Backpack:GetChildren()) do
		if tool:IsA("Tool") then return tool end
	end
	return nil
end

-- Get closest valid target
local function getNearestTarget()
	local closestDist = math.huge
	local closestHRP = nil

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local char = plr.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local arena = char:FindFirstChild("isInArena")
			local humanoid = char:FindFirstChild("Humanoid")

			if hrp and arena and arena.Value == true and humanoid and humanoid.Health > 0 then
				local dist = (HRP.Position - hrp.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestHRP = hrp
				end
			end
		end
	end

	return closestHRP
end

-- Main slap loop
task.spawn(function()
	while true do
		if enabled then
			local tool = getFirstTool()
			if tool then
				local baseName = tool.Name
				local possibleEvents = {
					RS:FindFirstChild(baseName .. "Hit"),
					RS:FindFirstChild("_" .. baseName .. "Hit"),
				}

				local foundEvent = nil
				for _, evt in ipairs(possibleEvents) do
					if evt and evt:IsA("RemoteEvent") then
						foundEvent = evt
						break
					end
				end

				if foundEvent then
					local target = getNearestTarget()
					if target then
						foundEvent:FireServer(target)
					end
				else
					warn("No usable RemoteEvent found for tool:", baseName)
				end
			else
				warn("No tools found!")
			end
		end
		task.wait(0.45)
	end
end)

function stateswap()
    enabled = not enabled
end
exposed = {stateswap = stateswap()}

return exposed
