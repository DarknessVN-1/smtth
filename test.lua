local p=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local c,h,hrp
local loopConn
local lastTarget

-- console
local g=Instance.new("ScreenGui",game.CoreGui)
local b=Instance.new("TextButton",g)
b.Size,b.Position,b.Text,b.BackgroundColor3=UDim2.new(0,100,0,40),UDim2.new(0,20,0,200),"Console",Color3.fromRGB(30,30,30)
local f=Instance.new("Frame",g)f.Size,f.Position,f.BackgroundColor3,f.Visible=UDim2.new(.6,0,.5,0),UDim2.new(.2,0,.25,0),Color3.fromRGB(20,20,20),false
local s=Instance.new("ScrollingFrame",f)s.Size,s.BackgroundTransparency=UDim2.new(1,0,1,0),1
local l=Instance.new("UIListLayout",s)
local function log(t,c0)local t0=Instance.new("TextLabel",s)t0.Size, t0.BackgroundTransparency, t0.TextColor3, t0.Font, t0.TextSize, t0.TextXAlignment=UDim2.new(1,-10,0,20),1,c0 or Color3.fromRGB(0,255,0),Enum.Font.Code,14,Enum.TextXAlignment.Left;t0.Text=t;s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y);s.CanvasPosition=Vector2.new(0,math.max(0,l.AbsoluteContentSize.Y-s.AbsoluteSize.Y))end
b.MouseButton1Click:Connect(function()f.Visible=not f.Visible end)

-- enemies
local function getE()
    if not workspace:FindFirstChild("dungeon") then return workspace.enemies and workspace.enemies:GetChildren() or {} end
    for _,v in pairs(workspace.dungeon:GetChildren()) do
        if v:FindFirstChild("enemyFolder") then return v.enemyFolder:GetChildren() end
    end
    return {}
end

local function getC()
    local e,d=nil,1/0
    for _,v in pairs(getE()) do
        local hr=v:FindFirstChild("HumanoidRootPart")
        local head=v:FindFirstChild("Head")
        if hr and head and head:FindFirstChild("enemyNameplate") then
            if head.enemyNameplate.Frame.healthBackground.healthBar.ImageColor3~=Color3.fromRGB(84,195,255) then
                local dist=(hrp.Position-hr.Position).Magnitude
                if dist<d then d,e=dist,v end
            end
        end
    end
    return e,d
end

-- dodge
local function watch(e)
    if e:FindFirstChild("TWatch") then return end
    Instance.new("BoolValue",e).Name="TWatch"
    e.DescendantAdded:Connect(function(o)
        if o:IsA("BasePart") and o.Size.Magnitude>6 then
            local dist=(hrp.Position-o.Position).Magnitude
            local radius=math.max(o.Size.X,o.Size.Z)/2
            if dist<radius then
                local old=h.WalkSpeed;h.WalkSpeed=math.max(old,36)
                h:ChangeState(Enum.HumanoidStateType.Jumping)
                local dir=(hrp.Position-o.Position).Unit
                h:MoveTo(o.Position+dir*(radius+14))
                task.delay(.7,function()if h then h.WalkSpeed=old end end)
                log("[DODGE] "..o.Name.." r="..math.floor(radius),Color3.fromRGB(255,0,0))
            end
        end
    end)
end

-- main loop (Heartbeat-based)
local function onStep()
    if not hrp or not h then return end
    local e,d=getC()
    if e and e:FindFirstChild("HumanoidRootPart") then
        if e~=lastTarget then
            lastTarget=e
            log("🎯 Target: "..e.Name.." ("..math.floor(d)..")",Color3.fromRGB(0,200,255))
        end
        watch(e)
        if d<12 then
            h:MoveTo(hrp.Position+(hrp.Position-e.HumanoidRootPart.Position).Unit*15)
        elseif d>20 then
            h:MoveTo(e.HumanoidRootPart.Position)
        else
            h:MoveTo(hrp.Position)
        end
    end
end

-- bind respawn
local function bind(char)
    c=char;h=c:WaitForChild("Humanoid");hrp=c:WaitForChild("HumanoidRootPart")
    if loopConn then loopConn:Disconnect() end
    loopConn=RS.Heartbeat:Connect(onStep)
    log("🎯 Bound new character",Color3.fromRGB(180,200,255))
end

if p.Character then bind(p.Character) end
p.CharacterAdded:Connect(bind)

log("✅ Auto Target + Precise Dodge Ready",Color3.fromRGB(0,255,0))
