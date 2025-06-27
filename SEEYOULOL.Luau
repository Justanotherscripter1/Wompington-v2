--[[
>sirius.menu/sense
>yoink.png
update
]]



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local BOX_COLOR = Color3.fromRGB(255, 0, 0)
local BOX_THICKNESS = 2
local tracers = {}

local boxes = {}
local nameTexts = {}
local connection

local MIN_WIDTH = 10
local MAX_WIDTH = 60
local MIN_HEIGHT = 20
local MAX_HEIGHT = 100

local function getTracer(plr)
    tracers[plr] = tracers[plr] or Drawing.new("Line")
    return tracers[plr]
end


-- Clamp helper
local function clamp(v, mi, ma)
    return v < mi and mi or (v > ma and ma or v)
end

local camera = workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()

local function GetScreenPos(part)
	local pos, visible = camera:WorldToViewportPoint(part.Position)
	return Vector2.new(pos.X, pos.Y), visible
end

local function MakeLine(from, to, color)
	local line = Drawing.new("Line")
	line.From = from
	line.To = to
	line.Color = color or Color3.new(1, 0, 0)
	line.Thickness = 1
	line.Transparency = 1
	line.ZIndex = 2
	line.Visible = true
	return line
end

-- example use: make a line from mouse to enemy's HumanoidRootPart
local function TracerToEnemy(target)
	if not target:FindFirstChild("HumanoidRootPart") then return end

	local screenPos, onScreen = GetScreenPos(target.HumanoidRootPart)
	if onScreen then
		local mousePos = Vector2.new(mouse.X, mouse.Y)
		local line = MakeLine(mousePos, screenPos)
	end
end


-- New box and name text creators
local function newBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = BOX_COLOR
    box.Thickness = BOX_THICKNESS
    box.Filled = false
    return box
end

local function newNameText()
    local text = Drawing.new("Text")
    text.Color = Color3.new(1, 1, 1)
    text.Center = true
    text.Size = 16
    text.Visible = false
    return text
end

local function getBox(plr)
    boxes[plr] = boxes[plr] or newBox()
    return boxes[plr]
end

local function getNameText(plr)
    nameTexts[plr] = nameTexts[plr] or newNameText()
    return nameTexts[plr]
end

-- Corrected scaling function
local function getBoxSize(dist)
    local maxDistance = 1000  -- max distance where box is smallest
    local minScale = 0.3      -- scale factor at max distance (30% size)
    local maxScale = 1        -- scale factor when super close (100%)

    dist = clamp(dist, 0, maxDistance)
    local scale = maxScale - ((dist / maxDistance) * (maxScale - minScale))

    local width = MIN_WIDTH + (MAX_WIDTH - MIN_WIDTH) * scale
    local height = MIN_HEIGHT + (MAX_HEIGHT - MIN_HEIGHT) * scale

    return width, height
end

local function addPlayer(plr)
    if plr ~= Players.LocalPlayer then
        getBox(plr)
        getNameText(plr)
    end
end

local function removePlayer(plr)
    if boxes[plr] then
        boxes[plr]:Remove()
        boxes[plr] = nil
    end
    if nameTexts[plr] then
        nameTexts[plr]:Remove()
        nameTexts[plr] = nil
    end
if tracers[plr] then
    tracers[plr]:Remove()
    tracers[plr] = nil
end

end

local function renderESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local box = getBox(plr)
            local nameText = getNameText(plr)

            if hrp and Camera then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude

                    -- Get size based on distance (bigger closer, smaller farther)
                    local width, height = getBoxSize(dist)

                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
                    box.Visible = true

                    nameText.Position = Vector2.new(screenPos.X, screenPos.Y - height / 2 - 18)
                    nameText.Text = plr.Name
                    nameText.Visible = true
                    local tracer = getTracer(plr)
tracer.From = Vector2.new(mouse.X, mouse.Y)
tracer.To = Vector2.new(screenPos.X, screenPos.Y)
tracer.Color = Color3.new(1, 0, 0)
tracer.Thickness = 1
tracer.Transparency = 1
tracer.ZIndex = 1
tracer.Visible = true

                else
local tracer = getTracer(plr)
tracer.Visible = false

                    box.Visible = false
                    nameText.Visible = false
                end
            else
                box.Visible = false
                nameText.Visible = false
            end
        end
    end
end

local function Enable()
    for _, plr in ipairs(Players:GetPlayers()) do
        addPlayer(plr)
    end
    Players.PlayerAdded:Connect(addPlayer)
    Players.PlayerRemoving:Connect(removePlayer)
    connection = RunService.RenderStepped:Connect(renderESP)
end

local function Disable()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    for _, box in pairs(boxes) do
        box:Remove()
    end
    for _, text in pairs(nameTexts) do
        text:Remove()
    end
for _, tracer in pairs(tracers) do
    tracer:Remove()
end
tracers = {}

    boxes = {}
    nameTexts = {}
end

local function SetColor(color)
    BOX_COLOR = color
    for _, box in pairs(boxes) do
        box.Color = BOX_COLOR
    end
end

return {
    Enable = Enable,
    Disable = Disable,
    SetColor = SetColor
}
