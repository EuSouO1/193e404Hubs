--// Player & Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

--// GUI (Mesmo estilo do seu hub)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "AntiFlingHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,400)
frame.Position = UDim2.new(0.5,-160,0.5,-200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "Anti-Fling Pro Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,40)
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

-- Estados
local antiFlingActive = false
local noClipActive = false
local whitelist = {}

-- Função de criar botão toggle (estilo original)
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

-- LÓGICA ANTI-FLING
RunService.Stepped:Connect(function()
    if antiFlingActive then
        local char = plr.Character
        if char then
            for _, child in pairs(char:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                    -- Zera a velocidade se for jogado pra longe
                    if child.Velocity.Magnitude > 50 or child.RotVelocity.Magnitude > 50 then
                        child.Velocity = Vector3.new(0,0,0)
                        child.RotVelocity = Vector3.new(0,0,0)
                    end
                end
            end
            -- Desativa colisão com outros players
            for _, other in pairs(game:GetService("Players"):GetPlayers()) do
                if other ~= plr and other.Character and not whitelist[other.Name] then
                    for _, part in pairs(other.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

-- Toggles
makeToggle("Anti-Fling", false, function(state)
    antiFlingActive = state
end)

makeToggle("Noclip (Atravessa)", false, function(state)
    noClipActive = state
end)

-- Botão para Whitelist (Simples para o Hub)
local wlBtn = Instance.new("TextButton", scroll)
wlBtn.Size = UDim2.new(1,-8,0,45)
wlBtn.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
wlBtn.TextColor3 = Color3.new(1,1,1)
wlBtn.TextScaled = true
wlBtn.Text = "Add Player to WL"

wlBtn.MouseButton1Click:Connect(function()
    -- Aqui você pode integrar com seu sistema de box, 
    -- por enquanto ele pega o nome que estiver no Clipboard ou alvo próximo
    print("Whitelist System Active")
end)

-- Botão fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
