local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local camera = workspace.CurrentCamera

local cmdGui = Instance.new("ScreenGui")
cmdGui.Name = "XDXDsCmd"
cmdGui.Parent = game.CoreGui
cmdGui.ResetOnSpawn = false

local cmdFrame = Instance.new("Frame")
cmdFrame.Size = UDim2.new(0, 250, 0, 30)
cmdFrame.Position = UDim2.new(1, -260, 1, -40)
cmdFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
cmdFrame.BackgroundTransparency = 0.15
cmdFrame.BorderSizePixel = 1
cmdFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
cmdFrame.Active = true
cmdFrame.Draggable = true
cmdFrame.Parent = cmdGui

local cmdbar = Instance.new("TextBox")
cmdbar.Size = UDim2.new(1, -10, 1, -6)
cmdbar.Position = UDim2.new(0, 5, 0, 3)
cmdbar.Text = ""
cmdbar.PlaceholderText = "XDXD >"
cmdbar.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
cmdbar.TextColor3 = Color3.fromRGB(255, 255, 255)
cmdbar.BackgroundTransparency = 1
cmdbar.Font = Enum.Font.SourceSans
cmdbar.TextSize = 16
cmdbar.TextXAlignment = Enum.TextXAlignment.Left
cmdbar.ClearTextOnFocus = false
cmdbar.Parent = cmdFrame

local flying = false
local flySpeed = 50
local flyGui = nil
local attachment, lv, ao

local function createFlyGUI()
    if flyGui then flyGui:Destroy() flyGui = nil end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XDXDsFly"
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.fromOffset(210, 135)
    MainFrame.Position = UDim2.new(0.5, -105, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 11)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Thickness = 2.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local UIGradient = Instance.new("UIGradient", UIStroke)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    })
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0.26, 0)
    Title.Text = "XDXD's Fly GUI"
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 22
    Title.TextColor3 = Color3.new(1, 1, 1)
    local SubTitle = Instance.new("TextLabel", MainFrame)
    SubTitle.Size = UDim2.new(1, 0, 0.09, 0)
    SubTitle.Position = UDim2.new(0, 0, 0.25, 0)
    SubTitle.Text = " "
    SubTitle.BackgroundTransparency = 1
    SubTitle.Font = Enum.Font.GothamBold
    SubTitle.TextSize = 7
    SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubTitle.TextStrokeTransparency = 0.8
    local SpeedFrame = Instance.new("Frame", MainFrame)
    SpeedFrame.Size = UDim2.new(0.88, 0, 0.22, 0)
    SpeedFrame.Position = UDim2.new(0.06, 0, 0.39, 0)
    SpeedFrame.BackgroundTransparency = 1
    local SpeedMinus = Instance.new("TextButton", SpeedFrame)
    SpeedMinus.Size = UDim2.new(0.25, 0, 1, 0)
    SpeedMinus.Position = UDim2.new(0, 0, 0, 0)
    SpeedMinus.Text = "-"
    SpeedMinus.TextSize = 18
    SpeedMinus.Font = Enum.Font.GothamBold
    SpeedMinus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    SpeedMinus.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", SpeedMinus).CornerRadius = UDim.new(0, 5)
    local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
    SpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
    SpeedLabel.Position = UDim2.new(0.25, 0, 0, 0)
    SpeedLabel.Text = "SPEED: " .. flySpeed
    SpeedLabel.TextSize = 11
    SpeedLabel.Font = Enum.Font.GothamBold
    SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
    SpeedLabel.BackgroundTransparency = 1
    local SpeedPlus = Instance.new("TextButton", SpeedFrame)
    SpeedPlus.Size = UDim2.new(0.25, 0, 1, 0)
    SpeedPlus.Position = UDim2.new(0.75, 0, 0, 0)
    SpeedPlus.Text = "+"
    SpeedPlus.TextSize = 18
    SpeedPlus.Font = Enum.Font.GothamBold
    SpeedPlus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    SpeedPlus.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", SpeedPlus).CornerRadius = UDim.new(0, 5)
    local Toggle = Instance.new("TextButton", MainFrame)
    Toggle.Size = UDim2.new(0.88, 0, 0.30, 0)
    Toggle.Position = UDim2.new(0.06, 0, 0.64, 0)
    Toggle.Text = flying and "STATUS: ACTIVE" or "STATUS: INACTIVE"
    Toggle.TextSize = 13
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.AutoButtonColor = false
    local ToggleCorner = Instance.new("UICorner", Toggle)
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    local ToggleStroke = Instance.new("UIStroke", Toggle)
    ToggleStroke.Thickness = 1.5
    ToggleStroke.Color = flying and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
    local function updateSpeedDisplay()
        SpeedLabel.Text = "SPEED: " .. flySpeed
    end
    SpeedMinus.MouseButton1Click:Connect(function()
        if flySpeed > 10 then
            flySpeed = flySpeed - 10
            updateSpeedDisplay()
        end
    end)
    SpeedPlus.MouseButton1Click:Connect(function()
        if flySpeed < 1000 then
            flySpeed = flySpeed + 10
            updateSpeedDisplay()
        end
    end)
    Toggle.MouseButton1Click:Connect(function()
        flying = not flying
        if flying then
            Toggle.Text = "STATUS: ACTIVE"
            TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 255, 150)}):Play()
            setupFly()
        else
            Toggle.Text = "STATUS: INACTIVE"
            TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(255, 50, 50)}):Play()
            stopFly()
        end
    end)
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    flyGui = ScreenGui
    return ScreenGui
