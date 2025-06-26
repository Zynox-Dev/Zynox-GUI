-- Zynox UI Library - Complete Ultimate Version 4.0
-- Full-featured UI library with all components and enhancements

local ZynoxUI = {}
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

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
        Info = Color3.fromRGB(23, 162, 184),
        Shadow = Color3.fromRGB(0, 0, 0),
        TabActive = Color3.fromRGB(0, 120, 215),
        TabHover = Color3.fromRGB(45, 45, 55),
        TabInactive = Color3.fromRGB(40, 40, 48),
        TabBorder = Color3.fromRGB(60, 60, 70)
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
        Info = Color3.fromRGB(23, 162, 184),
        Shadow = Color3.fromRGB(0, 0, 0),
        TabActive = Color3.fromRGB(0, 120, 215),
        TabHover = Color3.fromRGB(230, 230, 235),
        TabInactive = Color3.fromRGB(255, 255, 255),
        TabBorder = Color3.fromRGB(200, 200, 210)
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
        Info = Color3.fromRGB(0, 255, 255),
        Shadow = Color3.fromRGB(255, 0, 255),
        TabActive = Color3.fromRGB(255, 0, 255),
        TabHover = Color3.fromRGB(40, 20, 40),
        TabInactive = Color3.fromRGB(25, 25, 35),
        TabBorder = Color3.fromRGB(100, 0, 100)
    },
    Ocean = {
        Primary = Color3.fromRGB(52, 152, 219),
        Secondary = Color3.fromRGB(26, 188, 156),
        Background = Color3.fromRGB(44, 62, 80),
        Surface = Color3.fromRGB(52, 73, 94),
        Sidebar = Color3.fromRGB(47, 68, 87),
        Text = Color3.fromRGB(236, 240, 241),
        TextSecondary = Color3.fromRGB(189, 195, 199),
        Accent = Color3.fromRGB(22, 160, 133),
        Success = Color3.fromRGB(39, 174, 96),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219),
        Shadow = Color3.fromRGB(0, 0, 0),
        TabActive = Color3.fromRGB(52, 152, 219),
        TabHover = Color3.fromRGB(57, 78, 99),
        TabInactive = Color3.fromRGB(52, 73, 94),
        TabBorder = Color3.fromRGB(72, 93, 114)
    },
    Sunset = {
        Primary = Color3.fromRGB(255, 107, 107),
        Secondary = Color3.fromRGB(255, 159, 67),
        Background = Color3.fromRGB(45, 52, 54),
        Surface = Color3.fromRGB(55, 63, 65),
        Sidebar = Color3.fromRGB(50, 57, 59),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(220, 221, 225),
        Accent = Color3.fromRGB(255, 118, 117),
        Success = Color3.fromRGB(85, 239, 196),
        Warning = Color3.fromRGB(255, 234, 167),
        Error = Color3.fromRGB(255, 107, 107),
        Info = Color3.fromRGB(116, 185, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        TabActive = Color3.fromRGB(255, 107, 107),
        TabHover = Color3.fromRGB(65, 73, 75),
        TabInactive = Color3.fromRGB(55, 63, 65),
        TabBorder = Color3.fromRGB(75, 83, 85)
    }
}

-- Sound System
local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    local self = setmetatable({}, SoundManager)
    self.sounds = {
        click = "rbxasset://sounds/electronicpingshort.wav",
        hover = "rbxasset://sounds/button-09.mp3",
        success = "rbxasset://sounds/impact_water.mp3",
        error = "rbxasset://sounds/impact_generic.mp3",
        notification = "rbxasset://sounds/notification.mp3"
    }
    self.enabled = true
    return self
end

function SoundManager:PlaySound(soundType, volume)
    if not self.enabled then return end
    
    volume = volume or 0.5
    local soundId = self.sounds[soundType]
    if not soundId then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = SoundService
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Background Animation System (Complete)
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
        for i = 2, #elementData do
            if elementData[i] and elementData[i].Cancel then
                elementData[i]:Cancel()
            end
        end
    end
    self.elements = {}
end

-- Notification System
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

    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

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

-- Progress Bar Component
local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar.new(parent, theme, options)
    local self = setmetatable({}, ProgressBar)
    options = options or {}
    
    self.parent = parent
    self.theme = theme
    self.value = options.value or 0
    self.maxValue = options.maxValue or 100
    self.showText = options.showText ~= false
    self.animated = options.animated ~= false
    
    self:_create()
    return self
