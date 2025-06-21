local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Main Library
local ZynoxClient = {
    Version = "1.0.0",
    Author = "Zynox",
    Windows = {},
    Notifications = {}
}

-- Enhanced Animation Settings
local Animations = {
    Speed = {
        Fast = 0.15,
        Normal = 0.25,
        Slow = 0.4
    },
    Easing = {
        Smooth = Enum.EasingStyle.Quint,
        Bounce = Enum.EasingStyle.Back,
        Elastic = Enum.EasingStyle.Elastic,
        Sharp = Enum.EasingStyle.Quad
    }
}

-- Modern Color Palette
local Theme = {
    Primary = Color3.fromRGB(138, 43, 226),
    Secondary = Color3.fromRGB(75, 0, 130),
    Accent = Color3.fromRGB(255, 20, 147),
    Background = Color3.fromRGB(18, 18, 25),
    Surface = Color3.fromRGB(25, 25, 35),
    SurfaceLight = Color3.fromRGB(35, 35, 45),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 170),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    Info = Color3.fromRGB(52, 152, 219)
}

-- Enhanced Utility Functions
local Utils = {}

function Utils.CreateTween(object, properties, duration, style, direction, delay)
    local tweenInfo = TweenInfo.new(
        duration or Animations.Speed.Normal,
        style or Animations.Easing.Smooth,
        direction or Enum.EasingDirection.Out,
        0,
        false,
        delay or 0
    )
    return TweenService:Create(object, tweenInfo, properties)
end

function Utils.AddCorners(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

function Utils.AddPadding(object, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or top or 0)
    padding.PaddingLeft = UDim.new(0, left or top or 0)
    padding.PaddingRight = UDim.new(0, right or left or top or 0)
    padding.Parent = object
    return padding
end

function Utils.AddGradient(object, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    }
    gradient.Rotation = rotation or 90
    gradient.Parent = object
    return gradient
end

function Utils.AddGlow(object, color, size)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, size or 20, 1, size or 20)
    glow.Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = color or Theme.Primary
    glow.ImageTransparency = 0.8
    glow.ZIndex = object.ZIndex - 1
    glow.Parent = object.Parent
    return glow
end

function Utils.CreateRipple(object, x, y)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.BackgroundColor3 = Theme.Accent
    ripple.BackgroundTransparency = 0.5
    ripple.ZIndex = object.ZIndex + 1
    ripple.Parent = object
    Utils.AddCorners(ripple, 100)
    
    local expand = Utils.CreateTween(ripple, {
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0, x - 100, 0, y - 100),
        BackgroundTransparency = 1
    }, 0.6, Animations.Easing.Sharp)
    
    expand:Play()
    expand.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Create Window Function
