--// Services
local plr = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")

--// GUI Principal
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "EventHub_V7_SelectionMenu"
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
title.Text = "Event Hub V7"
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

--// LISTA LATERAL DE EVENTOS
local listFrame = Instance.new("Frame", gui)
listFrame.Size = UDim2.new(0, 250, 0, 450)
listFrame.Position = UDim2.new(0.5, 165, 0.5, -225)
listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
listFrame.Visible = false

local listTitle = Instance.new("TextLabel", listFrame)
listTitle.Size = UDim2.new(1, 0, 0, 30)
listTitle.Text = "Selecione o Remote"
listTitle.TextColor3 = Color3.new(1, 1, 1)
listTitle.TextScaled = true
listTitle.BackgroundTransparency = 1

local searchBox = Instance.new("TextBox", listFrame)
searchBox.Size = UDim2.new(1, -10, 0, 30)
searchBox.Position = UDim2.new(0, 5, 0, 35)
searchBox.PlaceholderText = "Pesquisar evento..."
searchBox.Text = ""
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBox.TextColor3 = Color3.new(1,1,1)

local eventScroll = Instance.new("ScrollingFrame", listFrame)
eventScroll.Size = UDim2.new(1, -10, 1, -75)
eventScroll.Position = UDim2.new(0, 5, 0, 70)
eventScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
eventScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
eventScroll.ScrollBarThickness = 4

local listLayout = Instance.new("UIListLayout", eventScroll)
listLayout.Padding = UDim.new(0, 2)

--// Componentes do Menu Principal
local eventBtn = Instance.new("TextButton", scroll)
eventBtn.Size = UDim2.new(1,-8,0,40); eventBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); eventBtn.TextColor3 = Color3.new(1,1,1); eventBtn.Text = "Clique para escolher Remote"; eventBtn.TextScaled = true

local boxPlayer = Instance.new("TextBox", scroll)
boxPlayer.Size = UDim2.new(1,-8,0,40); boxPlayer.BackgroundColor3 = Color3.fromRGB(40,40,40); boxPlayer.TextColor3 = Color3.new(1,1,1); boxPlayer.Text = plr.Name; boxPlayer.TextScaled = true

local boxValue = Instance.new("TextBox", scroll)
boxValue.Size = UDim2.new(1,-8,0,40); boxValue.BackgroundColor3 = Color3.fromRGB(40,40,40); boxValue.TextColor3 = Color3.new(1,1,1); boxValue.Text = "100"; boxValue.TextScaled = true

--// Funções de Lógica
local selectedRemote = nil

local function getGameEvents()
    local res = {}
    local targets = {game:GetService("ReplicatedStorage"), game:GetService("Workspace")}
    for _, s in pairs(targets) do
        for _, v in pairs(s:GetDescendants()) do if v:IsA("RemoteEvent") then table.insert(res, v) end end
    end
    return res
end

local function refreshEventList()
    for _, child in pairs(eventScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    
    local filter = searchBox.Text:lower()
    for _, v in pairs(getGameEvents()) do
        if filter == "" or v.Name:lower():find(filter) then
            local b = Instance.new("TextButton", eventScroll)
            b.Size = UDim2.new(1, 0, 0, 30)
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            b.Text = v.Name
            b.TextColor3 = Color3.new(1, 1, 1)
            b.TextScaled = true
            b.MouseButton1Click:Connect(function()
                selectedRemote = v
                eventBtn.Text = v.Name
                listFrame.Visible = false
            end)
        end
    end
    eventScroll.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y)
end

eventBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
    if listFrame.Visible then refreshEventList() end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshEventList)

boxPlayer.FocusLost:Connect(function(e)
    if e and boxPlayer.Text ~= "" then
        for _, p in pairs(Players:GetPlayers()) do if p.Name:lower():find(boxPlayer.Text:lower()) then boxPlayer.Text = p.Name break end end
    end
end)

local function fire(remote)
    if not remote then return end
    local args = {}
    if boxPlayer.Text ~= "" then
        local target = Players:FindFirstChild(boxPlayer.Text)
        table.insert(args, target or boxPlayer.Text)
    end
    if boxValue.Text ~= "" then
        local val = tonumber(boxValue.Text) or boxValue.Text
        table.insert(args, val)
    end
    remote:FireServer(unpack(args))
end

--// Interface de Alerta
local alertGui = Instance.new("Frame", gui)
alertGui.Size = UDim2.new(0, 260, 0, 160); alertGui.Position = UDim2.new(0.5, -130, 0.5, -80); alertGui.BackgroundColor3 = Color3.fromRGB(60, 0, 0); alertGui.Visible = false; alertGui.ZIndex = 100

local alertText = Instance.new("TextLabel", alertGui)
alertText.Size = UDim2.new(1, 0, 0.6, 0); alertText.BackgroundTransparency = 1; alertText.Text = "DISPARAR TODOS?"; alertText.TextColor3 = Color3.new(1, 1, 1); alertText.TextScaled = true; alertText.ZIndex = 101

local yesBtn = Instance.new("TextButton", alertGui)
yesBtn.Size = UDim2.new(0.4, 0, 0.3, 0); yesBtn.Position = UDim2.new(0.05, 0, 0.65, 0); yesBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); yesBtn.Text = "SIM"; yesBtn.TextColor3 = Color3.new(1, 1, 1); yesBtn.TextScaled = true; yesBtn.ZIndex = 101

local noBtn = Instance.new("TextButton", alertGui)
noBtn.Size = UDim2.new(0.4, 0, 0.3, 0); noBtn.Position = UDim2.new(0.55, 0, 0.65, 0); noBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70); noBtn.Text = "NÃO"; noBtn.TextColor3 = Color3.new(1, 1, 1); noBtn.TextScaled = true; noBtn.ZIndex = 101

--// Botões de Ação
local function makeBtn(txt, col, cb)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1,-8,0,45); b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1); b.TextScaled = true; b.Text = txt
    b.MouseButton1Click:Connect(cb)
end

makeBtn("Disparar Selecionado", Color3.fromRGB(0, 120, 215), function() fire(selectedRemote) end)

makeBtn("Disparar Aleatório", Color3.fromRGB(100, 0, 150), function()
    local remotes = getGameEvents()
    if #remotes > 0 then
        local r = remotes[math.random(1, #remotes)]
        selectedRemote = r
        eventBtn.Text = r.Name
        fire(r)
    end
end)

makeBtn("DISPARAR TODOS", Color3.fromRGB(170, 0, 0), function() alertGui.Visible = true end)

yesBtn.MouseButton1Click:Connect(function() alertGui.Visible = false; for _, v in pairs(getGameEvents()) do fire(v) end end)
noBtn.MouseButton1Click:Connect(function() alertGui.Visible = false end)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25); close.Position = UDim2.new(1,-28,0,4); close.Text = "X"; close.BackgroundColor3 = Color3.fromRGB(170,0,0); close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
