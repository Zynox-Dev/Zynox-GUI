-- Zynox UI Library - Complete Enhanced Version 3.0
-- Fixed version with all methods, Label element, and background animations

local ZynoxUI = {}
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- Enhanced Theme System
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(0, 120, 215),
        Secondary = Color3.fromRGB(0, 200, 255),
        Background = Color3.fromRGB(25, 25, 30),
        Surface = Color3.fromRGB(35, 35, 42),
        Sidebar = Color3.fromRGB(30, 30, 36),
        Text = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(0, 170, 255),
        Success = Color3.fromRGB(40, 167, 69),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(220, 53, 69),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        Primary = Color3.fromRGB(0, 120, 215),
        Secondary = Color3.fromRGB(0, 150, 255),
        Background = Color3.fromRGB(248, 249, 250),
        Surface = Color3.fromRGB(255, 255, 255),
        Sidebar = Color3.fromRGB(241, 243, 245),
        Text = Color3.fromRGB(33, 37, 41),
        TextSecondary = Color3.fromRGB(108, 117, 125),
        Accent = Color3.fromRGB(0, 123, 255),
        Success = Color3.fromRGB(40, 167, 69),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(220, 53, 69),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Neon = {
        Primary = Color3.fromRGB(255, 0, 255),
        Secondary = Color3.fromRGB(0, 255, 255),
        Background = Color3.fromRGB(10, 10, 15),
        Surface = Color3.fromRGB(20, 20, 30),
        Sidebar = Color3.fromRGB(15, 15, 25),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 255),
        Accent = Color3.fromRGB(255, 0, 128),
        Success = Color3.fromRGB(0, 255, 128),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 64),
        Shadow = Color3.fromRGB(255, 0, 255)
    }
}

-- Background Animation System
local BackgroundAnimator = {}
BackgroundAnimator.__index = BackgroundAnimator

function BackgroundAnimator.new(parent, theme, animationType)
    local self = setmetatable({}, BackgroundAnimator)
    self.parent = parent
    self.theme = theme
    self.animationType = animationType or "gradient"
    self.isActive = true
    self.elements = {}
    
    self:_createAnimation()
    return self
end

function BackgroundAnimator:_createAnimation()
    if self.animationType == "gradient" then
        self:_createGradientAnimation()
    elseif self.animationType == "particles" then
        self:_createParticleAnimation()
    elseif self.animationType == "geometric" then
        self:_createGeometricAnimation()
    elseif self.animationType == "waves" then
        self:_createWaveAnimation()
    end
end

function BackgroundAnimator:_createGradientAnimation()
    local gradientFrame = Instance.new("Frame")
    gradientFrame.Name = "AnimatedBackground"
    gradientFrame.Size = UDim2.new(1, 0, 1, 0)
    gradientFrame.Position = UDim2.new(0, 0, 0, 0)
    gradientFrame.BackgroundColor3 = self.theme.Background
    gradientFrame.BorderSizePixel = 0
    gradientFrame.ZIndex = -1
    gradientFrame.Parent = self.parent
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.theme.Primary),
        ColorSequenceKeypoint.new(0.5, self.theme.Background),
        ColorSequenceKeypoint.new(1, self.theme.Secondary)
    })
    gradient.Rotation = 0
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.5, 0.95),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    gradient.Parent = gradientFrame
    
    -- Animate gradient rotation and colors
    local rotationTween = TweenService:Create(gradient, 
        TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), 
        {Rotation = 360}
    )
    rotationTween:Play()
    
    table.insert(self.elements, {gradientFrame, rotationTween})
end

