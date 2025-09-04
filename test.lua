-- minimal console
local g=Instance.new("ScreenGui",game.CoreGui)
local b=Instance.new("TextButton",g) b.Size, b.Position, b.Text, b.BackgroundColor3=UDim2.new(0,100,0,36),UDim2.new(0,16,0,180),"Console",Color3.fromRGB(30,30,30)
local f=Instance.new("Frame",g) f.Size,f.Position,f.BackgroundColor3,f.Visible=UDim2.new(.55,0,.45,0),UDim2.new(.22,0,.28,0),Color3.fromRGB(20,20,20),false
local s=Instance.new("ScrollingFrame",f) s.Size,s.BackgroundTransparency=UDim2.new(1,0,1,0),1
local l=Instance.new("UIListLayout",s)
local function log(txt,col) local t=Instance.new("TextLabel",s) t.BackgroundTransparency=1 t.Size=UDim2.new(1,-10,0,18) t.Font=Enum.Font.Code t.TextSize=14 t.TextXAlignment=Enum.TextXAlignment.Left t.TextColor3=col or Color3.fromRGB(0,255,0) t.Text=tostring(txt) s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y) end
b.MouseButton1Click:Connect(function() f.Visible=not f.Visible end)

-- services / globals
local RS=game:GetService("RunService")
local PFS=game:GetService("PathfindingService")
local WS=game:GetService("Workspace")
local plr=game.Players.LocalPlayer
local c,h,hrp; local running=true

-- enemy helpers
local function getEnemies()
    if not WS:FindFirstChild("dungeon") then return WS.enemies and WS.enemies:GetChildren() or {} end
    for _,v in pairs(WS.dungeon:GetChildren()) do if v:FindFirstChild("enemyFolder") then return v.enemyFolder:GetChildren() end end
    return {}
end

local function getClosest()
    if not hrp then return end
    local best,bd=nil,1/0
    for _,v in ipairs(getEnemies()) do
        local head=v:FindFirstChild("Head"); local hp=v:FindFirstChild("Humanoid"); local r=v:FindFirstChild("HumanoidRootPart")
        if head and hp and r and head:FindFirstChild("enemyNameplate") then
            if head.enemyNameplate.Frame.healthBackground.healthBar.ImageColor3~=Color3.fromRGB(84,195,255) then
                local d=(hrp.Position-r.Position).Magnitude
                if d<bd then bd, best = d, v end
            end
        end
    end
    return best, bd
end

-- movement: path + wall check
local ignore=RaycastParams.new(); ignore.FilterType=Enum.RaycastFilterType.Blacklist
local function go(toPos)
    if not hrp or not h then return end
    ignore.FilterDescendantsInstances={c}
    local path=PFS:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
    path:ComputeAsync(hrp.Position, toPos)
    if path.Status==Enum.PathStatus.Success then
        local wp=path:GetWaypoints()
        if #wp>1 then h:MoveTo(wp[2].Position) else h:MoveTo(toPos) end
    else
        local dir=(toPos-hrp.Position); if dir.Magnitude<1 then return end
        dir=dir.Unit
        local hit=WS:Raycast(hrp.Position, dir*10, ignore)
        if hit then
            local side=hrp.CFrame.RightVector
            local leftHit=WS:Raycast(hrp.Position, -side*12, ignore)
            local rightHit=WS:Raycast(hrp.Position, side*12, ignore)
            local sidestep = (leftHit and not rightHit) and side or (rightHit and not leftHit) and -side or side
            h:MoveTo(hrp.Position + sidestep*12)
        else
            h:MoveTo(hrp.Position + dir*12)
        end
    end
end

-- telegraph detection + dodge
local watching=setmetatable({}, {__mode="k"})
local function watchEnemy(e)
    if watching[e] then return end
    watching[e]=true
    e.DescendantAdded:Connect(function(o)
        if not hrp or not h then return end
        if o:IsA("BasePart") and o.Anchored and o.Size.Magnitude>6 then
            local n=o.Name:lower()
            if n:find("torso") or n:find("arm") or n:find("leg") or n:find("head") then return end
            local inside=(hrp.Position-o.Position).Magnitude < (o.Size.Magnitude/2)
            if inside then
                local old=h.WalkSpeed; h.WalkSpeed=math.max(old, 34)
                h:ChangeState(Enum.HumanoidStateType.Jumping)
                local outDir=(hrp.Position-o.Position).Unit
                local target=o.Position + outDir*(o.Size.Magnitude/2 + 14)
                go(target)
                task.delay(.6,function() if h then h.WalkSpeed=old end end)
                log("[DODGE] "..o.Name, Color3.fromRGB(255,120,120))
            end
        end
    end)
end

-- main loop (approach/hold/retreat)
local SAFE, RANGE = 12, 20
local function mainTick()
    local e,d=getClosest()
    if not e or not e:FindFirstChild("HumanoidRootPart") then return end
    watchEnemy(e)
    local ep=e.HumanoidRootPart.Position
    if d<SAFE then
        local dir=(hrp.Position-ep).Unit
        go(hrp.Position + dir*16)
    elseif d>RANGE then
        go(ep)
    else
        h:MoveTo(hrp.Position)
    end
end

-- bind / respawn safe
local hbConn; local loopConn
local function bind(char)
    c=char; h=c:WaitForChild("Humanoid"); hrp=c:WaitForChild("HumanoidRootPart")
    if hbConn then hbConn:Disconnect() end
    hbConn=RS.Heartbeat:Connect(function() if running then mainTick() end end)
    log("Character bound", Color3.fromRGB(180,220,255))
end

if plr.Character then bind(plr.Character) end
plr.CharacterAdded:Connect(function(nc) bind(nc) end)

log("✅ Auto-move + dodge (respawn-safe)", Color3.fromRGB(0,255,0))
