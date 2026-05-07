--// Services
local plr = game:GetService("Players").LocalPlayer
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "ChatEchoHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "Chat Echo System"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

--// Variáveis de Lógica
local echoEnabled = false
local messageThreshold = 10 -- Padrão inicial
local currentHistory = {}
local messageCounter = 0

-- TEXTBOX PARA O INTERVALO
local label = Instance.new("TextLabel", scroll)
label.Size = UDim2.new(1,-8,0,25)
label.BackgroundTransparency = 1
label.Text = "Intervalo de Mensagens (2-20):"
label.TextColor3 = Color3.new(1,1,1)
label.TextScaled = true

local box = Instance.new("TextBox", scroll)
box.Size = UDim2.new(1,-8,0,45)
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)
box.Text = "10"
box.TextScaled = true
box.PlaceholderText = "Ex: 10"

box.FocusLost:Connect(function()
    local val = tonumber(box.Text)
    if not val then
        box.Text = tostring(messageThreshold)
    else
        -- Limita entre 2 e 20
        val = math.clamp(math.floor(val), 2, 20)
        messageThreshold = val
        box.Text = tostring(val)
    end
end)

-- FUNÇÃO DE TOGGLE (MESMO ESTILO)
local function makeToggle(text, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    local state = false
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." OFF"

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
    
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    return btn
end

-- LÓGICA DO CHAT
local function sendMessage(txt)
    local channel = TextChatService.TextChannels.RBXGeneral
    if channel then
        channel:SendAsync(txt)
    end
end

TextChatService.MessageReceived:Connect(function(message)
    if not echoEnabled then return end
    if not message.TextSource then return end -- Ignora sistema
    
    -- Se for o próprio player, não conta e nem guarda
    if message.TextSource.UserId == plr.UserId then return end

    -- Guarda a mensagem no histórico atual
    table.insert(currentHistory, message.Text)
    messageCounter = messageCounter + 1

    -- Quando atingir o número definido no TextBox
    if messageCounter >= messageThreshold then
        if #currentHistory > 0 then
            local randomMsg = currentHistory[math.random(1, #currentHistory)]
            sendMessage(randomMsg)
        end
        -- Reseta para o próximo ciclo
        messageCounter = 0
        currentHistory = {}
    end
end)

-- Botão de Ligar
makeToggle("Ativar Echo", function(s)
    echoEnabled = s
    if not s then
        messageCounter = 0
        currentHistory = {}
    end
end)

-- Botão fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
