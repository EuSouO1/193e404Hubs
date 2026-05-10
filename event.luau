--// Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "EventHub_V2_Fixed"
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
title.Text = "Event Hub Pro V2"
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

-- FILTRO DE BUSCA (IGNORA PLAYER)
local function getGameEvents()
    local validRemotes = {}
    local targets = {game:GetService("ReplicatedStorage"), game:GetService("Workspace")}
    
    for _, service in pairs(targets) do
        for _, v in pairs(service:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                table.insert(validRemotes, v)
            end
        end
    end
    return validRemotes
end

-- TEXTBOX
local box = Instance.new("TextBox", scroll)
box.Size = UDim2.new(1,-8,0,45)
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)
box.PlaceholderText = "Nome do Remote"
box.Text = ""
box.TextScaled = true

box.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local searchText = box.Text:lower()
        for _, v in pairs(getGameEvents()) do
            if v.Name:lower():find(searchText) then
                box.Text = v.Name
                break
            end
        end
    end
end)

-- FUNÇÃO BOTÃO
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

-- 1. DISPARAR SELECIONADO
makeBtn("Disparar Selecionado", Color3.fromRGB(0, 120, 215), function()
    for _, v in pairs(getGameEvents()) do
        if v.Name == box.Text then
            v:FireServer()
        end
    end
end)

-- 2. DISPARAR ALEATÓRIO
makeBtn("Disparar Aleatório", Color3.fromRGB(100, 0, 150), function()
    local remotes = getGameEvents()
    if #remotes > 0 then
        local randomEvent = remotes[math.random(1, #remotes)]
        randomEvent:FireServer()
        box.Text = randomEvent.Name
    end
end)

-- 3. ALERTA DE CONFIRMAÇÃO (CORRIGIDO)
local confirmFrame = Instance.new("Frame", gui)
confirmFrame.Size = UDim2.new(0,260,0,160)
confirmFrame.Position = UDim2.new(0.5,-130,0.5,-80)
confirmFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
confirmFrame.BorderSizePixel = 2
confirmFrame.Visible = false
confirmFrame.ZIndex = 10

local alertText = Instance.new("TextLabel", confirmFrame)
alertText.Size = UDim2.new(1, 0, 0.6, 0)
alertText.BackgroundTransparency = 1
alertText.Text = "AVISO:\nDisparar todos pode te dar KICK ou travar o mapa. Continuar?"
alertText.TextColor3 = Color3.new(1, 1, 1)
alertText.TextScaled = true
alertText.ZIndex = 11

local yes = Instance.new("TextButton", confirmFrame)
yes.Size = UDim2.new(0.4, 0, 0.3, 0)
yes.Position = UDim2.new(0.05, 0, 0.65, 0)
yes.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
yes.Text = "SIM"
yes.TextColor3 = Color3.new(1, 1, 1)
yes.TextScaled = true
yes.ZIndex = 11

local no = Instance.new("TextButton", confirmFrame)
no.Size = UDim2.new(0.4, 0, 0.3, 0)
no.Position = UDim2.new(0.55, 0, 0.65, 0)
no.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
no.Text = "NÃO"
no.TextColor3 = Color3.new(1, 1, 1)
no.TextScaled = true
no.ZIndex = 11

makeBtn("DISPARAR TODOS", Color3.fromRGB(170, 0, 0), function()
    confirmFrame.Visible = true
end)

yes.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
    local remotes = getGameEvents()
    for _, v in pairs(remotes) do
        v:FireServer()
    end
end)

no.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
end)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -28, 0, 4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