function ZynoxClient:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Name = config.Name or "Zynox Client",
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Elements = {}
    }
    
    -- Destroy existing window if exists
    local existing = playerGui:FindFirstChild("ZynoxClient_" .. Window.Name)
    if existing then
        existing:Destroy()
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZynoxClient_" .. Window.Name
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    -- Background Blur Effect
    local blurFrame = Instance.new("Frame")
    blurFrame.Name = "BlurBackground"
    blurFrame.Size = UDim2.new(1, 0, 1, 0)
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 0.7
    blurFrame.Visible = false
    blurFrame.Parent = screenGui
    
    -- Main Container
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0, 750, 0, 550)
    mainContainer.Position = UDim2.new(0.5, -375, 0.5, -275)
    mainContainer.BackgroundTransparency = 1
    mainContainer.ClipsDescendants = true
    mainContainer.Parent = screenGui
    
    -- Window Frame
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "WindowFrame"
    windowFrame.Size = UDim2.new(1, 0, 1, 0)
    windowFrame.BackgroundColor3 = Theme.Background
    windowFrame.BorderSizePixel = 0
    windowFrame.Parent = mainContainer
    Utils.AddCorners(windowFrame, 16)
    
    -- Window Glow
    Utils.AddGlow(windowFrame, Theme.Primary, 40)
    
    -- Background Gradient
    Utils.AddGradient(windowFrame, Theme.Background, Theme.Surface, 135)
    
    -- Animated Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = Theme.Surface
    header.BorderSizePixel = 0
    header.Parent = windowFrame
    Utils.AddCorners(header, 16)
    Utils.AddGradient(header, Theme.Primary, Theme.Secondary, 45)
    
    -- Animated Logo
    local logo = Instance.new("Frame")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 45, 0, 45)
    logo.Position = UDim2.new(0, 15, 0, 12.5)
    logo.BackgroundColor3 = Theme.Accent
    logo.Parent = header
    Utils.AddCorners(logo, 22.5)
    
    local logoIcon = Instance.new("TextLabel")
    logoIcon.Size = UDim2.new(1, 0, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "Z"
    logoIcon.TextColor3 = Color3.new(1, 1, 1)
    logoIcon.TextScaled = true
    logoIcon.Font = Enum.Font.GothamBold
    logoIcon.Parent = logo
    
    -- Pulse animation for logo
    local logoPulse = Utils.CreateTween(logo, {Size = UDim2.new(0, 50, 0, 50)}, 1, Animations.Easing.Smooth)
    local logoShrink = Utils.CreateTween(logo, {Size = UDim2.new(0, 45, 0, 45)}, 1, Animations.Easing.Smooth)
    
    local function animateLogo()
        logoPulse:Play()
        logoPulse.Completed:Connect(function()
            logoShrink:Play()
            logoShrink.Completed:Connect(animateLogo)
        end)
    end
    animateLogo()
    
    -- Window Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 300, 0, 25)
    title.Position = UDim2.new(0, 75, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = Window.Name
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(0, 300, 0, 20)
    subtitle.Position = UDim2.new(0, 75, 0, 37)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = config.LoadingSubtitle or "Enhanced UI Library"
    subtitle.TextColor3 = Theme.TextDim
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header
    
    -- Control Buttons
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Size = UDim2.new(0, 100, 0, 30)
    controlsFrame.Position = UDim2.new(1, -115, 0, 20)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0, 70, 0, 0)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = controlsFrame
    Utils.AddCorners(closeBtn, 15)
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(0, 35, 0, 0)
    minimizeBtn.BackgroundColor3 = Theme.Warning
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 16
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = controlsFrame
    Utils.AddCorners(minimizeBtn, 15)
    
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Size = UDim2.new(0, 30, 0, 30)
    settingsBtn.Position = UDim2.new(0, 0, 0, 0)
    settingsBtn.BackgroundColor3 = Theme.Info
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.new(1, 1, 1)
    settingsBtn.TextSize = 12
    settingsBtn.Font = Enum.Font.GothamBold
    settingsBtn.Parent = controlsFrame
    Utils.AddCorners(settingsBtn, 15)
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 200, 1, -70)
    sidebar.Position = UDim2.new(0, 0, 0, 70)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = windowFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 0)
    sidebarCorner.Parent = sidebar
    
    -- Tab Container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 6
    tabContainer.ScrollBarImageColor3 = Theme.Primary
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.Parent = sidebar
    Utils.AddPadding(tabContainer, 15)
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabContainer
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -200, 1, -70)
    contentArea.Position = UDim2.new(0, 200, 0, 70)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = windowFrame
    
    -- Window Animation Functions
    local function AnimateWindowIn()
        mainContainer.Size = UDim2.new(0, 0, 0, 0)
        mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        blurFrame.Visible = true
        
        local blurTween = Utils.CreateTween(blurFrame, {BackgroundTransparency = 0.3}, 0.4)
        local sizeTween = Utils.CreateTween(mainContainer, {
            Size = UDim2.new(0, 750, 0, 550),
            Position = UDim2.new(0.5, -375, 0.5, -275)
        }, 0.6, Animations.Easing.Bounce)
        
        blurTween:Play()
        sizeTween:Play()
        
        -- Animate logo rotation
        local logoRotate = Utils.CreateTween(logoIcon, {Rotation = 360}, 0.8, Animations.Easing.Smooth)
        logoRotate:Play()
        logoRotate.Completed:Connect(function()
            logoIcon.Rotation = 0
        end)
    end
    
    local function AnimateWindowOut()
        local blurTween = Utils.CreateTween(blurFrame, {BackgroundTransparency = 1}, 0.3)
        local sizeTween = Utils.CreateTween(mainContainer, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.4, Animations.Easing.Sharp)
        
        blurTween:Play()
        sizeTween:Play()
        sizeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end
    
    -- Button Events
    closeBtn.MouseButton1Click:Connect(AnimateWindowOut)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        local targetSize = Window.Visible and UDim2.new(0, 750, 0, 550) or UDim2.new(0, 750, 0, 70)
        local tween = Utils.CreateTween(mainContainer, {Size = targetSize}, 0.3)
        tween:Play()
    end)
    
    -- Dragging System
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
            
            local dragTween = Utils.CreateTween(mainContainer, {Size = UDim2.new(0, 740, 0, 540)}, 0.1)
            dragTween:Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainContainer.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            local releaseTween = Utils.CreateTween(mainContainer, {Size = UDim2.new(0, 750, 0, 550)}, 0.1)
            releaseTween:Play()
        end
    end)
    
    -- Create Tab Function
    function Window:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "New Tab"
        local tabIcon = config.Icon or "📄"
        
        local Tab = {
            Name = tabName,
            Elements = {},
            Visible = false
        }
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton_" .. tabName
        tabButton.Size = UDim2.new(1, 0, 0, 45)
        tabButton.BackgroundColor3 = Theme.SurfaceLight
        tabButton.Text = ""
        tabButton.Parent = tabContainer
        Utils.AddCorners(tabButton, 8)
        
        local tabIcon = Instance.new("TextLabel")
        tabIcon.Size = UDim2.new(0, 30, 0, 30)
        tabIcon.Position = UDim2.new(0, 10, 0, 7.5)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = config.Icon or "📄"
        tabIcon.TextColor3 = Theme.TextDim
        tabIcon.TextSize = 16
        tabIcon.Parent = tabButton
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -50, 1, 0)
        tabLabel.Position = UDim2.new(0, 45, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Theme.TextDim
        tabLabel.TextSize = 14
        tabLabel.Font = Enum.Font.Gotham
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "TabContent_" .. tabName
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 8
        tabContent.ScrollBarImageColor3 = Theme.Primary
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = contentArea
        Utils.AddPadding(tabContent, 20)
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 12)
        contentLayout.Parent = tabContent
        
        Tab.Frame = tabContent
        
        -- Tab Selection
        tabButton.MouseButton1Click:Connect(function(x, y)
            Utils.CreateRipple(tabButton, x, y)
            
            -- Hide all tabs
            for _, tab in pairs(Window.Tabs) do
                if tab.Frame then
                    tab.Frame.Visible = false
                    tab.Visible = false
                end
                
                local btn = tabContainer:FindFirstChild("TabButton_" .. tab.Name)
                if btn then
                    local iconLabel = btn:FindFirstChild("TextLabel")
                    local textLabel = btn:FindFirstChildOfClass("TextLabel")
                    if iconLabel then iconLabel.TextColor3 = Theme.TextDim end
                    if textLabel and textLabel ~= iconLabel then 
                        textLabel.TextColor3 = Theme.TextDim 
                    end
                    Utils.CreateTween(btn, {BackgroundColor3 = Theme.SurfaceLight}):Play()
                end
            end
            
            -- Show current tab
            tabContent.Visible = true
            Tab.Visible = true
            Window.CurrentTab = Tab
            
            tabIcon.TextColor3 = Theme.Accent
            tabLabel.TextColor3 = Theme.Text
            Utils.CreateTween(tabButton, {BackgroundColor3 = Theme.Primary}):Play()
        end)
        
        -- Hover effects
        tabButton.MouseEnter:Connect(function()
            if not Tab.Visible then
                Utils.CreateTween(tabButton, {BackgroundColor3 = Theme.Surface}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not Tab.Visible then
                Utils.CreateTween(tabButton, {BackgroundColor3 = Theme.SurfaceLight}):Play()
            end
        end)
        
        -- Tab Element Creation Functions
        function Tab:CreateButton(config)
            config = config or {}
            
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Size = UDim2.new(1, 0, 0, 45)
            button.BackgroundColor3 = Theme.SurfaceLight
            button.Text = ""
            button.Parent = tabContent
            Utils.AddCorners(button, 10)
            
            local buttonGlow = Utils.AddGlow(button, Theme.Primary, 10)
            buttonGlow.ImageTransparency = 1
            
            local buttonLabel = Instance.new("TextLabel")
            buttonLabel.Size = UDim2.new(1, -20, 1, 0)
            buttonLabel.Position = UDim2.new(0, 10, 0, 0)
            buttonLabel.BackgroundTransparency = 1
            buttonLabel.Text = config.Name or "Button"
            buttonLabel.TextColor3 = Theme.Text
            buttonLabel.TextSize = 14
            buttonLabel.Font = Enum.Font.Gotham
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
            buttonLabel.Parent = button
            
            button.MouseEnter:Connect(function()
                Utils.CreateTween(button, {BackgroundColor3 = Theme.Primary}):Play()
                Utils.CreateTween(buttonLabel, {TextColor3 = Color3.new(1, 1, 1)}):Play()
                Utils.CreateTween(buttonGlow, {ImageTransparency = 0.6}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                Utils.CreateTween(button, {BackgroundColor3 = Theme.SurfaceLight}):Play()
                Utils.CreateTween(buttonLabel, {TextColor3 = Theme.Text}):Play()
                Utils.CreateTween(buttonGlow, {ImageTransparency = 1}):Play()
            end)
            
            button.MouseButton1Click:Connect(function()
                local clickTween = Utils.CreateTween(button, {Size = UDim2.new(1, -4, 0, 43)}, 0.1)
                clickTween:Play()
                clickTween.Completed:Connect(function()
                    Utils.CreateTween(button, {Size = UDim2.new(1, 0, 0, 45)}, 0.1):Play()
                end)
                
                if config.Callback then
                    pcall(config.Callback)
                end
            end)
            
            return button
        end
        
        function Tab:CreateToggle(config)
            config = config or {}
            local isToggled = config.CurrentValue or false
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = "ToggleFrame"
            toggleFrame.Size = UDim2.new(1, 0, 0, 50)
            toggleFrame.BackgroundColor3 = Theme.SurfaceLight
            toggleFrame.Parent = tabContent
            Utils.AddCorners(toggleFrame, 10)
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -80, 1, 0)
            toggleLabel.Position = UDim2.new(0, 15, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = config.Name or "Toggle"
            toggleLabel.TextColor3 = Theme.Text
            toggleLabel.TextSize = 14
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleSwitch = Instance.new("TextButton")
            toggleSwitch.Size = UDim2.new(0, 50, 0, 25)
            toggleSwitch.Position = UDim2.new(1, -65, 0.5, -12.5)
            toggleSwitch.BackgroundColor3 = isToggled and Theme.Success or Theme.Background
            toggleSwitch.Text = ""
            toggleSwitch.Parent = toggleFrame
            Utils.AddCorners(toggleSwitch, 12.5)
            
            local toggleKnob = Instance.new("Frame")
            toggleKnob.Size = UDim2.new(0, 21, 0, 21)
            toggleKnob.Position = isToggled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
            toggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            toggleKnob.Parent = toggleSwitch
            Utils.AddCorners(toggleKnob, 10.5)
            
            local knobGlow = Utils.AddGlow(toggleKnob, Theme.Accent, 8)
            knobGlow.ImageTransparency = isToggled and 0.7 or 1
            
            toggleSwitch.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                
                local switchColor = isToggled and Theme.Success or Theme.Background
                local knobPos = isToggled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
                local glowTrans = isToggled and 0.7 or 1
                
                Utils.CreateTween(toggleSwitch, {BackgroundColor3 = switchColor}, 0.2):Play()
                Utils.CreateTween(toggleKnob, {Position = knobPos}, 0.2, Animations.Easing.Bounce):Play()
                Utils.CreateTween(knobGlow, {ImageTransparency = glowTrans}, 0.2):Play()
                
                if config.Callback then
                    pcall(config.Callback, isToggled)
                end
            end)
            
            return toggleFrame
        end
        
        function Tab:CreateSlider(config)
            config = config or {}
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local currentValue = default
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = "SliderFrame"
            sliderFrame.Size = UDim2.new(1, 0, 0, 60)
            sliderFrame.BackgroundColor3 = Theme.SurfaceLight
            sliderFrame.Parent = tabContent
            Utils.AddCorners(sliderFrame, 10)
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, -100, 0, 25)
            sliderLabel.Position = UDim2.new(0, 15, 0, 5)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = config.Name or "Slider"
            sliderLabel.TextColor3 = Theme.Text
            sliderLabel.TextSize = 14
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 80, 0, 25)
            valueLabel.Position = UDim2.new(1, -95, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(currentValue)
            valueLabel.TextColor3 = Theme.Accent
            valueLabel.TextSize = 14
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -30, 0, 6)
            sliderTrack.Position = UDim2.new(0, 15, 0, 38)
            sliderTrack.BackgroundColor3 = Theme.Background
            sliderTrack.Parent = sliderFrame
            Utils.AddCorners(sliderTrack, 3)
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Theme.Primary
            sliderFill.Parent = sliderTrack
            Utils.AddCorners(sliderFill, 3)
            Utils.AddGradient(sliderFill, Theme.Primary, Theme.Accent, 45)
            
            local sliderKnob = Instance.new("Frame")
            sliderKnob.Size = UDim2.new(0, 18, 0, 18)
            sliderKnob.Position = UDim2.new((currentValue - min) / (max - min), -9, 0.5, -9)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            sliderKnob.Parent = sliderTrack
            Utils.AddCorners(sliderKnob, 9)
            
            local knobGlow = Utils.AddGlow(sliderKnob, Theme.Primary, 12)
            knobGlow.ImageTransparency = 0.8
            
            local dragging = false
            
            local function updateSlider(input)
                local trackPos = sliderTrack.AbsolutePosition.X
                local trackSize = sliderTrack.AbsoluteSize.X
                local mouseX = input.Position.X
                local relativeX = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
                
                currentValue = math.floor(min + (max - min) * relativeX)
                local displayValue = config.Suffix and tostring(currentValue) .. config.Suffix or tostring(currentValue)
                valueLabel.Text = displayValue
                
                Utils.CreateTween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1):Play()
                Utils.CreateTween(sliderKnob, {Position = UDim2.new(relativeX, -9, 0.5, -9)}, 0.1):Play()
                
                if config.Callback then
                    pcall(config.Callback, currentValue)
                end
            end
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                    Utils.CreateTween(sliderKnob, {Size = UDim2.new(0, 22, 0, 22)}, 0.1):Play()
                    Utils.CreateTween(knobGlow, {ImageTransparency = 0.5}, 0.1):Play()
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                    dragging = false
                    Utils.CreateTween(sliderKnob, {Size = UDim2.new(0, 18, 0, 18)}, 0.1):Play()
                    Utils.CreateTween(knobGlow, {ImageTransparency = 0.8}, 0.1):Play()
                end
            end)
            
            -- Hover effects
            sliderFrame.MouseEnter:Connect(function()
                Utils.CreateTween(sliderFrame, {BackgroundColor3 = Theme.Surface}, 0.2):Play()
            end)
            
            sliderFrame.MouseLeave:Connect(function()
                if not dragging then
                    Utils.CreateTween(sliderFrame, {BackgroundColor3 = Theme.SurfaceLight}, 0.2):Play()
                end
            end)
            
            return sliderFrame
        end
        
        function Tab:CreateDropdown(config)
            config = config or {}
            local options = config.Options or {}
            local currentOption = config.Default or (options[1] and options[1] or "None")
            local isOpen = false
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 45)
            dropdownFrame.BackgroundColor3 = Theme.SurfaceLight
            dropdownFrame.Parent = tabContent
            Utils.AddCorners(dropdownFrame, 10)
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
            dropdownLabel.Position = UDim2.new(0, 15, 0, 0)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = config.Name or "Dropdown"
            dropdownLabel.TextColor3 = Theme.Text
            dropdownLabel.TextSize = 14
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Parent = dropdownFrame
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(0.5, -25, 0, 35)
            dropdownButton.Position = UDim2.new(0.5, 5, 0, 5)
            dropdownButton.BackgroundColor3 = Theme.Background
            dropdownButton.Text = ""
            dropdownButton.Parent = dropdownFrame
            Utils.AddCorners(dropdownButton, 8)
            
            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -30, 1, 0)
            selectedLabel.Position = UDim2.new(0, 10, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = currentOption
            selectedLabel.TextColor3 = Theme.Text
            selectedLabel.TextSize = 12
            selectedLabel.Font = Enum.Font.Gotham
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLabel.Parent = dropdownButton
            
            local dropdownArrow = Instance.new("TextLabel")
            dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
            dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
            dropdownArrow.BackgroundTransparency = 1
            dropdownArrow.Text = "▼"
            dropdownArrow.TextColor3 = Theme.TextDim
            dropdownArrow.TextSize = 10
            dropdownArrow.Font = Enum.Font.Gotham
            dropdownArrow.Parent = dropdownButton
            
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Name = "OptionsFrame"
            optionsFrame.Size = UDim2.new(0.5, -25, 0, 0)
            optionsFrame.Position = UDim2.new(0.5, 5, 1, 5)
            optionsFrame.BackgroundColor3 = Theme.Surface
            optionsFrame.Visible = false
            optionsFrame.ZIndex = 100
            optionsFrame.Parent = dropdownFrame
            Utils.AddCorners(optionsFrame, 8)
            
            local optionsList = Instance.new("UIListLayout")
            optionsList.SortOrder = Enum.SortOrder.LayoutOrder
            optionsList.Padding = UDim.new(0, 2)
            optionsList.Parent = optionsFrame
            
            local function createOption(optionText, index)
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.BackgroundColor3 = Theme.Surface
                optionButton.Text = ""
                optionButton.LayoutOrder = index
                optionButton.Parent = optionsFrame
                Utils.AddCorners(optionButton, 6)
                
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Size = UDim2.new(1, -20, 1, 0)
                optionLabel.Position = UDim2.new(0, 10, 0, 0)
                optionLabel.BackgroundTransparency = 1
                optionLabel.Text = optionText
                optionLabel.TextColor3 = Theme.Text
                optionLabel.TextSize = 12
                optionLabel.Font = Enum.Font.Gotham
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                optionLabel.Parent = optionButton
                
                optionButton.MouseEnter:Connect(function()
                    Utils.CreateTween(optionButton, {BackgroundColor3 = Theme.Primary}, 0.1):Play()
                    Utils.CreateTween(optionLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.1):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    Utils.CreateTween(optionButton, {BackgroundColor3 = Theme.Surface}, 0.1):Play()
                    Utils.CreateTween(optionLabel, {TextColor3 = Theme.Text}, 0.1):Play()
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    currentOption = optionText
                    selectedLabel.Text = optionText
                    
                    -- Close dropdown
                    isOpen = false
                    Utils.CreateTween(dropdownArrow, {Rotation = 0}, 0.2):Play()
                    Utils.CreateTween(optionsFrame, {Size = UDim2.new(0.5, -25, 0, 0)}, 0.2):Play()
                    
                    wait(0.2)
                    optionsFrame.Visible = false
                    
                    if config.Callback then
                        pcall(config.Callback, optionText)
                    end
                end)
            end
            
            -- Create option buttons
            for i, option in ipairs(options) do
                createOption(option, i)
            end
            
            -- Update options frame size
            local totalHeight = #options * 32 - 2
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    optionsFrame.Visible = true
                    Utils.CreateTween(dropdownArrow, {Rotation = 180}, 0.2):Play()
                    Utils.CreateTween(optionsFrame, {Size = UDim2.new(0.5, -25, 0, totalHeight)}, 0.2):Play()
                    Utils.CreateTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 45 + totalHeight + 5)}, 0.2):Play()
                else
                    Utils.CreateTween(dropdownArrow, {Rotation = 0}, 0.2):Play()
                    Utils.CreateTween(optionsFrame, {Size = UDim2.new(0.5, -25, 0, 0)}, 0.2):Play()
                    Utils.CreateTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.2):Play()
                    
                    wait(0.2)
                    optionsFrame.Visible = false
                end
            end)
            
            return dropdownFrame
        end
        
        function Tab:CreateTextbox(config)
            config = config or {}
            local currentText = config.Default or ""
            
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = "TextboxFrame"
            textboxFrame.Size = UDim2.new(1, 0, 0, 50)
            textboxFrame.BackgroundColor3 = Theme.SurfaceLight
            textboxFrame.Parent = tabContent
            Utils.AddCorners(textboxFrame, 10)
            
            local textboxLabel = Instance.new("TextLabel")
            textboxLabel.Size = UDim2.new(0.4, -10, 1, 0)
            textboxLabel.Position = UDim2.new(0, 15, 0, 0)
            textboxLabel.BackgroundTransparency = 1
            textboxLabel.Text = config.Name or "Textbox"
            textboxLabel.TextColor3 = Theme.Text
            textboxLabel.TextSize = 14
            textboxLabel.Font = Enum.Font.Gotham
            textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            textboxLabel.Parent = textboxFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(0.6, -25, 0, 35)
            textbox.Position = UDim2.new(0.4, 5, 0, 7.5)
            textbox.BackgroundColor3 = Theme.Background
            textbox.Text = currentText
            textbox.TextColor3 = Theme.Text
            textbox.TextSize = 12
            textbox.Font = Enum.Font.Gotham
            textbox.PlaceholderText = config.PlaceholderText or "Enter text..."
            textbox.PlaceholderColor3 = Theme.TextDim
            textbox.ClearButtonOnFocus = false
            textbox.Parent = textboxFrame
            Utils.AddCorners(textbox, 8)
            Utils.AddPadding(textbox, 0, 0, 10, 10)
            
            local textboxBorder = Instance.new("UIStroke")
            textboxBorder.Color = Theme.Background
            textboxBorder.Thickness = 2
            textboxBorder.Parent = textbox
            
            textbox.Focused:Connect(function()
                Utils.CreateTween(textboxBorder, {Color = Theme.Primary}, 0.2):Play()
                Utils.CreateTween(textbox, {BackgroundColor3 = Theme.Surface}, 0.2):Play()
            end)
            
            textbox.FocusLost:Connect(function(enterPressed)
                Utils.CreateTween(textboxBorder, {Color = Theme.Background}, 0.2):Play()
                Utils.CreateTween(textbox, {BackgroundColor3 = Theme.Background}, 0.2):Play()
                
                if enterPressed and config.Callback then
                    pcall(config.Callback, textbox.Text)
                end
            end)
            
            return textboxFrame
        end
        
        function Tab:CreateLabel(config)
            config = config or {}
            
            local labelFrame = Instance.new("Frame")
            labelFrame.Name = "LabelFrame"
            labelFrame.Size = UDim2.new(1, 0, 0, 35)
            labelFrame.BackgroundColor3 = Theme.SurfaceLight
            labelFrame.Parent = tabContent
            Utils.AddCorners(labelFrame, 10)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Text or "Label"
            label.TextColor3 = config.Color or Theme.Text
            label.TextSize = config.Size or 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = labelFrame
            
            return labelFrame
        end
        
        Window.Tabs[tabName] = Tab
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            tabButton.MouseButton1Click()
        end
        
        return Tab
    end
    
    -- Initialize window
    Window.Elements.MainContainer = mainContainer
    Window.Elements.ScreenGui = screenGui
    AnimateWindowIn()
    
    table.insert(ZynoxClient.Windows, Window)
    return Window
