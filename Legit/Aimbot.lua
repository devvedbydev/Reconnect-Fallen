local CONFIG = {
    AimbotSmoothness = 5,
    AimbotFOV = 300,
    ShowFOVCircle = true,
    FOVCircleColor = Color3.fromRGB(127, 3, 252),
    FOVCircleRadius = 300,
    FOVCircleTransparency = 1,
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local targetPlayer = nil
local aiming = false
local FOVCircle = nil

local function createFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = CONFIG.ShowFOVCircle
    FOVCircle.Color = CONFIG.FOVCircleColor
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Transparency = CONFIG.FOVCircleTransparency
    FOVCircle.Radius = CONFIG.FOVCircleRadius
end

local function updateFOVCircle()
    if FOVCircle and CONFIG.ShowFOVCircle then
        local mouse = LocalPlayer:GetMouse()
        FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end

local function isEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function getClosestPlayerToCursor()
    local mouse = LocalPlayer:GetMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local characterPosition = player.Character.HumanoidRootPart.Position
            local screenPosition, onScreen = Camera:WorldToScreenPoint(characterPosition)
            if onScreen then
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if distance < shortestDistance and distance <= CONFIG.AimbotFOV then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function smoothAim(currentCFrame, targetPosition, smoothness)
    return currentCFrame:Lerp(CFrame.new(currentCFrame.Position, targetPosition), smoothness / 10)
end

local function handleAimlock()
    if aiming and targetPlayer and targetPlayer.Character then
        local targetPosition = targetPlayer.Character.Head.Position
        Camera.CFrame = smoothAim(Camera.CFrame, targetPosition, CONFIG.AimbotSmoothness)
        if not targetPlayer.Character:FindFirstChild("Humanoid") or targetPlayer.Character.Humanoid.Health <= 0 then
            aiming = false
            targetPlayer = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F then
        aiming = not aiming
        targetPlayer = aiming and getClosestPlayerToCursor() or nil
    end
end)

RunService.RenderStepped:Connect(function()
    handleAimlock()
    updateFOVCircle()
end)

createFOVCircle()