end

function ProgressBar:_create()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(1, -20, 0, 25)
    self.frame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    self.frame.BorderSizePixel = 0
    self.frame.Parent = self.parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.frame
    
    self.fill = Instance.new("Frame")
    self.fill.Size = UDim2.new(0, 0, 1, 0)
    self.fill.BackgroundColor3 = self.theme.Primary
    self.fill.BorderSizePixel = 0
    self.fill.Parent = self.frame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 12)
    fillCorner.Parent = self.fill
    
    if self.showText then
        self.label = Instance.new("TextLabel")
        self.label.Size = UDim2.new(1, 0, 1, 0)
        self.label.BackgroundTransparency = 1
        self.label.Text = "0%"
        self.label.TextColor3 = self.theme.Text
        self.label.TextSize = 12
        self.label.Font = Enum.Font.GothamBold
        self.label.Parent = self.frame
    end
    
    self:UpdateValue(self.value)
end

function ProgressBar:UpdateValue(newValue)
    self.value = math.clamp(newValue, 0, self.maxValue)
    local percentage = self.value / self.maxValue
    
    if self.animated then
        TweenService:Create(self.fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(percentage, 0, 1, 0)
        }):Play()
    else
        self.fill.Size = UDim2.new(percentage, 0, 1, 0)
    end
    
    if self.showText and self.label then
        self.label.Text = math.floor(percentage * 100) .. "%"
    end
end

function ProgressBar:SetColor(color)
    self.fill.BackgroundColor3 = color
end

-- Dropdown Component
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, theme, options)
    local self = setmetatable({}, Dropdown)
    options = options or {}
    
    self.parent = parent
    self.theme = theme
    self.options = options.options or {"Option 1", "Option 2", "Option 3"}
    self.selectedIndex = options.selectedIndex or 1
    self.callback = options.callback
    self.isOpen = false
    
    self:_create()
    return self
end

