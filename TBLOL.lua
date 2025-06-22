local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local TriggerBot = {}
local enabled = false
local ignoreTeam = true
local delay = 0.1
local targetPart = "Head"
local lastShot = 0

-- Fallback: Basic click function
local function mouseClick()
    -- This works in Synapse, Fluxus, Electron, Hydrogen etc.
    mouse1press()
    task.wait()
    mouse1release()
end

-- Raycast helper
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

local function isEnemy(player)
	if not player or player == LocalPlayer then return false end
	if ignoreTeam then
		return player.Team ~= LocalPlayer.Team
	end
	return true
end

-- Check for target under crosshair
local function getTargetUnderCrosshair()
	local mousePos = UserInputService:GetMouseLocation()
	local screenCenter = Vector2.new(mousePos.X, mousePos.Y)
	
	local unitRay = Camera:ViewportPointToRay(screenCenter.X, screenCenter.Y)
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 10000, rayParams)

	if result and result.Instance then
		local hitPart = result.Instance
		local plr = Players:GetPlayerFromCharacter(hitPart:FindFirstAncestorOfClass("Model"))

		if plr and isEnemy(plr) then
			if hitPart.Name == targetPart or hitPart.Parent:FindFirstChild(targetPart) then
				return true
			end
		end
	end
	return false
end

-- Enable
local renderConnection
function TriggerBot.Enable()
	if renderConnection then renderConnection:Disconnect() end
	enabled = true
	renderConnection = RunService.RenderStepped:Connect(function()
		if tick() - lastShot >= delay and getTargetUnderCrosshair() then
			lastShot = tick()
			mouseClick()
		end
	end)
end

-- Disable
function TriggerBot.Disable()
	if renderConnection then renderConnection:Disconnect() end
	renderConnection = nil
	enabled = false
end

-- Config Setters
function TriggerBot.SetIgnoreTeam(state)
	ignoreTeam = state
end

function TriggerBot.SetTargetPart(part)
	targetPart = part or "Head"
end

function TriggerBot.SetDelay(sec)
	delay = tonumber(sec) or 0.1
end

function TriggerBot.IsEnabled()
	return enabled
end

return TriggerBot
