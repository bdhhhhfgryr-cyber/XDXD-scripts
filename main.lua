local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local camera = workspace.CurrentCamera
local TS = game:GetService("TweenService")

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
local noclipActive = false
local noclipConnection = nil
local espEnabled = false
local espContainer = nil
local playerData = {}
local tpMode = false
local selectionBox = nil
local tpGui = nil
local tpListGui = nil
local helpGui = nil

local function findMurderer()
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char and char:FindFirstChild("Knife") then
                return p
            end
            if p.Backpack:FindFirstChild("Knife") then
                return p
            end
        end
    end
    if playerData then
        for name, data in pairs(playerData) do
            if data.Role == "Murderer" then
                local p = game.Players:FindFirstChild(name)
                if p then return p end
            end
        end
    end
    return nil
end

local function findSheriff()
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char and char:FindFirstChild("Gun") then
                return p
            end
            if p.Backpack:FindFirstChild("Gun") then
                return p
            end
        end
    end
    if playerData then
        for name, data in pairs(playerData) do
            if data.Role == "Sheriff" then
                local p = game.Players:FindFirstChild(name)
                if p then return p end
            end
        end
    end
    return nil
end

local function setupESP()
    if espContainer then
        espContainer:Destroy()
        espContainer = nil
    end
    espContainer = Instance.new("Folder")
    espContainer.Name = "XDXD_ESP"
    espContainer.Parent = game.CoreGui
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_" .. p.Name
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = char
            highlight.Parent = espContainer
            local murderer = findMurderer()
            local sheriff = findSheriff()
            if p == murderer then
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            elseif p == sheriff then
                highlight.FillColor = Color3.fromRGB(0, 150, 255)
                highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            end
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 150, 0, 30)
                bill.Adornee = head
                bill.AlwaysOnTop = true
                bill.Parent = espContainer
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                local role = "Innocent"
                if p == murderer then role = "MURDERER"
                elseif p == sheriff then role = "SHERIFF" end
                label.Text = p.Name .. " [" .. role .. "]"
                label.TextColor3 = p == murderer and Color3.fromRGB(255, 0, 0) or p == sheriff and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(0, 255, 0)
                label.Parent = bill
            end
        end
    end
end

local function refreshESP()
    if espEnabled then
        if espContainer then
            espContainer:Destroy()
        end
        setupESP()
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        setupESP()
    else
        if espContainer then
            espContainer:Destroy()
            espContainer = nil
        end
    end
end

local function autoGun()
    local gun = nil
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "GunDrop" then
            gun = v
            break
        end
    end
    if not gun then
        cmdbar.PlaceholderText = "[ERROR] No dropped gun!"
        task.wait(1)
        cmdbar.PlaceholderText = "XDXD >"
        cmdbar.Text = ""
        return
    end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(gun.Position.X, gun.Position.Y + 2, gun.Position.Z)
    cmdbar.PlaceholderText = "[GUN TAKEN]"
    task.wait(1)
    cmdbar.PlaceholderText = "XDXD >"
    cmdbar.Text = ""
end

if game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("Gameplay") then
    local dataEvent = game.ReplicatedStorage.Remotes.Gameplay:FindFirstChild("PlayerDataChanged")
    if dataEvent then
        dataEvent.OnClientEvent:Connect(function(data)
            playerData = data
            if espEnabled then
                refreshESP()
            end
        end)
    end
end

game.Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if espEnabled then
        refreshESP()
    end
end)

game.Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if espEnabled then
        refreshESP()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if espEnabled then
        refreshESP()
    end
end)

local function createFlyGUI()
    if flyGui then
        flyGui:Destroy()
        flyGui = nil
    end
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
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
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

