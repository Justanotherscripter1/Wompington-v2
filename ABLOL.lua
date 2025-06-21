local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Aimbot = {}

-- Settings with defaults
local enabled = false
local targetPartName = "Head"
local snapSpeed = 10

local minDistance = 0
local maxDistance = 1000
local maxFOV = 30 -- degrees

-- Drawing FOV Circle setup
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(1, 1, 1) -- white circle
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.Visible = false -- start hidden

local function updateFOVCircle()
    local mousePos = UserInputService:GetMouseLocation()
    local cameraFOV = Camera.FieldOfView -- usually 70
    local screenHeight = Camera.ViewportSize.Y
    local radiusPixels = (maxFOV / cameraFOV) * (screenHeight / 2)

    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    fovCircle.Radius = radiusPixels
end

local function getClosestTarget()
    local closestTarget = nil
    local closestDistToMouse = math.huge

    local mousePos = UserInputService:GetMouseLocation()
    local cameraPos = Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            local char = plr.Character
            if char then
                local targetPart = char:FindFirstChild(targetPartName)
                if targetPart then
                    local dist = (targetPart.Position - cameraPos).Magnitude

                    -- Distance checks
                    if dist >= minDistance and dist <= maxDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dirToTarget = (targetPart.Position - cameraPos).Unit
                            local cameraLook = Camera.CFrame.LookVector
                            local angle = math.deg(math.acos(cameraLook:Dot(dirToTarget)))

                            -- Check if within FOV
                            if angle <= maxFOV then
                                local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                                if distToMouse < closestDistToMouse then
                                    closestDistToMouse = distToMouse
                                    closestTarget = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

local connection
local renderConnection

function Aimbot.Enable()
    if connection then return end
    enabled = true

    -- Aim update
    connection = RunService.RenderStepped:Connect(function(dt)
        if not enabled then return end
        local target = getClosestTarget()
        if target then
            local cameraCFrame = Camera.CFrame
            local direction = (target.Position - cameraCFrame.Position).Unit
            local targetCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + direction)

            Camera.CFrame = cameraCFrame:Lerp(targetCFrame, math.clamp(snapSpeed * dt, 0, 1))
        end
    end)

    -- FOV circle update
    renderConnection = RunService.RenderStepped:Connect(function()
        if enabled then
            updateFOVCircle()
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end)
end

function Aimbot.Disable()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    enabled = false
    fovCircle.Visible = false
end

function Aimbot.SetTargetPart(partName)
    if partName == "Head" or partName == "Torso" then
        targetPartName = partName
    else
        warn("Invalid target part! Use 'Head' or 'Torso'.")
    end
end

function Aimbot.SetSnapSpeed(speed)
    if type(speed) == "number" and speed > 0 then
        snapSpeed = speed
    else
        warn("Snap speed must be a positive number.")
    end
end

function Aimbot.SetMinDistance(value)
    if type(value) == "number" and value >= 0 then
        minDistance = value
    else
        warn("Min distance must be a non-negative number.")
    end
end

function Aimbot.SetMaxDistance(value)
    if type(value) == "number" and value >= minDistance then
        maxDistance = value
    else
        warn("Max distance must be >= min distance.")
    end
end

function Aimbot.SetMaxFOV(value)
    if type(value) == "number" and value >= 0 then
        maxFOV = value
    else
        warn("Max FOV must be a non-negative number.")
    end
end

function Aimbot.IsEnabled()
    return enabled
end

function Aimbot.GetMaxFOV()
    return maxFOV
end

return Aimbot