function BackgroundAnimator:_createParticleAnimation()
    for i = 1, 15 do
        local particle = Instance.new("Frame")
        particle.Name = "Particle" .. i
        particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = self.theme.Primary
        particle.BorderSizePixel = 0
        particle.BackgroundTransparency = 0.7
        particle.ZIndex = -1
        particle.Parent = self.parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = particle
        
        -- Floating animation
        local floatTween = TweenService:Create(particle,
            TweenInfo.new(math.random(3, 8), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {
                Position = particle.Position + UDim2.new(0, math.random(-50, 50), 0, math.random(-30, 30)),
                BackgroundTransparency = math.random(3, 9) / 10
            }
        )
        floatTween:Play()
        
        table.insert(self.elements, {particle, floatTween})
    end
end

function BackgroundAnimator:_createGeometricAnimation()
    for i = 1, 8 do
        local shape = Instance.new("Frame")
        shape.Name = "Shape" .. i
        shape.Size = UDim2.new(0, math.random(20, 60), 0, math.random(20, 60))
        shape.Position = UDim2.new(math.random(), 0, math.random(), 0)
        shape.BackgroundColor3 = i % 2 == 0 and self.theme.Primary or self.theme.Secondary
        shape.BorderSizePixel = 0
        shape.BackgroundTransparency = 0.85
        shape.Rotation = math.random(0, 360)
        shape.ZIndex = -1
        shape.Parent = self.parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, math.random(0, 15))
        corner.Parent = shape
        
        -- Rotation and movement animation
        local rotateTween = TweenService:Create(shape,
            TweenInfo.new(math.random(5, 12), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
            {Rotation = shape.Rotation + 360}
        )
        
        local moveTween = TweenService:Create(shape,
            TweenInfo.new(math.random(8, 15), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Position = UDim2.new(math.random(), 0, math.random(), 0)}
        )
        
        rotateTween:Play()
        moveTween:Play()
        
        table.insert(self.elements, {shape, rotateTween, moveTween})
    end
end

function BackgroundAnimator:_createWaveAnimation()
    local waveFrame = Instance.new("Frame")
    waveFrame.Name = "WaveBackground"
    waveFrame.Size = UDim2.new(1, 0, 1, 0)
    waveFrame.BackgroundTransparency = 1
    waveFrame.ZIndex = -1
    waveFrame.Parent = self.parent
    
    -- Create wave lines
    for i = 1, 5 do
        local wave = Instance.new("Frame")
        wave.Name = "Wave" .. i
        wave.Size = UDim2.new(1, 100, 0, 2)
        wave.Position = UDim2.new(0, -50, 0, i * 100)
        wave.BackgroundColor3 = self.theme.Primary
        wave.BorderSizePixel = 0
        wave.BackgroundTransparency = 0.8
        wave.Rotation = math.random(-5, 5)
        wave.Parent = waveFrame
        
        local gradient = Instance.new("UIGradient")
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        gradient.Parent = wave
        
        -- Wave movement
        local waveTween = TweenService:Create(wave,
            TweenInfo.new(math.random(4, 8), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {
                Position = wave.Position + UDim2.new(0, math.random(-30, 30), 0, math.random(-20, 20)),
                Rotation = wave.Rotation + math.random(-10, 10)
            }
        )
        waveTween:Play()
        
        table.insert(self.elements, {wave, waveTween})
    end
end

function BackgroundAnimator:Destroy()
    self.isActive = false
    for _, elementData in pairs(self.elements) do
        local element = elementData[1]
        if element and element.Parent then
            element:Destroy()
        end
        -- Stop tweens
        for i = 2, #elementData do
            if elementData[i] and elementData[i].Cancel then
                elementData[i]:Cancel()
            end
        end
    end
    self.elements = {}
end

-- Notification System (Fixed)
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new()
    local self = setmetatable({}, NotificationManager)
    self.notifications = {}
    self.container = nil
    self:_createContainer()
    return self
end

function NotificationManager:_createContainer()
    -- Wait for ScreenGui to exist
    repeat task.wait() until game.CoreGui:FindFirstChild("ZynoxUI")
    
    self.container = Instance.new("Frame")
    self.container.Name = "NotificationContainer"
    self.container.Size = UDim2.new(0, 300, 1, 0)
    self.container.Position = UDim2.new(1, -320, 0, 20)
    self.container.BackgroundTransparency = 1
    self.container.Parent = game.CoreGui:FindFirstChild("ZynoxUI")
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = self.container
end

function NotificationManager:Show(title, message, type, duration)
    if not self.container then return end
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 80)
    notification.BackgroundColor3 = type == "error" and Color3.fromRGB(220, 53, 69) or 
                                   type == "warning" and Color3.fromRGB(255, 193, 7) or
                                   type == "success" and Color3.fromRGB(40, 167, 69) or
                                   Color3.fromRGB(0, 120, 215)
    notification.BorderSizePixel = 0
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification.Parent = self.container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 45)
    messageLabel.Position = UDim2.new(0, 10, 0, 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Slide in animation
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    -- Auto dismiss
    task.delay(duration or 5, function()
        self:Dismiss(notification)
    end)
    
    table.insert(self.notifications, notification)
    return notification
end

function NotificationManager:Dismiss(notification)
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.3, function()
        if notification and notification.Parent then
            notification:Destroy()
        end
        for i, notif in ipairs(self.notifications) do
            if notif == notification then
                table.remove(self.notifications, i)
                break
            end
        end
    end)