local function createTPTool()
    if tpGui then
        tpGui:Destroy()
        tpGui = nil
    end
    tpGui = Instance.new("ScreenGui")
    tpGui.Name = "XDXD_TPTool"
    tpGui.Parent = game.CoreGui
    tpGui.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(1, -210, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = tpGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "XDXD's TP Tool"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Parent = frame
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 35)
    status.Text = "Click TP START to teleport"
    status.TextColor3 = Color3.fromRGB(150, 200, 255)
    status.TextScaled = true
    status.BackgroundTransparency = 1
    status.Parent = frame
    local tpStart = Instance.new("TextButton")
    tpStart.Size = UDim2.new(0, 80, 0, 25)
    tpStart.Position = UDim2.new(0.5, -85, 0, 70)
    tpStart.Text = "TP START"
    tpStart.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpStart.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    tpStart.BorderSizePixel = 0
    tpStart.Parent = frame
    Instance.new("UICorner", tpStart).CornerRadius = UDim.new(0, 5)
    local tpClose = Instance.new("TextButton")
    tpClose.Size = UDim2.new(0, 80, 0, 25)
    tpClose.Position = UDim2.new(0.5, 5, 0, 70)
    tpClose.Text = "Close"
    tpClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    tpClose.BorderSizePixel = 0
    tpClose.Parent = frame
    Instance.new("UICorner", tpClose).CornerRadius = UDim.new(0, 5)
    local function teleportToMouse()
        local c = player.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        if not root then return end
        local hit = player:GetMouse().Hit
        root.CFrame = CFrame.new(hit.X, hit.Y + 2, hit.Z)
        status.Text = "Teleported!"
        task.wait(0.5)
        status.Text = "Click TP START to teleport"
        tpMode = false
        tpStart.Text = "TP START"
        tpStart.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
    tpStart.MouseButton1Click:Connect(function()
        tpMode = not tpMode
        if tpMode then
            tpStart.Text = "TP ACTIVE"
            tpStart.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            status.Text = "Click anywhere to teleport"
            if not selectionBox then
                selectionBox = Instance.new("SelectionBox")
                selectionBox.Name = "TPSelectionBox"
                selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
                selectionBox.LineThickness = 0.1
                selectionBox.Parent = cmdGui
            end
        else
            tpStart.Text = "TP START"
            tpStart.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            status.Text = "Click TP START to teleport"
            if selectionBox then
                selectionBox.Adornee = nil
            end
        end
    end)
    tpClose.MouseButton1Click:Connect(function()
        tpGui:Destroy()
        tpGui = nil
        tpMode = false
        if selectionBox then
            selectionBox:Destroy()
            selectionBox = nil
        end
    end)
    local mouse = player:GetMouse()
    mouse.Move:Connect(function()
        if tpMode and selectionBox then
            local target = mouse.Target
            if target and target:IsA("BasePart") then
                selectionBox.Adornee = target
            else
                selectionBox.Adornee = nil
            end
        end
    end)
    mouse.Button1Down:Connect(function()
        if tpMode and tpGui then
            teleportToMouse()
        end
    end)
end

local function toggleTPTool()
    if tpGui then
        tpGui:Destroy()
        tpGui = nil
        tpMode = false
        if selectionBox then
            selectionBox:Destroy()
            selectionBox = nil
        end
    else
        createTPTool()
    end
end

