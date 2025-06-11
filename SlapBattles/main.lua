local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Your external modules
local scripts = {
    SilentAura = loadstring(game:HttpGet("https://raw.githubusercontent.com/Justanotherscripter1/Wompington-v2/refs/heads/individuals/SlapBattles/scripts/SilentAura.Lua"))(),
    Hitbox = loadstring(game:HttpGeZt("https://raw.githubusercontent.com/Justanotherscripter1/Wompington-v2/individuals/SlapBattles/scripts/hitbox.lua"))(),
}

-- WindUI config
WindUI:SetTheme("Dark")
WindUI:SetNotificationLower(true)

local Window = WindUI:CreateWindow({
    Title = "wompington slapware",
    Icon = "hand",
    Author = "mrwompington | slap battles",
    Folder = "WOMPSB",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            Anonymous = not Anonymous
        end,
    },
    KeySystem = {
        Key = { "h" },
        Note = "not finished - enter h",
        URL = "https://github.com/Footagesus/WindUI",
        SaveKey = true,
    },
})
Window:SetToggleKey(Enum.KeyCode.RightShift)

-- ⚙️ Empty Dashboard Tab
local Dash = Window:Tab({
    Title = "Dashboard",
    Icon = "layout-grid",
    Locked = false,
})
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "circle-user-round",
    Locked = false,
})

-- Ghost Glove: Go invisible
PlayerTab:Button({
    Title = "Invis",
    Desc = "Activates invis with Ghost Glove. <b>REQUIRES GHOST GLOVE</b>",
    Locked = false,
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("Ghostinvisibilityactivated"):FireServer()
    end
})

-- Ghost Glove: Remove invisibility
PlayerTab:Button({
    Title = "UnInvis",
    Desc = "Deactivates invis. <b>REQUIRES GHOST GLOVE</b>",
    Locked = false,
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("Ghostinvisibilitydeactivated"):FireServer()
    end
})

-- Tournament Autoclick Join
local connection
local TournamentInvoke = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Tournament"):WaitForChild("TournamentInvoke")
local TournamentResponse = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Tournament"):WaitForChild("TournamentResponse")

PlayerTab:Toggle({
    Title = "Auto Tournament",
    Desc = "Automatically joins tournament prompts when they appear.",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        if state then
            connection = TournamentInvoke.OnClientEvent:Connect(function()
                TournamentResponse:FireServer(true)
                WindUI:Notify({
                    Title = "Auto Tournament",
                    Content = "Joined tournament automatically.",
                    Duration = 3,
                    Icon = "check"
                })
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

-- 🥊 Combat Tab
local Combat = Window:Tab({
    Title = "Combat",
    Icon = "swords",
    Locked = false,
})

Combat:Toggle({
    Title = "Silent Aura",
    Desc = "Silent slapping without a glove. Remote-based, may not work with all gloves.",
    Icon = "hand",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        scripts.SilentAura.setEnabled(state)
        WindUI:Notify({
            Title = "Silent Aura",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = "hand",
        })
    end,
})

Combat:Slider({
    Title = "Silent Aura Cooldown",
    Step = 0.05,
    Value = {
        Min = 0.4,
        Max = 1.5,
        Default = 0.6,
    },
    Callback = function(value)
        scripts.SilentAura.setWaitTime(value)
    end,
})

Combat:Toggle({
    Title = "Extend Hitboxes",
    Desc = "Extends hitbox size visually and functionally.",
    Icon = "plus-square",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        scripts.Hitbox.setEnabled(state)
    end,
})

Combat:Slider({
    Title = "Hitbox Size",
    Step = 1,
    Value = {
        Min = 2,
        Max = 15,
        Default = 5,
    },
    Callback = function(val)
        scripts.Hitbox.setSize(val)
    end,
})
