--// Serviços
local plr = game.Players.LocalPlayer
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

--// GUI Principal
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "SkyboxChangerGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 280)
frame.Position = UDim2.new(0.5, -150, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Skybox Customizer"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold

-- TextBox para ID da Imagem
local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(0.85, 0, 0, 40)
idBox.Position = UDim2.new(0.075, 0, 0.2, 0)
idBox.PlaceholderText = "ID da Imagem (Ex: 12345)"
idBox.Text = ""
idBox.TextScaled = true
idBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
idBox.TextColor3 = Color3.new(1, 1, 1)

-- Botão "My Account" (Pega o ID do perfil)
local myAccBtn = Instance.new("TextButton", frame)
myAccBtn.Size = UDim2.new(0.85, 0, 0, 40)
myAccBtn.Position = UDim2.new(0.075, 0, 0.4, 0)
myAccBtn.Text = "My Account"
myAccBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
myAccBtn.TextColor3 = Color3.new(1, 1, 1)
myAccBtn.TextScaled = true

-- Botão "Set Skybox" (Aplica a mudança)
local setBtn = Instance.new("TextButton", frame)
setBtn.Size = UDim2.new(0.85, 0, 0, 45)
setBtn.Position = UDim2.new(0.075, 0, 0.65, 0)
setBtn.Text = "SET SKYBOX"
setBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
setBtn.TextColor3 = Color3.new(1, 1, 1)
setBtn.TextScaled = true

-- Botão de Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.TextScaled = true
close.TextColor3 = Color3.new(1, 1, 1)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

---// Lógica das Funções

-- Função para limpar a Skybox atual e criar uma nova
local function changeSkybox(assetId)
    -- Remove Skyboxes antigas
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end

    -- Cria a nova Skybox
    local newSky = Instance.new("Sky")
    local textureString = "rbxassetid://" .. tostring(assetId):match("%d+")
    
    newSky.SkyboxBk = textureString
    newSky.SkyboxDn = textureString
    newSky.SkyboxFt = textureString
    newSky.SkyboxLf = textureString
    newSky.SkyboxRt = textureString
    newSky.SkyboxUp = textureString
    
    newSky.Parent = Lighting
    setBtn.Text = "APPLIED!"
    task.wait(1)
    setBtn.Text = "SET SKYBOX"
end

-- Evento Botão My Account
myAccBtn.MouseButton1Click:Connect(function()
    -- Pega o Headshot do player local
    local userId = plr.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    
    -- Extrai apenas os números da URL gerada pelo GetUserThumbnailAsync
    local idOnly = content:match("%d+")
    idBox.Text = idOnly
end)

-- Evento Botão Set Skybox
setBtn.MouseButton1Click:Connect(function()
    if idBox.Text ~= "" then
        changeSkybox(idBox.Text)
    else
        setBtn.Text = "EMPTY ID!"
        task.wait(1)
        setBtn.Text = "SET SKYBOX"
    end
end)
