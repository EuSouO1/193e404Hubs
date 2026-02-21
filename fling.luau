--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer

-- esperar character carregar
local function getCharacter()
	local char = plr.Character or plr.CharacterAdded:Wait()
	return char
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FlingGui"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,300)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = gui
frame.Active = true

-- DRAG manual (substitui Draggable deprecated)
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Fling Player"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- caixa
local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8,0,0,35)
box.Position = UDim2.new(0.1,0,0.15,0)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)

-- botão
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.75,0)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

-- procurar player
local function findPlayer(str)
	str = str:lower()
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= plr and p.Name:lower():find(str,1,true) then
			return p
		end
	end
end

local running = false

local function flingTarget(target)
	local char = getCharacter()
	local hrp = char:WaitForChild("HumanoidRootPart")

	while running and target and target.Character do
		local thrp = target.Character:FindFirstChild("HumanoidRootPart")
		if not thrp then break end

		local pos = thrp.Position + Vector3.new(0,2,0)

		hrp.CFrame = CFrame.new(pos)
		hrp.AssemblyAngularVelocity = Vector3.new(0,9999,0)

		RunService.Heartbeat:Wait()
	end
end

toggle.MouseButton1Click:Connect(function()
	running = not running

	if running then
		toggle.Text = "ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)

		local target = findPlayer(box.Text)
		if target then
			task.spawn(function()
				flingTarget(target)
			end)
		else
			toggle.Text = "NOT FOUND"
			running = false
		end
	else
		toggle.Text = "OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
	end
end)
