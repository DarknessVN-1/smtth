-- 🌌 Enemy Activity Tracker
local Players,workspace = game:GetService("Players"),game:GetService("Workspace")
local lp = Players.LocalPlayer

-- Console
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
    l.Size, l.BackgroundTransparency, l.TextColor3, l.Font, l.TextSize, l.TextXAlignment =
        UDim2.new(1,-10,0,20),1,c or Color3.fromRGB(0,255,0),Enum.Font.Code,14,Enum.TextXAlignment.Left
    l.Text = tostring(t)
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y)
    scroll.CanvasPosition = Vector2.new(0, math.max(0, list.AbsoluteContentSize.Y - scroll.AbsoluteSize.Y))
end
btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- Enemy getter
local function getEnemys()
    if workspace:FindFirstChild("dungeon") then
        for _,v in pairs(workspace.dungeon:GetChildren()) do
            if v:FindFirstChild("enemyFolder") then return v.enemyFolder:GetChildren() end
        end
    end
    return (workspace.enemies and workspace.enemies:GetChildren()) or {}
end

-- Tracker
local function track()
    for _,enemy in ipairs(getEnemys()) do
        if not enemy:FindFirstChild("ActivityWatcher") then
            Instance.new("BoolValue",enemy).Name="ActivityWatcher"
            
            -- Log when new stuff spawns
            enemy.DescendantAdded:Connect(function(obj)
                log("➕ "..enemy.Name.." added "..obj.ClassName.." ("..obj.Name..")",Color3.fromRGB(0,255,255))
            end)
            -- Log when stuff removed
            enemy.DescendantRemoving:Connect(function(obj)
                log("➖ "..enemy.Name.." removed "..obj.ClassName.." ("..obj.Name..")",Color3.fromRGB(255,100,100))
            end)
            -- Log health if humanoid exists
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.HealthChanged:Connect(function(h)
                    log("❤️ "..enemy.Name.." HP: "..math.floor(h),Color3.fromRGB(255,200,200))
                end)
                hum.Died:Connect(function()
                    log("💀 "..enemy.Name.." died",Color3.fromRGB(255,0,0))
                end)
            end

            log("👾 Tracking "..enemy.Name,Color3.fromRGB(200,200,255))
        end
    end
end

-- Loop check
task.spawn(function()
    while task.wait(0.2) do
        track()
    end
end)

log("✅ Enemy Activity Tracker initialized",Color3.fromRGB(0,255,0))
