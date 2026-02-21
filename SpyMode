--// Serviços
local plr = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "SpyGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,280)
frame.Position = UDim2.new(0.5,-150,0.5,-140)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Spy Follow"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- distancia
local distBox = Instance.new("TextBox", frame)
distBox.Size = UDim2.new(0.8,0,0,35)
distBox.Position = UDim2.new(0.1,0,0.15,0)
distBox.PlaceholderText = "Distância atrás (studs)"
distBox.Text = "5"
distBox.TextScaled = true
distBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
distBox.TextColor3 = Color3.new(1,1,1)

-- lista
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.9,0,0,120)
listFrame.Position = UDim2.new(0.05,0,0.32,0)
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,4)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.78,0)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

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

-- lista players
local selectedTarget = nil

local function refreshPlayers()
    for _,v in ipairs(listFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-6,0,24)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Text = p.Name
            btn.Parent = listFrame

            btn.MouseButton1Click:Connect(function()
                selectedTarget = p
                title.Text = "Spy: "..p.Name
            end)
        end
    end

    task.wait()
    listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- sistema de seguir
local running = false

local function getHRP(character)
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
end

RunService.Heartbeat:Connect(function()
    if not running then return end
    if not selectedTarget then return end
    if not Players:FindFirstChild(selectedTarget.Name) then
        running = false
        toggle.Text = "TARGET LEFT"
        return
    end

    local dist = tonumber(distBox.Text) or 5

    local myChar = plr.Character
    local targetChar = selectedTarget.Character

    if myChar and targetChar then
        local myHRP = getHRP(myChar)
        local tHRP = getHRP(targetChar)

        if myHRP and tHRP then
            local behindPos = tHRP.Position - (tHRP.CFrame.LookVector * dist)
            myHRP.CFrame = CFrame.new(behindPos, tHRP.Position)
        end
    end
end)

toggle.MouseButton1Click:Connect(function()
    running = not running

    if running then
        if not selectedTarget then
            toggle.Text = "NO TARGET"
            running = false
            return
        end
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