end

-- Main UI Class
local UI = {}
UI.__index = UI

function ZynoxUI.new(config)
    local self = setmetatable({}, UI)
    
    -- Enhanced configuration
    self.config = {
        title = config.title or "Zynox UI",
        size = config.size or {850, 550},
        theme = config.theme or "Dark",
        draggable = config.draggable ~= false,
        resizable = config.resizable or false,
        showWelcome = config.showWelcome ~= false,
        saveConfig = config.saveConfig ~= false,
        configName = config.configName or "ZynoxConfig",
        keybind = config.keybind or Enum.KeyCode.RightControl,
        mobileSupport = config.mobileSupport ~= false,
        notifications = config.notifications ~= false,
        backgroundAnimation = config.backgroundAnimation or "gradient" -- "gradient", "particles", "geometric", "waves", "none"
    }
    
    self.tabs = {}
    self.currentTab = nil
    self.elements = {}
    self.isVisible = true
    self.savedConfig = {}
    self.backgroundAnimator = nil
    
    self:_createUI()
    self:_setupKeybind()
    self:_setupMobileSupport()
    
    -- Initialize notification manager after UI is created
    if self.config.notifications then
        task.spawn(function()
            task.wait(0.1) -- Wait for UI to be fully created
            self.notifications = NotificationManager.new()
        end)
    end
    
    if self.config.showWelcome then
        self:_showWelcome()
    end
    
    if self.config.saveConfig then
        self:LoadConfig()
    end
    
    return self
end

function UI:_createUI()
    -- Remove existing UI
    local existing = game.CoreGui:FindFirstChild("ZynoxUI")
    if existing then existing:Destroy() end
    
    -- Create ScreenGui in CoreGui for persistence
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ZynoxUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.IgnoreGuiInset = true
    
    -- Protected call for CoreGui access
    local success, err = pcall(function()
        self.screenGui.Parent = game.CoreGui
    end)
    
    if not success then
        self.screenGui.Parent = Player.PlayerGui
        warn("ZynoxUI: Using PlayerGui instead of CoreGui - " .. tostring(err))
    end
    
    -- Main Frame with enhanced styling
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, self.config.size[1], 0, self.config.size[2])
    self.mainFrame.Position = UDim2.new(0.5, -self.config.size[1]/2, 0.5, -self.config.size[2]/2)
    self.mainFrame.BackgroundColor3 = Themes[self.config.theme].Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui
    
    -- Enhanced styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[self.config.theme].Primary
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = self.mainFrame
    
    -- Create background animation
    if self.config.backgroundAnimation ~= "none" then
        self.backgroundAnimator = BackgroundAnimator.new(
            self.mainFrame, 
            Themes[self.config.theme], 
            self.config.backgroundAnimation
        )
    end
    
    self:_createTopBar()
    self:_createSidebar()
    self:_createTabContainer()
    self:_setupDragging()
    self:_setupAnimations()
end

