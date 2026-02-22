--// Powered Hub (clean rewrite)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat task.wait() until plr.Character

--====================================================
-- GUI
--====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "PoweredHub"
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
title.Text="Powered Hub"
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

local function hum()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function isGrounded(humanoid)
    local state = humanoid:GetState()
    return state ~= Enum.HumanoidStateType.Freefall
       and state ~= Enum.HumanoidStateType.Jumping
       and state ~= Enum.HumanoidStateType.FallingDown
end

--====================================================
-- STATES
--====================================================
local speed=false
local aimbot=false
local nearest=false
local targetPlayer=nil
local autoJump=false
local proxJump=false
local espColor=Color3.fromRGB(0,170,255)
local espEnabled=true

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
    local b=Instance.new("TextButton",list)
    b.Size=UDim2.new(1,-6,0,28)
    b.Text=p.Name
    b.TextScaled=true
    b.BackgroundColor3=Color3.fromRGB(60,60,60)
    b.TextColor3=Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        targetPlayer=p
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

local function toggle(name,callback)
    local state=false
    local b=Instance.new("TextButton",options)
    b.Size=UDim2.new(1,-6,0,35)
    b.Text=name.." OFF"
    b.TextScaled=true
    b.BackgroundColor3=Color3.fromRGB(170,0,0)
    b.TextColor3=Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        state=not state
        b.Text=name..(state and " ON" or " OFF")
        b.BackgroundColor3=state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
end

toggle("Speed 1.25x",function(v) speed=v end)
toggle("Aimbot",function(v) aimbot=v end)
toggle("Nearest Target",function(v) nearest=v end)
toggle("Auto Jump",function(v) autoJump=v end)
toggle("Jump Proximity",function(v) proxJump=v end)
toggle("ESP",function(v) espEnabled=v end)

--====================================================
-- ESP
--====================================================
local esp={}

local function makeESP(p)
    if p==plr then return end

    local h=Instance.new("Highlight")
    h.FillTransparency=1
    h.Parent=workspace

    local bill=Instance.new("BillboardGui")
    bill.Size=UDim2.new(0,200,0,40)
    bill.StudsOffset=Vector3.new(0,3,0)
    bill.AlwaysOnTop=true

    local txt=Instance.new("TextLabel",bill)
    txt.Size=UDim2.new(1,0,1,0)
    txt.BackgroundTransparency=1
    txt.TextColor3=Color3.new(1,1,1)
    txt.TextScaled=true

    esp[p]={h,bill,txt}
end

for _,p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)

--====================================================
-- LOOP
--====================================================
RunService.RenderStepped:Connect(function()

    local char=plr.Character
    if not char then return end

    local myHRP=hrp(char)
    local myHum=hum()
    if not myHRP then return end

    myHum.AutoRotate = not aimbot

    -- speed
    myHum.WalkSpeed = speed and 20 or 16

    -- auto jump (FIXED)
    if autoJump and isGrounded(myHum) then
        if proxJump then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=plr and hrp(p.Character) then
                    if (hrp(p.Character).Position-myHRP.Position).Magnitude<10 then
                        myHum:ChangeState(Enum.HumanoidStateType.Jumping)
                        break
                    end
                end
            end
        else
            myHum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

-- AIMBOT
    if aimbot then
        local target = nil

        if nearest then
            local dist = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                -- VERIFICAÇÃO: Se o player existe, tem corpo, e a VIDA é maior que 0
                if p ~= plr and hrp(p.Character) and p.Character:FindFirstChildOfClass("Humanoid") then
                    if p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local d = (hrp(p.Character).Position - myHRP.Position).Magnitude
                        if d < dist then 
                            dist = d 
                            target = p 
                        end
                    end
                end
            end
        else
            -- Se for alvo selecionado manualmente, também checa se está vivo
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid") then
                if targetPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    target = targetPlayer
                end
            end
        end

        if target and hrp(target.Character) then
            local camPos = camera.CFrame.Position
            local targetPos = hrp(target.Character).Position + Vector3.new(0, 1.5, 0)

            local currentLook = camera.CFrame.LookVector
            local desiredLook = (targetPos - camPos).Unit
            local dot = math.clamp(currentLook:Dot(desiredLook), -1, 1)
            local angle = math.acos(dot)
            local lookSpeed = math.clamp(angle * 12, 0.05, 1) -- renomeado para não conflitar com a var speed do walk

            local newLook = currentLook:Lerp(desiredLook, lookSpeed)
            camera.CFrame = CFrame.lookAt(camPos, camPos + newLook)

            local flatTarget = Vector3.new(targetPos.X, myHRP.Position.Y, targetPos.Z)
            local look = (flatTarget - myHRP.Position).Unit
            local newCF = CFrame.lookAt(myHRP.Position, myHRP.Position + look)

            myHum.AutoRotate = false
            myHRP.CFrame = myHRP.CFrame:Lerp(newCF, lookSpeed * 0.6)
        end
    end

    -- ESP UPDATE
    for p,data in pairs(esp) do
        local h,bill,txt=unpack(data)

        if espEnabled and p.Character and hrp(p.Character) then
            h.Enabled=true
            h.Adornee=p.Character
            h.OutlineColor=espColor

            bill.Parent=p.Character.Head
            txt.Text=p.Name.." ["..math.floor((hrp(p.Character).Position-myHRP.Position).Magnitude).."]"
        else
            h.Enabled=false
            bill.Parent=nil
        end
    end
end)
