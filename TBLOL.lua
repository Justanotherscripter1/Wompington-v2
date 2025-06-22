local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

local TriggerBot = {}
local enabled = false
local ignoreTeam = true
local delay = 0.1
local targetPart = "Head"

local lastShot = 0
local shootFunction = function()
    mouse1press()
    wait()
    mouse1release()
end

local function isOnEnemy(player)
    if ignoreTeam then
        return player.Team ~= Players.LocalPlayer.Team
    end
    return true
end

local function getTargetUnderCrosshair()
    local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 10000)
    local hitPart, hitPos = workspace:FindPartOnRay(ray, Players.LocalPlayer.Character, false, true)

    if hitPart and hitPart.Parent then
        local plr = Players:GetPlayerFromCharacter(hitPart.Parent)
        if plr and plr ~= Players.LocalPlayer and isOnEnemy(plr) then
            if hitPart.Name == targetPart or hitPart.Parent:FindFirstChild(targetPart) then
                return true
            end
        end
    end
    return false
end

local renderConnection
function TriggerBot.Enable()
    if renderConnection then renderConnection:Disconnect() end
    enabled = true
    renderConnection = RunService.RenderStepped:Connect(function()
        if tick() - lastShot >= delay and getTargetUnderCrosshair() then
            lastShot = tick()
            shootFunction()
        end
    end)
end

function TriggerBot.Disable()
    if renderConnection then renderConnection:Disconnect() end
    renderConnection = nil
    enabled = false
end

function TriggerBot.SetIgnoreTeam(state)
    ignoreTeam = state
end

function TriggerBot.SetTargetPart(part)
    targetPart = part
end

function TriggerBot.SetDelay(sec)
    delay = sec
end

function TriggerBot.IsEnabled()
    return enabled
end

return TriggerBot