function UI:_createTopBar()
    self.topBar = Instance.new("Frame")
    self.topBar.Name = "TopBar"
    self.topBar.Size = UDim2.new(1, 0, 0, 45)
    self.topBar.BackgroundColor3 = Themes[self.config.theme].Surface
    self.topBar.BorderSizePixel = 0
    self.topBar.Parent = self.mainFrame
    
    -- Enhanced gradient with animation
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Themes[self.config.theme].Primary),
        ColorSequenceKeypoint.new(1, Themes[self.config.theme].Secondary)
    })
    gradient.Rotation = 45
    gradient.Parent = self.topBar
    
    -- Animate gradient
    local gradientTween = TweenService:Create(gradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
        Rotation = 405
    })
    gradientTween:Play()
    
    -- Title with version info
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 250, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.config.title .. " v3.0"
    title.TextColor3 = Themes[self.config.theme].Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.topBar
    
    self:_createWindowControls()
end

function UI:_createWindowControls()
    -- Enhanced window controls
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 140, 1, 0)
    controlsFrame.Position = UDim2.new(1, -140, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = self.topBar
    
    -- Theme Toggle Button
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 40, 0, 30)
    themeBtn.Position = UDim2.new(0, 5, 0.5, -15)
    themeBtn.BackgroundColor3 = Themes[self.config.theme].Surface
    themeBtn.Text = "🎨"
    themeBtn.TextColor3 = Themes[self.config.theme].Text
    themeBtn.TextSize = 16
    themeBtn.Font = Enum.Font.Gotham
    themeBtn.AutoButtonColor = false
    themeBtn.Parent = controlsFrame
    
    local themeBtnCorner = Instance.new("UICorner")
    themeBtnCorner.CornerRadius = UDim.new(0, 6)
    themeBtnCorner.Parent = themeBtn
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 40, 0, 30)
    minimizeBtn.Position = UDim2.new(0, 50, 0.5, -15)
    minimizeBtn.BackgroundColor3 = Themes[self.config.theme].Surface
    minimizeBtn.Text = "–"
    minimizeBtn.TextColor3 = Themes[self.config.theme].Text
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = controlsFrame
    
    local minimizeBtnCorner = Instance.new("UICorner")
    minimizeBtnCorner.CornerRadius = UDim.new(0, 6)
    minimizeBtnCorner.Parent = minimizeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 30)
    closeBtn.Position = UDim2.new(0, 95, 0.5, -15)
    closeBtn.BackgroundColor3 = Themes[self.config.theme].Surface
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Themes[self.config.theme].Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = controlsFrame
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    -- Button functionality
    themeBtn.MouseButton1Click:Connect(function()
        self:CycleTheme()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    local isMinimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
        isMinimized = not isMinimized
    end)
    
    -- Enhanced hover effects
    self:_addHoverEffect(themeBtn, Themes[self.config.theme].Primary)
    self:_addHoverEffect(minimizeBtn, Themes[self.config.theme].Warning)
    self:_addHoverEffect(closeBtn, Themes[self.config.theme].Error)
end

function UI:_createSidebar()
    self.sidebar = Instance.new("Frame")
    self.sidebar.Name = "Sidebar"
    self.sidebar.Size = UDim2.new(0, 200, 1, -45)
    self.sidebar.Position = UDim2.new(0, 0, 0, 45)
    self.sidebar.BackgroundColor3 = Themes[self.config.theme].Sidebar
    self.sidebar.BorderSizePixel = 0
    self.sidebar.Parent = self.mainFrame
    
    -- Sidebar container
    self.sidebarContainer = Instance.new("ScrollingFrame")
    self.sidebarContainer.Size = UDim2.new(1, 0, 1, 0)
    self.sidebarContainer.BackgroundTransparency = 1
    self.sidebarContainer.ScrollBarThickness = 4
    self.sidebarContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    self.sidebarContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.sidebarContainer.BorderSizePixel = 0
    self.sidebarContainer.Parent = self.sidebar
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = self.sidebarContainer
end

function UI:_createTabContainer()
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContainer"
    self.tabContainer.Size = UDim2.new(1, -200, 1, -45)
    self.tabContainer.Position = UDim2.new(0, 200, 0, 45)
    self.tabContainer.BackgroundTransparency = 1
    self.tabContainer.ClipsDescendants = true
    self.tabContainer.Parent = self.mainFrame
end

