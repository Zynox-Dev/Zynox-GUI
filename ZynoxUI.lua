-- Enhanced ZynoxUI Library v2.0
-- Features: Smooth drag, auto-sizing, mobile compatibility, responsive design

local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Device Detection
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function isTablet()
    return UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
end

-- Animation Settings
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local fastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local smoothTween = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Utility Functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createPadding(parent, padding)
    local pad = Instance.new("UIPadding")
    if typeof(padding) == "number" then
        pad.PaddingTop = UDim.new(0, padding)
        pad.PaddingBottom = UDim.new(0, padding)
        pad.PaddingLeft = UDim.new(0, padding)
        pad.PaddingRight = UDim.new(0, padding)
    else
        pad.PaddingTop = UDim.new(0, padding.Top or 0)
        pad.PaddingBottom = UDim.new(0, padding.Bottom or 0)
        pad.PaddingLeft = UDim.new(0, padding.Left or 0)
        pad.PaddingRight = UDim.new(0, padding.Right or 0)
    end
    pad.Parent = parent
    return pad
end

local function createStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Color3.fromRGB(60, 60, 70)
    stroke.Parent = parent
    return stroke
end

local function addHoverEffect(element, normalColor, hoverColor, pressedColor)
    local isPressed = false
    
    element.MouseEnter:Connect(function()
        if not isPressed then
            TweenService:Create(element, fastTween, {BackgroundColor3 = hoverColor}):Play()
        end
    end)
    
    element.MouseLeave:Connect(function()
        if not isPressed then
            TweenService:Create(element, fastTween, {BackgroundColor3 = normalColor}):Play()
        end
    end)
    
    if element:IsA("GuiButton") then
        element.MouseButton1Down:Connect(function()
            isPressed = true
            TweenService:Create(element, fastTween, {
                BackgroundColor3 = pressedColor or hoverColor,
                Size = element.Size - UDim2.new(0, 2, 0, 2)
            }):Play()
        end)
        
        element.MouseButton1Up:Connect(function()
            isPressed = false
            TweenService:Create(element, fastTween, {
                BackgroundColor3 = hoverColor,
                Size = element.Size + UDim2.new(0, 2, 0, 2)
            }):Play()
        end)
    end
end

local function addRippleEffect(element)
    element.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        ripple.Parent = element
        
        createCorner(ripple, 100)
        
        local maxSize = math.max(element.AbsoluteSize.X, element.AbsoluteSize.Y) * 2
        
        local expandTween = TweenService:Create(ripple, 
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, maxSize, 0, maxSize),
                BackgroundTransparency = 1
            }
        )
        
        expandTween:Play()
        expandTween.Completed:Connect(function()
            ripple:Destroy()
        end)
    end)
end

-- Smooth Drag System
local function makeDraggable(frame, dragHandle)
    local dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, mousePos, framePos
    
    -- Smooth drag with momentum
    local velocity = Vector2.new(0, 0)
    local lastPosition = Vector2.new(0, 0)
    local momentum = 0.85
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            lastPosition = input.Position
            velocity = Vector2.new(0, 0)
            
            -- Visual feedback
            TweenService:Create(frame, fastTween, {
                Size = frame.Size * 0.98
            }):Play()
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            velocity = (input.Position - lastPosition) * momentum
            lastPosition = input.Position
            
            local newPos = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
            
            -- Smooth position update
            TweenService:Create(frame, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Position = newPos}
            ):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                
                -- Reset visual feedback
                TweenService:Create(frame, fastTween, {
                    Size = frame.Size / 0.98
                }):Play()
                
                -- Apply momentum
                if velocity.Magnitude > 5 then
                    local momentumPos = UDim2.new(
                        frame.Position.X.Scale,
                        frame.Position.X.Offset + velocity.X * 0.3,
                        frame.Position.Y.Scale,
                        frame.Position.Y.Offset + velocity.Y * 0.3
                    )
                    
                    TweenService:Create(frame, 
                        TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {Position = momentumPos}
                    ):Play()
                end
            end
        end
    end)
end

