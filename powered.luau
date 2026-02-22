-- Powered Hub
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PoweredHub"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,340,0,420)
frame.Position = UDim2.new(0.5,-170,0.5,-210)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active=true
frame.Draggable=true

-- botão fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,28,0,28)
close.Position = UDim2.new(1,-32,0,2)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled=true
close.TextColor3=Color3.new(1,1,1)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-30,0,30)
title.BackgroundTransparency=1
title.Text="Powered Hub"
title.TextScaled=true
title.TextColor3=Color3.new(1,1,1)

-- helpers
local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- states
local speed=false
local aimbot=false
local aimbotTarget=nil
local aimbotNearest=false
local esp=false
local espColor=Color3.fromRGB(0,170,255)
local autoJump=false
local jumpProx=false

------------------------------------------------------------------
-- PLAYER LIST
------------------------------------------------------------------
local list = Instance.new("ScrollingFrame", frame)
list.Size=UDim2.new(1,-10,0,120)
list.Position=UDim2.new(0,5,0,35)
list.CanvasSize=UDim2.new(0,0,0,0)
list.ScrollBarThickness=6
list.BackgroundColor3=Color3.fromRGB(35,35,35)

local layout=Instance.new("UIListLayout",list)

local function updateList()
    task.wait()
    list.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+5)
end

local function addPlayer(p)
    local b=Instance.new("TextButton",list)
    b.Size=UDim2.new(1,-6,0,28)
    b.Text=p.Name
    b.TextScaled=true
    b.BackgroundColor3=Color3.fromRGB(60,60,60)
    b.TextColor3=Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function()
        aimbotTarget=p
    end)
    updateList()
end

for _,p in ipairs(Players:GetPlayers()) do addPlayer(p) end
Players.PlayerAdded:Connect(addPlayer)

------------------------------------------------------------------
-- OPTIONS SCROLL
------------------------------------------------------------------
local options = Instance.new("ScrollingFrame", frame)
options.Size = UDim2.new(1,-10,0,220)
options.Position = UDim2.new(0,5,0,165)
options.CanvasSize = UDim2.new(0,0,0,0)
options.ScrollBarThickness = 6
options.BackgroundColor3 = Color3.fromRGB(30,30,30)

local optLayout = Instance.new("UIListLayout", options)
optLayout.Padding = UDim.new(0,5)

local function updateOptions()
    task.wait()
    options.CanvasSize = UDim2.new(0,0,0,optLayout.AbsoluteContentSize.Y+5)
end

local function toggle(text,callback)
    local b=Instance.new("TextButton",options)
    b.Size=UDim2.new(1,-6,0,35)
    b.BackgroundColor3=Color3.fromRGB(170,0,0)
    b.Text=text.." OFF"
    b.TextScaled=true
    b.TextColor3=Color3.new(1,1,1)
    local state=false
    b.MouseButton1Click:Connect(function()
        state=not state
        b.Text=text..(state and " ON" or " OFF")
        b.BackgroundColor3=state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
    updateOptions()
end

-- speed
toggle("Speed 1.25x",function(s) speed=s end)

-- aimbot
toggle("Aimbot",function(s) aimbot=s end)
toggle("Nearest Target",function(s) aimbotNearest=s end)

-- autojump
toggle("Auto Jump",function(s) autoJump=s end)
toggle("Jump Proximity",function(s) jumpProx=s end)

------------------------------------------------------------------
-- ESP COLORS
------------------------------------------------------------------
local colors={
    Azul=Color3.fromRGB(0,170,255),
    Branco=Color3.fromRGB(255,255,255),
    Vermelho=Color3.fromRGB(255,60,60),
    Verde=Color3.fromRGB(60,255,60),
    Amarelo=Color3.fromRGB(255,255,60),
    Roxo=Color3.fromRGB(170,60,255)
}

local colorBtn=Instance.new("TextButton",options)
colorBtn.Size=UDim2.new(1,-6,0,35)
colorBtn.Text="Mudar cor ESP"
colorBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
colorBtn.TextColor3=Color3.new(1,1,1)
colorBtn.TextScaled=true

colorBtn.MouseButton1Click:Connect(function()
    for _,c in pairs(colors) do espColor=c break end
end)

updateOptions()

------------------------------------------------------------------
-- ESP OBJECTS
------------------------------------------------------------------
local espObjects={}
local function createESP(p)
    if p==plr then return end
    local h=Instance.new("Highlight")
    h.FillTransparency=1
    h.OutlineColor=espColor
    h.Parent=workspace
    espObjects[p]=h
end

for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

------------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char=plr.Character
    if not char then return end
    local hum=getHum()
    local hrp=getHRP(char)
    if not hrp then return end

    if speed then hum.WalkSpeed=hum.WalkSpeed*1.25 end

    -- aimbot
    if aimbot then
        local target=nil
        if aimbotNearest then
            local dist=math.huge
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=plr and getHRP(p.Character) then
                    local d=(getHRP(p.Character).Position-hrp.Position).Magnitude
                    if d<dist then dist=d target=p end
                end
            end
        else
            target=aimbotTarget
        end
if target and getHRP(target.Character) then
    local camCF = camera.CFrame
    local camPos = camCF.Position

    local targetPos = getHRP(target.Character).Position

    -- direção desejada
    local direction = (targetPos - camPos).Unit

    -- CFrame só de rotação (não move posição)
    local newLook = CFrame.lookAt(camPos, camPos + direction)

    -- suavidade
    local smooth = 0.22

    camera.CFrame = camCF:Lerp(newLook, smooth)
end
    -- autojump
    if autoJump then
        if jumpProx then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=plr and getHRP(p.Character) and (getHRP(p.Character).Position-hrp.Position).Magnitude<10 then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        else
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- esp update
    for p,h in pairs(espObjects) do
        if p.Character and getHRP(p.Character) then
            h.Adornee=p.Character
            h.OutlineColor=espColor
        end
    end
end)