end

-- Notification System
function ZynoxClient:CreateNotification(config)
    config = config or {}
    
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "ZynoxNotification"
    notificationGui.ResetOnSpawn = false
    notificationGui.Parent = playerGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 350, 0, 80)
    notification.Position = UDim2.new(1, 20, 0, 20 + (#ZynoxClient.Notifications * 90))
    notification.BackgroundColor3 = Theme.Surface
    notification.Parent = notificationGui
    Utils.AddCorners(notification, 12)
    Utils.AddGlow(notification, Theme.Primary, 15)
    
    local notificationIcon = Instance.new("Frame")
    notificationIcon.Size = UDim2.new(0, 50, 0, 50)
    notificationIcon.Position = UDim2.new(0, 15, 0, 15)
    notificationIcon.BackgroundColor3 = config.Type == "Success" and Theme.Success 
        or config.Type == "Warning" and Theme.Warning 
        or config.Type == "Error" and Theme.Error 
        or Theme.Info
    notificationIcon.Parent = notification
    Utils.AddCorners(notificationIcon, 25)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = config.Type == "Success" and "✓" 
        or config.Type == "Warning" and "⚠" 
        or config.Type == "Error" and "✗" 
        or "ℹ"
    iconLabel.TextColor3 = Color3.new(1, 1, 1)
    iconLabel.TextSize = 24
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notificationIcon
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 25)
    titleLabel.Position = UDim2.new(0, 75, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Notification"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -80, 0, 20)
    messageLabel.Position = UDim2.new(0, 75, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = config.Message or "This is a notification"
    messageLabel.TextColor3 = Theme.TextDim
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Animation in
    local slideIn = Utils.CreateTween(notification, {Position = UDim2.new(1, -370, 0, 20 + (#ZynoxClient.Notifications * 90))}, 0.5, Animations.Easing.Bounce)
    slideIn:Play()
    
    table.insert(ZynoxClient.Notifications, notification)
    
    -- Auto dismiss after duration
    local duration = config.Duration or 5
    game:GetService("Debris"):AddItem(notificationGui, duration)
    
    spawn(function()
        wait(duration - 0.5)
        local slideOut = Utils.CreateTween(notification, {Position = UDim2.new(1, 20, 0, 20 + (#ZynoxClient.Notifications * 90))}, 0.3)
        slideOut:Play()
    end)
end

return ZynoxClient
