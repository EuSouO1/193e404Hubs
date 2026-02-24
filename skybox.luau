--// Serviços
local plr = game.Players.LocalPlayer
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

--// GUI Principal (Mantendo seu estilo)
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

-- TextBox para ID
local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(0.85, 0, 0, 40)
idBox.Position = UDim2.new(0.075, 0, 0.2, 0)
idBox.PlaceholderText = "Cole o ID da Imagem aqui"
idBox.Text = ""
idBox.TextScaled = true
idBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
idBox.TextColor3 = Color3.new(1, 1, 1)

-- Botão My Account
local myAccBtn = Instance.new("TextButton", frame)
myAccBtn.Size = UDim2.new(0.85, 0, 0, 40)
myAccBtn.Position = UDim2.new(0.075, 0, 0.4, 0)
myAccBtn.Text = "My Account (Avatar)"
myAccBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
myAccBtn.TextColor3 = Color3.new(1, 1, 1)
myAccBtn.TextScaled = true

-- Botão Set Skybox
local setBtn = Instance.new("TextButton", frame)
setBtn.Size = UDim2.new(0.85, 0, 0, 45)
setBtn.Position = UDim2.new(0.075, 0, 0.65, 0)
setBtn.Text = "SET SKYBOX"
setBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
setBtn.TextColor3 = Color3.new(1, 1, 1)
setBtn.TextScaled = true

-- Botão Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.TextScaled = true
close.TextColor3 = Color3.new(1, 1, 1)

close.MouseButton1Click:Connect(function() gui:Destroy() end)

---// Lógica de Funcionamento

local function applySky(id)
    -- Se o ID estiver vazio, não faz nada
    if id == "" or id == nil then return end
    
    -- Formata o ID corretamente
    local assetId = "rbxassetid://" .. tostring(id):match("%d+")
    
    -- Deleta Skyboxes existentes para evitar conflito
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end

    -- Cria a nova Skybox e aplica a textura em todos os lados
    local newSky = Instance.new("Sky")
    newSky.Name = "CustomSky"
    newSky.SkyboxBk = assetId
    newSky.SkyboxDn = assetId
    newSky.SkyboxFt = assetId
    newSky.SkyboxLf = assetId
    newSky.SkyboxRt = assetId
    newSky.SkyboxUp = assetId
    
    -- Algumas propriedades para garantir visibilidade
    newSky.CelestialBodiesShown = true
    newSky.Parent = Lighting
    
    setBtn.Text = "APLICADO!"
    task.wait(1)
    setBtn.Text = "SET SKYBOX"
end

-- Botão My Account
myAccBtn.MouseButton1Click:Connect(function()
    local thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    -- O 'thumb' já vem no formato rbxassetid://..., vamos extrair só o número para a caixa
    local numericId = thumb:match("%d+")
    idBox.Text = numericId
    myAccBtn.Text = "ID COPIADO"
    task.wait(1)
    myAccBtn.Text = "My Account (Avatar)"
end)

-- Botão Set Skybox
setBtn.MouseButton1Click:Connect(function()
    if idBox.Text ~= "" then
        applySky(idBox.Text)
    else
        setBtn.Text = "INSIRA UM ID!"
        task.wait(1)
        setBtn.Text = "SET SKYBOX"
    end
end)