local function toggleTPList()
    if tpListGui then
        tpListGui:Destroy()
        tpListGui = nil
        return
    end
    tpListGui = Instance.new("ScreenGui")
    tpListGui.Name = "XDXDsTPGUI"
    tpListGui.Parent = game.CoreGui
    tpListGui.DisplayOrder = 9999
    tpListGui.IgnoreGuiInset = true
    local f = Instance.new("Frame")
    f.Parent = tpListGui
    f.Size = UDim2.new(.45, 0, .65, 0)
    f.Position = UDim2.new(.275, 0, .175, 0)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    local t = Instance.new("Frame")
    t.Parent = f
    t.Size = UDim2.new(1, 0, 0, 35)
    t.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local tt = Instance.new("TextLabel")
    tt.Parent = t
    tt.Size = UDim2.new(1, 0, 1, 0)
    tt.BackgroundTransparency = 1
    tt.Text = "XDXD's TP GUI"
    tt.TextColor3 = Color3.new(1, 1, 1)
    tt.TextSize = 20
    tt.Font = Enum.Font.SourceSansBold
    local cr = Instance.new("TextLabel")
    cr.Parent = f
    cr.Size = UDim2.new(1, 0, 0, 20)
    cr.Position = UDim2.new(0, 0, 0, 35)
    cr.BackgroundTransparency = 1
    cr.Text = "Click on player to teleport"
    cr.TextColor3 = Color3.fromRGB(160, 160, 160)
    cr.TextSize = 13
    cr.Font = Enum.Font.SourceSansItalic
    cr.TextXAlignment = Enum.TextXAlignment.Center
    local mb = Instance.new("TextButton")
    mb.Parent = t
    mb.Size = UDim2.new(0, 35, 0, 35)
    mb.Position = UDim2.new(1, -70, 0, 0)
    mb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mb.Text = "-"
    mb.TextColor3 = Color3.new(1, 1, 1)
    local cb = Instance.new("TextButton")
    cb.Parent = t
    cb.Size = UDim2.new(0, 35, 0, 35)
    cb.Position = UDim2.new(1, -35, 0, 0)
    cb.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cb.Text = "X"
    cb.TextColor3 = Color3.new(1, 1, 1)
    local sc = Instance.new("ScrollingFrame")
    sc.Parent = f
    sc.Size = UDim2.new(1, -10, 1, -60)
    sc.Position = UDim2.new(0, 5, 0, 55)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 6
    local ll = Instance.new("UIListLayout")
    ll.Parent = sc
    ll.Padding = UDim.new(0, 6)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    local function updateTPList()
        for _, c in ipairs(sc:GetChildren()) do
            if c:IsA("Frame") then
                c:Destroy()
            end
        end
        for _, pl in ipairs(game.Players:GetPlayers()) do
            if pl == player then
                continue
            end
            local r = Instance.new("Frame")
            r.Parent = sc
            r.Size = UDim2.new(1, 0, 0, 42)
            r.BackgroundTransparency = 1
            local rl = Instance.new("UIListLayout")
            rl.Parent = r
            rl.FillDirection = Enum.FillDirection.Horizontal
            rl.Padding = UDim.new(0, 8)
            rl.VerticalAlignment = Enum.VerticalAlignment.Center
            local i = Instance.new("ImageLabel")
            i.Parent = r
            i.Size = UDim2.new(0, 42, 0, 42)
            i.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            pcall(function()
                i.Image = game.Players:GetUserThumbnailAsync(pl.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            local b = Instance.new("TextButton")
            b.Parent = r
            b.Size = UDim2.new(1, 0, 1, 0)
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            b.Text = pl.Name
            b.TextColor3 = Color3.new(1, 1, 1)
            b.TextSize = 16
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.MouseButton1Click:Connect(function()
                pcall(function()
                    local rt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local tg = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                    if rt and tg then
                        rt.CFrame = tg.CFrame * CFrame.new(0, 0, -3)
                    end
                end)
            end)
        end
        sc.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 10)
    end
    updateTPList()
    game.Players.PlayerAdded:Connect(updateTPList)
    game.Players.PlayerRemoving:Connect(updateTPList)
    local minimized = false
    mb.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            f.Size = UDim2.new(.45, 0, 0, 35)
            sc.Visible = false
            cr.Visible = false
            mb.Text = "+"
        else
            f.Size = UDim2.new(.45, 0, .65, 0)
            sc.Visible = true
            cr.Visible = true
            mb.Text = "-"
        end
    end)
    cb.MouseButton1Click:Connect(function()
        tpListGui:Destroy()
        tpListGui = nil
    end)
    local dragging, dragStart, startPos
    t.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = f.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    t.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function loadESP()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-esp-gui-224252"))()
end