function Dropdown:_create()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(1, -20, 0, 35)
    self.frame.BackgroundTransparency = 1
    self.frame.Parent = self.parent
    
    self.button = Instance.new("TextButton")
    self.button.Size = UDim2.new(1, 0, 1, 0)
    self.button.BackgroundColor3 = self.theme.Surface
    self.button.Text = self.options[self.selectedIndex] .. " ▼"
    self.button.TextColor3 = self.theme.Text
    self.button.TextSize = 14
    self.button.Font = Enum.Font.Gotham
    self.button.AutoButtonColor = false
    self.button.Parent = self.frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.button
    
    self.dropdown = Instance.new("Frame")
    self.dropdown.Size = UDim2.new(1, 0, 0, #self.options * 30)
    self.dropdown.Position = UDim2.new(0, 0, 1, 2)
    self.dropdown.BackgroundColor3 = self.theme.Surface
    self.dropdown.BorderSizePixel = 0
    self.dropdown.Visible = false
    self.dropdown.ZIndex = 10
    self.dropdown.Parent = self.frame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = self.dropdown
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = self.dropdown
    
    for i, option in ipairs(self.options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = self.theme.Surface
        optionButton.Text = option
        optionButton.TextColor3 = self.theme.Text
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.Gotham
        optionButton.AutoButtonColor = false
        optionButton.Parent = self.dropdown
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = self.theme.Primary
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = self.theme.Surface
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            self:SelectOption(i)
        end)
    end
    
    self.button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
end

function Dropdown:Toggle()
    self.isOpen = not self.isOpen
    self.dropdown.Visible = self.isOpen
    self.button.Text = self.options[self.selectedIndex] .. (self.isOpen and " ▲" or " ▼")
end

function Dropdown:SelectOption(index)
    self.selectedIndex = index
    self.button.Text = self.options[self.selectedIndex] .. " ▼"
    self:Toggle()
    
    if self.callback then
        self.callback(self.options[self.selectedIndex], index)
    end
end

-- Enhanced Tab System
local TabManager = {}
TabManager.__index = TabManager

function TabManager.new(parent, theme)
    local self = setmetatable({}, TabManager)
    self.parent = parent
    self.theme = theme
    self.tabs = {}
    self.currentTab = nil
    self.tabButtons = {}
    self.isAnimating = false
    
    self:_createTabSystem()
    return self
end

function TabManager:_createTabSystem()
    self.sidebar = Instance.new("Frame")
    self.sidebar.Name = "EnhancedSidebar"
    self.sidebar.Size = UDim2.new(0, 220, 1, -45)
    self.sidebar.Position = UDim2.new(0, 0, 0, 45)
    self.sidebar.BackgroundColor3 = self.theme.Sidebar
    self.sidebar.BorderSizePixel = 0
    self.sidebar.ZIndex = 2
    self.sidebar.Parent = self.parent
    
    local sidebarGradient = Instance.new("UIGradient")
    sidebarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.theme.Sidebar),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.max(0, self.theme.Sidebar.R * 255 - 10),
            math.max(0, self.theme.Sidebar.G * 255 - 10),
            math.max(0, self.theme.Sidebar.B * 255 - 10)
        ))
    })
    sidebarGradient.Rotation = 90
    sidebarGradient.Parent = self.sidebar
    
    local sidebarHeader = Instance.new("Frame")
    sidebarHeader.Name = "SidebarHeader"
    sidebarHeader.Size = UDim2.new(1, 0, 0, 50)
    sidebarHeader.BackgroundColor3 = self.theme.Surface
    sidebarHeader.BorderSizePixel = 0
    sidebarHeader.Parent = self.sidebar
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.theme.Primary),
        ColorSequenceKeypoint.new(1, self.theme.Secondary)
    })
    headerGradient.Rotation = 45
    headerGradient.Parent = sidebarHeader
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -20, 1, 0)
    headerText.Position = UDim2.new(0, 10, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "📑 Navigation"
    headerText.TextColor3 = self.theme.Text
    headerText.TextSize = 16
    headerText.Font = Enum.Font.GothamBold
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = sidebarHeader
    
    self.sidebarContainer = Instance.new("ScrollingFrame")
    self.sidebarContainer.Name = "TabContainer"
    self.sidebarContainer.Size = UDim2.new(1, 0, 1, -50)
    self.sidebarContainer.Position = UDim2.new(0, 0, 0, 50)
    self.sidebarContainer.BackgroundTransparency = 1
    self.sidebarContainer.ScrollBarThickness = 6
    self.sidebarContainer.ScrollBarImageColor3 = self.theme.Primary
    self.sidebarContainer.ScrollBarImageTransparency = 0.3
    self.sidebarContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.sidebarContainer.BorderSizePixel = 0
    self.sidebarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.sidebarContainer.Parent = self.sidebar
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = self.sidebarContainer
    
    local containerPadding = Instance.new("UIPadding")
    containerPadding.PaddingTop = UDim.new(0, 15)
    containerPadding.PaddingBottom = UDim.new(0, 15)
    containerPadding.PaddingLeft = UDim.new(0, 10)
    containerPadding.PaddingRight = UDim.new(0, 10)
    containerPadding.Parent = self.sidebarContainer
    
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContentContainer"
    self.tabContainer.Size = UDim2.new(1, -220, 1, -45)
    self.tabContainer.Position = UDim2.new(0, 220, 0, 45)
    self.tabContainer.BackgroundColor3 = self.theme.Background
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.ClipsDescendants = true
    self.tabContainer.ZIndex = 1
    self.tabContainer.Parent = self.parent
    
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(0, 2, 1, 0)
    separator.Position = UDim2.new(0, -2, 0, 0)
    separator.BackgroundColor3 = self.theme.TabBorder
    separator.BorderSizePixel = 0
    separator.Parent = self.tabContainer
    
    local separatorGradient = Instance.new("UIGradient")
    separatorGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.theme.Primary),
        ColorSequenceKeypoint.new(0.5, self.theme.TabBorder),
        ColorSequenceKeypoint.new(1, self.theme.Secondary)
    })
    separatorGradient.Rotation = 90
    separatorGradient.Parent = separator
end

