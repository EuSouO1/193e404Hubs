--// Player & Services
local plr = game:GetService("Players").LocalPlayer
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

--// Referências do Chat
local chatInput = TextChatService:WaitForChild("ChatInputBarConfiguration")
local chatWindow = TextChatService:WaitForChild("ChatWindowConfiguration")
local channelTabs = TextChatService:WaitForChild("ChannelTabsConfiguration")

--// GUI (Mesmo estilo do seu hub)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "ChatConfigHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Chat Config Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,35)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function updateCanvas()
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

-- Função de criar botão toggle (mesmo estilo do original)
local function makeToggle(text, targetProperty, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    
    -- Inicia com a cor baseada no estado atual do chat
    local state = targetProperty
    btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." "..(state and "ON" or "OFF")

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)

    updateCanvas()
    return btn
end

---// Controles de Chat

-- Alternar Barra de Digitação
makeToggle("Input Bar", chatInput.Enabled, function(state)
    chatInput.Enabled = state
end)

-- Alternar Janela de Mensagens
makeToggle("Chat Window", chatWindow.Enabled, function(state)
    chatWindow.Enabled = state
end)

-- Alternar Abas de Canais
makeToggle("Channel Tabs", channelTabs.Enabled, function(state)
    channelTabs.Enabled = state
end)

-- Botão para fechar o Hub
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
