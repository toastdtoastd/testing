local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MeteorUILib"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local function createBaseElement(config, parent, headerColor)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 24)
    button.Text = config.Text
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BackgroundTransparency = 0.3
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Code
    button.TextSize = 16
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent
    return button
end

local function createButton(config, parent, headerColor)
    local btn = createBaseElement(config, parent, headerColor)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = headerColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = headerColor}):Play()
        if config.Function then config.Function() end
        wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)

    return btn
end

local function createToggle(config, parent, headerColor)
    local state = config.State or false
    local btn = createBaseElement(config, parent, headerColor)
    btn.BackgroundColor3 = state and headerColor or Color3.fromRGB(40, 40, 40)

    btn.MouseEnter:Connect(function()
        if not state then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = headerColor}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not state then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and headerColor or Color3.fromRGB(40, 40, 40)
        if config.Function then config.Function(state) end
    end)

    return btn
end

local function createColorPicker(config, parent, headerColor)
    local btn = createBaseElement(config, parent, headerColor)
    local expanded = false
    local cycling = false
    local hue = 0

    local spacing = 45

    local expansion = Instance.new("Frame")
    expansion.Size = btn.Size
    expansion.Position = UDim2.new(0, btn.Size.X.Offset, 0, 0) -- placeholder
    expansion.BackgroundColor3 = headerColor
    expansion.BackgroundTransparency = 0.3
    expansion.BorderSizePixel = 0
    expansion.Visible = false
    expansion.Parent = btn

    btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        expansion.Position = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)
    end)

    local rBox = Instance.new("TextBox")
    local gBox = Instance.new("TextBox")
    local bBox = Instance.new("TextBox")
    local cycleToggle = Instance.new("TextButton")
    local boxes = {rBox, gBox, bBox}

    for i, box in ipairs(boxes) do
        box.Size = UDim2.new(0, 40, 1, 0)
        box.Position = UDim2.new(0, (i - 1) * spacing, 0, 0)
        box.PlaceholderText = ({"R", "G", "B"})[i]
        box.Text = ""
        box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        box.BackgroundTransparency = 0.3
        box.TextColor3 = Color3.new(1, 1, 1)
        box.Font = Enum.Font.Code
        box.TextSize = 16
        box.BorderSizePixel = 0
        box.Visible = true
        box.Parent = expansion

        box.FocusLost:Connect(function()
            local r = tonumber(rBox.Text) or 0
            local g = tonumber(gBox.Text) or 0
            local b = tonumber(bBox.Text) or 0
            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)
            if config.Function then
                config.Function(Color3.fromRGB(r, g, b))
            end
        end)
    end

    cycleToggle.Size = UDim2.new(0, 50, 1, 0)
    cycleToggle.Position = UDim2.new(0, (#boxes) * spacing, 0, 0)
    cycleToggle.Text = "Cycle"
    cycleToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    cycleToggle.BackgroundTransparency = 0.3
    cycleToggle.TextColor3 = Color3.new(1, 1, 1)
    cycleToggle.Font = Enum.Font.Code
    cycleToggle.TextSize = 16
    cycleToggle.BorderSizePixel = 0
    cycleToggle.Visible = true
    cycleToggle.Parent = expansion

    cycleToggle.MouseButton1Click:Connect(function()
        cycling = not cycling
        cycleToggle.BackgroundColor3 = cycling and headerColor or Color3.fromRGB(30, 30, 30)
    end)

    RunService.RenderStepped:Connect(function()
        if cycling then
            hue = (hue + 0.005) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
            rBox.Text = tostring(r)
            gBox.Text = tostring(g)
            bBox.Text = tostring(b)
            if config.Function then
                config.Function(color)
            end
        end
    end)

    btn.MouseEnter:Connect(function()
        if not expanded then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = headerColor}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if not expanded then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        expanded = not expanded
        expansion.Visible = expanded
        btn.BackgroundColor3 = expanded and headerColor or Color3.fromRGB(40, 40, 40)
    end)

    return btn
end

local function CreateTab(config)
    local color = Color3.fromRGB(unpack(config.Color))
    local pos = UDim2.new(0, config.Pos[1], 0, config.Pos[2])
    local width = config.Width or 200

    local container = Instance.new("Frame")
    container.Position = pos
    container.Size = UDim2.new(0, width, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = color
    header.BorderSizePixel = 0
    header.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = config.Text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 18
    label.Parent = header

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.new(0, 30, 1, 0)
    minimize.Position = UDim2.new(1, -30, 0, 0)
    minimize.Text = "▼"
    minimize.BackgroundTransparency = 1
    minimize.TextColor3 = Color3.new(0, 0, 0)
    minimize.Font = Enum.Font.Code
    minimize.TextSize = 18
    minimize.BorderSizePixel = 0
    minimize.AutoButtonColor = false
    minimize.Parent = header

    local body = Instance.new("Frame")
    body.Position = UDim2.new(0, 0, 0, 30)
    body.Size = UDim2.new(1, 0, 0, 0)
    body.BackgroundTransparency = 1
    body.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = body

    local minimized = false
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        body.Visible = not minimized
        minimize.Text = minimized and "▶" or "▼"
    end)

    local dragging, offset
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = Vector2.new(input.Position.X - container.Position.X.Offset, input.Position.Y - container.Position.Y.Offset)
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            container.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
        end
    end)

    local tab = {}

    function tab:AddButton(cfg)
        return createButton(cfg, body, color)
    end

    function tab:AddToggle(cfg)
        return createToggle(cfg, body, color)
    end

    function tab:AddColorPicker(cfg)
        return createColorPicker(cfg, body, color)
    end

    return tab
end

return {
    CreateTab = CreateTab
}
