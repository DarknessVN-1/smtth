-- 🌌 Enemy Auto-Dodge Teleport System with Console + AOE Highlight
local Players,workspace = game:GetService("Players"),game:GetService("Workspace")
local lp,Character = Players.LocalPlayer,nil
local hrp,WaitingToTp,LastplayerPos = nil,false,nil
local Settings = {AutoFarm={Distance=12,Delay=0.4}}

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

-- 🌌 Teleport
local Functions = {}
function Functions:Teleport(Cframe)
    if not Character or not hrp then return end
    LastplayerPos = Character:GetPivot().p
    if WaitingToTp then return end
    local bodyGyro = hrp:FindFirstChildOfClass("BodyGyro")
    local bodyPosition = hrp:FindFirstChildOfClass("BodyPosition")
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro",hrp)
        bodyGyro.MaxTorque=Vector3.new(400000,400000,400000) bodyGyro.D=500
    end
    if not bodyPosition then
        bodyPosition = Instance.new("BodyPosition",hrp)
        bodyPosition.MaxForce=Vector3.new(400000,400000,400000) bodyPosition.D=300
    end
    WaitingToTp=true
    local oldTime=tick()
    repeat task.wait()
        if hrp then
            hrp.Velocity=Vector3.zero
            bodyPosition.Position = Cframe.Position + Vector3.new(0,Settings.AutoFarm.Distance*2,0)
            bodyGyro.CFrame = CFrame.new(hrp.Position,Cframe.Position)
        end
    until tick()-oldTime>=Settings.AutoFarm.Delay or not hrp
    WaitingToTp=false
    if bodyPosition then bodyPosition:Destroy() end
end

-- 🌌 Enemy getter
local function getEnemys()
    if workspace:FindFirstChild("dungeon") then
        for _,v in pairs(workspace.dungeon:GetChildren()) do
            if v:FindFirstChild("enemyFolder") then return v.enemyFolder:GetChildren() end
        end
    end
    return (workspace.enemies and workspace.enemies:GetChildren()) or {}
end

-- 🌌 Highlight helper
local function highlightAOE(p,color)
    local box = Instance.new("SelectionBox",p)
    box.Adornee = p
    box.LineThickness = 0.05
    box.Color3 = color
    task.spawn(function()
        p.AncestryChanged:Wait() -- auto-remove when part gone
        if box then box:Destroy() end
    end)
end

-- 🌌 Safe zone calc
local function dodgeCircle(p)
    highlightAOE(p,Color3.fromRGB(255,0,0))
    local dir=(hrp.Position-p.Position).Unit
    Functions:Teleport(CFrame.new(p.Position+dir*(p.Size.X/2+10)))
    print("[DODGE] circle",p.Name)
end
local function dodgeLine(p)
    highlightAOE(p,Color3.fromRGB(0,128,255))
    local side=p.CFrame.RightVector
    Functions:Teleport(CFrame.new(hrp.Position+side*(p.Size.Z/2+10)))
    print("[DODGE] line",p.Name)
end
local function isJunk(n)
    n=n:lower()
    return n:find("left") or n:find("right") or n:find("head") or n:find("aura") or n:find("sword") or n:find("upper") or n:find("lower")
end

-- 🌌 Watch enemies
local function track()
    local enemies=getEnemys()
    if #enemies==0 then print("⚠️ No enemies detected") return end
    print("👾 Enemies: "..#enemies)
    for _,e in ipairs(enemies) do
        if not e:FindFirstChild("SkillWatcher") then
            Instance.new("BoolValue",e).Name="SkillWatcher"
            e.DescendantAdded:Connect(function(o)
                if (o:IsA("BasePart") or o:IsA("MeshPart")) and not isJunk(o.Name) then
                    if math.abs(o.Size.X-o.Size.Z)<5 then dodgeCircle(o) else dodgeLine(o) end
                end
            end)
            print("🔍 Watching "..e.Name)
        end
    end
end

-- 🌌 Loop
task.spawn(function()
    while task.wait(0.2) do
        Character=lp.Character
        hrp=Character and Character:FindFirstChild("HumanoidRootPart")
        track()
    end
end)

print("✅ Enemy Auto-Dodge Teleport System + AOE Highlight initialized")
