local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Aimbot = {}

-- Settings
local enabled = false
local targetPartName = "Head" -- or "Torso"
local snapSpeed = 10 -- higher = faster snap, recommended 5-20

-- Helper to get closest target in FOV (simple distance to mouse)
local function getClosestTarget()
    local closestPlayer = nil
    local closestDist = math.huge

    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            local char = plr.Character
            if char then
                local targetPart = char:FindFirstChild(targetPartName)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if distToMouse < closestDist then
                            closestDist = distToMouse
                            closestPlayer = targetPart
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

local connection

function Aimbot.Enable()
    if connection then return end
    enabled = true
    connection = RunService.RenderStepped:Connect(function(dt)
        if not enabled then return end
        local target = getClosestTarget()
        if target then
            local cameraCFrame = Camera.CFrame
            local direction = (target.Position - cameraCFrame.Position).Unit
            local targetCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + direction)

            -- Smoothly interpolate camera CFrame towards target
            Camera.CFrame = cameraCFrame:Lerp(targetCFrame, math.clamp(snapSpeed * dt, 0, 1))
        end
    end)
end

function Aimbot.Disable()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    enabled = false
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

return Aimbot
