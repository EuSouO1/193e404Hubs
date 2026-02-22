--// GUI CONFIG
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingGui_V3"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 380) -- Altura aumentada para 380
frame.Position = UDim2.new(0.5, -150, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Fling Player Pro V3"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.9, 0, 0, 35)
box.Position = UDim2.new(0.05, 0, 0.1, 0)
box.PlaceholderText = "Nome do alvo..."
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.TextColor3 = Color3.new(1, 1, 1)

-- LISTA DE JOGADORES
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.9, 0, 0, 120)
listFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0, 4)

-- CONTAINER PARA BOTÕES (Organização automática)
local buttonContainer = Instance.new("Frame", frame)
buttonContainer.Size = UDim2.new(0.9, 0, 0, 140)
buttonContainer.Position = UDim2.new(0.05, 0, 0.58, 0)
buttonContainer.BackgroundTransparency = 1

local bLayout = Instance.new("UIListLayout", buttonContainer)
bLayout.Padding = UDim.new(0, 5)

local function createBtn(text, color)
    local b = Instance.new("TextButton", buttonContainer)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextScaled = true
    b.BorderSizePixel = 0
    return b
end

local flingAllBtn = createBtn("Fling All OFF", Color3.fromRGB(170, 0, 0))
local toggle = createBtn("Fling OFF", Color3.fromRGB(170, 0, 0))
local itemToggle = createBtn("FlingItem OFF", Color3.fromRGB(170, 0, 0))

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -28, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ESTADOS
local running = false
local flingAllActive = false
local flingItem = false
local currentDist = 2

-- FUNÇÃO DE ATAQUE REVISADA
local function attack(target)
    local spin = 0
    local isVoiding = false
    
    -- O loop roda enquanto o alvo for válido E um dos modos estiver ligado
    while target and target.Character and (running or flingAllActive) do
        local char = plr.Character
        local tchar = target.Character
        if not char or not tchar then break end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        local thum = tchar:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not thrp or not thum then break end

        if thum.Sit or isVoiding then
            isVoiding = true
            hrp.CFrame = CFrame.new(thrp.Position.X, -3000, thrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.new(0, -5000, 0)
        else
            if flingItem then
                local tool = plr.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
                if tool then char.Humanoid:EquipTool(tool) end
                hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, currentDist)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            else
                spin += 60
                local pos = thrp.Position + Vector3.new(math.cos(spin)*2.5, 0, math.sin(spin)*2.5)
                hrp.CFrame = CFrame.new(pos, thrp.Position)
                hrp.AssemblyLinearVelocity = (thrp.Position - hrp.Position).Unit * 500
                hrp.AssemblyAngularVelocity = Vector3.new(0, 10000, 0)
            end
        end
        RunService.Heartbeat:Wait()
        -- Pequena pausa para o Fling All trocar de alvo sem travar o script
        if not running and flingAllActive then break end 
    end
end

-- LÓGICA FLING ALL
flingAllBtn.MouseButton1Click:Connect(function()
    flingAllActive = not flingAllActive
    if flingAllActive then
        flingAllBtn.Text = "Fling All ON"
        flingAllBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        task.spawn(function()
            while flingAllActive do
                local plrs = game.Players:GetPlayers()
                for _, p in ipairs(plrs) do
                    if not flingAllActive then break end
                    if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        attack(p)
                        task.wait(0.5)
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        flingAllBtn.Text = "Fling All OFF"
        flingAllBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

-- LÓGICA SINGLE FLING
toggle.MouseButton1Click:Connect(function()
    running = not running
    if running then
        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(box.Text:lower()) then target = p break end
        end
        if target then
            toggle.Text = "Flinging: " .. target.DisplayName
            toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            task.spawn(function() attack(target) end)
        else
            running = false
            toggle.Text = "Não encontrado"
            task.wait(1)
            toggle.Text = "Fling OFF"
        end
    else
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

-- ITEM TOGGLE
itemToggle.MouseButton1Click:Connect(function()
    flingItem = not flingItem
    itemToggle.Text = flingItem and "FlingItem ON" or "FlingItem OFF"
    itemToggle.BackgroundColor3 = flingItem and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- REFRESH LISTA
local function refresh()
    for _,v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            local b = Instance.new("TextButton", listFrame)
            b.Size = UDim2.new(1, -6, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            b.TextColor3 = Color3.new(1,1,1)
            b.TextScaled = true
            b.MouseButton1Click:Connect(function() box.Text = p.Name end)
        end
    end
end
refresh()
game.Players.PlayerAdded:Connect(refresh)
game.Players.PlayerRemoving:Connect(refresh)

-- DISTANCIA RANDOM
task.spawn(function()
    while true do
        currentDist = math.random(1, 4)
        task.wait(0.1)
    end
end)