function TabManager:CreateTab(name, icon, layoutOrder)
    local tab = {
        name = name,
        icon = icon or "📄",
        frame = nil,
        button = nil,
        elements = {},
        layoutOrder = layoutOrder or (#self.tabs + 1)
    }
    
    tab.frame = Instance.new("Frame")
    tab.frame.Name = name .. "TabContent"
    tab.frame.Size = UDim2.new(1, 0, 1, 0)
    tab.frame.BackgroundTransparency = 1
    tab.frame.Visible = false
    tab.frame.ZIndex = 1
    tab.frame.Parent = self.tabContainer
    
    local fadeFrame = Instance.new("Frame")
    fadeFrame.Name = "FadeFrame"
    fadeFrame.Size = UDim2.new(1, 0, 1, 0)
    fadeFrame.BackgroundColor3 = self.theme.Background
    fadeFrame.BackgroundTransparency = 1
    fadeFrame.BorderSizePixel = 0
    fadeFrame.ZIndex = 2
    fadeFrame.Parent = tab.frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ContentScroller"
    scrollFrame.Size = UDim2.new(1, -30, 1, -30)
    scrollFrame.Position = UDim2.new(0, 15, 0, 15)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = self.theme.Primary
    scrollFrame.ScrollBarImageTransparency = 0.2
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ZIndex = 1
    scrollFrame.Parent = tab.frame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.Parent = scrollFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 20)
    contentPadding.PaddingLeft = UDim.new(0, 5)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.Parent = scrollFrame
    
    tab.content = scrollFrame
    tab.fadeFrame = fadeFrame
    
    tab.button = self:_createEnhancedTabButton(tab)
    
    table.insert(self.tabs, tab)
    self.tabButtons[name] = tab.button
    
    if #self.tabs == 1 then
        task.spawn(function()
            task.wait(0.1)
            self:SwitchToTab(tab, false)
        end)
    end
    
    return tab
end

function TabManager:_createEnhancedTabButton(tab)
    local button = Instance.new("TextButton")
    button.Name = tab.name .. "TabButton"
    button.Size = UDim2.new(1, -20, 0, 50)
    button.BackgroundColor3 = self.theme.TabInactive
    button.Text = ""
    button.AutoButtonColor = false
    button.LayoutOrder = tab.layoutOrder
    button.ZIndex = 3
    button.Parent = self.sidebarContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.TabBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = button
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, 40, 1, 0)
    iconFrame.Position = UDim2.new(0, 0, 0, 0)
    iconFrame.BackgroundTransparency = 1
    iconFrame.Parent = button
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = tab.icon
    iconLabel.TextColor3 = self.theme.TextSecondary
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    iconLabel.Parent = iconFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -45, 1, 0)
    textLabel.Position = UDim2.new(0, 40, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = tab.name
    textLabel.TextColor3 = self.theme.TextSecondary
    textLabel.TextSize = 15
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel.Parent = button
    
    local activeIndicator = Instance.new("Frame")
    activeIndicator.Name = "ActiveIndicator"
    activeIndicator.Size = UDim2.new(0, 4, 0.6, 0)
    activeIndicator.Position = UDim2.new(0, -2, 0.2, 0)
    activeIndicator.BackgroundColor3 = self.theme.Primary
    activeIndicator.BorderSizePixel = 0
    activeIndicator.Visible = false
    activeIndicator.Parent = button
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = activeIndicator
    
    local glowFrame = Instance.new("Frame")
    glowFrame.Name = "GlowFrame"
    glowFrame.Size = UDim2.new(1, 4, 1, 4)
    glowFrame.Position = UDim2.new(0, -2, 0, -2)
    glowFrame.BackgroundColor3 = self.theme.Primary
    glowFrame.BackgroundTransparency = 1
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = 2
    glowFrame.Parent = button
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 12)
    glowCorner.Parent = glowFrame
    
    button.IconLabel = iconLabel
    button.TextLabel = textLabel
    button.ActiveIndicator = activeIndicator
    button.GlowFrame = glowFrame
    button.Stroke = stroke
    
    local isHovering = false
    local isActive = false
    
    button.MouseEnter:Connect(function()
        if self.isAnimating then return end
        isHovering = true
        
        if not isActive then
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = self.theme.TabHover
            }):Play()
            
            TweenService:Create(iconLabel, TweenInfo.new(0.2), {
                TextColor3 = self.theme.Text,
                TextSize = 22
            }):Play()
            
            TweenService:Create(textLabel, TweenInfo.new(0.2), {
                TextColor3 = self.theme.Text
            }):Play()
            
            TweenService:Create(stroke, TweenInfo.new(0.2), {
                Transparency = 0.3,
                Thickness = 2
            }):Play()
            
            TweenService:Create(glowFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.9
            }):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        isHovering = false
        
        if not isActive then
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = self.theme.TabInactive
            }):Play()
            
            TweenService:Create(iconLabel, TweenInfo.new(0.2), {
                TextColor3 = self.theme.TextSecondary,
                TextSize = 20
            }):Play()
            
            TweenService:Create(textLabel, TweenInfo.new(0.2), {
                TextColor3 = self.theme.TextSecondary
            }):Play()
            
            TweenService:Create(stroke, TweenInfo.new(0.2), {
                Transparency = 0.7,
                Thickness = 1
            }):Play()
            
            TweenService:Create(glowFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        if self.isAnimating then return end
        self:SwitchToTab(tab, true)
    end)
    
    button.SetActive = function(active)
        isActive = active
        if active then
            activeIndicator.Visible = true
            TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                BackgroundColor3 = self.theme.TabActive
            }):Play()
            
            TweenService:Create(iconLabel, TweenInfo.new(0.3), {
                TextColor3 = self.theme.Text,
                TextSize = 22
            }):Play()
            
            TweenService:Create(textLabel, TweenInfo.new(0.3), {
                TextColor3 = self.theme.Text
            }):Play()
            
            TweenService:Create(stroke, TweenInfo.new(0.3), {
                Color = self.theme.Primary,
                Transparency = 0,
                Thickness = 2
            }):Play()
            
            TweenService:Create(activeIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 4, 0.8, 0),
                Position = UDim2.new(0, -2, 0.1, 0)
            }):Play()
        else
            activeIndicator.Visible = false
            if not isHovering then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = self.theme.TabInactive
                }):Play()
                
                TweenService:Create(iconLabel, TweenInfo.new(0.2), {
                    TextColor3 = self.theme.TextSecondary,
                    TextSize = 20
                }):Play()
                
                TweenService:Create(textLabel, TweenInfo.new(0.2), {
                    TextColor3 = self.theme.TextSecondary
                }):Play()
                
                TweenService:Create(stroke, TweenInfo.new(0.2), {
                    Color = self.theme.TabBorder,
                    Transparency = 0.7,
                    Thickness = 1
                }):Play()
            end
        end
    end
    
    return button
