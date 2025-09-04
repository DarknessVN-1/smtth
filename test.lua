-- ✅ Console
local gui = Instance.new("ScreenGui", game.CoreGui)
local btn = Instance.new("TextButton", gui)
btn.Size, btn.Position, btn.Text, btn.BackgroundColor3 =
    UDim2.new(0,100,0,40), UDim2.new(0,20,0,200), "Console", Color3.fromRGB(30,30,30)

local frame = Instance.new("Frame", gui)
frame.Size, frame.Position, frame.BackgroundColor3, frame.Visible =
    UDim2.new(.6,0,.5,0), UDim2.new(.2,0,.25,0), Color3.fromRGB(20,20,20), false

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size, scroll.BackgroundTransparency = UDim2.new(1,0,1,0), 1
local list = Instance.new("UIListLayout", scroll)

local function log(t,c)
    local l = Instance.new("TextLabel", scroll)
    l.Size, l.BackgroundTransparency, l.TextColor3, l.Font, l.TextSize, l.TextXAlignment =
        UDim2.new(1,-10,0,20),1,c or Color3.fromRGB(0,255,0),Enum.Font.Code,14,Enum.TextXAlignment.Left
    l.Text = tostring(t)
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y)
    scroll.CanvasPosition = Vector2.new(0, math.max(0, list.AbsoluteContentSize.Y - scroll.AbsoluteSize.Y))
end

btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- ✅ Enemy getter (your version)
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

-- ✅ Tracker
local function track()
    for _,e in ipairs(getEnemys()) do
        if not e:FindFirstChild("SkillWatcher") then
            Instance.new("BoolValue",e).Name="SkillWatcher"

            -- same as your working one
            e.DescendantAdded:Connect(function(o)
                if o:IsA("Part") or o:IsA("MeshPart") or o:IsA("ParticleEmitter") then
                    log("[SKILL] "..e.Name.." used "..o.Name,Color3.fromRGB(255,200,0))
                end
            end)

            -- also log attribute + animator + values
            e.AttributeChanged:Connect(function(attr)
                log("🔧 "..e.Name.." attr "..attr.."="..tostring(e:GetAttribute(attr)),Color3.fromRGB(0,200,255))
            end)

            local hum = e:FindFirstChildOfClass("Humanoid")
            if hum and hum:FindFirstChild("Animator") then
                hum.Animator.AnimationPlayed:Connect(function(track)
                    log("🎬 "..e.Name.." animation "..(track.Animation and track.Animation.AnimationId or "Unknown"),Color3.fromRGB(255,150,0))
                end)
            end
        end
    end
end

-- ✅ Loop
task.spawn(function()
    while task.wait(1) do
        track()
    end
end)

log("✅ Enemy Skill Tracker initialized",Color3.fromRGB(0,255,0))
