--// Player
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local function getHum()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local hum = getHum()

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "PlayerEditor"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,260)
frame.Position = UDim2.new(0.5,-150,0.5,-130)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Player Stats"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- caixas
local function makeBox(text, y, default)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4,0,0,30)
    label.Position = UDim2.new(0.05,0,y,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.5,0,0,30)
    box.Position = UDim2.new(0.45,0,y,0)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    box.TextColor3 = Color3.new(1,1,1)
    box.TextScaled = true
    box.Text = tostring(default)

    return box
end

local speedBox = makeBox("Speed",0.18,hum.WalkSpeed)
local jumpBox = makeBox("JumpPower",0.36,hum.JumpPower)
local gravBox = makeBox("Gravity",0.54,workspace.Gravity)

-- botão aplicar
local apply = Instance.new("TextButton", frame)
apply.Size = UDim2.new(0.8,0,0,35)
apply.Position = UDim2.new(0.1,0,0.7,0)
apply.Text = "APPLY"
apply.BackgroundColor3 = Color3.fromRGB(0,120,255)
apply.TextScaled = true
apply.TextColor3 = Color3.new(1,1,1)

-- toggle lock
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.85,0)
toggle.Text = "LOCK OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

-- fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- aplicar valores
local saved = {16,50,196.2}

apply.MouseButton1Click:Connect(function()
    local s = tonumber(speedBox.Text)
    local j = tonumber(jumpBox.Text)
    local g = tonumber(gravBox.Text)

    if s then saved[1]=s hum.WalkSpeed=s end
    if j then saved[2]=j hum.JumpPower=j end
    if g then saved[3]=g workspace.Gravity=g end
end)

-- lock sistema
local locking = false

toggle.MouseButton1Click:Connect(function()
    locking = not locking

    if locking then
        toggle.Text = "LOCK ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        toggle.Text = "LOCK OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)

-- impedir reset pelo jogo
RunService.Heartbeat:Connect(function()
    if not locking then return end

    if not plr.Character then return end
    hum = getHum()

    if hum.WalkSpeed ~= saved[1] then
        hum.WalkSpeed = saved[1]
    end

    if hum.JumpPower ~= saved[2] then
        hum.JumpPower = saved[2]
    end

    if workspace.Gravity ~= saved[3] then
        workspace.Gravity = saved[3]
    end
end)
