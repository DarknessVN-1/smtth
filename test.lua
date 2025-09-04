local p = game.Players.LocalPlayer
local c, h, hrp

-- setup function (runs at spawn + respawn)
local function setupChar(char)
    c = char
    h = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
end

-- initial setup
setupChar(p.Character or p.CharacterAdded:Wait())
-- re-setup when respawn
p.CharacterAdded:Connect(setupChar)

-- console
local g = Instance.new("ScreenGui", game.CoreGui)
local b = Instance.new("TextButton", g)
b.Size,b.Position,b.Text,b.BackgroundColor3=UDim2.new(0,100,0,40),UDim2.new(0,20,0,200),"Console",Color3.fromRGB(30,30,30)
local f=Instance.new("Frame",g) f.Size,f.Position,f.BackgroundColor3,f.Visible=UDim2.new(.6,0,.5,0),UDim2.new(.2,0,.25,0),Color3.fromRGB(20,20,20),false
local s=Instance.new("ScrollingFrame",f) s.Size,s.BackgroundTransparency=UDim2.new(1,0,1,0),1
local l=Instance.new("UIListLayout",s)

local maxLogs = 200
local function log(t,c0)
    local t0=Instance.new("TextLabel",s)
    t0.Size,t0.BackgroundTransparency,t0.TextColor3,t0.Font,t0.TextSize,t0.TextXAlignment=
        UDim2.new(1,-10,0,20),1,c0 or Color3.fromRGB(0,255,0),Enum.Font.Code,14,Enum.TextXAlignment.Left
    t0.Text=t

    -- auto clean if too many logs
    if #s:GetChildren() > maxLogs then
        for i = 1, (#s:GetChildren()-maxLogs) do
            if s:GetChildren()[i] and s:GetChildren()[i]:IsA("TextLabel") then
                s:GetChildren()[i]:Destroy()
            end
        end
    end

    s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y)
    s.CanvasPosition=Vector2.new(0,math.max(0,l.AbsoluteContentSize.Y-s.AbsoluteSize.Y))
end
b.MouseButton1Click:Connect(function()f.Visible=not f.Visible end)

local defaultSpeed = 16

-- functions (your originals kept the same)
local Functions = {}
function Functions:GetEnemys()
    if not workspace:FindFirstChild("dungeon") then
        return workspace.enemies and workspace.enemies:GetChildren() or {}
    end
    for _,v in pairs(workspace.dungeon:GetChildren()) do
        if v:FindFirstChild("enemyFolder") then
            return v.enemyFolder:GetChildren()
        end
    end
    return {}
end

function Functions:GetClosestEnemy()
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    if Functions:GetEnemys()==nil then return end
    local closestEnemy, shortestDistance, maxHealth = nil, math.huge, -math.huge
    for _,v in pairs(Functions:GetEnemys()) do
        local enemyPosition=v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position
        local enemyHumanoid=v:FindFirstChild("Humanoid")
        if enemyPosition and enemyHumanoid then
            local head=v:FindFirstChild("Head")
            if head and head:FindFirstChild("enemyNameplate") then
                if head.enemyNameplate.Frame.healthBackground.healthBar.ImageColor3~=Color3.fromRGB(84,195,255) then
                    local distance=(hrp.Position-enemyPosition).Magnitude
                    if distance<shortestDistance or (distance==shortestDistance and enemyHumanoid.MaxHealth>maxHealth) then
                        shortestDistance=distance
                        closestEnemy=v
                        maxHealth=enemyHumanoid.MaxHealth
                    end
                end
            end
        end
    end
    return closestEnemy,shortestDistance
end

-- dodge
local function danger(z)
    return hrp and z:IsA("BasePart") and (z.Size.Magnitude>5) and (hrp.Position-z.Position).Magnitude<z.Size.Magnitude/2
end
local function watch(e)
    if e:FindFirstChild("TWatch") then return end
    Instance.new("BoolValue",e).Name="TWatch"
    e.DescendantAdded:Connect(function(o)
        if danger(o) and h and hrp then
            h.WalkSpeed=28
            h:MoveTo(hrp.Position+(hrp.Position-o.Position).Unit*(o.Size.Magnitude/2+12))
            log("[DODGE]"..o.Name,Color3.fromRGB(255,0,0))
            task.delay(1,function()if h then h.WalkSpeed=defaultSpeed end end)
        end
    end)
end

-- loop
task.spawn(function()
    while task.wait(0.2) do
        if not h or not hrp then continue end
        local allEnemies = Functions:GetEnemys()
        if #allEnemies==0 then
            log("[NO ENEMY]",Color3.fromRGB(255,100,100))
        else
            for _,v in pairs(allEnemies) do
                if v:FindFirstChild("HumanoidRootPart") then
                    local dist=(hrp.Position-v.HumanoidRootPart.Position).Magnitude
                    log("[ENEMY] "..v.Name.." ("..math.floor(dist)..")",Color3.fromRGB(200,200,200))
                end
            end
        end
        local e,d=Functions:GetClosestEnemy()
        if e and e:FindFirstChild("HumanoidRootPart") then
            watch(e)
            if d<12 then
                h.WalkSpeed=28
                h:MoveTo(hrp.Position+(hrp.Position-e.HumanoidRootPart.Position).Unit*15)
                log("[RETREAT]"..e.Name,Color3.fromRGB(255,200,0))
            elseif d>20 then
                h.WalkSpeed=20
                h:MoveTo(e.HumanoidRootPart.Position)
                log("[APPROACH]"..e.Name,Color3.fromRGB(0,200,255))
            else
                h.WalkSpeed=defaultSpeed
                log("[HOLD]"..e.Name,Color3.fromRGB(0,255,0))
            end
        else
            h.WalkSpeed=defaultSpeed
        end
    end
end)

log("✅ Auto Target + Dodge + Enemy Tracking + Log Cleanup Ready",Color3.fromRGB(0,255,0))
