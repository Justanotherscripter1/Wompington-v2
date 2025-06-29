-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
--load depens/modules
--esp
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Justanotherscripter1/Wompington-v2/refs/heads/modules/exploits/SEEYOULOL.Luau"))()
--AB
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Justanotherscripter1/Wompington-v2/refs/heads/modules/exploits/ABLOL.lua"))()
--TB
local TriggerBot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Justanotherscripter1/Wompington-v2/refs/heads/modules/exploits/TBLOL.lua"))()

InviteCode = "6XsCmfbHwd" 

WindUI:SetNotificationLower(true)
WindUI:SetTheme("Dark")

-- Create the main window
local Window = WindUI:CreateWindow({
    Title = "Wompington Universal | Reforged",
    Icon = "cat",
    Author = "@stardestroyer89 on discord | version 1 | private",
    Folder = "WOMPUNIREWRITE",
    Size = UDim2.fromOffset(580, 460),
    Transparent = false, -- keep false for visibility
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "0", -- you can add a background image if needed
})

local Notice = Window:Dialog({
    Icon = "droplet",
    Title = "THI SCRIPT WAS MADE ON HYDROGEN",
    Content = "this Script was made on Hydrogen, for hydrogen, for more info on hydrogen executor visit hydrogen.lat in your browser.",
    Buttons = {
        {
            Title = "Confirm",
            Callback = function()
                Notice:Close()
            end,
        }
    },
})

Window:SetToggleKey(Enum.KeyCode.RightShift)
Window:CreateTopbarButton("EXPLOIT: HYDROGEN", "droplet",  function() local Notice = Window:Dialog({
    Icon = "droplet",
    Title = "THI SCRIPT WAS MADE ON HYDROGEN",
    Content = "this Script was made on Hydrogen, for hydrogen, for more info on hydrogen executor visit hydrogen.lat in your browser.",
    Buttons = {
        {
            Title = "Confirm",
            Callback = function()
                Notice:Close()
            end,
        }
    },
}) end,  989)

-- Create a dashboard tab
local Dashboard = Window:Tab({
    Title = "Dashboard",
    Icon = "layout-grid",
})

--Discord info integration

local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local success, result = pcall(function()
    return game:GetService("HttpService"):JSONDecode(WindUI.Creator.Request({
        Url = DiscordAPI,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "RobloxBot/1.0",
            ["Accept"] = "application/json"
        }
    }).Body)
end)

if success and result and result.guild then
    Dashboard:Paragraph({
        Title = result.guild.name,
        Desc = 
            ' <font color="#52525b">•</font> Member Count: ' .. tostring(result.approximate_member_count) .. 
            '\n <font color="#16a34a">•</font> Online: ' .. tostring(result.approximate_presence_count),
        Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
        ImageSize = 42, Buttons = {
        {
            Icon = "door-open",
            Title = "Join Discord",
            Callback = function() setclipboard('discord://discord.gg/' .. InviteCode) end,
                Color = "Grey"
        }}
    })
else
    Dashboard:Paragraph({
        Title = "Discord",
        Desc = "Failed to load server info. :(",
        ImageSize = 42,
    })
end
Window:SelectTab(1)-- Number of Tab
-- Create the Visuals tab
local Visuals = Window:Tab({Title = "Visuals", Icon = "eye"})

-- Add the ESP toggle
Visuals:Toggle({
    Title = "Box ESP",
    Default = false,
    Callback = function(state)
        if state then
            ESP.Enable()
        else
            ESP.Disable()
        end
    end
})

local Colorpicker = Visuals:Colorpicker({
    Title = "ESP color",
    Desc = "change color of silly box",
    Default = Color3.fromRGB(255, 0, 0),
    Transparency = 0,
    Locked = false,
    Callback = function(color) 
       ESP.SetColor(color)
    end
})

local AimbotTab = Window:Tab({
    Title = "Combat",
    Icon = "crosshair"
})

-- Enable/Disable toggle
AimbotTab:Toggle({
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        if state then
            Aimbot.Enable()
        else
            Aimbot.Disable()
        end
    end
})

-- Target Part dropdown
AimbotTab:Dropdown({
    Title = "Target Part",
    Desc = "Choose where to aim",
    Values = {"Head", "Torso"},  -- <-- use Values here
    Value = "Head",              -- default selected option
    Callback = function(option)
        Aimbot.SetTargetPart(option)
    end
})

AimbotTab:Dropdown({
    Title = "Visibility Mode",
    Desc = "Choose whether to aim through walls or not",
    Values = { "Visible Only", "Ignore Visibility" },
    Value = "Visible Only",
    Callback = function(mode)
        Aimbot.SetVisibilityMode(mode)
    end
})


-- Snap Speed slider
AimbotTab:Slider({
    Title = "Snap Speed",
    Desc = "How fast the camera snaps/interpolates to the target",
    Step = 1,
    Value = {
        Min = 1,
        Max = 30,
        Default = 10,
    },
    Callback = function(value)
        Aimbot.SetSnapSpeed(value)
    end
})

-- Min Distance slider
AimbotTab:Slider({
    Title = "Min Distance",
    Desc = "Ignore targets closer than this (studs)",
    Step = 1,
    Value = {
        Min = 0,
        Max = 500,
        Default = 0,
    },
    Callback = function(value)
        Aimbot.SetMinDistance(value)
    end
})

-- Max Distance slider
AimbotTab:Slider({
    Title = "Max Distance",
    Desc = "Ignore targets farther than this (studs)",
    Step = 1,
    Value = {
        Min = 100,
        Max = 2000,
        Default = 1000,
    },
    Callback = function(value)
        Aimbot.SetMaxDistance(value)
    end
})

-- Max FOV slider
AimbotTab:Slider({
    Title = "Max FOV",
    Desc = "Max angle from center of screen (degrees)",
    Step = 1,
    Value = {
        Min = 0,
        Max = 180,
        Default = 30,
    },
    Callback = function(value)
        Aimbot.SetMaxFOV(value)
    end
})


AimbotTab:Toggle({
    Title = "Ignore Teammates",
    Default = true,
    Callback = function(state)
        Aimbot.SetIgnoreTeam(state)
    end
})

AimbotTab:Toggle({
    Title = "Enable Trigger Bot",
    Default = false,
    Callback = function(state)
        if state then
            TriggerBot.Enable()
        else
            TriggerBot.Disable()
        end
    end
})

AimbotTab:Dropdown({
    Title = "Trigger Target Part",
    Desc = "Where to hit",
    Values = { "Head", "Torso" },
    Value = "Head",
    Callback = function(part)
        TriggerBot.SetTargetPart(part)
    end
})

AimbotTab:Slider({
    Title = "Trigger Delay",
    Desc = "Minimum delay between shots (sec)",
    Step = 0.05,
    Value = {
        Min = 0.05,
        Max = 1,
        Default = 0.1,
    },
    Callback = function(val)
        TriggerBot.SetDelay(val)
    end
})

AimbotTab:Toggle({
    Title = "Trigger Ignore Teammates",
    Default = true,
    Callback = function(state)
        TriggerBot.SetIgnoreTeam(state)
    end
})

local configuration = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local Keybind = configuration:Keybind({
    Title = "Toggle UI",
    Desc = "Keybind to open ui",
    Value = "RightShift",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