end

function TabManager:SwitchToTab(targetTab, animate)
    if self.isAnimating or self.currentTab == targetTab then return end
    
    animate = animate ~= false
    self.isAnimating = animate
    
    local previousTab = self.currentTab
    
    if previousTab and previousTab.button then
        previousTab.button.SetActive(false)
    end
    
    if targetTab.button then
        targetTab.button.SetActive(true)
    end
    
    if animate and previousTab then
        local fadeOutTween = TweenService:Create(previousTab.fadeFrame, 
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundTransparency = 0}
        )
        
        fadeOutTween:Play()
        fadeOutTween.Completed:Connect(function()
            previousTab.frame.Visible = false
            targetTab.frame.Visible = true
            
            local fadeInTween = TweenService:Create(targetTab.fadeFrame, 
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {BackgroundTransparency = 1}
            )
            
            fadeInTween:Play()
            fadeInTween.Completed:Connect(function()
                self.isAnimating = false
            end)
        end)
    else
        if previousTab then
            previousTab.frame.Visible = false
        end
        targetTab.frame.Visible = true
        targetTab.fadeFrame.BackgroundTransparency = 1
        self.isAnimating = false
    end
    
    self.currentTab = targetTab
end

function TabManager:UpdateTheme(newTheme)
    self.theme = newTheme
    
    if self.sidebar then
        self.sidebar.BackgroundColor3 = newTheme.Sidebar
    end
    
    if self.tabContainer then
        self.tabContainer.BackgroundColor3 = newTheme.Background
    end
    
    for _, tab in pairs(self.tabs) do
        if tab.button then
            if tab == self.currentTab then
                tab.button.SetActive(true)
            else
                tab.button.SetActive(false)
            end
        end
    end
end

-- Main UI Class
local UI = {}
UI.__index = UI

