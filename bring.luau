-- TP Hub (versão limpa e funcional)

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- garantir PlayerGui
local playerGui = plr:WaitForChild("PlayerGui")

-- remover GUI antiga se existir
if playerGui:FindFirstChild("TPHub") then
    playerGui.TPHub:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TPHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,400,0,400)
frame.Position = UDim2.new(0.5,-200,0.5,-200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "TP Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

-- PLAYER LIST
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.4,-5,1,-40)
playerList.Position = UDim2.new(0,5,0,35)
playerList.CanvasSize = UDim2.new(0,0,0,0)
playerList.ScrollBarThickness = 6
playerList.BackgroundColor3 = Color3.fromRGB(35,35,35)
playerList.BorderSizePixel = 0
playerList.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = playerList

local actions = Instance.new("Frame")
actions.Size = UDim2.new(0.6,-10,1,-40)
actions.Position = UDim2.new(0.4,10,0,35)
actions.BackgroundColor3 = Color3.fromRGB(40,40,40)
actions.BorderSizePixel = 0
actions.Parent = frame

local selectedPlayer = nil

local function updateCanvas()
    task.wait()
    playerList.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+10)
end

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- adicionar players na lista
local function addPlayer(p)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-6,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = p.Name
    btn.Parent = playerList

    btn.MouseButton1Click:Connect(function()
        selectedPlayer = p
        for _,v in pairs(playerList:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Color3.fromRGB(60,60,60)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    end)

    updateCanvas()
end

for _,p in ipairs(Players:GetPlayers()) do
    addPlayer(p)
end

Players.PlayerAdded:Connect(addPlayer)

-- BOTÃO: TP para todas as tools (não equipadas)
local tpTools = Instance.new("TextButton")
tpTools.Size = UDim2.new(1,-10,0,50)
tpTools.Position = UDim2.new(0,5,0,10)
tpTools.BackgroundColor3 = Color3.fromRGB(170,0,0)
tpTools.TextColor3 = Color3.new(1,1,1)
tpTools.TextScaled = true
tpTools.Text = "Teleport To All Tools"
tpTools.Parent = actions

tpTools.MouseButton1Click:Connect(function()
    local char = plr.Character
    if not char then return end
    local hrp = getHRP(char)
    if not hrp then return end

    for _,tool in ipairs(workspace:GetDescendants()) do
        if tool:IsA("Tool") and tool.Parent == workspace and tool:FindFirstChild("Handle") then
            hrp.CFrame = tool.Handle.CFrame
            task.wait(0.2)
        end
    end
end)

-- BOTÃO: TP para jogador selecionado
local tpPlayer = Instance.new("TextButton")
tpPlayer.Size = UDim2.new(1,-10,0,50)
tpPlayer.Position = UDim2.new(0,5,0,70)
tpPlayer.BackgroundColor3 = Color3.fromRGB(170,0,0)
tpPlayer.TextColor3 = Color3.new(1,1,1)
tpPlayer.TextScaled = true
tpPlayer.Text = "Teleport To Selected"
tpPlayer.Parent = actions

tpPlayer.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        warn("Selecione um jogador")
        return
    end

    local char = plr.Character
    if not char then return end

    local myHRP = getHRP(char)
    local targetHRP = getHRP(selectedPlayer.Character)

    if myHRP and targetHRP then
        myHRP.CFrame = targetHRP.CFrame
    end
end)

-- BOTÃO FECHAR
local close = Instance.new("TextButton")
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)
close.Parent = frame

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
