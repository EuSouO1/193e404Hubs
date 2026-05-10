--// Services
local plr = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")

--// GUI Principal
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "EventHub_V4_Final"
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
title.Text = "Event Hub V4"
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

--// TextBoxes
local boxEvent = Instance.new("TextBox", scroll)
boxEvent.Size = UDim2.new(1,-8,0,40); boxEvent.BackgroundColor3 = Color3.fromRGB(40,40,40); boxEvent.TextColor3 = Color3.new(1,1,1); boxEvent.PlaceholderText = "Nome do Remote"; boxEvent.Text = ""; boxEvent.TextScaled = true

local boxPlayer = Instance.new("TextBox", scroll)
boxPlayer.Size = UDim2.new(1,-8,0,40); boxPlayer.BackgroundColor3 = Color3.fromRGB(40,40,40); boxPlayer.TextColor3 = Color3.new(1,1,1); boxPlayer.PlaceholderText = "Player (Vazio = Nenhum)"; boxPlayer.Text = plr.Name; boxPlayer.TextScaled = true

local boxValue = Instance.new("TextBox", scroll)
boxValue.Size = UDim2.new(1,-8,0,40); boxValue.BackgroundColor3 = Color3.fromRGB(40,40,40); boxValue.TextColor3 = Color3.new(1,1,1); boxValue.PlaceholderText = "Valor (Vazio = Nenhum)"; boxValue.Text = "100"; boxValue.TextScaled = true

--// Lógica de Busca
local function getGameEvents()
    local res = {}
    local targets = {game:GetService("ReplicatedStorage"), game:GetService("Workspace")}
    for _, s in pairs(targets) do
        for _, v in pairs(s:GetDescendants()) do if v:IsA("RemoteEvent") then table.insert(res, v) end end
    end
    return res
end

boxEvent.FocusLost:Connect(function(e)
    if e then
        for _, v in pairs(getGameEvents()) do if v.Name:lower():find(boxEvent.Text:lower()) then boxEvent.Text = v.Name break end end
    end
end)

boxPlayer.FocusLost:Connect(function(e)
    if e and boxPlayer.Text ~= "" then
        for _, p in pairs(Players:GetPlayers()) do if p.Name:lower():find(boxPlayer.Text:lower()) then boxPlayer.Text = p.Name break end end
    end
end)

--// Função de Disparo Inteligente
local function fire(remote)
    if not remote or not remote:IsA("RemoteEvent") then return end
    
    local args = {}
    
    -- Checa Player
    if boxPlayer.Text ~= "" then
        local target = Players:FindFirstChild(boxPlayer.Text)
        table.insert(args, target or boxPlayer.Text)
    end
    
    -- Checa Valor
    if boxValue.Text ~= "" then
        local val = tonumber(boxValue.Text) or boxValue.Text
        table.insert(args, val)
    end
    
    -- Dispara com a lista de argumentos (unpack desempacota a tabela)
    remote:FireServer(unpack(args))
end

--// Interface de Alerta (Corrigida)
local alertGui = Instance.new("Frame", gui)
alertGui.Size = UDim2.new(0, 260, 0, 160)
alertGui.Position = UDim2.new(0.5, -130, 0.5, -80)
alertGui.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
alertGui.BorderSizePixel = 2
alertGui.Visible = false
alertGui.ZIndex = 50 -- Valor alto para garantir prioridade

local alertText = Instance.new("TextLabel", alertGui)
alertText.Size = UDim2.new(1, 0, 0.6, 0)
alertText.BackgroundTransparency = 1
alertText.Text = "DISPARAR TODOS?\nIsso pode causar lag intenso."
alertText.TextColor3 = Color3.new(1, 1, 1)
alertText.TextScaled = true
alertText.ZIndex = 51

local yesBtn = Instance.new("TextButton", alertGui)
yesBtn.Size = UDim2.new(0.4, 0, 0.3, 0)
yesBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
yesBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
yesBtn.Text = "SIM"; yesBtn.TextColor3 = Color3.new(1, 1, 1); yesBtn.TextScaled = true; yesBtn.ZIndex = 51

local noBtn = Instance.new("TextButton", alertGui)
noBtn.Size = UDim2.new(0.4, 0, 0.3, 0)
noBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
noBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
noBtn.Text = "NÃO"; noBtn.TextColor3 = Color3.new(1, 1, 1); noBtn.TextScaled = true; noBtn.ZIndex = 51

--// Botões do Menu
local function makeBtn(txt, col, cb)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1,-8,0,45); b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1); b.TextScaled = true; b.Text = txt
    b.MouseButton1Click:Connect(cb)
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

makeBtn("Disparar Selecionado", Color3.fromRGB(0, 120, 215), function()
    for _, v in pairs(getGameEvents()) do if v.Name == boxEvent.Text then fire(v) end end
end)

makeBtn("Disparar Aleatório", Color3.fromRGB(100, 0, 150), function()
    local remotes = getGameEvents()
    if #remotes > 0 then
        local r = remotes[math.random(1, #remotes)]
        boxEvent.Text = r.Name
        fire(r)
    end
end)

makeBtn("DISPARAR TODOS", Color3.fromRGB(170, 0, 0), function() alertGui.Visible = true end)

yesBtn.MouseButton1Click:Connect(function()
    alertGui.Visible = false
    for _, v in pairs(getGameEvents()) do fire(v) end
end)
noBtn.MouseButton1Click:Connect(function() alertGui.Visible = false end)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25); close.Position = UDim2.new(1,-28,0,4); close.Text = "X"; close.BackgroundColor3 = Color3.fromRGB(170,0,0); close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
