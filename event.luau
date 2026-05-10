--// Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "EventHub_V1"
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
title.Text = "Event Hub Pro"
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

-- TEXTBOX DE BUSCA
local box = Instance.new("TextBox", scroll)
box.Size = UDim2.new(1,-8,0,45)
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)
box.PlaceholderText = "Nome do RemoteEvent"
box.Text = ""
box.TextScaled = true

-- Lógica de Auto-Completar
box.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local searchText = box.Text:lower()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find(searchText) then
                box.Text = v.Name
                break
            end
        end
    end
end)

-- FUNÇÃO PARA CRIAR BOTÕES PADRÃO
local function makeBtn(text, color, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text
    btn.MouseButton1Click:Connect(callback)
    
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    return btn
end

-- 1. BOTÃO DISPARAR SELECIONADO
makeBtn("Disparar Selecionado", Color3.fromRGB(0, 120, 215), function()
    local event = game:GetDescendants()
    for _, v in pairs(event) do
        if v:IsA("RemoteEvent") and v.Name == box.Text then
            v:FireServer()
            print("Disparado: " .. v.Name)
        end
    end
end)

-- 2. BOTÃO DISPARAR ALEATÓRIO
makeBtn("Disparar Aleatório", Color3.fromRGB(100, 0, 150), function()
    local remotes = {}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then table.insert(remotes, v) end
    end
    
    if #remotes > 0 then
        local randomEvent = remotes[math.random(1, #remotes)]
        randomEvent:FireServer()
        box.Text = randomEvent.Name
    end
end)

-- 3. BOTÃO DISPARAR TODOS (COM ALERTA)
local confirmFrame = Instance.new("Frame", gui)
confirmFrame.Size = UDim2.new(0,250,0,150)
confirmFrame.Position = UDim2.new(0.5,-125,0.5,-75)
confirmFrame.BackgroundColor3 = Color3.fromRGB(40,0,0)
confirmFrame.Visible = false
confirmFrame.ZIndex = 10

local alertText = Instance.new("TextLabel", confirmFrame)
alertText.Size = UDim2.new(1,0,0.6,0)
alertText.Text = "VOCÊ TEM CERTEZA?\nIsso pode travar o servidor!"
alertText.TextColor3 = Color3.new(1,1,1)
alertText.TextScaled = true
alertText.BackgroundTransparency = 1

local yes = Instance.new("TextButton", confirmFrame)
yes.Size = UDim2.new(0.4,0,0.3,0)
yes.Position = UDim2.new(0.05,0,0.65,0)
yes.Text = "SIM"
yes.BackgroundColor3 = Color3.fromRGB(200,0,0)

local no = Instance.new("TextButton", confirmFrame)
no.Size = UDim2.new(0.4,0,0.3,0)
no.Position = UDim2.new(0.55,0,0.65,0)
no.Text = "NÃO"
no.BackgroundColor3 = Color3.fromRGB(60,60,60)

makeBtn("DISPARAR TODOS", Color3.fromRGB(170, 0, 0), function()
    confirmFrame.Visible = true
end)

yes.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            v:FireServer()
        end
    end
end)

no.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
end)

-- Botão fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
