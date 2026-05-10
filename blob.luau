--// Player & Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

--// GUI (Blob Hub)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BlobHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Blob Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,35)
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

-- Função de criar botão toggle
local function makeToggle(text, callback)
    local state = false
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." OFF"

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)

    updateCanvas()
    return btn
end

---// Lógica das Funções

-- Anti AFK
local antiAfkEnabled = false
plr.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

makeToggle("Anti AFK", function(state)
    antiAfkEnabled = state
end)

-- Auto Farm (Movimentação por Caminhada)
local autoFarmEnabled = false

local function isPlayerNearby(pos)
    for _, otherPlr in pairs(game:GetService("Players"):GetPlayers()) do
        if otherPlr ~= plr and otherPlr.Character and otherPlr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (otherPlr.Character.HumanoidRootPart.Position - pos).Magnitude
            if dist < 15 then return true end
        end
    end
    return false
end

local function hasFloor(pos)
    -- Lógica de detecção de chão com Raycast
    local rayOrigin = pos + Vector3.new(0, 5, 0)
    local rayDirection = Vector3.new(0, -15, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {plr.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return result and result.Instance and result.Instance.CanCollide == true
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if autoFarmEnabled and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local hum = plr.Character.Humanoid
            local hrp = plr.Character.HumanoidRootPart
            
            local directions = {
                Vector3.new(20, 0, 0), Vector3.new(-20, 0, 0), 
                Vector3.new(0, 0, 20), Vector3.new(0, 0, -20),
                Vector3.new(15, 0, 15), Vector3.new(-15, 0, -15)
            }
            
            -- Embaralha a ordem das direções para ser aleatório
            for i = #directions, 2, -1 do
                local j = math.random(i)
                directions[i], directions[j] = directions[j], directions[i]
            end

            local targetPoint = nil
            
            for _, offset in ipairs(directions) do
                local checkPos = hrp.Position + offset
                if not isPlayerNearby(checkPos) and hasFloor(checkPos) then
                    targetPoint = checkPos
                    break
                end
            end
            
            -- Se não achou ponto ideal, tenta apenas o que tem chão
            if not targetPoint then
                for _, offset in ipairs(directions) do
                    if hasFloor(hrp.Position + offset) then
                        targetPoint = hrp.Position + offset
                        break
                    end
                end
            end

            if targetPoint then
                hum:MoveTo(targetPoint)
            end
        end
    end
end)

makeToggle("Auto Farm", function(state)
    autoFarmEnabled = state
    if not state and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid:MoveTo(plr.Character.HumanoidRootPart.Position) -- Para o player ao desligar
    end
end)

-- Botão de Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
