local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ParentGui = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if ParentGui:FindFirstChild("ShinHubUI") then ParentGui.ShinHubUI:Destroy() end
if ParentGui:FindFirstChild("ShinHubESP") then ParentGui.ShinHubESP:Destroy() end

local State = { Speed = false, Noclip = false, Fly = false, EntityESP = false, DoorESP = false, KeyESP = false }
local Val = { Speed = 25, Noclip = 25, Fly = 30 }

local Gui = Instance.new("ScreenGui", ParentGui)
Gui.Name = "ShinHubUI"
Gui.ResetOnSpawn = false

local Pill = Instance.new("TextButton", Gui)
Pill.Size = UDim2.new(0, 90, 0, 32)
Pill.Position = UDim2.new(0, 15, 0.45, 0)
Pill.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Pill.BorderColor3 = Color3.fromRGB(115, 75, 200)
Pill.BorderSizePixel = 2
Pill.Text = "ShinHub"
Pill.TextColor3 = Color3.new(1, 1, 1)
Pill.Font = Enum.Font.GothamBold
Pill.TextSize = 13
Pill.Active = true
Pill.Draggable = true

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(0, 440, 0, 270)
Frame.Position = UDim2.new(0.5, -220, 0.5, -135)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Frame.BorderColor3 = Color3.fromRGB(115, 75, 200)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true

local Top = Instance.new("TextLabel", Frame)
Top.Size = UDim2.new(1, 0, 0, 30)
Top.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
Top.Text = "  ShinHub | DOORS"
Top.TextColor3 = Color3.fromRGB(235, 235, 245)
Top.Font = Enum.Font.GothamBold
Top.TextSize = 14
Top.TextXAlignment = Enum.TextXAlignment.Left

local function AddToggle(x, y, key, label)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(0, 195, 0, 28)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    b.BorderColor3 = Color3.fromRGB(65, 65, 80)
    b.Text = label .. ": OFF"
    b.TextColor3 = Color3.fromRGB(220, 220, 230)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        b.Text = label .. (State[key] and ": ON" or ": OFF")
        b.BorderColor3 = State[key] and Color3.fromRGB(115, 75, 200) or Color3.fromRGB(65, 65, 80)
    end)
end

local function AddSlider(x, y, key, label, minV, maxV, defV)
    Val[key] = defV
    local box = Instance.new("Frame", Frame)
    box.Size = UDim2.new(0, 195, 0, 36)
    box.Position = UDim2.new(0, x, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    box.BorderColor3 = Color3.fromRGB(65, 65, 80)

    local txt = Instance.new("TextLabel", box)
    txt.Size = UDim2.new(1, -6, 0, 16)
    txt.Position = UDim2.new(0, 4, 0, 2)
    txt.BackgroundTransparency = 1
    txt.Text = label .. ": " .. defV
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 11
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("TextButton", box)
    bar.Size = UDim2.new(1, -8, 0, 12)
    bar.Position = UDim2.new(0, 4, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    bar.Text = ""

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((defV - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(115, 75, 200)
    fill.BorderSizePixel = 0

    local drag = false
    local function upd(pos)
        local rel = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV - minV) * rel)
        Val[key] = v
        fill.Size = UDim2.new(rel, 0, 1, 0)
        txt.Text = label .. ": " .. v
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; upd(i.Position) end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then upd(i.Position) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
end

-- Left Column: Movement & Sliders
AddToggle(15, 42, "Speed", "Speed Boost")
AddSlider(15, 74, "Speed", "WalkSpeed", 16, 75, 25)
AddToggle(15, 118, "Noclip", "Noclip")
AddSlider(15, 150, "Noclip", "Noclip Speed", 10, 100, 25)
AddToggle(15, 194, "Fly", "Fly")
AddSlider(15, 226, "Fly", "Fly Speed", 10, 120, 30)

-- Right Column: ESPs
AddToggle(230, 42, "EntityESP", "Entity ESP")
AddToggle(230, 78, "DoorESP", "Door ESP")
AddToggle(230, 114, "KeyESP", "Key & Lever ESP")

-- Movement Loop
local bv, bg
RunService.RenderStepped:Connect(function()
    if not Gui.Parent then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        if State.Noclip then hum.WalkSpeed = Val.Noclip
        elseif State.Speed then hum.WalkSpeed = Val.Speed end
    end
    if char and State.Noclip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    if root and hum and State.Fly then
        if not bv then
            bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bg = Instance.new("BodyGyro", root); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4
        end
        bg.CFrame = workspace.CurrentCamera.CFrame
        bv.Velocity = hum.MoveDirection * Val.Fly
    elseif bv then
        bv:Destroy(); bv = nil
        if bg then bg:Destroy(); bg = nil end
    end
end)

-- ESP Loop
local ESPFolder = Instance.new("Folder", ParentGui)
ESPFolder.Name = "ShinHubESP"

local function Mark(obj, name, col)
    if not obj or not obj.Parent or ESPFolder:FindFirstChild(tostring(obj:GetDebugId())) then return end
    local h = Instance.new("Folder", ESPFolder); h.Name = tostring(obj:GetDebugId())
    local hl = Instance.new("Highlight", h); hl.Adornee = obj; hl.FillColor = col; hl.OutlineColor = col; hl.FillTransparency = 0.65
    local bb = Instance.new("BillboardGui", h); bb.Adornee = obj; bb.Size = UDim2.new(0, 120, 0, 24); bb.AlwaysOnTop = true
    local tx = Instance.new("TextLabel", bb); tx.Size = UDim2.new(1, 0, 1, 0); tx.BackgroundTransparency = 1; tx.Text = name; tx.TextColor3 = col; tx.TextStrokeTransparency = 0; tx.Font = Enum.Font.GothamBold; tx.TextSize = 12
    obj.AncestryChanged:Connect(function(_, p) if not p then h:Destroy() end end)
end

local Entities = { RushMoving = "Rush", AmbushMoving = "Ambush", Eyes = "Eyes", FigureRagdoll = "Figure", SeekMoving = "Seek", A60 = "A-60", A120 = "A-120" }
task.spawn(function()
    while task.wait(0.8) do
        if not Gui.Parent then ESPFolder:Destroy() break end
        if State.EntityESP then
            for _, c in ipairs(workspace:GetChildren()) do
                if Entities[c.Name] then Mark(c, Entities[c.Name], Color3.fromRGB(255, 60, 60)) end
            end
        end
        local rooms = workspace:FindFirstChild("CurrentRooms")
        if rooms then
            for _, r in ipairs(rooms:GetChildren()) do
                for _, item in ipairs(r:GetDescendants()) do
                    if State.DoorESP and item.Name == "Door" and item:IsA("Model") then Mark(item, "Door " .. r.Name, Color3.fromRGB(0, 255, 140))
                    elseif State.KeyESP and (item.Name == "KeyObtain" or item.Name == "LeverForGate") then Mark(item, item.Name == "KeyObtain" and "Key" or "Lever", Color3.fromRGB(255, 220, 50)) end
                end
            end
        end
    end
end)

Pill.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)