-- Public Methods
function UI:CreateTab(name, icon)
    local tab = {
        name = name,
        icon = icon or "📄",
        frame = nil,
        button = nil,
        elements = {}
    }
    
    -- Create tab frame
    tab.frame = Instance.new("Frame")
    tab.frame.Name = name .. "Tab"
    tab.frame.Size = UDim2.new(1, 0, 1, 0)
    tab.frame.BackgroundTransparency = 1
    tab.frame.Visible = false
    tab.frame.Parent = self.tabContainer
    
    -- Create scrollable content
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -40, 1, -20)
    scrollFrame.Position = UDim2.new(0, 20, 0, 10)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Parent = tab.frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame
    
    tab.content = scrollFrame
    
    -- Create sidebar button
    tab.button = self:_createSidebarButton(name, icon, function()
        self:_switchTab(tab)
    end)
    
    table.insert(self.tabs, tab)
    
    -- Auto-select first tab
    if #self.tabs == 1 then
        self:_switchTab(tab)
    end
    
    return tab
end

-- NEW: Label Element
function UI:AddLabel(tab, text, options)
    options = options or {}
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, options.height or 30)
    label.BackgroundTransparency = options.background and 0 or 1
    label.BackgroundColor3 = options.backgroundColor or Themes[self.config.theme].Surface
    label.Text = text
    label.TextColor3 = options.textColor or Themes[self.config.theme].Text
    label.TextSize = options.textSize or 14
    label.Font = options.font or Enum.Font.Gotham
    label.TextXAlignment = options.alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = options.wrapped ~= false
    label.Parent = tab.content
    
    -- Add styling if background is enabled
    if options.background then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, options.cornerRadius or 6)
        corner.Parent = label
        
        if options.border then
            local stroke = Instance.new("UIStroke")
            stroke.Color = options.borderColor or Themes[self.config.theme].Primary
            stroke.Thickness = options.borderThickness or 1
            stroke.Parent = label
        end
    end
    
    -- Add gradient if specified
    if options.gradient then
        local gradient = Instance.new("UIGradient")
        gradient.Color = options.gradientColors or ColorSequence.new({
            ColorSequenceKeypoint.new(0, Themes[self.config.theme].Primary),
            ColorSequenceKeypoint.new(1, Themes[self.config.theme].Secondary)
        })
        gradient.Rotation = options.gradientRotation or 0
        gradient.Parent = label
    end
    
    -- Add animation if specified
    if options.animate then
        local animationType = options.animationType or "fade"
        
        if animationType == "fade" then
            label.TextTransparency = 1
            TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        elseif animationType == "slide" then
            local originalPos = label.Position
            label.Position = originalPos + UDim2.new(0, -50, 0, 0)
            TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = originalPos}):Play()
        elseif animationType == "typewriter" then
            local fullText = text
            label.Text = ""
            for i = 1, #fullText do
                task.wait(0.05)
                label.Text = string.sub(fullText, 1, i)
            end
        end
    end
    
    return {
        Set = function(newText) label.Text = newText end,
        Get = function() return label.Text end,
        SetColor = function(color) label.TextColor3 = color end,
        SetSize = function(size) label.TextSize = size end,
        Element = label
    }
end

function UI:AddButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = Themes[self.config.theme].Surface
    button.Text = text
    button.TextColor3 = Themes[self.config.theme].Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = tab.content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    self:_addHoverEffect(button, Themes[self.config.theme].Primary)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

function UI:AddToggle(tab, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Themes[self.config.theme].Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 24)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    toggleButton.Text = ""
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 20, 0, 20)
    dot.Position = UDim2.new(0, 2, 0.5, -10)
    dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    dot.BorderSizePixel = 0
    dot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0.5, 0)
    dotCorner.Parent = dot
    
    local isToggled = defaultValue or false
    
    local function updateToggle()
        local goalPos = isToggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local goalColor = isToggled and Themes[self.config.theme].Accent or Color3.fromRGB(50, 50, 58)
        
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = goalPos}):Play()
        
        if callback then callback(isToggled) end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
    end)
    
    updateToggle()
    return {Set = function(value) isToggled = value; updateToggle() end, Get = function() return isToggled end}
end

