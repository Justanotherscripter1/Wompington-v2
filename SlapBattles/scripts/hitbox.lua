local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local size = 5
local enabled = false
local hitboxes = {}
local debounce = {}

-- Rebind on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)

-- Get first tool in character or backpack
local function getFirstTool()
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") then return tool end
    end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then return tool end
    end
    return nil
end

-- Get the slap RemoteEvent from ReplicatedStorage by tool name
local function getSlapEvent(tool)
    if not tool then return nil end
    local name = tool.Name
    local candidates = {
        ReplicatedStorage:FindFirstChild(name .. "Hit"),
        ReplicatedStorage:FindFirstChild("_" .. name .. "Hit"),
    }
    for _, evt in ipairs(candidates) do
        if evt and evt:IsA("RemoteEvent") then
            return evt
        end
    end
    return nil
end

-- Clean up hitbox for a player
local function removeHitbox(plr)
    if hitboxes[plr] then
        hitboxes[plr]:Destroy()
        hitboxes[plr] = nil
        debounce[plr.Name] = nil
    end
end

-- Create or update hitboxes on enemies
local function updateHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local arena = char:FindFirstChild("isInArena")
            local hum = char:FindFirstChild("Humanoid")

            if hrp and arena and arena.Value == true and hum and hum.Health > 0 then
                local hitbox = hitboxes[plr]
                if not hitbox or not hitbox.Parent then
                    hitbox = Instance.new("Part")
                    hitbox.Name = "ExtendedHitbox"
                    hitbox.Anchored = true
                    hitbox.CanCollide = false
                    hitbox.Transparency = 0.5
                    hitbox.Material = Enum.Material.Neon
                    hitbox.Color = Color3.fromRGB(0, 255, 0)
                    hitbox.Size = Vector3.new(size, size, size)
                    hitbox.Parent = hrp
                    hitboxes[plr] = hitbox

                    hitbox.Touched:Connect(function(hit)
                        if not enabled then return end
                        if hit:IsDescendantOf(Character) then
                            local plrName = plr.Name
                            if debounce[plrName] then return end
                            debounce[plrName] = true

                            local tool = getFirstTool()
                            local evt = getSlapEvent(tool)
                            if evt then
                                print("[Hitbox] Firing slap event on", plrName)
                                evt:FireServer(hrp)
                            else
                                print("[Hitbox] No slap event found for tool", tool and tool.Name or "nil")
                            end

                            task.delay(0.5, function()
                                debounce[plrName] = nil
                            end)
                        end
                    end)
                else
                    hitbox.Size = Vector3.new(size, size, size)
                    hitbox.CFrame = hrp.CFrame
                end
            else
                removeHitbox(plr)
            end
        end
    end
end

-- Visual range box around your character
local visualRange = Instance.new("Part")
visualRange.Name = "VisualHitboxRange"
visualRange.Anchored = true
visualRange.CanCollide = false
visualRange.Transparency = 0.6
visualRange.Material = Enum.Material.Neon
visualRange.Color = Color3.fromRGB(0, 255, 0)
visualRange.Size = Vector3.new(size * 2, size * 2, size * 2)
visualRange.Parent = workspace

-- Update loop
RunService.RenderStepped:Connect(function()
    if HRP then
        visualRange.CFrame = HRP.CFrame
        visualRange.Size = Vector3.new(size * 2, size * 2, size * 2)
        visualRange.Transparency = enabled and 0.6 or 1
    end

    if enabled then
        updateHitboxes()
    else
        -- Clean up all hitboxes
        for plr, hb in pairs(hitboxes) do
            removeHitbox(plr)
        end
    end
end)

-- Exposed API for control
local exposed = {}

function exposed.setEnabled(state)
    enabled = state
    if not enabled then
        visualRange.Transparency = 1
        for plr, hb in pairs(hitboxes) do
            removeHitbox(plr)
        end
    end
end

function exposed.setSize(newSize)
    size = newSize
    visualRange.Size = Vector3.new(size * 2, size * 2, size * 2)
    -- Resize all current hitboxes too
    for _, hb in pairs(hitboxes) do
        if hb and hb.Parent then
            hb.Size = Vector3.new(size, size, size)
        end
    end
end

function exposed.toggle()
    exposed.setEnabled(not enabled)
end

return exposed