function ZynoxUI.new(config)
    local self = setmetatable({}, UI)
    
    self.config = {
        title = config.title or "Zynox UI Ultimate",
        size = config.size or {1000, 700},
        theme = config.theme or "Dark",
        draggable = config.draggable ~= false,
        resizable = config.resizable or false,
        showWelcome = config.showWelcome ~= false,
        saveConfig = config.saveConfig ~= false,
        configName = config.configName or "ZynoxConfig",
        keybind = config.keybind or Enum.KeyCode.RightControl,
        mobileSupport = config.mobileSupport ~= false,
        notifications = config.notifications ~= false,
        backgroundAnimation = config.backgroundAnimation or "gradient",
        soundEffects = config.soundEffects ~= false
    }
    
    self.elements = {}
    self.isVisible = true
    self.savedConfig = {}
    self.backgroundAnimator = nil
    self.tabManager = nil
    
    if self.config.soundEffects then
        self.soundManager = SoundManager.new()
    end
    
    self:_createUI()
    self:_setupKeybind()
    self:_setupMobileSupport()
    
    if self.config.notifications then
        task.spawn(function()
            task.wait(0.1)
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
    local existing = game.CoreGui:FindFirstChild("ZynoxUI")
    if existing then existing:Destroy() end
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ZynoxUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.IgnoreGuiInset = true
    
    local success, err = pcall(function()
        self.screenGui.Parent = game.CoreGui
    end)
    
    if not success then
        self.screenGui.Parent = Player.PlayerGui
        warn("ZynoxUI: Using PlayerGui instead of CoreGui")
    end
    
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, self.config.size[1], 0, self.config.size[2])
    self.mainFrame.Position = UDim2.new(0.5, -self.config.size[1]/2, 0.5, -self.config.size[2]/2)
    self.mainFrame.BackgroundColor3 = Themes[self.config.theme].Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = self.mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[self.config.theme].Primary
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = self.mainFrame
    
    if self.config.backgroundAnimation ~= "none" then
        self.backgroundAnimator = BackgroundAnimator.new(
            self.mainFrame, 
            Themes[self.config.theme], 
            self.config.backgroundAnimation
        )
    end
    
    self:_createTopBar()
    
    self.tabManager = TabManager.new(self.mainFrame, Themes[self.config.theme])
    
    self:_setupDragging()
    self:_setupAnimations()
end

function UI:_createTopBar()
    self.topBar = Instance.new("Frame")
    self.topBar.Name = "TopBar"
    self.topBar.Size = UDim2.new(1, 0, 0, 45)
    self.topBar.BackgroundColor3 = Themes[self.config.theme].Surface
    self.topBar.BorderSizePixel = 0
    self.topBar.ZIndex = 5
    self.topBar.Parent = self.mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Themes[self.config.theme].Primary),
        ColorSequenceKeypoint.new(1, Themes[self.config.theme].Secondary)
    })
    gradient.Rotation = 45
    gradient.Parent = self.topBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 250, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.config.title .. " v4.0"
    title.TextColor3 = Themes[self.config.theme].Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = self.topBar
    
    self:_createWindowControls()
end

