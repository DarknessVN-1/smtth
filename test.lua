-- console
local gui=Instance.new("ScreenGui",game.CoreGui)
local btn=Instance.new("TextButton",gui)
btn.Size,btn.Position,btn.Text,btn.BackgroundColor3=UDim2.new(0,100,0,40),UDim2.new(0,20,0,200),"Console",Color3.fromRGB(30,30,30)
local frame=Instance.new("Frame",gui)
frame.Size,frame.Position,frame.BackgroundColor3,frame.Visible=UDim2.new(.6,0,.5,0),UDim2.new(.2,0,.25,0),Color3.fromRGB(20,20,20),false
local scroll=Instance.new("ScrollingFrame",frame)scroll.Size,scroll.BackgroundTransparency=UDim2.new(1,0,1,0),1
local list=Instance.new("UIListLayout",scroll)

local function log(t,c)local l=Instance.new("TextLabel",scroll)
l.Size,l.BackgroundTransparency,l.TextColor3,l.Font,l.TextSize,l.TextXAlignment=UDim2.new(1,-10,0,20),1,c or Color3.fromRGB(0,255,0),Enum.Font.Code,14,Enum.TextXAlignment.Left
l.Text=tostring(t)scroll.CanvasSize=UDim2.new(0,0,0,list.AbsoluteContentSize.Y)
scroll.CanvasPosition=Vector2.new(0,math.max(0,list.AbsoluteContentSize.Y-scroll.AbsoluteSize.Y))end

local oP,oW,oE=print,warn,error
print=function(...)oP(...)log("[PRINT] "..table.concat({...}," "),Color3.fromRGB(0,255,0))end
warn=function(...)oW(...)log("[WARN] "..table.concat({...}," "),Color3.fromRGB(255,255,0))end
error=function(m,l)oE(m,(l or 1)+1)log("[ERROR] "..tostring(m),Color3.fromRGB(255,0,0))end
btn.MouseButton1Click:Connect(function()frame.Visible=not frame.Visible end)

-- character
local p=game.Players.LocalPlayer
local c=p.Character or p.CharacterAdded:Wait()
local h=c:WaitForChild("Humanoid")
local hrp=c:WaitForChild("HumanoidRootPart")

-- get enemies
local function getEnemys()
    if not workspace:FindFirstChild("dungeon") then
        return (workspace:FindFirstChild("enemies") and workspace.enemies:GetChildren()) or {}
    end
    for _,v in pairs(workspace.dungeon:GetChildren()) do
        if v:FindFirstChild("enemyFolder") and v.enemyFolder:FindFirstChildOfClass("Model") then
            return v.enemyFolder:GetChildren()
        end
    end
    return {}
end

-- get closest enemy
local function getClosest()
    local closest,d=nil,math.huge
    for _,v in pairs(getEnemys()) do
        local hr=v:FindFirstChild("HumanoidRootPart")
        local hum=v:FindFirstChild("Humanoid")
        local head=v:FindFirstChild("Head")
        if hr and hum and head and head:FindFirstChild("enemyNameplate") then
            if head.enemyNameplate.Frame.healthBackground.healthBar.ImageColor3~=Color3.fromRGB(84,195,255) then
                local dist=(hrp.Position-hr.Position).Magnitude
                if dist<d then closest,d=v,dist end
            end
        end
    end
    return closest,d
end

-- filter function (removes unwanted spam parts)
local function isJunk(name)
    name=name:lower()
    return name:find("left") or name:find("right") or name:find("head")
        or name:find("aura") or name:find("sword")
        or name:find("upper") or name:find("lower")
end

-- skill tracking
local function trackSkills()
    for _,e in ipairs(getEnemys()) do
        if not e:FindFirstChild("SkillWatcher") then
            Instance.new("BoolValue",e).Name="SkillWatcher"
            e.DescendantAdded:Connect(function(o)
                if (o:IsA("BasePart") or o:IsA("ParticleEmitter")) and not isJunk(o.Name) then
                    log("[SKILL] "..e.Name.." -> "..o.Name,Color3.fromRGB(255,0,0))
                end
            end)
        end
    end
end

-- movement
local function moveLoop()
    local e,d=getClosest()
    if not e or not e:FindFirstChild("HumanoidRootPart") then return end
    if d<12 then
        h:MoveTo(hrp.Position+(hrp.Position-e.HumanoidRootPart.Position).Unit*15)
        log("[RETREAT] "..e.Name,Color3.fromRGB(255,200,0))
    elseif d>20 then
        h:MoveTo(e.HumanoidRootPart.Position)
        log("[APPROACH] "..e.Name,Color3.fromRGB(0,200,255))
    else
        h:MoveTo(hrp.Position)
        log("[HOLD] "..e.Name,Color3.fromRGB(0,255,0))
    end
end

-- loops
task.spawn(function()
    while task.wait(0.2) do
        local es=getEnemys()
        if #es==0 then
            log("[NO ENEMY]",Color3.fromRGB(200,200,200))
        else
            log("[ENEMY TRACK] "..#es.." enemies",Color3.fromRGB(150,255,150))
        end
        trackSkills()
        moveLoop()
    end
end)

print("✅ Auto Target + Skill Tracker Ready")
