--// UI Console
local gui = Instance.new("ScreenGui", game.CoreGui)
local btn = Instance.new("TextButton", gui)
btn.Size, btn.Position, btn.Text, btn.BackgroundColor3 = UDim2.new(0,100,0,40), UDim2.new(0,20,0,200), "Console", Color3.fromRGB(30,30,30)

local frame = Instance.new("Frame", gui)
frame.Size, frame.Position, frame.BackgroundColor3, frame.Visible = UDim2.new(.6,0,.5,0), UDim2.new(.2,0,.25,0), Color3.fromRGB(20,20,20), false
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size, scroll.BackgroundTransparency = UDim2.new(1,0,1,0), 1
local list = Instance.new("UIListLayout", scroll)

local function log(t,c)
    local l = Instance.new("TextLabel", scroll)
    l.Size, l.BackgroundTransparency, l.TextColor3, l.Font, l.TextSize, l.TextXAlignment = UDim2.new(1,-10,0,20),1,c or Color3.fromRGB(0,255,0),Enum.Font.Code,14,Enum.TextXAlignment.Left
    l.Text = tostring(t)
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y)
    scroll.CanvasPosition = Vector2.new(0, math.max(0, list.AbsoluteContentSize.Y - scroll.AbsoluteSize.Y))
end

btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

--// CONFIG
local safeRadius   = 12   -- keep this far away from melee enemies
local attackRange  = 20   -- move closer until this distance
local checkDelay   = 0.2  -- seconds between checks

local plr = game.Players.LocalPlayer
local Character = plr.Character or plr.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local Functions = {}

--// Get Enemies
function Functions:GetEnemys()
    if not workspace:FindFirstChild("dungeon") then 
        return workspace:FindFirstChild("enemies") and workspace.enemies:GetChildren() or {}
    end
    for _, v in pairs(workspace.dungeon:GetChildren()) do
        if v:FindFirstChild("enemyFolder") and v.enemyFolder:FindFirstChildOfClass("Model") then
            return v.enemyFolder:GetChildren()
        end
    end
    return {}
end

--// Get Closest Enemy (skips shielded)
function Functions:GetClosestEnemy(maxRange)
    if not Character:FindFirstChild("HumanoidRootPart") then return end
    local enemys = Functions:GetEnemys()
    if not enemys then return end

    local closestEnemy, shortestDistance, maxHealth = nil, math.huge, -math.huge

    for _, v in pairs(enemys) do
        local hrp, hum, head = v:FindFirstChild("HumanoidRootPart"), v:FindFirstChild("Humanoid"), v:FindFirstChild("Head")
        if hrp and hum and head and head:FindFirstChild("enemyNameplate") then
            local healthBar = head.enemyNameplate.Frame.healthBackground.healthBar
            local shielded = (healthBar.ImageColor3 == Color3.fromRGB(84,195,255))
            if not shielded then
                local distance = (HRP.Position - hrp.Position).Magnitude
                if (not maxRange or distance <= maxRange) and (distance < shortestDistance or (distance == shortestDistance and hum.MaxHealth > maxHealth)) then
                    shortestDistance, closestEnemy, maxHealth = distance, v, hum.MaxHealth
                end
            end
        end
    end

    return closestEnemy, shortestDistance
end

--// Detect if player inside danger zone
local function isInDangerZone(zone)
    if not zone:IsA("BasePart") then return false end
    return (HRP.Position - zone.Position).Magnitude < (zone.Size.Magnitude/2)
end

--// Dodge telegraphs
local lastLog = {}
local function trackTelegraphs(enemy)
    if not enemy:FindFirstChild("TelegraphWatcher") then
        Instance.new("BoolValue", enemy).Name = "TelegraphWatcher"
        enemy.DescendantAdded:Connect(function(o)
            if o:IsA("BasePart") and o.Anchored and o.Size.Magnitude > 5 then
                local n = o.Name:lower()
                if not (n:find("torso") or n:find("arm") or n:find("leg") or n:find("head")) then
                    if isInDangerZone(o) then
                        local dir = (HRP.Position - o.Position).Unit
                        Humanoid:MoveTo(HRP.Position + dir * (o.Size.Magnitude/2 + 10))
                        local key = enemy.Name.."_"..o.Name
                        if not lastLog[key] or tick()-lastLog[key] > 2 then
                            log("[DODGE] Escaped "..o.Name, Color3.fromRGB(255,0,0))
                            lastLog[key] = tick()
                        end
                    end
                end
            end
        end)
    end
end

--// Main loop
task.spawn(function()
    while task.wait(checkDelay) do
        local enemy, dist = Functions:GetClosestEnemy(150)
        if enemy and enemy:FindFirstChild("HumanoidRootPart") then
            trackTelegraphs(enemy) -- attach telegraph watcher

            if dist < safeRadius then
                local dir = (HRP.Position - enemy.HumanoidRootPart.Position).Unit
                Humanoid:MoveTo(HRP.Position + dir * 15)
                log("[MOVE] Retreating from "..enemy.Name, Color3.fromRGB(255,200,0))
            elseif dist > attackRange then
                Humanoid:MoveTo(enemy.HumanoidRootPart.Position)
                log("[MOVE] Approaching "..enemy.Name, Color3.fromRGB(0,200,255))
            else
                Humanoid:MoveTo(HRP.Position)
                log("[MOVE] Holding position near "..enemy.Name, Color3.fromRGB(0,255,0))
            end
        end
    end
end)

log("✅ Auto Target + Dodge + Console Initialized", Color3.fromRGB(0,255,0))

