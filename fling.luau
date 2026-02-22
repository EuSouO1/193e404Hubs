-- FlingHub (Powered Hub Style)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

repeat task.wait() until plr.Character

--====================================================
-- GUI (Visual idêntico ao Powered Hub)
--====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FlingHub"
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
title.BackgroundTransparency=1
title.Text="Fling Hub"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3=Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,28,0,28)
close.Position = UDim2.new(1,-32,0,2)
close.Text="X"
close.TextScaled=true
close.BackgroundColor3=Color3.fromRGB(170,0,0)
close.TextColor3=Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

--====================================================
-- STATES & VARIABLES
--====================================================
local targetPlayer = nil
local flingActive = false
local flingItemActive = false

--====================================================
-- PLAYER LIST
--====================================================
local list = Instance.new("ScrollingFrame", frame)
list.Size=UDim2.new(1,-10,0,130)
list.Position=UDim2.new(0,5,0,35)
list.CanvasSize=UDim2.new(0,0,0,0)
list.ScrollBarThickness=6
list.BackgroundColor3=Color3.fromRGB(35,35,35)

local layout=Instance.new("UIListLayout",list)

local function updateCanvas()
    task.wait()
    list.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+5)
end

local function addPlayer(p)
    if p == plr then return end
    local b=Instance.new("TextButton",list)
    b.Size=UDim2.new(1,-6,0,28)
    b.Text=p.DisplayName.." (@"..p.Name..")"
    b.TextScaled=true
    b.BackgroundColor3=Color3.fromRGB(60,60,60)
    b.TextColor3=Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        targetPlayer = p
        title.Text = "Target: " .. p.Name
    end)
    updateCanvas()
end

for _,p in ipairs(Players:GetPlayers()) do addPlayer(p) end
Players.PlayerAdded:Connect(addPlayer)

--====================================================
-- TOGGLE SYSTEM
--====================================================
local options = Instance.new("ScrollingFrame", frame)
options.Size=UDim2.new(1,-10,0,230)
options.Position=UDim2.new(0,5,0,175)
options.ScrollBarThickness=6
options.BackgroundColor3=Color3.fromRGB(30,30,30)

local optLayout=Instance.new("UIListLayout",options)
optLayout.Padding=UDim.new(0,5)

local function toggle(name, callback)
    local state = false
    local b = Instance.new("TextButton", options)
    b.Size = UDim2.new(1,-6,0,35)
    b.Text = name.." OFF"
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(170,0,0)
    b.TextColor3 = Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name..(state and " ON" or " OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
end

--====================================================
-- FLING LOGIC
--====================================================
toggle("Fling", function(v) 
    flingActive = v 
    if not v then
        -- Resetar velocidade ao desligar
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
            plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

toggle("Fling Item", function(v) flingItemActive = v end)

--====================================================
-- MAIN LOOP
--====================================================
RunService.Stepped:Connect(function()
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = plr.Character.HumanoidRootPart
    
    -- Lógica do Fling Normal (Girar e Seguir)
    if flingActive and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        -- Movimentação e Rotação Extrema
        hrp.Velocity = Vector3.new(500000, 500000, 500000)
        hrp.RotVelocity = Vector3.new(500000, 500000, 500000)
        hrp.CFrame = targetHRP.CFrame * CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), math.rad(math.random(0,360)))
    end

    -- Lógica do Fling Item (Tool + Seat)
    if flingItemActive and targetPlayer and targetPlayer.Character then
        local tool = plr.Backpack:FindFirstChildOfClass("Tool") or plr.Character:FindFirstChildOfClass("Tool")
        
        if tool then
            if tool.Parent ~= plr.Character then tool.Parent = plr.Character end -- Equipa a tool
            
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                -- Alterna posição entre 1 e 5 studs
                local offset = math.random(1, 5)
                hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -offset) * CFrame.Angles(0, math.rad(180), 0)
                
                -- Verifica se o alvo sentou no item
                local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsDescendantOf(tool) then
                    -- Teleporta para o Void e desliga
                    hrp.CFrame = CFrame.new(0, -500, 0)
                    flingItemActive = false
                    print("Alvo capturado! Teleportando para o void.")
                end
            end
        end
        task.wait(0.1) -- Delay conforme pedido
    end
end)

-- Notificação de inicialização
print("FlingHub Loaded - Select a player to begin.")
