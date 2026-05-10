--// Player & Services
local plr = game:GetService("Players").LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

--// GUI (nti-AFK)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "Anti-AFK"
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
title.Text = "Anti-AFK"
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

-- Função de criar botão toggle
local function makeToggle(text, callback)
    local state = false
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." OFF"

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)

    updateCanvas()
    return btn
end

---// MÉTODOS ANTI-AFK

-- 1. Método Virtual User (Simula cliques/mouse)
local methodVU = false
plr.Idled:Connect(function()
    if methodVU then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

makeToggle("Método Cliques (VU)", function(state)
    methodVU = state
end)

-- 2. Método Movimento (Pequenos passos)
local methodMove = false
task.spawn(function()
    while true do
        task.wait(10)
        if methodMove and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local hum = plr.Character.Humanoid
            local hrp = plr.Character.HumanoidRootPart
            -- Dá um micro passo pro lado e volta
            hum:MoveTo(hrp.Position + Vector3.new(0.2, 0, 0.2))
            task.wait(0.5)
            hum:MoveTo(hrp.Position)
        end
    end
end)

makeToggle("Método Movimento", function(state)
    methodMove = state
end)

-- 3. Método Jump (Pulo Periódico)
local methodJump = false
task.spawn(function()
    while true do
        task.wait(30) -- Pula a cada 30 segundos
        if methodJump and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.Jump = true
        end
    end
end)

makeToggle("Método Pulo", function(state)
    methodJump = state
end)

-- Botão de Fechar
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
