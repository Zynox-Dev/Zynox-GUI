-- ZynoxUI: Enhanced with Smooth Animations

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Animation presets
local tweenInfo = {
    quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    spring = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0.2)
}

-- Create main module
local ZynoxUI = {}

-- Utility function for rounded corners
local function applyRoundedCorners(instance, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(cornerRadius or 0.2, 0)
    corner.Parent = instance
    return corner
end

-- Utility function for drop shadow
local function applyDropShadow(instance)
    local shadow = Instance.new("UIStroke")
    shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Transparency = 0.7
    shadow.Thickness = 2
    shadow.Parent = instance
    return shadow
end

-- Function to animate window appearance
local function animateWindowOpen(window, duration)
    window.BackgroundTransparency = 1
    window.Visible = true
    
    -- Set initial state (slightly scaled down and transparent)
    window.Size = UDim2.new(0, window.Size.X.Offset, 0, 0)
    window.Position = UDim2.new(0.5, -window.Size.X.Offset/2, 0.5, 0)
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Create animations
    local fadeIn = TweenService:Create(window, tweenInfo.smooth, {
        BackgroundTransparency = 0.1
    })
    
    local sizeIn = TweenService:Create(window, tweenInfo.spring, {
        Size = UDim2.new(0, window.Size.X.Offset, 0, 300)
    })
    
    -- Play animations
    fadeIn:Play()
    sizeIn:Play()
    
    -- Add drop shadow after animation
    task.delay(0.2, function()
        applyDropShadow(window)
    end)
end

-- Function to create a main window using Instance.new
function ZynoxUI:CreateMainWindow(title)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZynoxUIScreenGui"
    screenGui.Parent = game:GetService("CoreGui")  -- Parent to CoreGui for visibility

    -- Create main window container
    local window = Instance.new("Frame")
    window.Name = title or "ZynoxUI"
    window.Size = UDim2.new(0, 400, 0, 300)
    window.Position = UDim2.new(0.5, -200, 0.5, -150)
    window.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    window.BorderSizePixel = 0
    window.Visible = false
    window.ClipsDescendants = true
    window.Parent = screenGui
    
    -- Add rounded corners
    applyRoundedCorners(window, 0.08)
    
    -- Add title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window
    
    -- Add title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "ZynoxUI"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.Parent = titleBar
    
    -- Add content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window
    
    -- Store content frame for easy access
    window.Content = contentFrame
    
    -- Apply window open animation
    animateWindowOpen(window, 0.5)

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
    -- Create toggle container
    local toggle = Instance.new("Frame")
    toggle.Name = label or "Toggle"
    toggle.Size = UDim2.new(0, 200, 0, 30)
    toggle.BackgroundTransparency = 1
    toggle.Parent = parent
    
    -- Add label
    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(1, -60, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Toggle"
    labelText.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.Parent = toggle
    
    -- Create toggle track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, 40, 0, 20)
    track.Position = UDim2.new(1, -40, 0.5, -10)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    track.BorderSizePixel = 0
    track.Parent = toggle
    applyRoundedCorners(track, 0.5)
    
    -- Create toggle thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0.5, -4, 1, -4)
    thumb.Position = UDim2.new(0, 2, 0, 2)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    applyRoundedCorners(thumb, 0.5)
    
    -- Add drop shadow to thumb
    local thumbShadow = applyDropShadow(thumb)
    thumbShadow.Thickness = 1
    thumbShadow.Transparency = 0.7
    
    -- State management
    local isToggled = initialState or false
    local isAnimating = false
    
    -- Function to update toggle state with animation
    local function updateToggleState(newState)
        if isAnimating then return end
        isAnimating = true
        
        isToggled = newState
        
        -- Animate thumb position
        local thumbTween = TweenService:Create(thumb, tweenInfo.quick, {
            Position = isToggled and UDim2.new(0.5, 2, 0, 2) or UDim2.new(0, 2, 0, 2)
        })
        
        -- Animate track color
        local trackTween = TweenService:Create(track, tweenInfo.quick, {
            BackgroundColor3 = isToggled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(60, 60, 70)
        })
        
        -- Play animations
        thumbTween:Play()
        trackTween:Play()
        
        -- Call callback after animation
        task.delay(0.15, function()
            if callback then
                callback(isToggled)
            end
            isAnimating = false
        end)
    end
    
    -- Click handling
    local function onToggle()
        updateToggleState(not isToggled)
    end
    
    -- Connect input events
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onToggle()
        end
    end)
    
    -- Set initial state
    updateToggleState(initialState or false)
    
    -- Add hover effect to the whole toggle
    local originalSize = track.Size
    
    track.MouseEnter:Connect(function()
        TweenService:Create(track, tweenInfo.quick, {
            Size = UDim2.new(0, originalSize.X.Offset * 1.1, 0, originalSize.Y.Offset * 1.1),
            Position = UDim2.new(1, -40 - (originalSize.X.Offset * 0.05), 0.5, -originalSize.Y.Offset * 0.55)
        }):Play()
    end)
    
    track.MouseLeave:Connect(function()
        TweenService:Create(track, tweenInfo.quick, {
            Size = originalSize,
            Position = UDim2.new(1, -40, 0.5, -originalSize.Y.Offset/2)
        }):Play()
    end)
    
    return toggle
