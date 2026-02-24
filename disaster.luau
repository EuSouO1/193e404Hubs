--// Disaster Hub - Force Motion Edition
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Limpeza
if plr.PlayerGui:FindFirstChild("DisasterHub_V2") then plr.PlayerGui.DisasterHub_V2:Destroy() end

local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "DisasterHub_V2"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,320)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8,0,0,35)
box.Position = UDim2.new(0.1,0,0.12,0)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.60,0)
toggle.Text = "Target Thrower: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextColor3 = Color3.new(1,1,1)

-- ESTADOS
local active = false

--// O SEGREDO: Simular posse das partes
local function GetControlAndThrow(target)
    if not target or not target.Character then return end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end

    for _, part in pairs(workspace:GetDescendants()) do
        -- Verifica se é uma parte móvel (não ancorada) e não é do seu player
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(plr.Character) then
            
            -- Só funciona se você estiver a menos de 50-100 studs da parte
            local dist = (plr.Character.HumanoidRootPart.Position - part.Position).Magnitude
            if dist < 100 then 
                -- Bypass: Forçar a peça a sair do estado de "sono" físico
                part.CanCollide = true 
                
                -- Direção do Alvo
                local dir = (tRoot.Position - part.Position).Unit
                
                -- Aplicar Velocidade Massiva
                part.Velocity = dir * 500 -- Aumentei a força para 500
                part.RotVelocity = Vector3.new(100, 100, 100)
            end
        end
    end
end

-- LOOP PRINCIPAL (Roda rápido para manter o controle)
RunService.Heartbeat:Connect(function()
    if active then
        local targetName = box.Text:lower()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= plr and p.Name:lower():find(targetName) then
                GetControlAndThrow(p)
            end
        end
    end
end)

toggle.MouseButton1Click:Connect(function()
    active = not active
    toggle.Text = active and "LANCANDO PEÇAS..." or "Target Thrower: OFF"
    toggle.BackgroundColor3 = active and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

-- Botão fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.MouseButton1Click:Connect(function() gui:Destroy() end)
