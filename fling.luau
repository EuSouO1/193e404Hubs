-- Fling Hub (Powered Style)
-- Compatível com Delta, Fluxus, ArceuX

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat task.wait() until plr.Character

--====================================================
-- GUI (Mesmo visual do Powered Hub)
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
-- HELPERS
--====================================================
local function hrp(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

--====================================================
-- STATES
--====================================================
local flingActive = false
local flingItemActive = false
local targetPlayer = nil

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
        targetPlayer=p
        title.Text = "Alvo: " .. p.DisplayName
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

--====================================================
-- LOGIC FUNCTIONS
--====================================================

toggle("Fling Clássico", function(v)
    flingActive = v
end)

toggle("Fling Item (Kill)", function(v)
    flingItemActive = v
end)

-- Loop de Execução
RunService.Stepped:Connect(function()
    local char = plr.Character
    local myHRP = hrp(char)
    if not myHRP or not targetPlayer or not hrp(targetPlayer.Character) then return end
    
    local targetHRP = hrp(targetPlayer.Character)

    -- Lógica Fling Clássico (Girar e Bater)
    if flingActive then
        myHRP.Velocity = Vector3.new(5000, 5000, 5000) -- Força física
        myHRP.RotVelocity = Vector3.new(10000, 10000, 10000) -- Gira absurdamente rápido
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
    end

    -- Lógica Fling Item
    if flingItemActive then
        local tool = plr.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
        if tool then
            if not char:FindFirstChild(tool.Name) then
                tool.Parent = char -- Equipa a ferramenta
            end
            
            -- Posicionamento e troca rápida
            local offset = Vector3.new(0, 0, -math.random(1, 5))
            myHRP.CFrame = CFrame.new(targetHRP.Position) * CFrame.new(offset) * CFrame.Angles(0, math.rad(180), 0)
            
            -- Checar se o alvo sentou (se a tool tiver seat)
            local seat = tool:FindFirstChildOfClass("Seat") or tool:FindFirstChildOfClass("VehicleSeat")
            if seat and seat.Occupant then
                if seat.Occupant.Parent == targetPlayer.Character then
                    -- Alvo pego! Teleportar para o void
                    myHRP.CFrame = CFrame.new(0, -500, 0)
                    flingItemActive = false
                    print("Alvo eliminado!")
                end
            end
        end
        task.wait(0.1) -- Delay conforme pedido
    end
end)

-- Limpeza ao morrer
plr.CharacterAdded:Connect(function()
    flingActive = false
    flingItemActive = false
end)
