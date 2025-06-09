-- Services
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local cam = workspace.CurrentCamera
-- Force scriptable camera
cam.CameraType = Enum.CameraType.Scriptable
-- UI libs & notifications
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Check game
local placeId = game.PlaceId
if placeId ~= 5698907818 and placeId ~= 15697416464 then
    WindUI:Notify({
        Title = "INCORRECT GAME",
        Content = "JOIN RE:Infected - https://www.roblox.com/share?code=483b9527dc973449936322ba0c294856&type=ExperienceDetails&stamp=1749428858358",
        Duration = 5,
    })
    return
end
if placeId ~= 15697416464 then
    WindUI:Notify({
        Title = "Join a server.",
        Content = "Try again in a server.",
        Duration = 5,
    })
    return 
end

-- UI setup
WindUI:SetTheme("Dark")
local Window = WindUI:CreateWindow({
    Title = "Wompington Standalone",
    Icon = "door-open",
    Author = "Mrwompington | RE:Infected",
    Folder = "WompREI",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "",
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {Enabled = true, Anonymous = true},
    KeySystem = {
        Key = {"h"},
        Note = "Not Finished - enter h",
        Thumbnail = {Image = "rbxassetid://", Title = "Thumbnail"},
        URL = "https://example.com",
        SaveKey = true,
    },
})

local DB = Window:Tab({Title = "Dashboard", Icon = "grid-2x2", Locked = false})
local VIS = Window:Tab({Title = "Visuals", Icon = "eye", Locked = false})

local AI_Zombies = workspace:WaitForChild("AI_Zombies")

-- Global connection trackers
_G.ZESPConnection = _G.ZESPConnection or nil
_G.ESP_Player_Conn = _G.ESP_Player_Conn or nil
_G.TeamChangeConnections = _G.TeamChangeConnections or {}

-- Highlight function for models
local function addHighlight(model)
    if model:IsA("Model") and not model:FindFirstChildOfClass("Highlight") then
        task.delay(0.1, function()
            if model and model.Parent and model:FindFirstChild("HumanoidRootPart") then
                local h = Instance.new("Highlight")
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.new(0, 0, 0)
                h.OutlineTransparency = 0.4
                h.Parent = model
            end
        end)
    end
end

-- Zombie ESP toggle
local function toggleZombieESP(enabled)
    if enabled then
        for _, zombie in ipairs(AI_Zombies:GetChildren()) do
            addHighlight(zombie)
        end
        _G.ZESPConnection = AI_Zombies.ChildAdded:Connect(addHighlight)
    else
        for _, zombie in ipairs(AI_Zombies:GetChildren()) do
            local h = zombie:FindFirstChildOfClass("Highlight")
            if h then h:Destroy() end
        end
        if _G.ZESPConnection then
            _G.ZESPConnection:Disconnect()
            _G.ZESPConnection = nil
        end
    end
end

VIS:Toggle({
    Title = "ESP - zombie AI",
    Desc = "Highlight AI zombies",
    Icon = "eye",
    Type = "Checkbox",
    Default = false,
    Callback = toggleZombieESP,
})

-- Check if player is an enemy (different team & not spectator)
local function isEnemy(player)
    local myTeam = LocalPlayer.Team
    return player ~= LocalPlayer and player.Team ~= myTeam and player.Team.Name ~= "Spectator"
end

-- Add ESP highlight to enemy players
local function addPlayerESP(player)
    if not player.Character or player.Character:FindFirstChild("WompESP") then return end
    task.delay(0.1, function()
        if isEnemy(player) and player.Character:FindFirstChild("HumanoidRootPart") then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(50, 200, 255)
            h.OutlineColor = Color3.fromRGB(0, 0, 0)
            h.OutlineTransparency = 0.5
            h.Name = "WompESP"
            h.Parent = player.Character
        end
    end)
end

-- Remove ESP highlight from player
local function removePlayerESP(player)
    if player.Character then
        local h = player.Character:FindFirstChild("WompESP")
        if h then h:Destroy() end
    end
end

