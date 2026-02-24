--// Player & Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

--// GUI (Mesmo estilo do Chat Config Hub)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrookhavenLagHub"
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
title.Text = "Brookhaven Lag Hub"
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

-- Variáveis de Controle
local lag1Enabled = false
local lag2Enabled = false

-- Função de criar botão toggle (idêntica ao original)
local function makeToggle(text, initialState, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    
    local state = initialState
    btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." "..(state and "ON" or "OFF")

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)

    updateCanvas()
    return btn
end

---// Lógica de Lag

-- Lag 1: Spam de "Phone"
makeToggle("Lag 1 (Phone Spam)", false, function(state)
    lag1Enabled = state
end)

task.spawn(function()
    while task.wait(0.001) do
        if lag1Enabled then
            -- Brookhaven Event para pegar item (Phone)
            local args = {
                [1] = "PickingTool",
                [2] = "Phone"
            }
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Updat1eAvata1r"):FireServer(unpack(args))
            
            -- Equipa automaticamente se aparecer na Backpack
            local tool = plr.Backpack:FindFirstChild("Phone")
            if tool and plr.Character then
                plr.Character.Humanoid:EquipTool(tool)
            end
        end
    end
end)

-- Lag 2: Spam de Uso de Ferramenta
makeToggle("Lag 2 (Tool Spam)", false, function(state)
    lag2Enabled = state
end)

task.spawn(function()
    while task.wait(0.001) do
        if lag2Enabled then
            -- Tenta usar a primeira tool que encontrar (na mão ou na mochila)
            local tool = plr.Character:FindFirstChildOfClass("Tool") or plr.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end)

-- Botão para fechar o Hub
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)

close.MouseButton1Click:Connect(function()
    lag1Enabled = false
    lag2Enabled = false
    gui:Destroy()
end)
