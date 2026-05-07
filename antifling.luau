--// Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "AntiFling_Selective_V3"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "Anti-Fling Selective"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

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

--// Variáveis de Controle
local AntiFlingEnabled = false
local GodAntiFling = false
local buttons = {} -- Para resetar o visual dos botões

--// Função de Toggle
local function makeToggle(text, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    local state = false
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." OFF"

    local function updateVisual(s)
        state = s
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual(state)
        callback(state)
    end)
    
    buttons[text] = updateVisual
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    return btn
end

--// Função para resetar tudo ao morrer/respawnar
local function resetSettings()
    AntiFlingEnabled = false
    GodAntiFling = false
    -- Reseta o visual de todos os botões registrados
    for name, updateFunc in pairs(buttons) do
        updateFunc(false)
    end
end

plr.CharacterAdded:Connect(resetSettings)

--// Lógica Principal (Focada no HumanoidRootPart)
RunService.Stepped:Connect(function()
    if not AntiFlingEnabled then return end
    
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Tira a colisão apenas do RootPart para evitar o impacto principal
        root.CanCollide = false
        
        -- Se a velocidade subir demais, anula
        if root.Velocity.Magnitude > 35 then
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
        end
        
        -- Lógica contra outros Players (Root to Root)
        for _, other in pairs(game:GetService("Players"):GetPlayers()) do
            if other ~= plr and other.Character then
                local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
                if otherRoot then
                    otherRoot.CanCollide = false
                    
                    -- Se o modo God estiver on, anula a força do atacante
                    if GodAntiFling then
                        otherRoot.Velocity = Vector3.new(0,0,0)
                        otherRoot.RotVelocity = Vector3.new(0,0,0)
                    end
                end
            end
        end
    end
end)

--// Controles
makeToggle("Anti-Fling Root", function(s)
    AntiFlingEnabled = s
end)

makeToggle("God Root Shield", function(s)
    GodAntiFling = s
end)

-- Botão fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