function UI:_createWindowControls()
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 140, 1, 0)
    controlsFrame.Position = UDim2.new(1, -140, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.ZIndex = 6
    controlsFrame.Parent = self.topBar
    
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 40, 0, 30)
    themeBtn.Position = UDim2.new(0, 5, 0.5, -15)
    themeBtn.BackgroundColor3 = Themes[self.config.theme].Surface
    themeBtn.Text = "🎨"
    themeBtn.TextColor3 = Themes[self.config.theme].Text
    themeBtn.TextSize = 16
    themeBtn.Font = Enum.Font.Gotham
    themeBtn.AutoButtonColor = false
    themeBtn.ZIndex = 7
    themeBtn.Parent = controlsFrame
    
    local themeBtnCorner = Instance.new("UICorner")
    themeBtnCorner.CornerRadius = UDim.new(0, 6)
    themeBtnCorner.Parent = themeBtn
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 40, 0, 30)
    minimizeBtn.Position = UDim2.new(0, 50, 0.5, -15)
    minimizeBtn.BackgroundColor3 = Themes[self.config.theme].Surface
    minimizeBtn.Text = "–"
    minimizeBtn.TextColor3 = Themes[self.config.theme].Text
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 7
    minimizeBtn.Parent = controlsFrame
    
    local minimizeBtnCorner = Instance.new("UICorner")
    minimizeBtnCorner.CornerRadius = UDim.new(0, 6)
    minimizeBtnCorner.Parent = minimizeBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 30)
    closeBtn.Position = UDim2.new(0, 95, 0.5, -15)
    closeBtn.BackgroundColor3 = Themes[self.config.theme].Surface
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Themes[self.config.theme].Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 7
    closeBtn.Parent = controlsFrame
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    themeBtn.MouseButton1Click:Connect(function()
        self:CycleTheme()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    self:_addHoverEffect(themeBtn, Themes[self.config.theme].Primary)
    self:_addHoverEffect(minimizeBtn, Themes[self.config.theme].Warning)
    self:_addHoverEffect(closeBtn, Themes[self.config.theme].Error)
end

-- Public Methods
function UI:CreateTab(name, icon)
    if not self.tabManager then
        warn("TabManager not initialized")
        return nil
    end
    
    return self.tabManager:CreateTab(name, icon)
end

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
    
    if options.gradient then
        local gradient = Instance.new("UIGradient")
        gradient.Color = options.gradientColors or ColorSequence.new({
            ColorSequenceKeypoint.new(0, Themes[self.config.theme].Primary),
            ColorSequenceKeypoint.new(1, Themes[self.config.theme].Secondary)
        })
        gradient.Rotation = options.gradientRotation or 0
        gradient.Parent = label
    end
    
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
    button.Size = UDim2.new(1, -20, 0, 45)
    button.BackgroundColor3 = Themes[self.config.theme].Surface
    button.Text = text
    button.TextColor3 = Themes[self.config.theme].Text
    button.TextSize = 15
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    button.Parent = tab.content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[self.config.theme].TabBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Themes[self.config.theme].Primary
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0,
            Thickness = 2
        }):Play()
        
        if self.config.soundEffects and self.soundManager then
            self.soundManager:PlaySound("hover", 0.3)
        end
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Themes[self.config.theme].Surface
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0.5,
            Thickness = 1
        }):Play()
    end)
    
    if callback then
        button.MouseButton1Click:Connect(function()
            if self.config.soundEffects and self.soundManager then
                self.soundManager:PlaySound("click", 0.5)
            end
            callback()
        end)
    end
    
    return button
end

function UI:AddToggle(tab, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Themes[self.config.theme].Text
    label.TextSize = 15
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 55, 0, 28)
    toggleButton.Position = UDim2.new(1, -55, 0.5, -14)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    toggleButton.Text = ""
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 14)
    toggleCorner.Parent = toggleButton
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 22, 0, 22)
    dot.Position = UDim2.new(0, 3, 0.5, -11)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0.5, 0)
    dotCorner.Parent = dot
    
    local isToggled = defaultValue or false
    
    local function updateToggle()
        local goalPos = isToggled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        local goalColor = isToggled and Themes[self.config.theme].Accent or Color3.fromRGB(50, 50, 58)
        
        TweenService:Create(toggleButton, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            BackgroundColor3 = goalColor
        }):Play()
        
        TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            Position = goalPos
        }):Play()
        
        if callback then callback(isToggled) end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
        
        if self.config.soundEffects and self.soundManager then
            self.soundManager:PlaySound("click", 0.4)
        end
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
    
    button.MouseButton1Down:Connect(function() 
        isDragging = true
        if self.config.soundEffects and self.soundManager then
            self.soundManager:PlaySound("click", 0.3)
        end
    end)
    
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

-- New Component Methods
function UI:AddProgressBar(tab, options)
    return ProgressBar.new(tab.content, Themes[self.config.theme], options)
end

function UI:AddDropdown(tab, options)
    return Dropdown.new(tab.content, Themes[self.config.theme], options)
end