local function createHelpGUI()
    if helpGui then
        helpGui:Destroy()
        helpGui = nil
        return
    end
    helpGui = Instance.new("ScreenGui")
    helpGui.Name = "XDXD_Help"
    helpGui.Parent = game.CoreGui
    helpGui.ResetOnSpawn = false
    local helpFrame = Instance.new("Frame")
    helpFrame.Size = UDim2.new(0, 300, 0, 350)
    helpFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    helpFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    helpFrame.BackgroundTransparency = 0.15
    helpFrame.BorderSizePixel = 1
    helpFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    helpFrame.Active = true
    helpFrame.Draggable = true
    helpFrame.Parent = helpGui
    Instance.new("UICorner", helpFrame).CornerRadius = UDim.new(0, 10)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "XDXD's Commands"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Parent = helpFrame
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 25)
    closeBtn.Position = UDim2.new(1, -35, 0, 2)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = helpFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
    closeBtn.MouseButton1Click:Connect(function()
        if helpGui then
            helpGui:Destroy()
            helpGui = nil
        end
    end)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -35)
    scroll.Position = UDim2.new(0, 0, 0, 30)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    scroll.Parent = helpFrame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    local commands = {
        {cmd = "fly", desc = "Toggle fly", type = "universal"},
        {cmd = "unfly", desc = "Disable fly", type = "universal"},
        {cmd = "noclip", desc = "Toggle noclip", type = "universal"},
        {cmd = "clip", desc = "Disable noclip", type = "universal"},
        {cmd = "speed [1-999]", desc = "Set walkspeed", type = "universal"},
        {cmd = "tptool", desc = "Toggle teleport tool", type = "universal"},
        {cmd = "tplist", desc = "Toggle TP list", type = "universal"},
        {cmd = "esp", desc = "Load ESP GUI", type = "universal"},
        {cmd = "espmm2", desc = "Toggle MM2 ESP", type = "mm2"},
        {cmd = "autogun", desc = "TP to dropped gun", type = "mm2"},
        {cmd = "help", desc = "Show this menu", type = "universal"},
    }
    for _, info in ipairs(commands) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 28)
        row.BackgroundTransparency = 1
        row.Parent = scroll
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.Position = UDim2.new(0, 5, 0.5, -6)
        if info.type == "universal" then
            dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            dot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        end
        dot.BorderSizePixel = 0
        dot.Parent = row
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local cmdLabel = Instance.new("TextLabel")
        cmdLabel.Size = UDim2.new(0, 100, 1, 0)
        cmdLabel.Position = UDim2.new(0, 22, 0, 0)
        cmdLabel.Text = info.cmd
        cmdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        cmdLabel.TextScaled = true
        cmdLabel.BackgroundTransparency = 1
        cmdLabel.Font = Enum.Font.GothamBold
        cmdLabel.Parent = row
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -130, 1, 0)
        descLabel.Position = UDim2.new(0, 125, 0, 0)
        descLabel.Text = info.desc
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        descLabel.TextScaled = true
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = row
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
end

local function handleCommand(cmd)
    cmd = cmd:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if cmd == "fly" then
        toggleFly()
        return
    end
    if cmd == "unfly" then
        if flying then
            stopFly()
            if flyGui then
                flyGui:Destroy()
                flyGui = nil
            end
        end
        return
    end
    if cmd == "noclip" then
        toggleNoclip()
        return
    end
    if cmd == "clip" then
        toggleClip()
        return
    end
    if cmd == "speed" then
        local num = tonumber(cmd:match("%d+"))
        if num then
            setSpeed(num)
        end
        return
    end
    if cmd == "tptool" then
        toggleTPTool()
        return
    end
    if cmd == "tplist" then
        toggleTPList()
        return
    end
    if cmd == "esp" then
        loadESP()
        return
    end
    if cmd == "espmm2" then
        toggleESP()
        return
    end
    if cmd == "autogun" then
        autoGun()
        return
    end
    if cmd == "help" then
        createHelpGUI()
        return
    end
    cmdbar.Text = ""
end

cmdbar.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local cmd = cmdbar.Text
        if cmd ~= "" then
            handleCommand(cmd)
        end
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
    if flying then
        setupFly()
    end
    if noclipActive then
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    if espEnabled then
        refreshESP()
    end
end)

print("XDXD's Commands Loaded!")
print("Commands: fly, unfly, noclip, clip, speed [1-999], tptool, tplist, esp, espmm2, autogun, help")
