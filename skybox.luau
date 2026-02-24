--// Serviços
local plr = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")

--// GUI Principal (Exatamente como a sua original)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "SkyboxChangerGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Skybox Customizer"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold

-- TextBox para o ID da Imagem (COM FILTRO DE NÚMEROS)
local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(0.8, 0, 0, 40)
idBox.Position = UDim2.new(0.1, 0, 0.25, 0)
idBox.PlaceholderText = "ID da Imagem (Apenas Números)"
idBox.Text = ""
idBox.TextScaled = true
idBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
idBox.TextColor3 = Color3.new(1, 1, 1)

-- Bloqueia qualquer coisa que não seja número enquanto você digita
idBox:GetPropertyChangedSignal("Text"):Connect(function()
    idBox.Text = idBox.Text:gsub("%D+", "")
end)

-- Botão "My Account"
local myAccBtn = Instance.new("TextButton", frame)
myAccBtn.Size = UDim2.new(0.8, 0, 0, 35)
myAccBtn.Position = UDim2.new(0.1, 0, 0.48, 0)
myAccBtn.Text = "MY ACCOUNT"
myAccBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
myAccBtn.TextColor3 = Color3.new(1, 1, 1)
myAccBtn.TextSize = 18

-- Botão "Set Skybox"
local setBtn = Instance.new("TextButton", frame)
setBtn.Size = UDim2.new(0.8, 0, 0, 45)
setBtn.Position = UDim2.new(0.1, 0, 0.72, 0)
setBtn.Text = "SET SKYBOX"
setBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
setBtn.TextColor3 = Color3.new(1, 1, 1)
setBtn.TextSize = 20
setBtn.Font = Enum.Font.SourceSansBold

-- Botão Fechar (X)
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 18

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--// Lógica de Varredura de RemoteEvents (Busca por brechas no Servidor)
local function scanForRemotes(assetID)
    local fullID = "rbxassetid://" .. assetID
    local keywords = {"Sky", "Lighting", "Atmosphere", "Weather", "Ceu", "Visual"}
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            for _, key in pairs(keywords) do
                if v.Name:lower():find(key:lower()) then
                    pcall(function()
                        v:FireServer(fullID) -- Tenta enviar o ID puro
                        v:FireServer("Skybox", fullID) -- Tenta formato de comando
                    end)
                end
            end
        end
    end
end

--// Funções dos Botões

myAccBtn.MouseButton1Click:Connect(function()
    local userId = plr.UserId
    idBox.Text = tostring(userId) -- Coloca apenas o ID para o filtro não apagar
    -- Nota: rbxthumb não funciona direto em SkyboxBk, por isso mantivemos o ID numérico
end)

setBtn.MouseButton1Click:Connect(function()
    local imgID = idBox.Text
    if imgID == "" then return end
    
    local formattedID = "rbxassetid://" .. imgID

    -- 1. Aplicação LOCAL (Sempre funciona para você)
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end

    sky.SkyboxBk = formattedID
    sky.SkyboxDn = formattedID
    sky.SkyboxFt = formattedID
    sky.SkyboxLf = formattedID
    sky.SkyboxRt = formattedID
    sky.SkyboxUp = formattedID
    
    -- 2. Tentativa de aplicação no SERVIDOR (Varredura)
    scanForRemotes(imgID)
    
    setBtn.Text = "APLICADO + SCAN!"
    task.wait(1)
    setBtn.Text = "SET SKYBOX"
end)
