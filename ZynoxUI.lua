-- ZynoxUI: Basic UI Structure

-- Create a main window
local ZynoxUI = {}

-- Function to apply a fade-in animation to the window
local function fadeIn(window, duration)
    window.BackgroundTransparency = 1
    window.Visible = true
    for i = 1, 0, -0.1 do
        window.BackgroundTransparency = i
        wait(duration / 10)
    end
end

-- Function to create a main window using Instance.new
function ZynoxUI:CreateMainWindow(title)
    local window = Instance.new("Frame")
    window.Name = title or "ZynoxUI"
    window.Size = UDim2.new(0, 400, 0, 300)
    window.Position = UDim2.new(0.5, -200, 0.5, -150)
    window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    window.BorderSizePixel = 0
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    window.Visible = false  -- Start as invisible

    -- Apply fade-in animation
    fadeIn(window, 1)  -- 1 second duration

    -- Make the window draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    window.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return window
end

-- Function to create a toggle using Instance.new
function ZynoxUI:CreateToggle(parent, label, initialState, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = label or "Toggle"
    toggle.Size = UDim2.new(0, 100, 0, 50)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Parent = parent

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 20, 0, 20)
    toggleButton.Position = UDim2.new(0, 5, 0.5, -10)
    toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggleButton.Text = ""
    toggleButton.Parent = toggle

    toggleButton.MouseButton1Click:Connect(function()
        initialState = not initialState
        toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(initialState)
    end)

    return toggle
end

-- Function to create a button using Instance.new
function ZynoxUI:CreateButton(parent, label, callback)
    local button = Instance.new("TextButton")
    button.Name = label or "Button"
    button.Size = UDim2.new(0, 100, 0, 50)
    button.Position = UDim2.new(0.5, -50, 0.5, -25)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = label or "Button"
    button.Parent = parent

    button.MouseButton1Click:Connect(function()
        callback()
    end)

    return button
end

-- Function to create a label using Instance.new
function ZynoxUI:CreateLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 50)
    label.Position = UDim2.new(0.5, -100, 0.5, -25)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text or "Label"
    label.Parent = parent

    return label
end

-- Function to create a slider using Instance.new
function ZynoxUI:CreateSlider(parent, label, min, max, initialValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 200, 0, 50)
    sliderFrame.Position = UDim2.new(0.5, -100, 0.5, -25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.Parent = parent

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Text = label or "Slider"
    sliderLabel.Parent = sliderFrame

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 10, 0.5, 0)
    sliderButton.Position = UDim2.new((initialValue - min) / (max - min), -5, 0.5, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderButton.Text = ""
    sliderButton.Parent = sliderFrame

    local function updateSlider(input)
        local delta = input.Position.X - sliderFrame.AbsolutePosition.X
        local newValue = math.clamp(delta / sliderFrame.AbsoluteSize.X, 0, 1) * (max - min) + min
        sliderButton.Position = UDim2.new((newValue - min) / (max - min), -5, 0.5, 0)
        callback(newValue)
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    input = nil
                end
            end)
        end
    end)

    sliderButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return sliderFrame
end

return ZynoxUI