function UI:AddSlider(tab, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. (default or min)
    label.TextColor3 = Themes[self.config.theme].Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Themes[self.config.theme].Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 16, 0, 16)
    button.Position = UDim2.new(0.5, -8, 0.5, -8)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = ""
    button.Parent = track
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.5, 0)
    buttonCorner.Parent = button
    
    local currentValue = default or min
    local isDragging = false
    
    local function updateSlider(posX)
        local relativeX = math.clamp(posX - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local percentage = relativeX / track.AbsoluteSize.X
        
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        button.Position = UDim2.new(percentage, -8, 0.5, -8)
        
        currentValue = math.floor(min + (max - min) * percentage + 0.5)
        label.Text = text .. ": " .. currentValue
        
        if callback then callback(currentValue) end
    end
    
    button.MouseButton1Down:Connect(function() isDragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        if isDragging then
            local mouse = UserInputService:GetMouseLocation()
            updateSlider(mouse.X)
        end
    end)
    
    return {Set = function(value) updateSlider(track.AbsolutePosition.X + (track.AbsoluteSize.X * ((value - min) / (max - min)))) end, Get = function() return currentValue end}
end

-- Helper Methods (Fixed)
function UI:_createSidebarButton(text, icon, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    button.Text = "  " .. icon .. "  " .. text
    button.TextColor3 = Themes[self.config.theme].TextSecondary
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.Parent = self.sidebarContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    self:_addHoverEffect(button, Themes[self.config.theme].Primary)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

function UI:_addHoverEffect(button, hoverColor)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
end

function UI:_switchTab(tab)
    if self.currentTab then
        self.currentTab.frame.Visible = false
        TweenService:Create(self.currentTab.button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        }):Play()
    end
    
    tab.frame.Visible = true
    self.currentTab = tab
    
    TweenService:Create(tab.button, TweenInfo.new(0.2), {
        BackgroundColor3 = Themes[self.config.theme].Primary
    }):Play()
end

function UI:_setupDragging()
    if not self.config.draggable then return end
    
    local dragging = false
    local dragStart, startPos
    
    self.topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function UI:_setupAnimations()
    -- Entrance animation
    self.mainFrame.Position = UDim2.new(0.5, -self.config.size[1]/2, 0.4, -self.config.size[2]/2)
    self.mainFrame.BackgroundTransparency = 1
    
    task.wait(0.1)
    TweenService:Create(self.mainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -self.config.size[1]/2, 0.5, -self.config.size[2]/2),
        BackgroundTransparency = 0
    }):Play()
end

function UI:_showWelcome()
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeGui"
    welcomeGui.ResetOnSpawn = false
    welcomeGui.Parent = Player.PlayerGui
    
    local welcomeFrame = Instance.new("Frame")
    welcomeFrame.Size = UDim2.new(0, 300, 0, 80)
    welcomeFrame.Position = UDim2.new(0.5, -150, 0.4, -40)
    welcomeFrame.BackgroundColor3 = Themes[self.config.theme].Background
    welcomeFrame.BackgroundTransparency = 0.2
    welcomeFrame.BorderSizePixel = 0
    welcomeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    welcomeFrame.Parent = welcomeGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = welcomeFrame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = "Welcome to " .. self.config.title .. "!"
    text.TextColor3 = Themes[self.config.theme].Text
    text.TextSize = 24
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.Parent = welcomeFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Themes[self.config.theme].Primary),
        ColorSequenceKeypoint.new(1, Themes[self.config.theme].Secondary)
    })
    gradient.Rotation = 90
    gradient.Parent = welcomeFrame
    
    task.wait(2)
    
    local fadeOut = TweenService:Create(welcomeFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1,
        Size = welcomeFrame.Size + UDim2.new(0, 20, 0, 20)
    })
    local textFade = TweenService:Create(text, TweenInfo.new(0.5), {TextTransparency = 1})
    
    fadeOut:Play()
    textFade:Play()
    
    fadeOut.Completed:Connect(function()
        welcomeGui:Destroy()
    end)
end

-- Enhanced Methods
function UI:CycleTheme()
    local themes = {"Dark", "Light", "Neon"}
    local currentIndex = 1
    
    for i, theme in ipairs(themes) do
        if theme == self.config.theme then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #themes) + 1
    self:SetTheme(themes[nextIndex])
    
    if self.config.notifications and self.notifications then
        self.notifications:Show("Theme Changed", "Switched to " .. themes[nextIndex] .. " theme", "success", 2)
    end