-- Track team changes on players to update ESP accordingly
local function trackTeamChange(player)
    if _G.TeamChangeConnections[player] then
        _G.TeamChangeConnections[player]:Disconnect()
        _G.TeamChangeConnections[player] = nil
    end
    local conn = player:GetPropertyChangedSignal("Team"):Connect(function()
        removePlayerESP(player)
        task.wait(0.2)
        addPlayerESP(player)
    end)
    _G.TeamChangeConnections[player] = conn
end

local function untrackAllTeamChanges()
    for _, conn in pairs(_G.TeamChangeConnections) do
        conn:Disconnect()
    end
    _G.TeamChangeConnections = {}
end

-- Toggle enemy player ESP
local function toggleEnemyESP(enabled)
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            addPlayerESP(player)
            player.CharacterAdded:Connect(function()
                task.wait(1)
                addPlayerESP(player)
            end)
            trackTeamChange(player)
        end
        _G.ESP_Player_Conn = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(1)
                addPlayerESP(plr)
            end)
            trackTeamChange(plr)
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            removePlayerESP(player)
        end
        if _G.ESP_Player_Conn then
            _G.ESP_Player_Conn:Disconnect()
            _G.ESP_Player_Conn = nil
        end
        untrackAllTeamChanges()
    end
end

VIS:Toggle({
    Title = "ESP - enemy team",
    Desc = "Highlight players not on your team",
    Icon = "eye-off",
    Type = "Checkbox",
    Default = false,
    Callback = toggleEnemyESP,
})

-- Combat tab & aimlock state
local CMBT = Window:Tab({
    Title = "Combat",
    Icon = "swords",
    Locked = false,
})

local aimlockEnabled = false
local userEnabled = false

local function refreshAimlockState()
    if LocalPlayer.Team and LocalPlayer.Team.Name == "Zombies" then
        if aimlockEnabled then
            aimlockEnabled = false
            WindUI:Notify({
                Title = "No Aimlock",
                Content = "You're a zombie. Aimlock disabled.",
                Duration = 4,
            })
        end
    else
        if userEnabled and not aimlockEnabled then
            aimlockEnabled = true
            WindUI:Notify({
                Title = "Aimlock On",
                Content = "Tracking hostile undeads.",
                Duration = 4,
            })
        elseif not userEnabled and aimlockEnabled then
            aimlockEnabled = false
            WindUI:Notify({
                Title = "Aimlock Off",
                Content = "Aimlock disabled by user.",
                Duration = 4,
            })
        end
    end
end

local function getClosestZombie()
    local closest, dist = nil, math.huge
    for _, zombie in ipairs(AI_Zombies:GetChildren()) do
        local hrp = zombie:FindFirstChild("HumanoidRootPart")
        if hrp and zombie:FindFirstChild("Humanoid") and zombie.Humanoid.Health > 0 then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if mag < dist then
                    closest = hrp
                    dist = mag
                end
            end
        end
    end
    return closest
end

local function aimAt(part)
    local cam = workspace.CurrentCamera
    if part then
        cam.CFrame = CFrame.new(cam.CFrame.Position, part.Position)
    end
end

-- Run loop to aim at closest zombie
RS.RenderStepped:Connect(function()
    if aimlockEnabled then
        -- Make sure the camera is actually scriptable every frame
        if cam.CameraType ~= Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Scriptable
        end

        local target = getClosestZombie()
        if target then
            aimAt(target)
        end
    elseif cam.CameraType == Enum.CameraType.Scriptable then
        -- Reset camera if aimlock disabled
        cam.CameraType = Enum.CameraType.Custom
    end
end)

-- Aimlock toggle UI
CMBT:Toggle({
    Title = "Aimlock",
    Desc = "Automatically aim at hostile zombies",
    Icon = "target",
    Default = false,
    Callback = function(state)
        userEnabled = state
        refreshAimlockState()
    end,
})

-- Update aimlock state on team changes and respawns
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(refreshAimlockState)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    refreshAimlockState()
end)

-- Notification example
WindUI:Notify({
    Title = "Notification Example 1",
    Content = "Content",
    Duration = 5,
})