end

local function setupFly()
    local c = player.Character
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart")
    local humanoid = c:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    humanoid.PlatformStand = true
    if attachment then
        attachment:Destroy()
        attachment = nil
        lv = nil
        ao = nil
    end
    attachment = Instance.new("Attachment", root)
    lv = Instance.new("LinearVelocity", attachment)
    lv.MaxForce = 9e9
    lv.VectorVelocity = Vector3.zero
    lv.Attachment0 = attachment
    ao = Instance.new("AlignOrientation", attachment)
    ao.MaxTorque = 9e9
    ao.Responsiveness = 200
    ao.RigidityEnabled = false
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.Attachment0 = attachment
    flying = true
end

local function stopFly()
    flying = false
    local c = player.Character
    if c then
        local humanoid = c:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    if attachment then
        attachment:Destroy()
        attachment = nil
        lv = nil
        ao = nil
    end
    if flyGui then
        flyGui:Destroy()
        flyGui = nil
    end
end

local function toggleFly()
    if flying then
        stopFly()
        if flyGui then
            flyGui:Destroy()
            flyGui = nil
        end
    else
        if not flyGui then
            createFlyGUI()
        end
        setupFly()
    end
end

local noclipActive = false
local noclipConnection = nil

local function toggleNoclip()
    noclipActive = not noclipActive
    if noclipActive then
        noclipConnection = RS.Heartbeat:Connect(function()
            local c = player.Character
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local c = player.Character
        if c then
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function toggleClip()
    if noclipActive then
        toggleNoclip()
    else
        noclipActive = true
        noclipConnection = RS.Heartbeat:Connect(function()
            local c = player.Character
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function setSpeed(speedVal)
    if type(speedVal) ~= "number" then return end
    if speedVal < 1 or speedVal > 999 then return end
    local c = player.Character
    if c then
        local humanoid = c:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedVal
        end
    end
end

local espGui = Instance.new("ScreenGui")
espGui.Name = "ESP_GUI"
espGui.ResetOnSpawn = false
espGui.Parent = player:WaitForChild("PlayerGui")

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 180, 0, 50)
espButton.Position = UDim2.new(0, 20, 0, 20)
espButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.TextSize = 20
espButton.Font = Enum.Font.GothamBold
espButton.Text = "ESP: OFF"
espButton.Parent = espGui
Instance.new("UICorner", espButton).CornerRadius = UDim.new(0, 10)

espGui.Enabled = false

local espEnabled = false

local function removeESP(p)
    if p.Character then
        local highlight = p.Character:FindFirstChild("ESPHighlight")
        if highlight then highlight:Destroy() end
    end
end

local function addESP(p)
    if p == player then return end
    if not espEnabled then return end
    local character = p.Character
    if not character then return end
    if character:FindFirstChild("ESPHighlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
end

local function updateESP()
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
            if espEnabled then addESP(p) else removeESP(p) end
        end
    end
end

for _, p in ipairs(game.Players:GetPlayers()) do
    if p ~= player then
        p.CharacterAdded:Connect(function()
            task.wait(0.1)
            if espEnabled then addESP(p) end
        end)
    end
end

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    updateESP()
end)

local tpGui = Instance.new("ScreenGui")
tpGui.Name = "TPToolGUI"
tpGui.ResetOnSpawn = false
tpGui.Parent = player:WaitForChild("PlayerGui")

local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(0, 200, 0, 120)
tpFrame.Position = UDim2.new(0.5, -100, 0.5, -60)
tpFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
tpFrame.BackgroundTransparency = 0.15
tpFrame.BorderSizePixel = 1
tpFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
tpFrame.Active = true
tpFrame.Draggable = true
tpFrame.Parent = tpGui

local tpTitle = Instance.new("TextLabel")
tpTitle.Size = UDim2.new(1, 0, 0, 30)
tpTitle.Text = "XDXD's TP Tool"
tpTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
tpTitle.TextScaled = true
tpTitle.BackgroundTransparency = 1
tpTitle.Parent = tpFrame

local tpStatus = Instance.new("TextLabel")
tpStatus.Size = UDim2.new(1, 0, 0, 25)
tpStatus.Position = UDim2.new(0, 0, 0, 35)
tpStatus.Text = "Click anywhere to teleport"
tpStatus.TextColor3 = Color3.fromRGB(150, 200, 255)
tpStatus.TextScaled = true
tpStatus.BackgroundTransparency = 1
tpStatus.Parent = tpFrame

local tpClose = Instance.new("TextButton")
tpClose.Size = UDim2.new(0, 50, 0, 25)
tpClose.Position = UDim2.new(1, -60, 0, 70)
tpClose.Text = "Close"
tpClose.TextColor3 = Color3.fromRGB(255, 255, 255)
tpClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
tpClose.BorderSizePixel = 0
tpClose.Parent = tpFrame
Instance.new("UICorner", tpClose).CornerRadius = UDim.new(0, 5)

tpGui.Enabled = false

local tpMode = false

local function teleportToMouse()
    local c = player.Character
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    if not root then return end
    local hit = player:GetMouse().Hit
    root.CFrame = CFrame.new(hit.X, hit.Y + 2, hit.Z)
    tpStatus.Text = "Teleported!"
    task.wait(1)
    tpStatus.Text = "Click anywhere to teleport"
end

local function toggleTPTool()
    tpMode = not tpMode
    tpGui.Enabled = tpMode
    if tpMode then
        tpStatus.Text = "Click anywhere to teleport"
    end
end

tpClose.MouseButton1Click:Connect(toggleTPTool)

player:GetMouse().Button1Down:Connect(function()
    if tpMode then
        teleportToMouse()
    end
end)

local function handleCommand(cmd)
    cmd = cmd:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if cmd == "fly" then toggleFly() return end
    if cmd == "unfly" then if flying then stopFly() if flyGui then flyGui:Destroy() flyGui = nil end end return end
    if cmd == "noclip" then toggleNoclip() return end
    if cmd == "clip" then toggleClip() return end
    if cmd:find("speed") then
        local num = tonumber(cmd:match("%d+"))
        if num then setSpeed(num) end
        return
    end
    if cmd == "esp" then
        espGui.Enabled = not espGui.Enabled
        return
    end
    if cmd == "tptool" then toggleTPTool() return end
    cmdbar.Text = ""
end

cmdbar.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local cmd = cmdbar.Text
        if cmd ~= "" then handleCommand(cmd) end
    end
end)

RS.RenderStepped:Connect(function(deltaTime)
    if flying and player.Character and lv and ao then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local cam = workspace.CurrentCamera
        local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
        local Controls = PlayerModule:GetControls()
        local moveVector = Controls:GetMoveVector()
        local targetDirection = Vector3.zero
        if moveVector.Magnitude > 0 then
            targetDirection = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            targetDirection = targetDirection + Vector3.new(0, 1, 0)
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            targetDirection = targetDirection + Vector3.new(0, -1, 0)
        end
        if targetDirection.Magnitude > 0 then
            lv.VectorVelocity = targetDirection.Unit * flySpeed
        else
            lv.VectorVelocity = Vector3.zero
        end
        local alpha = 1 - math.exp(-20 * deltaTime)
        ao.CFrame = ao.CFrame:Lerp(cam.CFrame, alpha)
    end
end)

player.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if flying then setupFly() end
    if noclipActive then
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

print("XDXD's CMD Loaded")
