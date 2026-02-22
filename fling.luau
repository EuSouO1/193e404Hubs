--// Powered Fling (Powered Hub Visual)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

--====================================================
-- GUI SETUP (Visual Powered Hub)
--====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "PoweredFling"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,360,0,430)
frame.Position = UDim2.new(0.5,-180,0.5,-215)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Powered Fling"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,28,0,28)
close.Position = UDim2.new(1,-32,0,2)
close.Text = "X"
close.TextScaled = true
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

--====================================================
-- STATES & VARIABLES
--====================================================
local running = false
local flingItem = false
local targetPlayer = nil
local currentDist = 2
local isVoiding = false

-- Distância Dinâmica (Jitter)
task.spawn(function()
    while true do
        currentDist = math.random(1, 4)
        task.wait(0.1)
    end
end)

--====================================================
-- PLAYER LIST (Lista Superior)
--====================================================
local list = Instance.new("ScrollingFrame", frame)
list.Size = UDim2.new(1,-10,0,130)
list.Position = UDim2.new(0,5,0,35)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarThickness = 6
list.BackgroundColor3 = Color3.fromRGB(35,35,35)
list.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,4)

local function updateCanvas()
    task.wait()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end

local function addPlayer(p)
    if p == plr then return end
    local b = Instance.new("TextButton", list)
    b.Size = UDim2.new(1,-6,0,28)
    b.Text = p.Name
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0

    b.MouseButton1Click:Connect(function()
        targetPlayer = p
        title.Text = "Target: " .. p.Name
    end)
    updateCanvas()
end

for _,p in ipairs(Players:GetPlayers()) do addPlayer(p) end
Players.PlayerAdded:Connect(addPlayer)

--====================================================
-- OPTIONS (Lista Inferior)
--====================================================
local options = Instance.new("ScrollingFrame", frame)
options.Size = UDim2.new(1,-10,0,230)
options.Position = UDim2.new(0,5,0,175)
options.ScrollBarThickness = 6
options.BackgroundColor3 = Color3.fromRGB(30,30,30)
options.BorderSizePixel = 0

local optLayout = Instance.new("UIListLayout", options)
optLayout.Padding = UDim.new(0,5)

local function createToggle(name, callback)
    local state = false
    local b = Instance.new("TextButton", options)
    b.Size = UDim2.new(1,-6,0,40)
    b.Text = name .. " OFF"
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(170,0,0)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0

    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name .. (state and " ON" or " OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
end

-- Botões de Opção
createToggle("Start Fling", function(v) 
    running = v 
    if v and targetPlayer then
        task.spawn(function() flingLoop(targetPlayer) end)
    end
end)

createToggle("Fling Item Mode", function(v) 
    flingItem = v 
end)

--====================================================
-- FLING LOGIC (CORE)
--====================================================
function flingLoop(target)
    local spin = 0
    isVoiding = false
    
    while running and target and target.Parent and plr.Character do
        local char = plr.Character
        local tchar = target.Character
        if not tchar then break end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        local thum = tchar:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not thrp or not thum then break end

        -- LÓGICA DO VOID (MORTE GARANTIDA)
        if (thum.Sit and flingItem) or isVoiding then
            isVoiding = true
            hrp.CFrame = CFrame.new(thrp.Position.X, -3000, thrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.new(0, -9000, 0)
        else
            -- MODOS DE ATAQUE
            if flingItem then
                -- Auto Equip Tool 1
                local tool = plr.Backpack:FindFirstChildOfClass("Tool")
                if tool then char.Humanoid:EquipTool(tool) end
                
                -- Perseguição Jitter
                hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, currentDist)
                hrp.AssemblyLinearVelocity = Vector3.zero
            else
                -- Fling Normal Rotacional
                spin += 60
                local pos = thrp.Position + Vector3.new(math.cos(spin)*2.5, 0, math.sin(spin)*2.5)
                hrp.CFrame = CFrame.new(pos, thrp.Position)
                hrp.AssemblyLinearVelocity = (thrp.Position - hrp.Position).Unit * 500
                hrp.AssemblyAngularVelocity = Vector3.new(0, 10000, 0)
            end
        end
        RunService.Heartbeat:Wait()
    end
    -- Limpeza ao desligar
    running = false
    isVoiding = false
end
