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

local function getEnemys()
    if not workspace:FindFirstChild("dungeon") then return (workspace.enemies and workspace.enemies:GetChildren()) or {} end
    for _,v in pairs(workspace.dungeon:GetChildren()) do
        if v:FindFirstChild("enemyFolder") and v.enemyFolder:FindFirstChildOfClass("Model") then return v.enemyFolder:GetChildren() end
    end
    return {}
end

local function track()
    for _,e in ipairs(getEnemys()) do
        if not e:FindFirstChild("SkillWatcher") then
            Instance.new("BoolValue",e).Name="SkillWatcher"
            e.DescendantAdded:Connect(function(o)
                if o:IsA("Part") or o:IsA("MeshPart") or o:IsA("ParticleEmitter") then
                    print("[SKILL] "..e.Name.." used "..o.Name)
                end
            end)
        end
    end
end

task.spawn(function() while task.wait(1) do track() end end)
print("✅ Enemy Skill Tracker initialized")