end

function UI:SetTheme(themeName)
    if not Themes[themeName] then return end
    
    self.config.theme = themeName
    
    -- Update background animation with new theme
    if self.backgroundAnimator then
        self.backgroundAnimator:Destroy()
        if self.config.backgroundAnimation ~= "none" then
            self.backgroundAnimator = BackgroundAnimator.new(
                self.mainFrame, 
                Themes[self.config.theme], 
                self.config.backgroundAnimation
            )
        end
    end
    
    if self.config.saveConfig then
        self:SaveConfig()
    end
end

function UI:_setupKeybind()
    if not self.config.keybind then return end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == self.config.keybind then
            self:Toggle()
        end
    end)
end

function UI:_setupMobileSupport()
    if not self.config.mobileSupport then return end
    
    -- Add mobile toggle button
    local mobileToggle = Instance.new("TextButton")
    mobileToggle.Size = UDim2.new(0, 60, 0, 60)
    mobileToggle.Position = UDim2.new(1, -80, 1, -80)
    mobileToggle.BackgroundColor3 = Themes[self.config.theme].Primary
    mobileToggle.Text = "UI"
    mobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileToggle.TextSize = 20
    mobileToggle.Font = Enum.Font.GothamBold
    mobileToggle.AutoButtonColor = false
    mobileToggle.Parent = self.screenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0.5, 0)
    mobileCorner.Parent = mobileToggle
    
    mobileToggle.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hide on desktop
    if UserInputService.KeyboardEnabled then
        mobileToggle.Visible = false
    end
end

-- Public Methods
function UI:Close()
    if self.backgroundAnimator then
        self.backgroundAnimator:Destroy()
    end
    
    local fadeOut = TweenService:Create(self.mainFrame, TweenInfo.new(0.3), {
        Position = self.mainFrame.Position + UDim2.new(0, 0, 0.05, 0),
        Size = self.mainFrame.Size * 0.95,
        BackgroundTransparency = 1
    })
    
    fadeOut:Play()
    fadeOut.Completed:Wait()
    self.screenGui:Destroy()
end

function UI:Toggle()
    local isMinimized = self.mainFrame.Size.Y.Offset <= 50
    
    if isMinimized then
        TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, self.config.size[1], 0, self.config.size[2])
        }):Play()
    else
        TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, self.config.size[1], 0, 45)
        }):Play()
    end
end

-- Configuration System (Fixed)
function UI:SaveConfig()
    local config = {
        theme = self.config.theme,
        size = self.config.size,
        position = {
            self.mainFrame.Position.X.Scale,
            self.mainFrame.Position.X.Offset,
            self.mainFrame.Position.Y.Scale,
            self.mainFrame.Position.Y.Offset
        },
        elements = {}
    }
    
    self.savedConfig = config
    
    if self.config.notifications and self.notifications then
        self.notifications:Show("Config Saved", "Configuration saved successfully", "success", 2)
    end
end

function UI:LoadConfig()
    if not self.savedConfig or not next(self.savedConfig) then return end
    
    local config = self.savedConfig
    
    if config.theme then
        self:SetTheme(config.theme)
    end
    
    if config.position then
        self.mainFrame.Position = UDim2.new(
            config.position[1], config.position[2],
            config.position[3], config.position[4]
        )
    end
    
    if self.config.notifications and self.notifications then
        self.notifications:Show("Config Loaded", "Configuration loaded successfully", "success", 2)
    end
end

-- Notification shortcuts
function UI:Notify(title, message, type, duration)
    if self.config.notifications and self.notifications then
        return self.notifications:Show(title, message, type, duration)
    end
end

function UI:NotifySuccess(message, duration)
    return self:Notify("Success", message, "success", duration)
end

function UI:NotifyError(message, duration)
    return self:Notify("Error", message, "error", duration)
end

function UI:NotifyWarning(message, duration)
    return self:Notify("Warning", message, "warning", duration)
end

return ZynoxUI