end

-- Function to create a button using Instance.new
function ZynoxUI:CreateButton(parent, label, callback)
    -- Create button container
    local button = Instance.new("TextButton")
    button.Name = label or "Button"
    button.Size = UDim2.new(0, 140, 0, 36)
    button.Position = UDim2.new(0.5, -70, 0.5, -18)
    button.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = label or "Button"
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = parent
    
    -- Add rounded corners
    local corner = applyRoundedCorners(button, 0.2)
    
    -- Add gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 140, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 200))
    })
    gradient.Rotation = 90
    gradient.Parent = button
    
    -- Add drop shadow
    local shadow = applyDropShadow(button)
    shadow.Transparency = 0.5
    
    -- Hover effect
    local originalSize = button.Size
    local originalPos = button.Position
    local isHovering = false
    
    -- Hover animation
    local function updateHoverState(hovering)
        isHovering = hovering
        
        local targetSize = hovering 
            and UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 1.05, originalSize.Y.Scale, originalSize.Y.Offset * 1.05) 
            or originalSize
            
        local targetPos = hovering 
            and UDim2.new(originalPos.X.Scale, originalPos.X.Offset - (originalSize.X.Offset * 0.025), originalPos.Y.Scale, originalPos.Y.Offset - (originalSize.Y.Offset * 0.025))
            or originalPos
            
        local targetGradient = hovering 
            and ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 160, 250)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 120, 220))
            })
            or ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 140, 240)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 200))
            })
            
        TweenService:Create(button, tweenInfo.quick, {
            Size = targetSize,
            Position = targetPos
        }):Play()
        
        TweenService:Create(gradient, tweenInfo.quick, {
            Color = targetGradient
        }):Play()
        
        TweenService:Create(shadow, tweenInfo.quick, {
            Transparency = hovering and 0.3 or 0.5
        }):Play()
    end
    
    -- Connect hover events
    button.MouseEnter:Connect(function()
        updateHoverState(true)
    end)
    
    button.MouseLeave:Connect(function()
        updateHoverState(false)
    end)
    
    -- Click animation and handler
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, tweenInfo.quick, {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.95, originalSize.Y.Scale, originalSize.Y.Offset * 0.95)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, tweenInfo.spring, {
            Size = isHovering and UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 1.05, originalSize.Y.Scale, originalSize.Y.Offset * 1.05) or originalSize
        }):Play()
        
        -- Trigger callback
        if callback then
            callback()
        end
    end)
    
    -- Disable text scaling
    local textLabel = button:FindFirstChild("TextLabel") or Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = button.Text
    textLabel.TextColor3 = button.TextColor3
    textLabel.Font = button.Font
    textLabel.TextSize = button.TextSize
    textLabel.Parent = button
    button.Text = ""
    
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
    -- Create slider container
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = label or "Slider"
    sliderFrame.Size = UDim2.new(0, 200, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    -- Add label
    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Slider"
    labelText.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.Parent = sliderFrame
    
    -- Add value display
    local valueText = Instance.new("TextLabel")
    valueText.Name = "ValueText"
    valueText.Size = UDim2.new(0, 40, 0, 20)
    valueText.Position = UDim2.new(1, -40, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(initialValue or min)
    valueText.TextColor3 = Color3.fromRGB(180, 180, 180)
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Font = Enum.Font.Gotham
    valueText.TextSize = 12
    valueText.Parent = sliderFrame
    
    -- Create slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    applyRoundedCorners(track, 1)
    
    -- Create fill bar
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    fill.BorderSizePixel = 0
    fill.Parent = track
    applyRoundedCorners(fill, 1)
    
    -- Create thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 2
    thumb.Parent = track
    applyRoundedCorners(thumb, 1)
    
    -- Add drop shadow to thumb
    local thumbShadow = applyDropShadow(thumb)
    thumbShadow.Thickness = 1
    thumbShadow.Transparency = 0.7
    
    -- Initialize values
    local value = math.clamp(initialValue or min, min, max)
    local isDragging = false
    
    -- Function to update slider position and value
    local function updateSlider(input)
        if not isDragging then return end
        
        -- Calculate new value based on mouse position
        local relativeX = math.clamp(
            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        
        local newValue = math.floor(min + (max - min) * relativeX + 0.5) -- Round to nearest integer
        
        if newValue ~= value then
            value = newValue
            
            -- Update visual elements
            local fillWidth = (value - min) / (max - min)
            
            TweenService:Create(fill, tweenInfo.quick, {
                Size = UDim2.new(fillWidth, 0, 1, 0)
            }):Play()
            
            TweenService:Create(thumb, tweenInfo.quick, {
                Position = UDim2.new(fillWidth, 0, 0.5, 0)
            }):Play()
            
            -- Update value text
            valueText.Text = tostring(value)
            
            -- Call callback
            if callback then
                callback(value)
            end
        end
    end
    
    -- Input handling
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input)
            
            -- Highlight thumb
            TweenService:Create(thumb, tweenInfo.quick, {
                Size = UDim2.new(0, 14, 0, 14)
            }):Play()
        end
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            
            -- Return thumb to normal size
            TweenService:Create(thumb, tweenInfo.quick, {
                Size = UDim2.new(0, 16, 0, 16)
            }):Play()
        end
    end
    
    -- Connect input events
    track.InputBegan:Connect(onInputBegan)
    track.InputEnded:Connect(onInputEnded)
    track.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    -- Set initial value
    updateSlider({
        Position = Vector2.new(
            track.AbsolutePosition.X + track.AbsoluteSize.X * ((value - min) / (max - min)),
            track.AbsolutePosition.Y
        ),
        UserInputType = Enum.UserInputType.MouseMovement
    })
    
    -- Add hover effect to thumb
    local originalThumbSize = thumb.Size
    
    thumb.MouseEnter:Connect(function()
        if not isDragging then
            TweenService:Create(thumb, tweenInfo.quick, {
                Size = originalThumbSize * UDim2.new(1.3, 0, 1.3, 0)
            }):Play()
        end
    end)
    
    thumb.MouseLeave:Connect(function()
        if not isDragging then
            TweenService:Create(thumb, tweenInfo.quick, {
                Size = originalThumbSize
            }):Play()
        end
    end)
    
    return sliderFrame
end

return ZynoxUI
