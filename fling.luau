-- Fling Hub (Clean Rewrite)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

repeat task.wait() until plr.Character

--====================================================
-- GUI (Mesmo Visual do Powered Hub)
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
title.TextScaled=true
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
-- STATES & HELPERS
--====================================================
local flingActive = false
local flingItemActive = false
local targetPlayer = nil

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

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
    b.Text=p.Name
    b.TextScaled=true
    b.BackgroundColor3=Color3.fromRGB(60,60,60)
    b.TextColor3=Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        targetPlayer = p
        title.Text = "Target: " .. p.DisplayName
    end)
    updateCanvas()
end

for _,p in ipairs(Players:GetPlayers()) do addPlayer(p) end
Players.PlayerAdded:Connect(addPlayer)

--====================================================
-- OPTIONS
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
    b.Text = name .. " OFF"
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(170,0,0)
    b.TextColor3 = Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name .. (state and " ON" or " OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
end

toggle("Fling Mode", function(v) flingActive = v end)
toggle("Fling Item (Seat)", function(v) flingItemActive = v end)

--====================================================
-- CORE LOGIC
--====================================================

RunService.PostSimulation:Connect(function()
    local char = plr.Character
    local hrp = getHRP(char)
    if not hrp or not targetPlayer or not targetPlayer.Character then return end
    
    local targetHRP = getHRP(targetPlayer.Character)
    if not targetHRP then return end

    -- FUNÇÃO: FLING (Girar e Atropelar)
    if flingActive then
        -- Torna o player "fantasma" para não colidir mas manter força
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        
        -- Velocidade angular massiva para o Fling
        hrp.Velocity = Vector3.new(0, 500, 0) -- Força vertical pra instabilizar
        hrp.RotVelocity = Vector3.new(0, 10000, 0) -- Giro ultra rápido
        
        -- Teleporte contínuo para o alvo
        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 0)
    end

    -- FUNÇÃO: FLING ITEM (Matar com Seat/Tool)
    if flingItemActive then
        local tool = plr.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
        
        if tool then
            if tool.Parent ~= char then tool.Parent = char end -- Equipa se não estiver equipado
            
            -- Lógica de aproximação (1 a 5 studs variando)
            local dist = math.random(1, 5)
            hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, dist) * CFrame.Angles(0, math.rad(180), 0)
            
            -- Verifica se o alvo sentou no Seat da Tool (comum em scripts de "kill script")
            local seat = tool:FindFirstChildWhichIsA("VehicleSeat", true) or tool:FindFirstChildWhichIsA("Seat", true)
            if seat and seat.Occupant then
                if seat.Occupant.Parent == targetPlayer.Character then
                    -- Teleporta para o void e desliga
                    hrp.CFrame = CFrame.new(0, -500, 0)
                    flingItemActive = false
                    print("Alvo capturado! Teleportando para o void.")
                end
            end
        end
    end
end)

-- Anti-Die/Ragdoll simples para o Fling não te matar
RunService.Stepped:Connect(function()
    if flingActive or flingItemActive then
        local hrp = getHRP(plr.Character)
        if hrp then
            for _, v in pairs(plr.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)
