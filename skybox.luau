--// Serviços
local plr = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")

--// GUI Principal
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

-- TextBox para o ID da Imagem
local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(0.8, 0, 0, 40)
idBox.Position = UDim2.new(0.1, 0, 0.25, 0)
idBox.PlaceholderText = "ID da Imagem (Asset ID)"
idBox.Text = ""
idBox.TextScaled = true
idBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
idBox.TextColor3 = Color3.new(1, 1, 1)

-- Botão "My Account" (Pega foto de perfil)
local myAccBtn = Instance.new("TextButton", frame)
myAccBtn.Size = UDim2.new(0.8, 0, 0, 35)
myAccBtn.Position = UDim2.new(0.1, 0, 0.48, 0)
myAccBtn.Text = "MY ACCOUNT"
myAccBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
myAccBtn.TextColor3 = Color3.new(1, 1, 1)
myAccBtn.TextSize = 18

-- Botão "Set Skybox" (Aplica a mudança)
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

--// Lógica das Funções

-- Função para pegar ID da conta
myAccBtn.MouseButton1Click:Connect(function()
    -- Formato de URL de imagem de perfil do Roblox
    local userId = plr.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = game.Players:GetCharacterAppearanceAsync(userId) -- Metodo simples de pegar imagem
    
    -- Maneira mais direta de setar o ID da imagem de perfil:
    idBox.Text = "rbxthumb://type=AvatarHeadShot&id="..userId.."&w=420&h=420"
end)

-- Função para aplicar Skybox
setBtn.MouseButton1Click:Connect(function()
    local imgID = idBox.Text
    if imgID == "" then return end
    
    -- Se for apenas números, formata para o padrão do Roblox
    if tonumber(imgID) then
        imgID = "rbxassetid://" .. imgID
    end

    -- Procura por skybox existente ou cria uma nova
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end

    -- Aplica a imagem em todas as faces do céu
    sky.SkyboxBk = imgID
    sky.SkyboxDn = imgID
    sky.SkyboxFt = imgID
    sky.SkyboxLf = imgID
    sky.SkyboxRt = imgID
    sky.SkyboxUp = imgID
    
    setBtn.Text = "APLICADO!"
    task.wait(1)
    setBtn.Text = "SET SKYBOX"
end)
