-- Desenvolvido por Malvadão DEV | Aim + ESP com Team Check
-- Jogo: CDP FPS - Complexo da Pedreira Troca de Tiro

-- CONFIGURAÇÕES INICIAIS
local aimbotAtivo = true
local teclaAim = Enum.UserInputType.MouseButton2 -- Botão direito do mouse
local aimFov = 100 -- Campo de visão do aimbot
local aimSmooth = 0.1 -- Suavidade do aimbot
local espAtivo = true

-- INÍCIO DO SCRIPT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local DrawingESP = {}

function getTeam(player)
    local teamName = player.Team and player.Team.Name or "Desconhecido"
    return teamName
end

function mesmaEquipe(p)
    if not p or not p.Team or not LocalPlayer.Team then return false end
    return p.Team == LocalPlayer.Team
end

-- ESP
function criarESP(player)
    local box = Drawing.new("Text")
    box.Size = 13
    box.Center = true
    box.Outline = true
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Visible = false

    DrawingESP[player] = box
end

function removerESP(player)
    if DrawingESP[player] then
        DrawingESP[player]:Remove()
        DrawingESP[player] = nil
    end
end

Players.PlayerAdded:Connect(function(player)
    criarESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removerESP(player)
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        criarESP(p)
    end
end

RunService.RenderStepped:Connect(function()
    if espAtivo then
        for player, box in pairs(DrawingESP) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and not mesmaEquipe(player) then
                local pos, vis = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                box.Text = player.Name .. " [" .. getTeam(player) .. "]"
                box.Position = Vector2.new(pos.X, pos.Y)
                box.Visible = vis
            else
                box.Visible = false
            end
        end
    end
end)

-- AIMBOT
local aimbotKeyPressed = false

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == teclaAim then
        aimbotKeyPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == teclaAim then
        aimbotKeyPressed = false
    end
end)

function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and not mesmaEquipe(p) then
            local head = p.Character.Head
            local pos, vis = Camera:WorldToViewportPoint(head.Position)
            if vis then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < shortestDistance and dist < aimFov then
                    shortestDistance = dist
                    closestPlayer = p
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotAtivo and aimbotKeyPressed then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head.Position
            local aimPos = Camera:WorldToScreenPoint(head)
            mousemoverel((aimPos.X - Mouse.X) * aimSmooth, (aimPos.Y - Mouse.Y) * aimSmooth)
        end
    end
end)
