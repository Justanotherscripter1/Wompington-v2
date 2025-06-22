local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Aimbot = {}
local enabled = false

-- Config
local targetPart = "Head"
local snapSpeed = 10
local minDistance = 0
local maxDistance = 1000
local maxFOV = 30
local ignoreTeam = true
local VisibilityMode = "Visible Only" -- default
local ignoreForceFields = false -- new flag


-- FOV circle setup
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.Radius = 60
fovCircle.Visible = false

-- RaycastParams for visibility checks
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

-- Helpers
local function isVisible(part)
	if not part then return false end
	rayParams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
	local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 9999, rayParams)
	return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestTarget()
	local closest = nil
	local shortestAngle = math.huge
	local mousePos = UserInputService:GetMouseLocation()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild(targetPart) and (not ignoreTeam or plr.Team ~= Players.LocalPlayer.Team) then
			if ignoreForceFields and plr.Character:FindFirstChildOfClass("ForceField") then
				continue -- skip protected players
			end

			local part = plr.Character[targetPart]
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Camera.CFrame.Position - part.Position).Magnitude
				if dist >= minDistance and dist <= maxDistance then
					if VisibilityMode == "Visible Only" and not isVisible(part) then
						continue -- skip if not visible
					end

					local fov = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
					local screenFOV = (maxFOV / Camera.FieldOfView) * (Camera.ViewportSize.Y / 2)
					if fov <= screenFOV and fov < shortestAngle then
						shortestAngle = fov
						closest = part
					end
				end
			end
		end
	end

	return closest
end

local function aimAt(target)
	local camCF = Camera.CFrame
	local lookVec = (target.Position - camCF.Position).Unit
	local desired = CFrame.new(camCF.Position, camCF.Position + lookVec)
	Camera.CFrame = camCF:Lerp(desired, math.clamp(snapSpeed / 100, 0, 1))
end

-- FOV Circle Update
local function updateFOVCircle()
	local mousePos = UserInputService:GetMouseLocation()
	local screenRadius = (maxFOV / Camera.FieldOfView) * (Camera.ViewportSize.Y / 2)
	fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
	fovCircle.Radius = screenRadius
end

local renderConnection
function Aimbot.Enable()
	if renderConnection then renderConnection:Disconnect() end
	enabled = true
	renderConnection = RunService.RenderStepped:Connect(function()
		updateFOVCircle()
		fovCircle.Visible = true

		local target = getClosestTarget()
		if target then
			aimAt(target)
		end
	end)
end

function Aimbot.Disable()
	if renderConnection then renderConnection:Disconnect() end
	renderConnection = nil
	enabled = false
	fovCircle.Visible = false
end

-- Setters
function Aimbot.SetTargetPart(part)
	if part == "Head" or part == "Torso" then
		targetPart = part
	end
end

function Aimbot.SetSnapSpeed(speed)
	snapSpeed = tonumber(speed) or 10
end

function Aimbot.SetMinDistance(dist)
	minDistance = tonumber(dist) or 0
end

function Aimbot.SetMaxDistance(dist)
	maxDistance = tonumber(dist) or 1000
end

function Aimbot.SetMaxFOV(fov)
	maxFOV = tonumber(fov) or 30
end

function Aimbot.SetIgnoreTeam(bool)
	ignoreTeam = bool and true or false
end

function Aimbot.SetVisibilityMode(mode)
	if mode == "Visible Only" or mode == "Ignore Visibility" then
		VisibilityMode = mode
	end
end

-- Getters
function Aimbot.IsEnabled()
	return enabled
end

function Aimbot.GetMaxFOV()
	return maxFOV
end

function Aimbot.SetIgnoreForceFields(state)
	ignoreForceFields = state and true or false
end


return Aimbot
