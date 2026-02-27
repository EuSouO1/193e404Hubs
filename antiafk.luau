--// Player & Services
local plr = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")

--// GUI (Mesmo estilo do seu hub)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "AntiAFKHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,150) -- Ajustado para ser menor, já que tem menos opções
frame.Position = UDim2.new(0.5,-160,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Anti-AFK System"
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

-- Função de criar botão toggle (mesmo estilo do original)
local function makeToggle(text, initialState, callback)
    local state = initialState
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    
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

---// Lógica Anti-AFK

local antiAfkEnabled = false
local antiAfkThread = nil

makeToggle("Anti-AFK Jump", false, function(state)
    antiAfkEnabled = state
    
    if state then
        -- Inicia o loop em uma thread separada
        antiAfkThread = task.spawn(function()
            while antiAfkEnabled do
                -- Espera 19 minutos e 55 segundos
                task.wait(1195) 
                
                -- Verifica novamente se ainda está ativado antes de pular
                if antiAfkEnabled and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Jump = true
                    end
                end
            end
        end)
    else
        -- Para a execução se o botão for desligado
        if antiAfkThread then
            antiAfkThread = nil
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
    antiAfkEnabled = false -- Desativa a função ao fechar
    gui:Destroy()
end)