-- Auto-sizing system
local function setupAutoSize(container, layout, padding)
    padding = padding or 20
    
    local function updateSize()
        local contentSize = layout.AbsoluteContentSize
        local newSize = UDim2.new(
            container.Size.X.Scale,
            math.max(container.Size.X.Offset, contentSize.X + padding),
            container.Size.Y.Scale,
            math.max(100, contentSize.Y + padding)
        )
        
        TweenService:Create(container, smoothTween, {Size = newSize}):Play()
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
    updateSize()
end

-- Responsive sizing based on device
local function getResponsiveSize(baseSize)
    local screenSize = workspace.CurrentCamera.ViewportSize
    local scaleFactor = 1
    
    if isMobile() then
        scaleFactor = math.min(screenSize.X / 400, screenSize.Y / 600) * 0.9
    elseif isTablet() then
        scaleFactor = math.min(screenSize.X / 600, screenSize.Y / 800) * 0.8
    else
        scaleFactor = math.min(screenSize.X / 800, screenSize.Y / 1000) * 0.7
    end
    
    return {
        math.floor(baseSize[1] * scaleFactor),
        math.floor(baseSize[2] * scaleFactor)
    }
end

-- Main Library
local Library = {}
Library.__index = Library

function Library:CreateWindow(config)
    local window = {}
    
    -- Default config with responsive sizing
    config = config or {}
    config.Title = config.Title or "ZynoxUI"
    config.Size = getResponsiveSize(config.Size or {350, 450})
    config.Theme = config.Theme or "Dark"
    config.Resizable = config.Resizable ~= false
    config.MinSize = config.MinSize or {250, 200}
    config.MaxSize = config.MaxSize or {800, 600}
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZynoxUI_" .. config.Title
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.CoreGui
    
    -- Main Frame with enhanced styling
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, config.Size[1], 0, config.Size[2])
    mainFrame.Position = UDim2.new(0.5, -config.Size[1]/2, 0.5, -config.Size[2]/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    
    createCorner(mainFrame, isMobile() and 16 or 12)
    createStroke(mainFrame, 1, Color3.fromRGB(40, 40, 50))
    
    -- Drop shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    createCorner(shadow, isMobile() and 16 or 12)
    
    -- Title Bar with gradient
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, isMobile() and 50 or 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    createCorner(titleBar, isMobile() and 16 or 12)
    
    -- Gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    }
    gradient.Rotation = 90
    gradient.Parent = titleBar
    
    -- Title Text with better positioning
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = isMobile() and 18 or 16
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Control buttons container
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Size = UDim2.new(0, 80, 1, -10)
    controlsFrame.Position = UDim2.new(1, -85, 0, 5)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 5)
    controlsLayout.Parent = controlsFrame
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, isMobile() and 35 or 30, 0, isMobile() and 35 or 30)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextSize = isMobile() and 20 or 18
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = controlsFrame
    
    createCorner(minimizeButton, 8)
    addHoverEffect(minimizeButton, Color3.fromRGB(100, 100, 120), Color3.fromRGB(120, 120, 140))
    addRippleEffect(minimizeButton)
    
    -- Close Button with enhanced styling
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, isMobile() and 35 or 30, 0, isMobile() and 35 or 30)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = isMobile() and 20 or 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = controlsFrame
    
    createCorner(closeButton, 8)
    addHoverEffect(closeButton, Color3.fromRGB(255, 75, 75), Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 50, 50))
    addRippleEffect(closeButton)
    
    -- Content Frame with auto-sizing
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -(titleBar.Size.Y.Offset + 15))
    contentFrame.Position = UDim2.new(0, 10, 0, titleBar.Size.Y.Offset + 5)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = isMobile() and 8 or 6
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    contentFrame.Parent = mainFrame
    
    -- Enhanced scrollbar styling
    contentFrame.ScrollBarImageTransparency = 0.3
    
    -- Layout with responsive padding
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, isMobile() and 12 or 10)
    layout.Parent = contentFrame
    
    createPadding(contentFrame, isMobile() and 8 : 5)
    
    -- Auto-update canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (isMobile() and 20 or 15))
    end)
    
    -- Make draggable with smooth drag
    makeDraggable(mainFrame, titleBar)
    
    -- Window state management
    local isMinimized = false
    local originalSize = mainFrame.Size
    
    -- Minimize functionality
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            TweenService:Create(mainFrame, smoothTween, {
                Size = UDim2.new(0, originalSize.X.Offset, 0, titleBar.Size.Y.Offset)
            }):Play()
            minimizeButton.Text = "+"
            contentFrame.Visible = false
        else
            TweenService:Create(mainFrame, smoothTween, {
                Size = originalSize
            }):Play()
            minimizeButton.Text = "−"
            contentFrame.Visible = true
        end
    end)
    
    -- Close functionality with animation
    closeButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainFrame, smoothTween, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        
        local shadowTween = TweenService:Create(shadow, smoothTween, {
            BackgroundTransparency = 1
        })
        
        closeTween:Play()
        shadowTween:Play()
        
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
    
    -- Window object with enhanced methods
    window.ScreenGui = screenGui
    window.MainFrame = mainFrame
    window.ContentFrame = contentFrame
    window.Layout = layout
    window.ElementCount = 0
    window.Config = config
    
    -- Enhanced Toggle with mobile optimization
    function window:CreateToggle(config)
        config = config or {}
        config.Name = config.Name or "Toggle"
        config.Default = config.Default or false
        config.Callback = config.Callback or function() end
        config.Description = config.Description
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "ToggleFrame"
        toggleFrame.Size = UDim2.new(1, 0, 0, config.Description and (isMobile() and 65 or 55) or (isMobile() and 50 or 45))
        toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.LayoutOrder = self.ElementCount
        toggleFrame.Parent = self.ContentFrame
        
        createCorner(toggleFrame, isMobile() and 12 or 8)
        createStroke(toggleFrame, 1, Color3.fromRGB(45, 45, 55))
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -80, config.Description and 0.6 or 1, 0)
        toggleLabel.Position = UDim2.new(0, 15, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = config.Name
        toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel.TextSize = isMobile() and 16 or 14
        toggleLabel.Font = Enum.Font.GothamBold
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.TextYAlignment = config.Description and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center
        toggleLabel.Parent = toggleFrame
        
        -- Description text
        if config.Description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, -80, 0.4, 0)
            descLabel.Position = UDim2.new(0, 15, 0.6, 0)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = config.Description
            descLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
            descLabel.TextSize = isMobile() and 13 or 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.TextYAlignment = Enum.TextYAlignment.Top
            descLabel.Parent = toggleFrame
        end
        
        -- Enhanced Toggle Switch
        local switchFrame = Instance.new("Frame")
        switchFrame.Size = UDim2.new(0, isMobile() and 55 or 50, 0, isMobile() and 28 or 25)
        switchFrame.Position = UDim2.new(1, -(isMobile() and 65 or 60), 0.5, -(isMobile() and 14 or 12.5))
        switchFrame.BackgroundColor3 = config.Default and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(60, 60, 70)
        switchFrame.BorderSizePixel = 0
        switchFrame.Parent = toggleFrame
        
        createCorner(switchFrame, isMobile() and 14 or 12.5)
        
        local switchButton = Instance.new("TextButton")
        switchButton.Size = UDim2.new(0, isMobile() and 22 or 20, 0, isMobile() and 22 or 20)
        switchButton.Position = config.Default and 
            UDim2.new(1, -(isMobile() and 25 or 23), 0, isMobile() and 3 or 2.5) or 
            UDim2.new(0, isMobile() and 3 or 2.5, 0, isMobile() and 3 or 2.5)
        switchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        switchButton.BorderSizePixel = 0
        switchButton.Text = ""
        switchButton.Parent = switchFrame
        
        createCorner(switchButton, isMobile() and 11 or 10)
        createStroke(switchButton, 1, Color3.fromRGB(200, 200, 210))
        
        local isToggled = config.Default
        
        -- Enhanced toggle animation
        local function updateToggle()
            local targetPos = isToggled and 
                UDim2.new(1, -(isMobile() and 25 or 23), 0, isMobile() and 3 or 2.5) or 
                UDim2.new(0, isMobile() and 3 or 2.5, 0, isMobile() and 3 or 2.5)
            local targetColor = isToggled and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(60, 60, 70)
            local buttonColor = isToggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 240, 245)
            
            TweenService:Create(switchButton, tweenInfo, {Position = targetPos, BackgroundColor3 = buttonColor}):Play()
            TweenService:Create(switchFrame, tweenInfo, {BackgroundColor3 = targetColor}):Play()
        end
        
        switchButton.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            updateToggle()
            config.Callback(isToggled)
        end)
        
        -- Touch-friendly click area
        switchFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                switchButton.MouseButton1Click:Fire()
            end
        end)
        
        addRippleEffect(switchButton)
        
        self.ElementCount = self.ElementCount + 1
        
        return {
            Toggle = function(state)
                if state ~= nil and state ~= isToggled then
                    isToggled = state
                    updateToggle()
                    config.Callback(isToggled)
                end
            end,
            GetState = function()
                return isToggled
            end
        }
    end
    
    -- Enhanced Slider with mobile optimization
    function window:CreateSlider(config)
        config = config or {}
        config.Name = config.Name or "Slider"
        config.Min = config.Min or 0
        config.Max = config.Max or 100
        config.Default = math.clamp(config.Default or config.Min, config.Min, config.Max)
        config.Increment = config.Increment or 1
        config.Callback = config.Callback or function() end
        config.Description = config.Description
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = "SliderFrame"
        sliderFrame.Size = UDim2.new(1, 0, 0, config.Description and (isMobile() and 75 or 65) or (isMobile() and 60 or 55))
        sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.LayoutOrder = self.ElementCount
        sliderFrame.Parent = self.ContentFrame
        
        createCorner(sliderFrame, isMobile() and 12 or 8)
        createStroke(sliderFrame, 1, Color3.fromRGB(45, 45, 55))
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(0.7, 0, config.Description and 0.4 or 0.5, 0)
        sliderLabel.Position = UDim2.new(0, 15, 0, 5)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = config.Name
        sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderLabel.TextSize = isMobile() and 16 or 14
        sliderLabel.Font = Enum.Font.GothamBold
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, -15, config.Description and 0.4 or 0.5, 0)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(config.Default)
        valueLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        valueLabel.TextSize = isMobile() and 16 or 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderFrame
        
        -- Description
        if config.Description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, -30, 0.3, 0)
            descLabel.Position = UDim2.new(0, 15, 0.4, 0)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = config.Description
            descLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
            descLabel.TextSize = isMobile() and 13 or 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = sliderFrame
        end
        
        -- Enhanced Slider Track
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Size = UDim2.new(1, -30, 0, isMobile() and 8 or 6)
        sliderTrack.Position = UDim2.new(0, 15, 1, -(isMobile() and 20 or 18))
        sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        sliderTrack.BorderSizePixel = 0
        sliderTrack.Parent = sliderFrame
        
        createCorner(sliderTrack, isMobile() and 4 or 3)
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderTrack
        
        createCorner(sliderFill, isMobile() and 4 or 3)
        
        local sliderKnob = Instance.new("TextButton")
        sliderKnob.Size = UDim2.new(0, isMobile() and 20 or 18, 0, isMobile() and 20 or 18)
        sliderKnob.Position = UDim2.new(0, -(isMobile() and 10 or 9), 0.5, -(isMobile() and 10 or 9))
        sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderKnob.BorderSizePixel = 0
        sliderKnob.Text = ""
        sliderKnob.Parent = sliderTrack
        
        createCorner(sliderKnob, isMobile() and 10 or 9)
        createStroke(sliderKnob, 2, Color3.fromRGB(100, 150, 255))
        
        local currentValue = config.Default
        local isDragging = false
        
        local function updateSlider()
            local percentage = (currentValue - config.Min) / (config.Max - config.Min)
            local fillSize = UDim2.new(percentage, 0, 1, 0)
            local knobPos = UDim2.new(percentage, -(isMobile() and 10 or 9), 0.5, -(isMobile() and 10 or 9))
            
            TweenService:Create(sliderFill, fastTween, {Size = fillSize}):Play()
            TweenService:Create(sliderKnob, fastTween, {Position = knobPos}):Play()
            
            valueLabel.Text = tostring(currentValue)
        end
        
        local function onSliderInput(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                
                -- Visual feedback
                TweenService:Create(sliderKnob, fastTween, {
                    Size = UDim2.new(0, (isMobile() and 20 or 18) * 1.2, 0, (isMobile() and 20 or 18) * 1.2)
                }):Play()
                
                local connection
                connection = UserInputService.InputChanged:Connect(function(input2)
                    if (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) and isDragging then
                        local mousePos = input2.Position.X
                        local trackPos = sliderTrack.AbsolutePosition.X
                        local trackSize = sliderTrack.AbsoluteSize.X
                        local relativePos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                        
                        local rawValue = config.Min + (config.Max - config.Min) * relativePos
                        currentValue = math.floor(rawValue / config.Increment + 0.5) * config.Increment
                        currentValue = math.clamp(currentValue, config.Min, config.Max)
                        
                        updateSlider()
                        config.Callback(currentValue)
                    end
                end)
                
                local releaseConnection
                releaseConnection = UserInputService.InputEnded:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                        isDragging = false
                        connection:Disconnect()
                        releaseConnection:Disconnect()
                        
                        -- Reset visual feedback
                        TweenService:Create(sliderKnob, fastTween, {
                            Size = UDim2.new(0, isMobile() and 20 or 18, 0, isMobile() and 20 or 18)
                        }):Play()
                    end
                end)
            end
        end
        
        sliderKnob.InputBegan:Connect(onSliderInput)
        sliderTrack.InputBegan:Connect(onSliderInput)
        
        updateSlider()
        self.ElementCount = self.ElementCount + 1
        
        return {
            SetValue = function(value)
                currentValue = math.clamp(value, config.Min, config.Max)
                updateSlider()
                config.Callback(currentValue)
            end,
            GetValue = function()
                return currentValue
            end
        }
    end
    
    -- Enhanced Button with better mobile support
    function window:CreateButton(config)
        config = config or {}
        config.Name = config.Name or "Button"
        config.Callback = config.Callback or function() end
        config.Description = config.Description
        config.Color = config.Color or Color3.fromRGB(100, 150, 255)
        
        local buttonFrame = Instance.new("TextButton")
        buttonFrame.Name = "ButtonFrame"
        buttonFrame.Size = UDim2.new(1, 0, 0, config.Description and (isMobile() and 60 or 50) or (isMobile() and 45 or 40))
        buttonFrame.BackgroundColor3 = config.Color
        buttonFrame.BorderSizePixel = 0
        buttonFrame.LayoutOrder = self.ElementCount
        buttonFrame.Text = ""
        buttonFrame.Parent = self.ContentFrame
        
        createCorner(buttonFrame, isMobile() and 12 or 8)
        createStroke(buttonFrame, 1, Color3.fromRGB(120, 170, 255))
        
        local buttonLabel = Instance.new("TextLabel")
        buttonLabel.Size = UDim2.new(1, -20, config.Description and 0.6 or 1, 0)
        buttonLabel.Position = UDim2.new(0, 10, 0, 0)
        buttonLabel.BackgroundTransparency = 1
        buttonLabel.Text = config.Name
        buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        buttonLabel.TextSize = isMobile() and 16 or 14
        buttonLabel.Font = Enum.Font.GothamBold
        buttonLabel.TextXAlignment = Enum.TextXAlignment.Center
        buttonLabel.TextYAlignment = config.Description and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center
        buttonLabel.Parent = buttonFrame
        
        if config.Description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, -20, 0.4, 0)
            descLabel.Position = UDim2.new(0, 10, 0.6, 0)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = config.Description
            descLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
            descLabel.TextSize = isMobile() and 13 or 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Center
            descLabel.TextYAlignment = Enum.TextYAlignment.Top
            descLabel.Parent = buttonFrame
        end
        
        local hoverColor = Color3.new(
            math.min(config.Color.R + 0.1, 1),
            math.min(config.Color.G + 0.1, 1),
            math.min(config.Color.B + 0.1, 1)
        )
        
        local pressedColor = Color3.new(
            math.max(config.Color.R - 0.1, 0),
            math.max(config.Color.G - 0.1, 0),
            math.max(config.Color.B - 0.1, 0)
        )
        
        addHoverEffect(buttonFrame, config.Color, hoverColor, pressedColor)
        addRippleEffect(buttonFrame)
        
        buttonFrame.MouseButton1Click:Connect(function()
            config.Callback()
        end)
        
        self.ElementCount = self.ElementCount + 1
        
        return {
            SetText = function(text)
                buttonLabel.Text = text
            end,
            SetColor = function(color)
                config.Color = color
                buttonFrame.BackgroundColor3 = color
            end
        }
    end
    
    return window
end

-- Export Library
return Library
