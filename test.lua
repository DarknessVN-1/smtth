-- ✅ Console UI
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

-- ✅ Your exact function
Functions = {}
function Functions:GetEnemys()
    if not workspace:FindFirstChild("dungeon") then 
        return workspace:FindFirstChild("enemies"):GetChildren()
    end
    for i, v in pairs(workspace.dungeon:GetChildren()) do
        if v:FindFirstChild("enemyFolder") and v.enemyFolder:FindFirstChildOfClass("Model") then
            return v.enemyFolder:GetChildren()
        end
    end
    return nil
end

-- ✅ Enemy activity tracker
local function track()
    for _,enemy in ipairs(Functions:GetEnemys() or {}) do
        if not enemy:FindFirstChild("ActivityWatcher") then
            Instance.new("BoolValue",enemy).Name="ActivityWatcher"

            -- Attributes
            enemy.AttributeChanged:Connect(function(attr)
                log("🔧 "..enemy.Name.." Attribute "..attr.." = "..tostring(enemy:GetAttribute(attr)),Color3.fromRGB(0,200,255))
            end)

            -- Values
            enemy.DescendantAdded:Connect(function(o)
                if o:IsA("ValueBase") then
                    log("📊 "..enemy.Name.." added "..o.ClassName.." "..o.Name.." = "..tostring(o.Value),Color3.fromRGB(200,255,200))
                    o.Changed:Connect(function(val)
                        log("📊 "..enemy.Name.." "..o.Name.." changed -> "..tostring(val),Color3.fromRGB(100,255,100))
                    end)
                end
            end)

            -- Animations
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if hum and hum:FindFirstChild("Animator") then
                hum.Animator.AnimationPlayed:Connect(function(track)
                    log("🎬 "..enemy.Name.." played animation "..(track.Animation and track.Animation.AnimationId or "Unknown"),Color3.fromRGB(255,150,0))
                end)
            end

            log("👾 Tracking "..enemy.Name,Color3.fromRGB(200,200,255))
        end
    end
end

-- ✅ Loop check
task.spawn(function()
    while task.wait(0.2) do
        track()
    end
end)

log("✅ Enemy Tracker Initialized",Color3.fromRGB(0,255,0))
