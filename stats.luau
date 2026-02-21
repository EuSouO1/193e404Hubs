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
gui.Name = "PlayerHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Player Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,35)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function updateCanvas()
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

-- criar caixa
local function makeBox(text, default, callback)
    local holder = Instance.new("Frame", scroll)
    holder.Size = UDim2.new(1,-8,0,40)
    holder.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(0.4,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true

    local box = Instance.new("TextBox", holder)
    box.Size = UDim2.new(0.6,-5,1,0)
    box.Position = UDim2.new(0.4,5,0,0)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    box.TextColor3 = Color3.new(1,1,1)
    box.TextScaled = true
    box.Text = tostring(default)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) end
    end)

    updateCanvas()
end

-- criar botão toggle
local function makeToggle(text, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." OFF"

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)

    updateCanvas()
    return btn
end

-- valores salvos
local saved = {hum.WalkSpeed, hum.JumpPower, workspace.Gravity}
local locking = false
local noclip = false
local lockPosition = false
local lockedCFrame = nil

makeToggle("LockPosição",function(state)
    lockPosition = state
    
    if state then
        local char = plr.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                lockedCFrame = hrp.CFrame
            end
        end
    end
end)

-- caixas
makeBox("Speed",hum.WalkSpeed,function(v) saved[1]=v hum.WalkSpeed=v end)
makeBox("JumpPower",hum.JumpPower,function(v) saved[2]=v hum.JumpPower=v end)
makeBox("Gravity",workspace.Gravity,function(v) saved[3]=v workspace.Gravity=v end)

-- lock
makeToggle("Lock",function(state)
    locking = state
end)

-- NOCLIP
makeToggle("Noclip",function(state)
    noclip = state
end)

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

-- loop
RunService.Stepped:Connect(function()
    if not plr.Character then return end
    hum = getHum()

    -- lock stats
    if locking then
        if hum.WalkSpeed ~= saved[1] then hum.WalkSpeed = saved[1] end
        if hum.JumpPower ~= saved[2] then hum.JumpPower = saved[2] end
        if workspace.Gravity ~= saved[3] then workspace.Gravity = saved[3] end
    end

    -- noclip
    if noclip then
        for _,v in pairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    -- lock posição
    if lockPosition and lockedCFrame then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = lockedCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)
