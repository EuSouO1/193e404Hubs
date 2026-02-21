```lua
--// PLAYER
local plr = game.Players.LocalPlayer
local workspace = game:GetService("Workspace")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "UniversalTPHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,360,0,360)
frame.Position = UDim2.new(0.5,-180,0.5,-180)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Universal Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,0,170)
scroll.Position = UDim2.new(0,5,0,35)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

local function updateCanvas()
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

-- PLAYER LIST
local playerFrame = Instance.new("Frame", frame)
playerFrame.Size = UDim2.new(1,-10,0,120)
playerFrame.Position = UDim2.new(0,5,1,-125)
playerFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local ptitle = Instance.new("TextLabel", playerFrame)
ptitle.Size = UDim2.new(1,0,0,25)
ptitle.BackgroundTransparency = 1
ptitle.Text = "Players"
ptitle.TextScaled = true
ptitle.TextColor3 = Color3.new(1,1,1)

local pscroll = Instance.new("ScrollingFrame", playerFrame)
pscroll.Size = UDim2.new(1,-6,1,-30)
pscroll.Position = UDim2.new(0,3,0,27)
pscroll.BackgroundColor3 = Color3.fromRGB(35,35,35)
pscroll.BorderSizePixel = 0
pscroll.ScrollBarThickness = 5

local playout = Instance.new("UIListLayout", pscroll)
playout.Padding = UDim.new(0,4)

local selectedPlayer=nil
local onlyUnanchored=false

local function refreshPlayers()
    for _,v in pairs(pscroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,p in ipairs(game.Players:GetPlayers()) do
        if p~=plr then
            local b=Instance.new("TextButton",pscroll)
            b.Size=UDim2.new(1,-4,0,28)
            b.Text=p.Name
            b.TextScaled=true
            b.BackgroundColor3=Color3.fromRGB(50,50,50)
            b.TextColor3=Color3.new(1,1,1)

            b.MouseButton1Click:Connect(function()
                selectedPlayer=p
                for _,x in pairs(pscroll:GetChildren()) do
                    if x:IsA("TextButton") then
                        x.BackgroundColor3=Color3.fromRGB(50,50,50)
                    end
                end
                b.BackgroundColor3=Color3.fromRGB(0,120,200)
            end)
        end
    end

    task.wait()
    pscroll.CanvasSize=UDim2.new(0,0,0,playout.AbsoluteContentSize.Y+5)
end

refreshPlayers()
game.Players.PlayerAdded:Connect(refreshPlayers)
game.Players.PlayerRemoving:Connect(refreshPlayers)

-- BUTTON CREATOR
local function makeButton(text,callback)
    local btn=Instance.new("TextButton",scroll)
    btn.Size=UDim2.new(1,-8,0,40)
    btn.BackgroundColor3=Color3.fromRGB(70,70,70)
    btn.TextColor3=Color3.new(1,1,1)
    btn.TextScaled=true
    btn.Text=text
    btn.MouseButton1Click:Connect(callback)
    updateCanvas()
end

local function makeToggle(text,callback)
    local state=false
    local btn=Instance.new("TextButton",scroll)
    btn.Size=UDim2.new(1,-8,0,40)
    btn.BackgroundColor3=Color3.fromRGB(170,0,0)
    btn.TextColor3=Color3.new(1,1,1)
    btn.TextScaled=true
    btn.Text=text.." OFF"

    btn.MouseButton1Click:Connect(function()
        state=not state
        btn.Text=text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3=state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)

    updateCanvas()
end

-- TOGGLE
makeToggle("Only UnAnchored",function(v)
    onlyUnanchored=v
end)

-- FUNCTIONS
local function bringTools()
    local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _,t in pairs(workspace:GetDescendants()) do
        if t:IsA("Tool") and t:FindFirstChild("Handle") then
            if onlyUnanchored and t.Handle.Anchored then continue end
            t.Handle.CFrame=hrp.CFrame
        end
    end
end

local function gotoTools()
    local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _,t in pairs(workspace:GetDescendants()) do
        if t:IsA("Tool") and t:FindFirstChild("Handle") then
            if onlyUnanchored and t.Handle.Anchored then continue end
            hrp.CFrame=t.Handle.CFrame
            task.wait(0.2)
        end
    end
end

local function bringParts()
    local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if onlyUnanchored and v.Anchored then continue end
            v.CFrame=hrp.CFrame
        end
    end
end

local function tpToPlayer()
    if selectedPlayer and selectedPlayer.Character then
        plr.Character.HumanoidRootPart.CFrame=
        selectedPlayer.Character.HumanoidRootPart.CFrame
    end
end

local function bringPlayer()
    if selectedPlayer and selectedPlayer.Character then
        selectedPlayer.Character.HumanoidRootPart.CFrame=
        plr.Character.HumanoidRootPart.CFrame
    end
end

local function bringAll()
    for _,p in pairs(game.Players:GetPlayers()) do
        if p~=plr and p.Character then
            p.Character.HumanoidRootPart.CFrame=
            plr.Character.HumanoidRootPart.CFrame
        end
    end
end

-- BUTTONS
makeButton("Bring Tools",bringTools)
makeButton("Goto Tools",gotoTools)
makeButton("Bring Parts",bringParts)
makeButton("TP To Player",tpToPlayer)
makeButton("Bring Player",bringPlayer)
makeButton("Bring All Players",bringAll)

-- CLOSE
local close=Instance.new("TextButton",frame)
close.Size=UDim2.new(0,25,0,25)
close.Position=UDim2.new(1,-28,0,4)
close.Text="X"
close.BackgroundColor3=Color3.fromRGB(170,0,0)
close.TextScaled=true
close.TextColor3=Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
```
