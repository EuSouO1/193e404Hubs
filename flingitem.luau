--// Fling Item Hub - Custom Version
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingItemHub_V3"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,300)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Fling Item Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8,0,0,35)
box.Position = UDim2.new(0.1,0,0.12,0)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)

local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.9,0,0,90)
listFrame.Position = UDim2.new(0.05,0,0.25,0)
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,4)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.60,0)
toggle.Text = "Fling OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

local allToggle = Instance.new("TextButton", frame)
allToggle.Size = UDim2.new(0.8,0,0,35)
allToggle.Position = UDim2.new(0.1,0,0.75,0)
allToggle.Text = "Fling All OFF"
allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
allToggle.TextScaled = true
allToggle.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

--// ESTADOS
local running = false
local flingAllActive = false
local SavedPos = nil

local function refreshPlayers()
    for _,v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-6,0,24)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Text = p.Name
            btn.Parent = listFrame
            btn.MouseButton1Click:Connect(function() box.Text = p.Name end)
        end
    end
end
refreshPlayers()
game.Players.PlayerAdded:Connect(refreshPlayers)
game.Players.PlayerRemoving:Connect(refreshPlayers)

--// LÓGICA DE TELEPORT/GLITCH
local function GlitchFling(TargetPlayer)
    local Character = plr.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
    
    local TCharacter = TargetPlayer.Character
    local TRoot = TCharacter and TCharacter:FindFirstChild("HumanoidRootPart")
    local THum = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")

    if not RootPart or not TRoot or not THum then return end

    -- Salva posição antes de começar (se não estiver fligando ainda)
    if not SavedPos then SavedPos = RootPart.CFrame end

    local startTime = tick()
    
    while (running or flingAllActive) and TargetPlayer.Parent do
        -- Se o alvo sentar: Teleporta para o void, solta item e volta
        if THum.Sit then
            RootPart.CFrame = CFrame.new(0, -495, 0)
            task.wait(0.1)
            if Hum then Hum:UnequipTools() end
            task.wait(0.1)
            if not flingAllActive then break end -- No All, ele continua pro próximo
        end

        -- Lógica de oscilação (1 a 5 studs)
        local distance = math.random(1, 5)
        RootPart.CFrame = TRoot.CFrame * CFrame.new(0, 0, -distance)
        
        task.wait(0.001) -- 1 milisegundo

        -- Tempo de segurança por alvo no modo 'All' ou timeout individual
        if tick() - startTime > 2.5 then break end 
        if not (running or flingAllActive) then break end
    end

    -- Retorno para a posição salva (Apenas no individual ou ao desligar o All)
    if not flingAllActive and SavedPos then
        RootPart.CFrame = SavedPos
        SavedPos = nil
    end
end

--// BOTÃO ALL
allToggle.MouseButton1Click:Connect(function()
    flingAllActive = not flingAllActive
    allToggle.Text = flingAllActive and "Fling All ON" or "Fling All OFF"
    allToggle.BackgroundColor3 = flingAllActive and Color3.fromRGB(0,170,0) or Color3.fromRGB(0, 85, 127)
    
    if flingAllActive then
        running = false
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        
        task.spawn(function()
            -- Salva posição uma vez antes de iniciar o loop global
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local mainSavedPos = plr.Character.HumanoidRootPart.CFrame
                while flingAllActive do
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if not flingAllActive then break end
                        if p ~= plr and p.Character then
                            GlitchFling(p)
                        end
                    end
                    task.wait()
                end
                -- Volta para o lugar original quando o All for desativado
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = mainSavedPos
                end
            end
        end)
    end
end)

--// BOTÃO INDIVIDUAL
toggle.MouseButton1Click:Connect(function()
    running = not running
    if running then
        flingAllActive = false
        allToggle.Text = "Fling All OFF"
        allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)

        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(box.Text:lower()) then target = p break end
        end
        
        if target then
            toggle.Text = "Flinging..."
            toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
            task.spawn(function()
                while running do
                    GlitchFling(target)
                    task.wait()
                end
                toggle.Text = "Fling OFF"
                toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
            end)
        else
            running = false
            toggle.Text = "Not Found"
            task.wait(1)
            toggle.Text = "Fling OFF"
        end
    else
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