-- Helper Methods
function UI:_addHoverEffect(button, hoverColor)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        if self.config.soundEffects and self.soundManager then
            self.soundManager:PlaySound("hover", 0.2)
        end
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
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
    self.mainFrame.Position = UDim2.new(0.5, -self.config.size[1]/2, 0.4, -self.config.size[2]/2)
    self.mainFrame.BackgroundTransparency = 1
    
    task.wait(0.1)
    TweenService:Create(self.mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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
    welcomeFrame.Size = UDim2.new(0, 350, 0, 100)
    welcomeFrame.Position = UDim2.new(0.5, -175, 0.4, -50)
    welcomeFrame.BackgroundColor3 = Themes[self.config.theme].Background
    welcomeFrame.BackgroundTransparency = 0.1
    welcomeFrame.BorderSizePixel = 0
    welcomeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    welcomeFrame.Parent = welcomeGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = welcomeFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[self.config.theme].Primary
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = welcomeFrame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -30, 1, -30)
    text.Position = UDim2.new(0, 15, 0, 15)
    text.BackgroundTransparency = 1
    text.Text = "🎉 Welcome to " .. self.config.title .. "!\nComplete Ultimate Edition v4.0"
    text.TextColor3 = Themes[self.config.theme].Text
    text.TextSize = 16
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = welcomeFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Themes[self.config.theme].Primary),
        ColorSequenceKeypoint.new(1, Themes[self.config.theme].Secondary)
    })
    gradient.Rotation = 45
    gradient.Parent = welcomeFrame
    
    task.wait(3)
    
    local fadeOut = TweenService:Create(welcomeFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1,
        Size = welcomeFrame.Size * 1.1
    })
    local textFade = TweenService:Create(text, TweenInfo.new(0.6), {TextTransparency = 1})
    local strokeFade = TweenService:Create(stroke, TweenInfo.new(0.6), {Transparency = 1})
    
    fadeOut:Play()
    textFade:Play()
    strokeFade:Play()
    
    fadeOut.Completed:Connect(function()
        welcomeGui:Destroy()
    end)
end

-- Enhanced Methods
function UI:CycleTheme()
    local themes = {"Dark", "Light", "Neon", "Ocean", "Sunset"}
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
    local newTheme = Themes[themeName]
    
    if self.tabManager then
        self.tabManager:UpdateTheme(newTheme)
    end
    
    if self.backgroundAnimator then
        self.backgroundAnimator:Destroy()
        if self.config.backgroundAnimation ~= "none" then
            self.backgroundAnimator = BackgroundAnimator.new(
                self.mainFrame, 
                newTheme, 
                self.config.backgroundAnimation
            )
        end
    end
    
    self.mainFrame.BackgroundColor3 = newTheme.Background
    
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
    
    local mobileToggle = Instance.new("TextButton")
    mobileToggle.Size = UDim2.new(0, 65, 0, 65)
    mobileToggle.Position = UDim2.new(1, -85, 1, -85)
    mobileToggle.BackgroundColor3 = Themes[self.config.theme].Primary
    mobileToggle.Text = "UI"
    mobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileToggle.TextSize = 22
    mobileToggle.Font = Enum.Font.GothamBold
    mobileToggle.AutoButtonColor = false
    mobileToggle.Parent = self.screenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0.5, 0)
    mobileCorner.Parent = mobileToggle
    
    local mobileStroke = Instance.new("UIStroke")
    mobileStroke.Color = Themes[self.config.theme].Secondary
    mobileStroke.Thickness = 3
    mobileStroke.Parent = mobileToggle
    
    mobileToggle.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    if UserInputService.KeyboardEnabled then
        mobileToggle.Visible = false
    end
end

-- Public Methods
function UI:Close()
    if self.backgroundAnimator then
        self.backgroundAnimator:Destroy()
    end
    
    local fadeOut = TweenService:Create(self.mainFrame, TweenInfo.new(0.4), {
        Position = self.mainFrame.Position + UDim2.new(0, 0, 0.1, 0),
        Size = self.mainFrame.Size * 0.9,
        BackgroundTransparency = 1
    })
    
    fadeOut:Play()
    fadeOut.Completed:Wait()
    self.screenGui:Destroy()
end

function UI:Toggle()
    local isMinimized = self.mainFrame.Size.Y.Offset <= 50
    
    if isMinimized then
        TweenService:Create(self.mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, self.config.size[1], 0, self.config.size[2])
        }):Play()
    else
        TweenService:Create(self.mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, self.config.size[1], 0, 45)
        }):Play()
    end
end

function UI:SaveConfig()
    local config = {
        theme = self.config.theme,
        size = self.config.size,
        position = {
            self.mainFrame.Position.X.Scale,
            self.mainFrame.Position.X.Offset,
            self.mainFrame.Position.Y.Scale,
            self.mainFrame.Position.Y.Offset
        }
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

-- Make BackgroundAnimator accessible for external use
ZynoxUI.BackgroundAnimator = BackgroundAnimator
ZynoxUI.Themes = Themes

return ZynoxUI
