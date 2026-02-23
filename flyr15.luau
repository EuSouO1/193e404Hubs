local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

main.Name = "main"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)
Frame.Active = true
Frame.Draggable = true

-- [CONFIGURAÇÃO DOS BOTÕES - MANTIDA IGUAL]
up.Name = "up"; up.Parent = Frame; up.BackgroundColor3 = Color3.fromRGB(79, 255, 152); up.Size = UDim2.new(0, 44, 0, 28); up.Text = "UP"
down.Name = "down"; down.Parent = Frame; down.BackgroundColor3 = Color3.fromRGB(215, 255, 121); down.Position = UDim2.new(0, 0, 0.491228074, 0); down.Size = UDim2.new(0, 44, 0, 28); down.Text = "DOWN"
onof.Name = "onof"; onof.Parent = Frame; onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74); onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0); onof.Size = UDim2.new(0, 56, 0, 28); onof.Text = "fly"
TextLabel.Parent = Frame; TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255); TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0); TextLabel.Size = UDim2.new(0, 100, 0, 28); TextLabel.Text = "FLY GUI V3"; TextLabel.TextScaled = true
plus.Name = "plus"; plus.Parent = Frame; plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255); plus.Position = UDim2.new(0.231578946, 0, 0, 0); plus.Size = UDim2.new(0, 45, 0, 28); plus.Text = "+"
speed.Name = "speed"; speed.Parent = Frame; speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0); speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0); speed.Size = UDim2.new(0, 44, 0, 28); speed.Text = "1"; speed.TextScaled = true
mine.Name = "mine"; mine.Parent = Frame; mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247); mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0); mine.Size = UDim2.new(0, 45, 0, 29); mine.Text = "-"
closebutton.Name = "Close"; closebutton.Parent = Frame; closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0); closebutton.Size = UDim2.new(0, 45, 0, 28); closebutton.Text = "X"; closebutton.Position = UDim2.new(0, 0, -1, 27)
mini.Name = "minimize"; mini.Parent = Frame; mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230); mini.Size = UDim2.new(0, 45, 0, 28); mini.Text = "-"; mini.Position = UDim2.new(0, 44, -1, 27)
mini2.Name = "minimize2"; mini2.Parent = Frame; mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230); mini2.Size = UDim2.new(0, 45, 0, 28); mini2.Text = "+"; mini2.Position = UDim2.new(0, 44, -1, 57); mini2.Visible = false

-- VARIAVEIS DE CONTROLE
local speeds = 1
local nowe = false
local tpwalking = false
local speaker = game:GetService("Players").LocalPlayer
local trackIdle, trackMove

-- CONFIGURAÇÃO DE ANIMAÇÕES
local animIdle = Instance.new("Animation")
animIdle.AnimationId = "rbxassetid://98353973763565"
local animMove = Instance.new("Animation")
animMove.AnimationId = "rbxassetid://117931620432186"

game:GetService("StarterGui"):SetCore("SendNotification", { Title = "FLY GUI V3", Text = "BY XNEO", Duration = 5 })

-- FUNÇÃO PARA GERENCIAR ANIMAÇÕES
local function updateAnimations()
    local char = speaker.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if nowe then
        if hum.MoveDirection.Magnitude > 0 then
            if trackIdle then trackIdle:Stop(0.3) end
            if trackMove and not trackMove.IsPlaying then trackMove:Play(0.3) end
        else
            if trackMove then trackMove:Stop(0.3) end
            if trackIdle and not trackIdle.IsPlaying then trackIdle:Play(0.3) end
        end
    else
        if trackIdle then trackIdle:Stop(0.3) end
        if trackMove then trackMove:Stop(0.3) end
    end
end

onof.MouseButton1Down:connect(function()
    if nowe == true then
        nowe = false
        tpwalking = false
        speaker.Character.Animate.Disabled = false
        if trackIdle then trackIdle:Stop() end
        if trackMove then trackMove:Stop() end

        local hum = speaker.Character:FindFirstChildOfClass("Humanoid")
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            hum:SetStateEnabled(state, true)
        end
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    else 
        nowe = true
        local char = speaker.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        char.Animate.Disabled = true

        -- Carregar Animações
        trackIdle = hum:LoadAnimation(animIdle)
        trackMove = hum:LoadAnimation(animMove)
        trackIdle.Looped = true
        trackMove.Looped = true

        -- Loop de monitoramento de movimento para animação
        task.spawn(function()
            while nowe and char and hum do
                updateAnimations()
                task.wait(0.1)
            end
        end)

        -- TP Walking Loop
        task.spawn(function()
            tpwalking = true
            local hb = game:GetService("RunService").Heartbeat
            while tpwalking and nowe and char and hum do
                hb:Wait()
                if hum.MoveDirection.Magnitude > 0 then
                    for i = 1, speeds do
                        char:TranslateBy(hum.MoveDirection)
                    end
                end
            end
        end)

        -- Desativar estados para não interferir no voo
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            hum:SetStateEnabled(state, false)
        end
        hum:ChangeState(Enum.HumanoidStateType.Swimming)

        -- Sistema de Voo (R6/R15)
        task.spawn(function()
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            local bg = Instance.new("BodyGyro", root)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = root.CFrame
            local bv = Instance.new("BodyVelocity", root)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

            hum.PlatformStand = true

            while nowe do
                game:GetService("RunService").RenderStepped:Wait()
                bv.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.LookVector * (hum.MoveDirection.Z * -50)) + (game.Workspace.CurrentCamera.CoordinateFrame.RightVector * (hum.MoveDirection.X * 50))
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame
                if hum.Health == 0 then break end
            end

            bg:Destroy()
            bv:Destroy()
            hum.PlatformStand = false
        end)
    end
end)

-- CONTROLES DE ALTURA (UP/DOWN)
local tis
up.MouseButton1Down:connect(function()
    tis = true
    while tis do
        wait()
        speaker.Character.HumanoidRootPart.CFrame *= CFrame.new(0,1,0)
    end
end)
up.MouseLeave:connect(function() tis = false end)
up.MouseButton1Up:connect(function() tis = false end)

local dis
down.MouseButton1Down:connect(function()
    dis = true
    while dis do
        wait()
        speaker.Character.HumanoidRootPart.CFrame *= CFrame.new(0,-1,0)
    end
end)
down.MouseLeave:connect(function() dis = false end)
down.MouseButton1Up:connect(function() dis = false end)

-- VELOCIDADE E UI
plus.MouseButton1Down:connect(function() speeds += 1; speed.Text = speeds end)
mine.MouseButton1Down:connect(function() 
    if speeds > 1 then speeds -= 1 else speed.Text = "min 1" wait(1) end
    speed.Text = speeds 
end)

closebutton.MouseButton1Click:Connect(function() main:Destroy() end)
mini.MouseButton1Click:Connect(function()
    for _, v in pairs({up, down, onof, plus, speed, mine, mini}) do v.Visible = false end
    mini2.Visible = true; Frame.BackgroundTransparency = 1; closebutton.Position = UDim2.new(0, 0, -1, 57)
end)
mini2.MouseButton1Click:Connect(function()
    for _, v in pairs({up, down, onof, plus, speed, mine, mini}) do v.Visible = true end
    mini2.Visible = false; Frame.BackgroundTransparency = 0; closebutton.Position = UDim2.new(0, 0, -1, 27)
end)
