local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MeteorUILib"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local function trackHover(button)
    local hovered = false
    button.MouseEnter:Connect(function() hovered = true end)
    button.MouseLeave:Connect(function() hovered = false end)
    return function() return hovered end
end

local function createBaseElement(config, parent, tab)
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
    button:SetAttribute("Active", false)
    return button
end

local function createButton(config, parent, tab)
    local btn = createBaseElement(config, parent, tab)
    local isHovered = trackHover(btn)

    RunService.RenderStepped:Connect(function()
        if not btn:GetAttribute("Active") then
            btn.BackgroundColor3 = isHovered() and tab._Color or Color3.fromRGB(40, 40, 40)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        btn:SetAttribute("Active", true)
        btn.BackgroundColor3 = tab._Color
        if config.Function then config.Function() end
        wait(0.1)
        btn:SetAttribute("Active", false)
    end)

    return btn
end

local function createToggle(config, parent, tab)
    local state = config.State or false
    local btn = createBaseElement(config, parent, tab)
    local isHovered = trackHover(btn)

    RunService.RenderStepped:Connect(function()
        btn.BackgroundColor3 = state and tab._Color or (isHovered() and tab._Color or Color3.fromRGB(40, 40, 40))
    end)

    btn.MouseButton1Click:Connect(function()
        state = not state
        if config.Function then config.Function(state) end
    end)

    return btn
end

-- Color Picker
local function createColorPicker(config, parent, tab)
    local btn = createBaseElement(config, parent, tab)
    local isHovered = trackHover(btn)
    local expanded, cycling, hue = false, false, 0

    local expansion = Instance.new("Frame")
    expansion.Size = btn.Size
    expansion.Position = UDim2.new(0, btn.Size.X.Offset, 0, 0)
    expansion.BackgroundColor3 = tab._Color
    expansion.BackgroundTransparency = 0.3
    expansion.BorderSizePixel = 0
    expansion.Visible = false
    expansion.Parent = btn

    btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        expansion.Position = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)
    end)

    local rBox, gBox, bBox = Instance.new("TextBox"), Instance.new("TextBox"), Instance.new("TextBox")
    local cycleToggle = Instance.new("TextButton")
    local boxes = {rBox, gBox, bBox}
    local spacing = 45

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
        box.Parent = expansion

        box.FocusLost:Connect(function()
            local r = tonumber(rBox.Text) or 0
            local g = tonumber(gBox.Text) or 0
            local b = tonumber(bBox.Text) or 0
            local newColor = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
            tab._Color = newColor
            tab._Header.BackgroundColor3 = newColor
            expansion.BackgroundColor3 = newColor
            btn.BackgroundColor3 = newColor
            cycleToggle.BackgroundColor3 = newColor
            if config.Function then config.Function(newColor) end
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
    cycleToggle.Parent = expansion

    cycleToggle.MouseButton1Click:Connect(function()
        cycling = not cycling
    end)

    RunService.RenderStepped:Connect(function()
        if cycling then
            hue = (hue + 0.005) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            tab._Color = color
            tab._Header.BackgroundColor3 = color
            expansion.BackgroundColor3 = color
            btn.BackgroundColor3 = color
            cycleToggle.BackgroundColor3 = color
            if config.Function then config.Function(color) end
        end
        if not expanded then
            btn.BackgroundColor3 = isHovered() and tab._Color or Color3.fromRGB(40, 40, 40)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        expanded = not expanded
        expansion.Visible = expanded
        btn.BackgroundColor3 = expanded and tab._Color or Color3.fromRGB(40, 40, 40)
    end)

    return btn
end

-- Slider
local function createSlider(config, parent, tab)
    local btn = createBaseElement(config, parent, tab)
    local isHovered = trackHover(btn)
    local expanded = false
    local value = config.Value or 0
    local precise = config.Precise == true
    local step = precise and 0.1 or 1

    local expansion = Instance.new("Frame")
    expansion.Size = btn.Size
    expansion.Position = UDim2.new(0, btn.Size.X.Offset, 0, 0)
    expansion.BackgroundColor3 = tab._Color
    expansion.BackgroundTransparency = 0.3
    expansion.BorderSizePixel = 0
    expansion.Visible = false
    expansion.Parent = btn

    btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        expansion.Position = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)
    end)

    local min = config.Min or 0
    local max = config.Max or 100

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 0.5, -3)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = expansion

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 16)
    valueLabel.Position = UDim2.new(1, 10, 0.5, -8)
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = sliderBar

    local dragging = false

    local function updateVisual()
        local percent = (value - min) / (max - min)
        local width = percent * sliderBar.AbsoluteSize.X
        fill.Size = UDim2.new(0, width, 1, 0)
        valueLabel.Text = precise and string.format("%.1f", value) or tostring(math.floor(value))
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)

    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = input.Position.X - sliderBar.AbsolutePosition.X
            local percent = math.clamp(rel / sliderBar.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percent
            value = math.floor(value / step + 0.5) * step
            updateVisual()
            if config.Function then config.Function(value) end
        end
    end)

    btn.MouseButton1Click:Connect(function()
        expanded = not expanded
        expansion.Visible = expanded
        updateVisual()
    end)

    RunService.RenderStepped:Connect(function()
        expansion.BackgroundColor3 = tab._Color
        btn.BackgroundColor3 = expanded and tab._Color or (isHovered() and tab._Color or Color3.fromRGB(40, 40, 40))
    end)

    return btn
