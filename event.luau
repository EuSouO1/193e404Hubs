--// Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "EventHub_V3_Advanced"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,450)
frame.Position = UDim2.new(0.5,-160,0.5,-225)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "Event Hub V3 + Args"
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

-- FILTRO DE EVENTOS DO JOGO
local function getGameEvents()
    local validRemotes = {}
    local targets = {game:GetService("ReplicatedStorage"), game:GetService("Workspace")}
    for _, service in pairs(targets) do
        for _, v in pairs(service:GetDescendants()) do
            if v:IsA("RemoteEvent") then table.insert(validRemotes, v) end
        end
    end
    return validRemotes
end

-- TEXTBOX: NOME DO EVENTO
local boxEvent = Instance.new("TextBox", scroll)
boxEvent.Size = UDim2.new(1,-8,0,40)
boxEvent.BackgroundColor3 = Color3.fromRGB(40,40,40)
boxEvent.TextColor3 = Color3.new(1,1,1)
boxEvent.PlaceholderText = "Nome do Remote"
boxEvent.Text = ""
boxEvent.TextScaled = true

boxEvent.FocusLost:Connect(function(enter)
    if enter then
        local search = boxEvent.Text:lower()
        for _, v in pairs(getGameEvents()) do
            if v.Name:lower():find(search) then boxEvent.Text = v.Name break end
        end
    end
end)

-- TEXTBOX: ALVO (PLAYER)
local boxPlayer = Instance.new("TextBox", scroll)
boxPlayer.Size = UDim2.new(1,-8,0,40)
boxPlayer.BackgroundColor3 = Color3.fromRGB(40,40,40)
boxPlayer.TextColor3 = Color3.new(1,1,1)
boxPlayer.Text = plr.Name
boxPlayer.TextScaled = true

boxPlayer.FocusLost:Connect(function(enter)
    if enter then
        local search = boxPlayer.Text:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():find(search) then boxPlayer.Text = p.Name break end
        end
    end
end)

-- TEXTBOX: VALOR
local boxValue = Instance.new("TextBox", scroll)
boxValue.Size = UDim2.new(1,-8,0,40)
boxValue.BackgroundColor3 = Color3.fromRGB(40,40,40)
boxValue.TextColor3 = Color3.new(1,1,1)
boxValue.Text = "100"
boxValue.TextScaled = true

-- FUNÇÃO DISPARAR COM ARGUMENTOS
local function fire(remote)
    if remote and remote:IsA("RemoteEvent") then
        local targetName = boxPlayer.Text
        local targetObj = Players:FindFirstChild(targetName) or targetName
        local val = tonumber(boxValue.Text) or boxValue.Text
        
        -- Dispara: Remote:FireServer(PlayerObject, Valor)
        remote:FireServer(targetObj, val)
    end
end

-- FUNÇÃO CRIAR BOTÃO
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

-- BOTÕES DE AÇÃO
makeBtn("Disparar Selecionado", Color3.fromRGB(0, 120, 215), function()
    for _, v in pairs(getGameEvents()) do
        if v.Name == boxEvent.Text then fire(v) end
    end
end)

makeBtn("Disparar Aleatório", Color3.fromRGB(100, 0, 150), function()
    local remotes = getGameEvents()
    if #remotes > 0 then
        local rd = remotes[math.random(1, #remotes)]
        boxEvent.Text = rd.Name
        fire(rd)
    end
end)

-- ALERTA DISPARAR TODOS
local confirmFrame = Instance.new("Frame", gui)
confirmFrame.Size = UDim2.new(0,260,0,160)
confirmFrame.Position = UDim2.new(0.5,-130,0.5,-80)
confirmFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
confirmFrame.Visible = false
confirmFrame.ZIndex = 15

local alertT = Instance.new("TextLabel", confirmFrame)
alertT.Size = UDim2.new(1,0,0.6,0)
alertT.Text = "AVISO:\nIsso enviará (Alvo, Valor) para TODOS os eventos. Continuar?"
alertT.TextColor3 = Color3.new(1,1,1)
alertT.TextScaled = true
alertT.BackgroundTransparency = 1

local yes = Instance.new("TextButton", confirmFrame)
yes.Size = UDim2.new(0.4,0,0.3,0)
yes.Position = UDim2.new(0.05,0,0.65,0)
yes.Text = "SIM"; yes.TextColor3 = Color3.new(1,1,1); yes.TextScaled = true; yes.BackgroundColor3 = Color3.fromRGB(200,0,0)

local no = Instance.new("TextButton", confirmFrame)
no.Size = UDim2.new(0.4,0,0.3,0)
no.Position = UDim2.new(0.55,0,0.65,0)
no.Text = "NÃO"; no.TextColor3 = Color3.new(1,1,1); no.TextScaled = true; no.BackgroundColor3 = Color3.fromRGB(70,70,70)

makeBtn("DISPARAR TODOS", Color3.fromRGB(170, 0, 0), function() confirmFrame.Visible = true end)

yes.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
    for _, v in pairs(getGameEvents()) do fire(v) end
end)
no.MouseButton1Click:Connect(function() confirmFrame.Visible = false end)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"; close.BackgroundColor3 = Color3.fromRGB(170,0,0); close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
