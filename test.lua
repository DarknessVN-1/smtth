-- 🌌 Console UI
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

local oP,oW,oE = print,warn,error
print=function(...) oP(...) log("[PRINT] "..table.concat({...}," "),Color3.fromRGB(0,255,0)) end
warn=function(...) oW(...) log("[WARN] "..table.concat({...}," "),Color3.fromRGB(255,255,0)) end
error=function(m,l) oE(m,(l or 1)+1) log("[ERROR] "..tostring(m),Color3.fromRGB(255,0,0)) end
btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- 🌌 Config
local Players,workspace = game:GetService("Players"),game:GetService("Workspace")
local lp,Character = Players.LocalPlayer,nil
local hrp,WaitingToTp,LastplayerPos = nil,false,nil
local Settings = {AutoFarm={Distance=12,Delay=0.4}}

-- 🌌 Teleport Function
local Functions = {}
function Functions:Teleport(Cframe)
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    LastplayerPos = Character:GetPivot().p
    if WaitingToTp then return end
    local bodyPosition = Character.HumanoidRootPart:FindFirstChildOfClass("BodyPosition")
    local bodyGyro = Character.HumanoidRootPart:FindFirstChildOfClass("BodyGyro")

    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.CFrame = Character.HumanoidRootPart.CFrame
        bodyGyro.D = 500
        bodyGyro.Parent = Character.HumanoidRootPart
    end
    if not bodyPosition then
        bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyPosition.Position = Cframe.Position
        bodyPosition.D = 300
        bodyPosition.Parent = Character.HumanoidRootPart
        Character.HumanoidRootPart.Velocity = Vector3.zero
    end

    local oldTime = tick()
    WaitingToTp = true
    Character.HumanoidRootPart.Anchored = false
    repeat task.wait()
        if Character:FindFirstChild("HumanoidRootPart") then
            Character:PivotTo(CFrame.new(Cframe.p + Vector3.new(0, Settings.AutoFarm.Distance * 2, 0))* CFrame.Angles(math.rad(90), 0, 0))
            bodyPosition.Position = Cframe.Position + Vector3.new(0, Settings.AutoFarm.Distance * 2, 0)
            bodyGyro.CFrame = CFrame.new(Character:GetPivot().p, Cframe.Position) * CFrame.Angles(math.rad(90), 0, 0)
        end
    until tick() - oldTime >= Settings.AutoFarm.Delay or not Character:FindFirstChild("HumanoidRootPart")
    WaitingToTp = false
    if Character:FindFirstChild("HumanoidRootPart") and bodyPosition then
        Character.HumanoidRootPart.Anchored = true
        bodyPosition:Destroy()
    end
end

-- 🌌 Enemy Fetcher
local function getEnemys()
    if not workspace:FindFirstChild("dungeon") then 
        return (workspace.enemies and workspace.enemies:GetChildren()) or {} 
    end
    for _,v in pairs(workspace.dungeon:GetChildren()) do
        if v:FindFirstChild("enemyFolder") then 
            return v.enemyFolder:GetChildren() 
        end
    end
    return {}
end

-- 🌌 Safe zone calculations
local function dodgeCircle(part)
    local dir = (hrp.Position - part.Position).Unit
    local safePos = part.Position + dir * (part.Size.X/2 + 10)
    Functions:Teleport(CFrame.new(safePos))
    log("[DODGE-CIRCLE] "..part.Name,Color3.fromRGB(255,0,0))
end

local function dodgeLine(part)
    local right = part.CFrame.RightVector
    local safePos = hrp.Position + right * (part.Size.Z/2 + 10)
    Functions:Teleport(CFrame.new(safePos))
    log("[DODGE-LINE] "..part.Name,Color3.fromRGB(255,100,0))
end

-- 🌌 Filter junk skills
local function isJunk(name)
    name = name:lower()
    return name:find("left") or name:find("right") or name:find("head") or 
           name:find("aura") or name:find("sword") or 
           name:find("upper") or name:find("lower")
end

-- 🌌 Enemy Skill Watcher
local function track()
    for _,e in ipairs(getEnemys()) do
        if not e:FindFirstChild("SkillWatcher") then
            Instance.new("BoolValue",e).Name="SkillWatcher"
            e.DescendantAdded:Connect(function(o)
                if (o:IsA("BasePart") or o:IsA("MeshPart")) and not isJunk(o.Name) then
                    local sz = o.Size
                    if math.abs(sz.X - sz.Z) < 5 then
                        dodgeCircle(o)
                    else
                        dodgeLine(o)
                    end
                end
            end)
        end
    end
end

-- 🌌 Heartbeat
task.spawn(function()
    while task.wait(0.2) do
        Character = lp.Character
        hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        if hrp then track() end
    end
end)

print("✅ Enemy Auto-Dodge Teleport System initialized")