end

-- SliderToggle
local function createSliderToggle(config, parent, tab)
    local state = config.State or false
    local value = config.Value or 0
    local precise = config.Precise == true
    local step = precise and 0.1 or 1

    local btn = createBaseElement(config, parent, tab)
    local isHovered = trackHover(btn)

    local expansion = Instance.new("Frame")
    expansion.Size = btn.Size
    expansion.Position = UDim2.new(0, btn.Size.X.Offset, 0, 0)
    expansion.BackgroundColor3 = tab._Color
    expansion.BackgroundTransparency = 0.3
    expansion.BorderSizePixel = 0
    expansion.Visible = false
    expansion.Parent = btn

    btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        expansion.Position = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)
    end)

    local min = config.Min or 0
    local max = config.Max or 100

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 0.5, -3)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = expansion

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 16)
    valueLabel.Position = UDim2.new(1, 10, 0.5, -8)
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = sliderBar

    local dragging = false

    local function updateVisual()
        local percent = (value - min) / (max - min)
        local width = percent * sliderBar.AbsoluteSize.X
        fill.Size = UDim2.new(0, width, 1, 0)
        valueLabel.Text = precise and string.format("%.1f", value) or tostring(math.floor(value))
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)

    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = input.Position.X - sliderBar.AbsolutePosition.X
            local percent = math.clamp(rel / sliderBar.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percent
            value = math.floor(value / step + 0.5) * step
            updateVisual()
            if config.Function then config.Function(state, value) end
        end
    end)

    btn.MouseButton1Click:Connect(function()
        state = not state
        if config.Function then config.Function(state, value) end
    end)

    btn.MouseButton2Click:Connect(function()
        expansion.Visible = not expansion.Visible
        updateVisual()
    end)

    RunService.RenderStepped:Connect(function()
        expansion.BackgroundColor3 = tab._Color
        btn.BackgroundColor3 = state and tab._Color or (isHovered() and tab._Color or Color3.fromRGB(40, 40, 40))
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
    tab._Header = header
    tab._Color = color

    function tab:AddButton(cfg)
        return createButton(cfg, body, tab)
    end

    function tab:AddToggle(cfg)
        return createToggle(cfg, body, tab)
    end

    function tab:AddColorPicker(cfg)
        return createColorPicker(cfg, body, tab)
    end

    function tab:AddSlider(cfg)
        return createSlider(cfg, body, tab)
    end

    function tab:AddSliderToggle(cfg)
        return createSliderToggle(cfg, body, tab)
    end

    return tab
end

return {
    CreateTab = CreateTab
}
