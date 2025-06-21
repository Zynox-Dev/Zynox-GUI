local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Enhanced Main Library with complete functionality
local ZynoxClient = {
    Version = "2.0.0",
    Author = "Zynox Enhanced",
    Windows = {},
    Notifications = {},
    ParticleEffects = {},
    Settings = {
        AnimationsEnabled = true,
        SoundsEnabled = true,
        ParticlesEnabled = true,
        AutoSave = true,
        Theme = "Default"
    },
    Callbacks = {},
    Connections = {},
    Cache = {},
    WelcomeSystem = {
        Enabled = true,
        ShowOnFirstLaunch = true,
        ShowOnEveryLaunch = false,
        Messages = {},
        CurrentMessage = nil
    },
    NotificationQueue = {},
    MaxNotifications = 5
}

-- Enhanced error handling system
local ErrorHandler = {}
function ErrorHandler.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[ZynoxClient Error]: " .. tostring(result))
        if ZynoxClient.CreateNotification then
            ZynoxClient:CreateNotification({
                Type = "Error",
                Title = "System Error",
                Message = "An error occurred. Check console for details.",
                Duration = 5
            })
        end
        return false, result
    end
    return true, result
end

function ErrorHandler.ValidateConfig(config, required, optional)
    config = config or {}
    local errors = {}
    
    -- Check required fields
    for _, field in ipairs(required or {}) do
        if config[field] == nil then
            table.insert(errors, "Missing required field: " .. field)
        end
    end
    
    -- Validate optional fields with defaults
    for field, default in pairs(optional or {}) do
        if config[field] == nil then
            config[field] = default
        end
    end
    
    if #errors > 0 then
        warn("[ZynoxClient Config Error]: " .. table.concat(errors, ", "))
        return false, errors
    end
    
    return true, config
end

-- Animation Settings with valid Roblox easing styles only
local Animations = {
    Speed = {
        Lightning = 0.08,
        Fast = 0.15,
        Normal = 0.25,
        Slow = 0.4,
        Cinematic = 0.8
    },
    Easing = {
        Smooth = Enum.EasingStyle.Quint,
        Bounce = Enum.EasingStyle.Back,
        Elastic = Enum.EasingStyle.Elastic,
        Sharp = Enum.EasingStyle.Quad,
        Sine = Enum.EasingStyle.Sine,
        Linear = Enum.EasingStyle.Linear,
        Cubic = Enum.EasingStyle.Cubic,
        Quart = Enum.EasingStyle.Quart
    },
    ActiveTweens = {},
    TweenPool = {}
}

-- Tween management system for better performance
function Animations.CleanupTweens()
    for i = #Animations.ActiveTweens, 1, -1 do
        local tween = Animations.ActiveTweens[i]
        if tween.PlaybackState == Enum.PlaybackState.Completed or 
           tween.PlaybackState == Enum.PlaybackState.Cancelled then
            table.remove(Animations.ActiveTweens, i)
        end
    end
end

-- Run cleanup every 5 seconds
spawn(function()
    while true do
        wait(5)
        Animations.CleanupTweens()
    end
end)

-- Enhanced Theme System with multiple themes
local Themes = {
    Default = {
        Primary = Color3.fromRGB(147, 51, 234),
        PrimaryLight = Color3.fromRGB(168, 85, 247),
        PrimaryDark = Color3.fromRGB(126, 34, 206),
        Secondary = Color3.fromRGB(79, 70, 229),
        SecondaryLight = Color3.fromRGB(99, 102, 241),
        Accent = Color3.fromRGB(236, 72, 153),
        AccentLight = Color3.fromRGB(244, 114, 182),
        AccentGlow = Color3.fromRGB(251, 207, 232),
        Background = Color3.fromRGB(15, 15, 23),
        BackgroundLight = Color3.fromRGB(20, 20, 30),
        Surface = Color3.fromRGB(25, 25, 35),
        SurfaceLight = Color3.fromRGB(35, 35, 45),
        SurfaceHover = Color3.fromRGB(45, 45, 55),
        Glass = Color3.fromRGB(255, 255, 255),
        GlassLight = Color3.fromRGB(240, 240, 255),
        Text = Color3.fromRGB(248, 250, 252),
        TextSecondary = Color3.fromRGB(203, 213, 225),
        TextDim = Color3.fromRGB(148, 163, 184),
        TextMuted = Color3.fromRGB(100, 116, 139),
        Success = Color3.fromRGB(34, 197, 94),
        SuccessLight = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(245, 158, 11),
        WarningLight = Color3.fromRGB(251, 191, 36),
        Error = Color3.fromRGB(239, 68, 68),
        ErrorLight = Color3.fromRGB(248, 113, 113),
        Info = Color3.fromRGB(59, 130, 246),
        InfoLight = Color3.fromRGB(96, 165, 250)
    },
    
    Ocean = {
        Primary = Color3.fromRGB(14, 165, 233),
        PrimaryLight = Color3.fromRGB(56, 189, 248),
        PrimaryDark = Color3.fromRGB(2, 132, 199),
        Secondary = Color3.fromRGB(6, 182, 212),
        SecondaryLight = Color3.fromRGB(34, 211, 238),
        Accent = Color3.fromRGB(168, 85, 247),
        AccentLight = Color3.fromRGB(196, 181, 253),
        AccentGlow = Color3.fromRGB(221, 214, 254),
        Background = Color3.fromRGB(8, 47, 73),
        BackgroundLight = Color3.fromRGB(12, 74, 110),
        Surface = Color3.fromRGB(15, 118, 110),
        SurfaceLight = Color3.fromRGB(20, 184, 166),
        SurfaceHover = Color3.fromRGB(45, 212, 191),
        Glass = Color3.fromRGB(255, 255, 255),
        GlassLight = Color3.fromRGB(240, 249, 255),
        Text = Color3.fromRGB(248, 250, 252),
        TextSecondary = Color3.fromRGB(203, 213, 225),
        TextDim = Color3.fromRGB(148, 163, 184),
        TextMuted = Color3.fromRGB(100, 116, 139),
        Success = Color3.fromRGB(34, 197, 94),
        SuccessLight = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(245, 158, 11),
        WarningLight = Color3.fromRGB(251, 191, 36),
        Error = Color3.fromRGB(239, 68, 68),
        ErrorLight = Color3.fromRGB(248, 113, 113),
        Info = Color3.fromRGB(59, 130, 246),
        InfoLight = Color3.fromRGB(96, 165, 250)
    },
    
    Sunset = {
        Primary = Color3.fromRGB(251, 146, 60),
        PrimaryLight = Color3.fromRGB(253, 186, 116),
        PrimaryDark = Color3.fromRGB(234, 88, 12),
        Secondary = Color3.fromRGB(239, 68, 68),
        SecondaryLight = Color3.fromRGB(248, 113, 113),
        Accent = Color3.fromRGB(236, 72, 153),
        AccentLight = Color3.fromRGB(244, 114, 182),
        AccentGlow = Color3.fromRGB(251, 207, 232),
        Background = Color3.fromRGB(69, 26, 3),
        BackgroundLight = Color3.fromRGB(92, 38, 5),
        Surface = Color3.fromRGB(120, 53, 15),
        SurfaceLight = Color3.fromRGB(154, 52, 18),
        SurfaceHover = Color3.fromRGB(194, 65, 12),
        Glass = Color3.fromRGB(255, 255, 255),
        GlassLight = Color3.fromRGB(255, 251, 235),
        Text = Color3.fromRGB(248, 250, 252),
        TextSecondary = Color3.fromRGB(203, 213, 225),
        TextDim = Color3.fromRGB(148, 163, 184),
        TextMuted = Color3.fromRGB(100, 116, 139),
        Success = Color3.fromRGB(34, 197, 94),
        SuccessLight = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(245, 158, 11),
        WarningLight = Color3.fromRGB(251, 191, 36),
        Error = Color3.fromRGB(239, 68, 68),
        ErrorLight = Color3.fromRGB(248, 113, 113),
        Info = Color3.fromRGB(59, 130, 246),
        InfoLight = Color3.fromRGB(96, 165, 250)
    }
}

-- Get current theme
function ZynoxClient:GetTheme()
    return Themes[self.Settings.Theme] or Themes.Default
end

-- Enhanced Utility Functions with better error handling
local Utils = {}

-- Enhanced tween creation with pooling and error handling
function Utils.CreateTween(object, properties, duration, style, direction, delay, repeatCount, reverses)
    if not object or not object.Parent then
        warn("[ZynoxClient]: Attempted to tween destroyed object")
        return nil
    end
    
    local success, tween = ErrorHandler.SafeCall(function()
        local tweenInfo = TweenInfo.new(
            duration or Animations.Speed.Normal,
            style or Animations.Easing.Smooth,
            direction or Enum.EasingDirection.Out,
            repeatCount or 0,
            reverses or false,
            delay or 0
        )
        return TweenService:Create(object, tweenInfo, properties)
    end)
    
    if success and tween then
        table.insert(Animations.ActiveTweens, tween)
        
        -- Auto-cleanup when completed
        tween.Completed:Connect(function()
            for i, activeTween in ipairs(Animations.ActiveTweens) do
                if activeTween == tween then
                    table.remove(Animations.ActiveTweens, i)
                    break
                end
            end
        end)
        
        return tween
    end
    
    return nil
end

-- Enhanced corner creation with validation
function Utils.AddCorners(object, radius, style)
    if not object or not object.Parent then
        return nil
    end
    
    local success, corner = ErrorHandler.SafeCall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, math.max(0, radius or 8))
        corner.Parent = object
        return corner
    end)
    
    return success and corner or nil
end

-- Enhanced padding with validation
function Utils.AddPadding(object, top, bottom, left, right)
    if not object or not object.Parent then
        return nil
    end
    
    local success, padding = ErrorHandler.SafeCall(function()
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, math.max(0, top or 0))
        padding.PaddingBottom = UDim.new(0, math.max(0, bottom or top or 0))
        padding.PaddingLeft = UDim.new(0, math.max(0, left or top or 0))
        padding.PaddingRight = UDim.new(0, math.max(0, right or left or top or 0))
        padding.Parent = object
        return padding
    end)
    
    return success and padding or nil
end

-- Enhanced gradient with better error handling
function Utils.AddGradient(object, colors, rotation, transparency)
    if not object or not object.Parent then
        return nil
    end
    
    local success, gradient = ErrorHandler.SafeCall(function()
        local gradient = Instance.new("UIGradient")
        
        if type(colors) == "table" and #colors >= 2 then
            if colors[1].Color then
                -- Multi-color gradient
                local colorSequence = {}
                for i, colorData in ipairs(colors) do
                    table.insert(colorSequence, ColorSequenceKeypoint.new(
                        colorData.Time or (i-1)/(#colors-1), 
                        colorData.Color
                    ))
                end
                gradient.Color = ColorSequence.new(colorSequence)
            else
                -- Simple two-color gradient
                gradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, colors[1]),
                    ColorSequenceKeypoint.new(1, colors[2])
                }
            end
        elseif typeof(colors) == "Color3" then
            gradient.Color = ColorSequence.new(colors)
        end
        
        gradient.Rotation = rotation or 90
        
        if transparency then
            gradient.Transparency = NumberSequence.new(transparency)
        end
        
        gradient.Parent = object
        return gradient
    end)
    
    return success and gradient or nil
end

-- Enhanced glow with performance optimization
function Utils.AddGlow(object, color, size, intensity)
    if not object or not object.Parent or not ZynoxClient.Settings.AnimationsEnabled then
        return nil
    end
    
    local success, glow = ErrorHandler.SafeCall(function()
        local glow = Instance.new("Frame")
        glow.Name = "Glow"
        glow.Size = UDim2.new(1, size or 20, 1, size or 20)
        glow.Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2)
        glow.BackgroundColor3 = color or ZynoxClient:GetTheme().Primary
        glow.BackgroundTransparency = intensity or 0.8
        glow.ZIndex = object.ZIndex - 1
        glow.Parent = object.Parent
        Utils.AddCorners(glow, (size or 20)/2)
        
        -- Add pulsing glow animation with cleanup
        if ZynoxClient.Settings.AnimationsEnabled then
            local glowPulse = Utils.CreateTween(glow, {
                BackgroundTransparency = (intensity or 0.8) - 0.2,
                Size = UDim2.new(1, (size or 20) + 5, 1, (size or 20) + 5)
            }, 2, Animations.Easing.Sine, Enum.EasingDirection.InOut, 0, -1, true)
            
            if glowPulse then
                glowPulse:Play()
            end
        end
        
        return glow
    end)
    
    return success and glow or nil
end

-- Enhanced glass morphism with better performance
function Utils.AddGlassMorphism(object, blur, transparency)
    if not object or not object.Parent then
        return nil
    end
    
    local success, blurFrame = ErrorHandler.SafeCall(function()
        local blurFrame = Instance.new("Frame")
        blurFrame.Size = UDim2.new(1, 0, 1, 0)
        blurFrame.BackgroundColor3 = ZynoxClient:GetTheme().Glass
        blurFrame.BackgroundTransparency = transparency or 0.9
        blurFrame.Parent = object
        blurFrame.ZIndex = object.ZIndex - 1
        Utils.AddCorners(blurFrame, 12)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = ZynoxClient:GetTheme().Glass
        stroke.Transparency = 0.8
        stroke.Thickness = 1
        stroke.Parent = object
        
        return blurFrame
    end)
    
    return success and blurFrame or nil
end

-- Enhanced ripple effect with better cleanup
function Utils.CreateRipple(object, x, y, color, size)
    if not object or not object.Parent or not ZynoxClient.Settings.AnimationsEnabled then
        return
    end
    
    ErrorHandler.SafeCall(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, x, 0, y)
        ripple.BackgroundColor3 = color or ZynoxClient:GetTheme().Accent
        ripple.BackgroundTransparency = 0.3
        ripple.ZIndex = object.ZIndex + 1
        ripple.Parent = object
        Utils.AddCorners(ripple, 100)
        
        local maxSize = size or 200
        local expand = Utils.CreateTween(ripple, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            Position = UDim2.new(0, x - maxSize/2, 0, y - maxSize/2),
            BackgroundTransparency = 1
        }, 0.6, Animations.Easing.Sharp)
        
        if expand then
            expand:Play()
            expand.Completed:Connect(function()
                if ripple and ripple.Parent then
                    ripple:Destroy()
                end
            end)
        else
            ripple:Destroy()
        end
    end)
end

-- Enhanced particle system with performance controls
function Utils.CreateParticles(parent, config)
    if not parent or not parent.Parent or not ZynoxClient.Settings.ParticlesEnabled then
        return
    end
    
    config = config or {}
    local particleCount = math.min(config.Count or 20, 50)
    local particleColor = config.Color or ZynoxClient:GetTheme().Accent
    local particleSize = math.max(1, config.Size or 3)
    local duration = math.max(0.5, config.Duration or 2)
    
    ErrorHandler.SafeCall(function()
        for i = 1, particleCount do
            local particle = Instance.new("Frame")
            particle.Size = UDim2.new(0, particleSize, 0, particleSize)
            particle.Position = UDim2.new(
                math.random(0, 100) / 100,
                math.random(-50, 50),
                math.random(0, 100) / 100,
                math.random(-50, 50)
            )
            particle.BackgroundColor3 = particleColor
            particle.BackgroundTransparency = math.random(30, 70) / 100
            particle.Parent = parent
            Utils.AddCorners(particle, particleSize/2)
            
            local moveX = math.random(-100, 100)
            local moveY = math.random(-100, 100)
            local particleTween = Utils.CreateTween(particle, {
                Position = UDim2.new(
                    particle.Position.X.Scale,
                    particle.Position.X.Offset + moveX,
                    particle.Position.Y.Scale,
                    particle.Position.Y.Offset + moveY
                ),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0)
            }, duration, Animations.Easing.Linear)
            
            if particleTween then
                particleTween:Play()
                particleTween.Completed:Connect(function()
                    if particle and particle.Parent then
                        particle:Destroy()
                    end
                end)
            else
                particle:Destroy()
            end
        end
    end)
end

-- Enhanced floating animation with cleanup
function Utils.AddFloatingAnimation(object, intensity, speed)
    if not object or not object.Parent or not ZynoxClient.Settings.AnimationsEnabled then
        return nil
    end
    
    local success, floatTween = ErrorHandler.SafeCall(function()
        intensity = math.max(1, intensity or 5)
        speed = math.max(1, speed or 3)
        
        local originalPos = object.Position
        local floatUp = Utils.CreateTween(object, {
            Position = UDim2.new(
                originalPos.X.Scale,
                originalPos.X.Offset,
                originalPos.Y.Scale,
                originalPos.Y.Offset - intensity
            )
        }, speed, Animations.Easing.Sine, Enum.EasingDirection.InOut, 0, -1, true)
        
        if floatUp then
            floatUp:Play()
        end
        
        return floatUp
    end)
    
    return success and floatTween or nil
end

-- Enhanced sound system
local SoundSystem = {}
SoundSystem.Sounds = {
    Click = "rbxassetid://131961136",
    Hover = "rbxassetid://131961136",
    Success = "rbxassetid://131961136",
    Error = "rbxassetid://131961136",
    Notification = "rbxassetid://131961136"
}

function SoundSystem.PlaySound(soundName, volume, pitch)
    if not ZynoxClient.Settings.SoundsEnabled then
        return
    end
    
    ErrorHandler.SafeCall(function()
        local soundId = SoundSystem.Sounds[soundName]
        if soundId then
            local sound = Instance.new("Sound")
            sound.SoundId = soundId
            sound.Volume = volume or 0.5
            sound.Pitch = pitch or 1
            sound.Parent = SoundService
            
            sound:Play()
            sound.Ended:Connect(function()
                sound:Destroy()
            end)
        end
    end)
end

-- Enhanced settings system with persistence
function ZynoxClient:SaveSettings()
    if not self.Settings.AutoSave then
        return
    end
    
    ErrorHandler.SafeCall(function()
        local settingsData = HttpService:JSONEncode(self.Settings)
        _G.ZynoxClientSettings = settingsData
    end)
end

function ZynoxClient:LoadSettings()
    ErrorHandler.SafeCall(function()
        if _G.ZynoxClientSettings then
            local loadedSettings = HttpService:JSONDecode(_G.ZynoxClientSettings)
            for key, value in pairs(loadedSettings) do
                self.Settings[key] = value
            end
        end
    end)
end

-- Welcome message templates
ZynoxClient.WelcomeSystem.Templates = {
    FirstTime = {
        Title = "Welcome to Zynox Client!",
        Message = "Thank you for choosing Zynox Client v2.0. This enhanced UI library provides modern, smooth, and reliable interface components for your applications.",
        SubMessage = "Take a moment to explore the features and customize your experience.",
        Icon = "👋",
        Duration = 8,
        Type = "Welcome",
        ShowTutorial = true
    },
    
    Returning = {
        Title = "Welcome Back!",
        Message = "Zynox Client v2.0 is ready to go. All your settings have been restored.",
        SubMessage = "What would you like to build today?",
        Icon = "🚀",
        Duration = 5,
        Type = "Return",
        ShowTutorial = false
    },
    
    Update = {
        Title = "Zynox Client Updated!",
        Message = "New features and improvements are now available in v2.0.",
        SubMessage = "Check out the enhanced animations, better performance, and new themes!",
        Icon = "✨",
        Duration = 6,
        Type = "Update",
        ShowTutorial = false
    },
    
    Custom = {
        Title = "Custom Welcome",
        Message = "Your custom welcome message here.",
        SubMessage = "Customize this in the settings.",
        Icon = "💎",
        Duration = 5,
        Type = "Custom",
        ShowTutorial = false
    }
}

-- Enhanced welcome message creation
function ZynoxClient:CreateWelcomeMessage(messageType, customConfig)
    if not self.WelcomeSystem.Enabled then
        return
    end
    
    messageType = messageType or "FirstTime"
    local template = self.WelcomeSystem.Templates[messageType]
    
    if not template then
        warn("[ZynoxClient]: Invalid welcome message type: " .. tostring(messageType))
        return
    end
    
    -- Merge custom config with template
    local config = {}
    for key, value in pairs(template) do
        config[key] = value
    end
    
    if customConfig then
        for key, value in pairs(customConfig) do
            config[key] = value
        end
    end
    
    local success = ErrorHandler.SafeCall(function()
        -- Create welcome screen GUI
        local welcomeGui = Instance.new("ScreenGui")
        welcomeGui.Name = "ZynoxWelcome_" .. tick()
        welcomeGui.ResetOnSpawn = false
        welcomeGui.DisplayOrder = 300
        welcomeGui.Parent = CoreGui
        
        -- Background overlay with blur effect
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 1
        overlay.Parent = welcomeGui
        
        -- Animate overlay in
        local overlayTween = Utils.CreateTween(overlay, {
            BackgroundTransparency = 0.4
        }, 0.5, Animations.Easing.Smooth)
        if overlayTween then overlayTween:Play() end
        
        -- Main welcome container
        local welcomeContainer = Instance.new("Frame")
        welcomeContainer.Size = UDim2.new(0, 500, 0, 350)
        welcomeContainer.Position = UDim2.new(0.5, -250, 0.5, -175)
        welcomeContainer.BackgroundColor3 = self:GetTheme().Surface
        welcomeContainer.BackgroundTransparency = 0.05
        welcomeContainer.Parent = overlay
        Utils.AddCorners(welcomeContainer, 25)
        
        -- Add glass morphism effect
        Utils.AddGlassMorphism(welcomeContainer, 15, 0.9)
        
        -- Enhanced glow effects
        Utils.AddGlow(welcomeContainer, self:GetTheme().Primary, 60, 0.8)
        Utils.AddGlow(welcomeContainer, self:GetTheme().Accent, 40, 0.9)
        
        -- Gradient background
        Utils.AddGradient(welcomeContainer, {
            {Time = 0, Color = self:GetTheme().Background},
            {Time = 0.3, Color = self:GetTheme().BackgroundLight},
            {Time = 0.7, Color = self:GetTheme().Surface},
            {Time = 1, Color = self:GetTheme().SurfaceLight}
        }, 135)
        
        -- Welcome icon with animation
        local iconContainer = Instance.new("Frame")
        iconContainer.Size = UDim2.new(0, 80, 0, 80)
        iconContainer.Position = UDim2.new(0.5, -40, 0, 30)
        iconContainer.BackgroundColor3 = self:GetTheme().Primary
        iconContainer.BackgroundTransparency = 0.1
        iconContainer.Parent = welcomeContainer
        Utils.AddCorners(iconContainer, 40)
        Utils.AddGlow(iconContainer, self:GetTheme().PrimaryLight, 20, 0.7)
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = config.Icon
        iconLabel.TextColor3 = Color3.new(1, 1, 1)
        iconLabel.TextSize = 40
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Parent = iconContainer
        
        -- Animate icon
        if self.Settings.AnimationsEnabled then
            local iconPulse = Utils.CreateTween(iconContainer, {
                Size = UDim2.new(0, 85, 0, 85),
                BackgroundTransparency = 0
            }, 1, Animations.Easing.Sine, Enum.EasingDirection.InOut, 0, -1, true)
            
            local iconRotate = Utils.CreateTween(iconLabel, {
                Rotation = 360
            }, 4, Animations.Easing.Smooth, Enum.EasingDirection.InOut, 0, -1, false)
            
            if iconPulse then iconPulse:Play() end
            if iconRotate then iconRotate:Play() end
        end
        
        -- Welcome title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -40, 0, 40)
        titleLabel.Position = UDim2.new(0, 20, 0, 130)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = config.Title
        titleLabel.TextColor3 = self:GetTheme().Text
        titleLabel.TextSize = 24
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextWrapped = true
        titleLabel.Parent = welcomeContainer
        
        -- Add title glow effect
        local titleGlow = titleLabel:Clone()
        titleGlow.TextColor3 = self:GetTheme().AccentLight
        titleGlow.TextTransparency = 0.8
        titleGlow.ZIndex = titleLabel.ZIndex - 1
        titleGlow.Position = UDim2.new(0, 22, 0, 132)
        titleGlow.Parent = welcomeContainer
        
        -- Main message
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -40, 0, 60)
        messageLabel.Position = UDim2.new(0, 20, 0, 180)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = config.Message
        messageLabel.TextColor3 = self:GetTheme().TextSecondary
        messageLabel.TextSize = 14
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextWrapped = true
        messageLabel.Parent = welcomeContainer
        
        -- Sub message
        local subMessageLabel = Instance.new("TextLabel")
        subMessageLabel.Size = UDim2.new(1, -40, 0, 30)
        subMessageLabel.Position = UDim2.new(0, 20, 0, 250)
        subMessageLabel.BackgroundTransparency = 1
        subMessageLabel.Text = config.SubMessage
        subMessageLabel.TextColor3 = self:GetTheme().TextDim
        subMessageLabel.TextSize = 12
        subMessageLabel.Font = Enum.Font.Gotham
        subMessageLabel.TextWrapped = true
        subMessageLabel.Parent = welcomeContainer
        
        -- Button container
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -40, 0, 40)
        buttonContainer.Position = UDim2.new(0, 20, 0, 290)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = welcomeContainer
        
        -- Get Started button
        local getStartedBtn = Instance.new("TextButton")
        getStartedBtn.Size = UDim2.new(0, 120, 0, 35)
        getStartedBtn.Position = UDim2.new(1, -125, 0, 0)
        getStartedBtn.BackgroundColor3 = self:GetTheme().Primary
        getStartedBtn.BackgroundTransparency = 0.1
        getStartedBtn.Text = "Get Started"
        getStartedBtn.TextColor3 = Color3.new(1, 1, 1)
        getStartedBtn.TextSize = 14
        getStartedBtn.Font = Enum.Font.GothamBold
        getStartedBtn.Parent = buttonContainer
        Utils.AddCorners(getStartedBtn, 17.5)
        Utils.AddGlow(getStartedBtn, self:GetTheme().PrimaryLight, 10, 0.8)
        
        -- Tutorial button (if enabled)
        local tutorialBtn
        if config.ShowTutorial then
            tutorialBtn = Instance.new("TextButton")
            tutorialBtn.Size = UDim2.new(0, 100, 0, 35)
            tutorialBtn.Position = UDim2.new(1, -235, 0, 0)
            tutorialBtn.BackgroundColor3 = self:GetTheme().Secondary
            tutorialBtn.BackgroundTransparency = 0.3
            tutorialBtn.Text = "Tutorial"
            tutorialBtn.TextColor3 = Color3.new(1, 1, 1)
            tutorialBtn.TextSize = 14
            tutorialBtn.Font = Enum.Font.Gotham
            tutorialBtn.Parent = buttonContainer
            Utils.AddCorners(tutorialBtn, 17.5)
            Utils.AddGlow(tutorialBtn, self:GetTheme().SecondaryLight, 8, 0.9)
        end
        
        -- Skip button
        local skipBtn = Instance.new("TextButton")
        skipBtn.Size = UDim2.new(0, 60, 0, 35)
        skipBtn.Position = UDim2.new(0, 5, 0, 0)
        skipBtn.BackgroundColor3 = self:GetTheme().SurfaceLight
        skipBtn.BackgroundTransparency = 0.5
        skipBtn.Text = "Skip"
        skipBtn.TextColor3 = self:GetTheme().TextDim
        skipBtn.TextSize = 12
        skipBtn.Font = Enum.Font.Gotham
        skipBtn.Parent = buttonContainer
        Utils.AddCorners(skipBtn, 17.5)
        
        -- Progress indicator for auto-close
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        progressBar.Position = UDim2.new(0, 0, 1, -3)
        progressBar.BackgroundColor3 = self:GetTheme().Primary
        progressBar.BorderSizePixel = 0
        progressBar.Parent = welcomeContainer
        Utils.AddCorners(progressBar, 1.5)
        
        -- Animate progress bar
        local progressTween = Utils.CreateTween(progressBar, {
            Size = UDim2.new(0, 0, 0, 3)
        }, config.Duration, Animations.Easing.Smooth)
        if progressTween then progressTween:Play() end
        
        -- Animate welcome container in
        welcomeContainer.Size = UDim2.new(0, 0, 0, 0)
        welcomeContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        local containerTween = Utils.CreateTween(welcomeContainer, {
            Size = UDim2.new(0, 500, 0, 350),
            Position = UDim2.new(0.5, -250, 0.5, -175)
        }, 0.8, Animations.Easing.Bounce)
        if containerTween then containerTween:Play() end
        
        -- Add floating animation
        if self.Settings.AnimationsEnabled then
            Utils.AddFloatingAnimation(welcomeContainer, 2, 3)
        end
        
        -- Particle effects
        if self.Settings.ParticlesEnabled then
            spawn(function()
                for i = 1, 3 do
                    Utils.CreateParticles(overlay, {
                        Count = 8,
                        Color = self:GetTheme().Accent,
                        Size = 3,
                        Duration = 4
                    })
                    wait(1)
                end
            end)
        end
        
        -- Button functionality
        local function closeWelcome()
            local fadeOut = Utils.CreateTween(overlay, {
                BackgroundTransparency = 1
            }, 0.3)
            
            local shrinkTween = Utils.CreateTween(welcomeContainer, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }, 0.4, Animations.Easing.Sharp)
            
            if fadeOut then fadeOut:Play() end
            if shrinkTween then
                shrinkTween:Play()
                shrinkTween.Completed:Connect(function()
                    if welcomeGui and welcomeGui.Parent then
                        welcomeGui:Destroy()
                    end
                end)
            else
                welcomeGui:Destroy()
            end
            
            SoundSystem.PlaySound("Click", 0.3)
        end
        
        -- Button events
        getStartedBtn.MouseButton1Click:Connect(function()
            SoundSystem.PlaySound("Success", 0.4)
            Utils.CreateRipple(getStartedBtn, getStartedBtn.AbsoluteSize.X/2, getStartedBtn.AbsoluteSize.Y/2)
            closeWelcome()
            
            -- Show success notification
            self:CreateNotification({
                Type = "Success",
                Title = "Welcome Complete!",
                Message = "You're all set to start using Zynox Client.",
                Duration = 4
            })
        end)
        
        if tutorialBtn then
            tutorialBtn.MouseButton1Click:Connect(function()
                SoundSystem.PlaySound("Click", 0.3)
                Utils.CreateRipple(tutorialBtn, tutorialBtn.AbsoluteSize.X/2, tutorialBtn.AbsoluteSize.Y/2)
                closeWelcome()
                
                -- Show tutorial
                self:CreateNotification({
                    Type = "Info",
                    Title = "Tutorial",
                    Message = "Tutorial system coming soon!",
                    Duration = 3
                })
            end)
        end
        
        skipBtn.MouseButton1Click:Connect(function()
            SoundSystem.PlaySound("Click", 0.2)
            closeWelcome()
        end)
        
        -- Auto-close after duration
        spawn(function()
            wait(config.Duration)
            if welcomeGui and welcomeGui.Parent then
                closeWelcome()
            end
        end)
        
        -- Play welcome sound
        SoundSystem.PlaySound("Success", 0.5)
        
        -- Store current message
        self.WelcomeSystem.CurrentMessage = welcomeGui
    end)
    
    if not success then
        self:CreateNotification({
            Type = "Error",
            Title = "Welcome Error",
            Message = "Failed to show welcome message.",
            Duration = 3
        })
    end
end

-- Enhanced notification system with queue management
function ZynoxClient:CreateNotification(config)
    local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {"Title"}, {
        Type = "Info",
        Message = "Notification",
        Duration = 5,
        Position = "TopRight"
    })
    
    if not isValid then
        return
    end
    
    -- Manage notification queue
    if #self.NotificationQueue >= self.MaxNotifications then
        local oldestNotification = table.remove(self.NotificationQueue, 1)
        if oldestNotification and oldestNotification.Parent then
            oldestNotification:Destroy()
        end
    end
    
    ErrorHandler.SafeCall(function()
        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "ZynoxNotification_" .. tick()
        notificationGui.ResetOnSpawn = false
        notificationGui.DisplayOrder = 200
        notificationGui.Parent = CoreGui
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 380, 0, 90)
        notification.Position = UDim2.new(1, 20, 0, 20 + (#self.NotificationQueue * 100))
        notification.BackgroundColor3 = self:GetTheme().Surface
        notification.BackgroundTransparency = 0.1
        notification.Parent = notificationGui
        Utils.AddCorners(notification, 15)
        Utils.AddGlassMorphism(notification, 10, 0.85)
        
        local statusColors = {
            Success = self:GetTheme().Success,
            Warning = self:GetTheme().Warning,
            Error = self:GetTheme().Error,
            Info = self:GetTheme().Info
        }
        
        Utils.AddGlow(notification, statusColors[validatedConfig.Type] or self:GetTheme().Info, 20, 0.9)
        
        -- Enhanced notification icon
        local notificationIcon = Instance.new("Frame")
        notificationIcon.Size = UDim2.new(0, 60, 0, 60)
        notificationIcon.Position = UDim2.new(0, 15, 0, 15)
        notificationIcon.BackgroundColor3 = statusColors[validatedConfig.Type] or self:GetTheme().Info
        notificationIcon.BackgroundTransparency = 0.1
        notificationIcon.Parent = notification
        Utils.AddCorners(notificationIcon, 30)
        Utils.AddGlow(notificationIcon, statusColors[validatedConfig.Type] or self:GetTheme().Info, 10, 0.8)
        
        local iconSymbols = {
            Success = "✓",
            Warning = "⚠",
            Error = "✗",
            Info = "ℹ"
        }
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = iconSymbols[validatedConfig.Type] or "ℹ"
        iconLabel.TextColor3 = Color3.new(1, 1, 1)
        iconLabel.TextSize = 28
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Parent = notificationIcon
        
        -- Enhanced title and message
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -90, 0, 30)
        titleLabel.Position = UDim2.new(0, 85, 0, 15)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = validatedConfig.Title
        titleLabel.TextColor3 = self:GetTheme().Text
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.Parent = notification
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -90, 0, 25)
        messageLabel.Position = UDim2.new(0, 85, 0, 45)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = validatedConfig.Message
        messageLabel.TextColor3 = self:GetTheme().TextDim
        messageLabel.TextSize = 13
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextWrapped = true
        messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
        messageLabel.Parent = notification
        
        -- Enhanced close button
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 25, 0, 25)
        closeButton.Position = UDim2.new(1, -35, 0, 10)
        closeButton.BackgroundColor3 = self:GetTheme().Error
        closeButton.BackgroundTransparency = 0.3
        closeButton.Text = "×"
        closeButton.TextColor3 = Color3.new(1, 1, 1)
        closeButton.TextSize = 14
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = notification
        Utils.AddCorners(closeButton, 12.5)
        
        -- Progress bar for duration
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        progressBar.Position = UDim2.new(0, 0, 1, -3)
        progressBar.BackgroundColor3 = statusColors[validatedConfig.Type] or self:GetTheme().Info
        progressBar.BorderSizePixel = 0
        progressBar.Parent = notification
        Utils.AddCorners(progressBar, 1.5)
        
        -- Animation in
        local slideIn = Utils.CreateTween(notification, {
            Position = UDim2.new(1, -400, 0, 20 + (#self.NotificationQueue * 100))
        }, 0.5, Animations.Easing.Bounce)
        
        if slideIn then
            slideIn:Play()
        end
        
        -- Progress bar animation
        local progressTween = Utils.CreateTween(progressBar, {
            Size = UDim2.new(0, 0, 0, 3)
        }, validatedConfig.Duration, Animations.Easing.Smooth)
        
        if progressTween then
            progressTween:Play()
        end
        
        -- Play notification sound
        SoundSystem.PlaySound("Notification", 0.3)
        
        -- Add to queue
        table.insert(self.NotificationQueue, notificationGui)
        
        -- Auto dismiss
        local function dismissNotification()
            local slideOut = Utils.CreateTween(notification, {
                Position = UDim2.new(1, 20, 0, 20 + (#self.NotificationQueue * 100))
            }, 0.3, Animations.Easing.Sharp)
            
            if slideOut then
                slideOut:Play()
                slideOut.Completed:Connect(function()
                    -- Remove from queue
                    for i, notif in ipairs(self.NotificationQueue) do
                        if notif == notificationGui then
                            table.remove(self.NotificationQueue, i)
                            break
                        end
                    end
                    
                    if notificationGui and notificationGui.Parent then
                        notificationGui:Destroy()
                    end
                end)
            else
                notificationGui:Destroy()
            end
        end
        
        -- Close button functionality
        closeButton.MouseButton1Click:Connect(dismissNotification)
        
        -- Auto dismiss timer
        spawn(function()
            wait(validatedConfig.Duration)
            dismissNotification()
        end)
    end)
end

-- Auto-show welcome message based on user status
function ZynoxClient:ShowAutoWelcome()
    -- Check if this is first launch
    local isFirstLaunch = not _G.ZynoxClientLaunched
    _G.ZynoxClientLaunched = true
    
    if isFirstLaunch and self.WelcomeSystem.ShowOnFirstLaunch then
        -- First time user
        self:CreateWelcomeMessage("FirstTime")
    elseif self.WelcomeSystem.ShowOnEveryLaunch then
        -- Returning user
        self:CreateWelcomeMessage("Returning")
    end
end

-- Enhanced Create Window Function with comprehensive functionality
function ZynoxClient:CreateWindow(config)
    local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
        Name = "Zynox Client Enhanced",
        LoadingSubtitle = "Next-Gen UI Library • v2.0",
        Size = {800, 600},
        Position = "Center",
        Resizable = false,
        Theme = "Default"
    })
    
    if not isValid then
        return nil
    end
    
    local success, window = ErrorHandler.SafeCall(function()
        local Window = {
            Name = validatedConfig.Name,
            Tabs = {},
            CurrentTab = nil,
            Visible = true,
            Elements = {},
            Connections = {},
            Config = validatedConfig,
            IsMinimized = false
        }
        
        -- Destroy existing window if exists
        local existing = CoreGui:FindFirstChild("ZynoxClient_" .. Window.Name)
        if existing then
            existing:Destroy()
        end
        
        -- Main ScreenGui with enhanced properties
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ZynoxClient_" .. Window.Name
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 100
        screenGui.Parent = CoreGui
        
        -- Enhanced background blur
        local blurFrame = Instance.new("Frame")
        blurFrame.Name = "BlurBackground"
        blurFrame.Size = UDim2.new(1, 0, 1, 0)
        blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blurFrame.BackgroundTransparency = 0.7
        blurFrame.Visible = false
        blurFrame.Parent = screenGui
        
        -- Particle system for background
        local particleConnection
        if self.Settings.ParticlesEnabled then
            particleConnection = spawn(function()
                while blurFrame.Parent and blurFrame.Visible do
                    Utils.CreateParticles(blurFrame, {
                        Count = 3,
                        Color = self:GetTheme().Primary,
                        Size = 2,
                        Duration = 6
                    })
                    wait(2)
                end
            end)
            table.insert(Window.Connections, particleConnection)
        end
        
        -- Enhanced main container
        local mainContainer = Instance.new("Frame")
        mainContainer.Name = "MainContainer"
        mainContainer.Size = UDim2.new(0, validatedConfig.Size[1], 0, validatedConfig.Size[2])
        mainContainer.Position = UDim2.new(0.5, -validatedConfig.Size[1]/2, 0.5, -validatedConfig.Size[2]/2)
        mainContainer.BackgroundTransparency = 1
        mainContainer.ClipsDescendants = true
        mainContainer.Parent = screenGui
        
        -- Add floating animation
        if self.Settings.AnimationsEnabled then
            local floatTween = Utils.AddFloatingAnimation(mainContainer, 3, 4)
            if floatTween then
                table.insert(Window.Connections, floatTween)
            end
        end
        
        -- Enhanced window frame
        local windowFrame = Instance.new("Frame")
        windowFrame.Name = "WindowFrame"
        windowFrame.Size = UDim2.new(1, 0, 1, 0)
        windowFrame.BackgroundColor3 = self:GetTheme().Background
        windowFrame.BackgroundTransparency = 0.1
        windowFrame.BorderSizePixel = 0
        windowFrame.Parent = mainContainer
        Utils.AddCorners(windowFrame, 20)
        
        -- Add glass morphism
        Utils.AddGlassMorphism(windowFrame, 10, 0.85)
        
        -- Enhanced glows
        Utils.AddGlow(windowFrame, self:GetTheme().Primary, 50, 0.9)
        Utils.AddGlow(windowFrame, self:GetTheme().Accent, 30, 0.95)
        
        -- Enhanced gradient
        Utils.AddGradient(windowFrame, {
            {Time = 0, Color = self:GetTheme().Background},
            {Time = 0.5, Color = self:GetTheme().BackgroundLight},
            {Time = 1, Color = self:GetTheme().Surface}
        }, 135)
        
        -- Enhanced header
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 80)
        header.BackgroundColor3 = self:GetTheme().Surface
        header.BackgroundTransparency = 0.2
        header.BorderSizePixel = 0
        header.Parent = windowFrame
        Utils.AddCorners(header, 20)
        
        -- Header gradient
        Utils.AddGradient(header, {
            {Time = 0, Color = self:GetTheme().Primary},
            {Time = 0.3, Color = self:GetTheme().PrimaryLight},
            {Time = 0.7, Color = self:GetTheme().Secondary},
            {Time = 1, Color = self:GetTheme().SecondaryLight}
        }, 45)
        
        -- Enhanced logo with better animations
        local logo = Instance.new("Frame")
        logo.Name = "Logo"
        logo.Size = UDim2.new(0, 55, 0, 55)
        logo.Position = UDim2.new(0, 20, 0, 12.5)
        logo.BackgroundColor3 = self:GetTheme().Accent
        logo.BackgroundTransparency = 0.1
        logo.Parent = header
        Utils.AddCorners(logo, 27.5)
        Utils.AddGlow(logo, self:GetTheme().AccentGlow, 15, 0.7)
        
        local logoIcon = Instance.new("TextLabel")
        logoIcon.Size = UDim2.new(1, 0, 1, 0)
        logoIcon.BackgroundTransparency = 1
        logoIcon.Text = "Z"
        logoIcon.TextColor3 = Color3.new(1, 1, 1)
        logoIcon.TextScaled = true
        logoIcon.Font = Enum.Font.GothamBold
        logoIcon.Parent = logo
        
        -- Enhanced logo animations with cleanup
        if self.Settings.AnimationsEnabled then
            local logoPulse = Utils.CreateTween(logo, {
                Size = UDim2.new(0, 60, 0, 60),
                BackgroundTransparency = 0
            }, 1.5, Animations.Easing.Sine, Enum.EasingDirection.InOut, 0, -1, true)
            
            local logoRotate = Utils.CreateTween(logoIcon, {
                Rotation = 360
            }, 8, Animations.Easing.Sine, Enum.EasingDirection.InOut, 0, -1, false)
            
            if logoPulse then
                logoPulse:Play()
                table.insert(Window.Connections, logoPulse)
            end
            
            if logoRotate then
                logoRotate:Play()
                table.insert(Window.Connections, logoRotate)
            end
        end
        
        -- Enhanced window title with better typography
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(0, 350, 0, 30)
        title.Position = UDim2.new(0, 90, 0, 15)
        title.BackgroundTransparency = 1
        title.Text = Window.Name
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 24
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header
        
        -- Add text glow effect
        local titleGlow = title:Clone()
        titleGlow.TextColor3 = self:GetTheme().AccentLight
        titleGlow.TextTransparency = 0.8
        titleGlow.ZIndex = title.ZIndex - 1
        titleGlow.Position = UDim2.new(0, 92, 0, 17)
        titleGlow.Parent = header
        
        -- Enhanced subtitle with animation
        local subtitle = Instance.new("TextLabel")
        subtitle.Name = "Subtitle"
        subtitle.Size = UDim2.new(0, 350, 0, 25)
        subtitle.Position = UDim2.new(0, 90, 0, 45)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = validatedConfig.LoadingSubtitle or "Next-Gen UI Library • v2.0"
        subtitle.TextColor3 = self:GetTheme().TextSecondary
        subtitle.TextSize = 14
        subtitle.Font = Enum.Font.Gotham
        subtitle.TextXAlignment = Enum.TextXAlignment.Left
        subtitle.Parent = header
        
        -- Animate subtitle text
        local subtitleTexts = {
            "Next-Gen UI Library • v2.0",
            "Enhanced Visual Experience",
            "Modern Design System",
            "Smooth Animations"
        }
        
        spawn(function()
            local index = 1
            while subtitle.Parent do
                wait(3)
                index = index % #subtitleTexts + 1
                local fadeOut = Utils.CreateTween(subtitle, {TextTransparency = 1}, 0.3)
                if fadeOut then
                    fadeOut:Play()
                    fadeOut.Completed:Connect(function()
                        subtitle.Text = subtitleTexts[index]
                        local fadeIn = Utils.CreateTween(subtitle, {TextTransparency = 0}, 0.3)
                        if fadeIn then fadeIn:Play() end
                    end)
                end
            end
        end)
        
        -- Enhanced control buttons with better styling
        local controlsFrame = Instance.new("Frame")
        controlsFrame.Name = "Controls"
        controlsFrame.Size = UDim2.new(0, 120, 0, 35)
        controlsFrame.Position = UDim2.new(1, -135, 0, 22.5)
        controlsFrame.BackgroundTransparency = 1
        controlsFrame.Parent = header
        
        -- Enhanced close button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 35, 0, 35)
        closeBtn.Position = UDim2.new(0, 85, 0, 0)
        closeBtn.BackgroundColor3 = self:GetTheme().Error
        closeBtn.BackgroundTransparency = 0.2
        closeBtn.Text = "×"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 18
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = controlsFrame
        Utils.AddCorners(closeBtn, 17.5)
        Utils.AddGlow(closeBtn, self:GetTheme().ErrorLight, 8, 0.9)
        
        -- Enhanced minimize button
        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
        minimizeBtn.Position = UDim2.new(0, 45, 0, 0)
        minimizeBtn.BackgroundColor3 = self:GetTheme().Warning
        minimizeBtn.BackgroundTransparency = 0.2
        minimizeBtn.Text = "−"
        minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
        minimizeBtn.TextSize = 18
        minimizeBtn.Font = Enum.Font.GothamBold
        minimizeBtn.Parent = controlsFrame
        Utils.AddCorners(minimizeBtn, 17.5)
        Utils.AddGlow(minimizeBtn, self:GetTheme().WarningLight, 8, 0.9)
        
        -- Enhanced settings button
        local settingsBtn = Instance.new("TextButton")
        settingsBtn.Size = UDim2.new(0, 35, 0, 35)
        settingsBtn.Position = UDim2.new(0, 5, 0, 0)
        settingsBtn.BackgroundColor3 = self:GetTheme().Info
        settingsBtn.BackgroundTransparency = 0.2
        settingsBtn.Text = "⚙"
        settingsBtn.TextColor3 = Color3.new(1, 1, 1)
        settingsBtn.TextSize = 14
        settingsBtn.Font = Enum.Font.GothamBold
        settingsBtn.Parent = controlsFrame
        Utils.AddCorners(settingsBtn, 17.5)
        Utils.AddGlow(settingsBtn, self:GetTheme().InfoLight, 8, 0.9)
        
        -- Add hover effects to control buttons
        for _, btn in pairs({closeBtn, minimizeBtn, settingsBtn}) do
            local hoverConnection1 = btn.MouseEnter:Connect(function()
                Utils.CreateTween(btn, {
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0, 38, 0, 38)
                }, 0.2):Play()
            end)
            
            local hoverConnection2 = btn.MouseLeave:Connect(function()
                Utils.CreateTween(btn, {
                    BackgroundTransparency = 0.2,
                    Size = UDim2.new(0, 35, 0, 35)
                }, 0.2):Play()
            end)
            
            table.insert(Window.Connections, hoverConnection1)
            table.insert(Window.Connections, hoverConnection2)
        end
        
        -- Enhanced sidebar with glass effect
        local sidebar = Instance.new("Frame")
        sidebar.Name = "Sidebar"
        sidebar.Size = UDim2.new(0, 220, 1, -80)
        sidebar.Position = UDim2.new(0, 0, 0, 80)
        sidebar.BackgroundColor3 = self:GetTheme().Surface
        sidebar.BackgroundTransparency = 0.3
        sidebar.BorderSizePixel = 0
        sidebar.Parent = windowFrame
        
        Utils.AddGlassMorphism(sidebar, 5, 0.9)
        
        -- Enhanced tab container
        local tabContainer = Instance.new("ScrollingFrame")
        tabContainer.Name = "TabContainer"
        tabContainer.Size = UDim2.new(1, 0, 1, 0)
        tabContainer.BackgroundTransparency = 1
        tabContainer.ScrollBarThickness = 8
        tabContainer.ScrollBarImageColor3 = self:GetTheme().Primary
        tabContainer.ScrollBarImageTransparency = 0.3
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContainer.Parent = sidebar
        Utils.AddPadding(tabContainer, 20)
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Padding = UDim.new(0, 10)
        tabLayout.Parent = tabContainer
        
        -- Enhanced content area
        local contentArea = Instance.new("Frame")
        contentArea.Name = "ContentArea"
        contentArea.Size = UDim2.new(1, -220, 1, -80)
        contentArea.Position = UDim2.new(0, 220, 0, 80)
        contentArea.BackgroundTransparency = 1
        contentArea.Parent = windowFrame
        
        -- Enhanced dragging system with bounds checking
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        local dragConnection1 = header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not Window.IsMinimized then
                dragging = true
                dragStart = input.Position
                startPos = mainContainer.Position
                
                SoundSystem.PlaySound("Click", 0.1)
                local dragTween = Utils.CreateTween(mainContainer, {Size = UDim2.new(0, validatedConfig.Size[1]-10, 0, validatedConfig.Size[2]-10)}, 0.1)
                if dragTween then dragTween:Play() end
            end
        end)
        
        local dragConnection2 = UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                
                -- Bounds checking
                local screenSize = workspace.CurrentCamera.ViewportSize
                newX = math.clamp(newX, -validatedConfig.Size[1]/2, screenSize.X - validatedConfig.Size[1]/2)
                newY = math.clamp(newY, -validatedConfig.Size[2]/2, screenSize.Y - validatedConfig.Size[2]/2)
                
                mainContainer.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            end
        end)
        
        local dragConnection3 = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                dragging = false
                local releaseTween = Utils.CreateTween(mainContainer, {Size = UDim2.new(0, validatedConfig.Size[1], 0, validatedConfig.Size[2])}, 0.1)
                if releaseTween then releaseTween:Play() end
            end
        end)
        
        -- Store drag connections
        table.insert(Window.Connections, dragConnection1)
        table.insert(Window.Connections, dragConnection2)
        table.insert(Window.Connections, dragConnection3)
        
        -- Enhanced window animations
        local function AnimateWindowIn()
            mainContainer.Size = UDim2.new(0, 0, 0, 0)
            mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            blurFrame.Visible = true
            
            local blurTween = Utils.CreateTween(blurFrame, {BackgroundTransparency = 0.3}, 0.4)
            local sizeTween = Utils.CreateTween(mainContainer, {
                Size = UDim2.new(0, validatedConfig.Size[1], 0, validatedConfig.Size[2]),
                Position = UDim2.new(0.5, -validatedConfig.Size[1]/2, 0.5, -validatedConfig.Size[2]/2)
            }, 0.6, Animations.Easing.Bounce)
            
            if blurTween then blurTween:Play() end
            if sizeTween then sizeTween:Play() end
            
            SoundSystem.PlaySound("Success", 0.4)
        end
        
        local function AnimateWindowOut()
            local blurTween = Utils.CreateTween(blurFrame, {BackgroundTransparency = 1}, 0.3)
            local sizeTween = Utils.CreateTween(mainContainer, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }, 0.4, Animations.Easing.Sharp)
            
            if blurTween then blurTween:Play() end
            if sizeTween then
                sizeTween:Play()
                sizeTween.Completed:Connect(function()
                    Window:Destroy()
                end)
            else
                Window:Destroy()
            end
        end
        
        -- Button Events
        closeBtn.MouseButton1Click:Connect(function()
            SoundSystem.PlaySound("Click", 0.3)
            Utils.CreateRipple(closeBtn, closeBtn.AbsoluteSize.X/2, closeBtn.AbsoluteSize.Y/2)
            AnimateWindowOut()
        end)
        
        minimizeBtn.MouseButton1Click:Connect(function()
            SoundSystem.PlaySound("Click", 0.3)
            Utils.CreateRipple(minimizeBtn, minimizeBtn.AbsoluteSize.X/2, minimizeBtn.AbsoluteSize.Y/2)
            
            Window.IsMinimized = not Window.IsMinimized
            
            if Window.IsMinimized then
                -- Minimize window
                local targetSize = UDim2.new(0, validatedConfig.Size[1], 0, 80)
                local tween = Utils.CreateTween(mainContainer, {Size = targetSize}, 0.3)
                if tween then tween:Play() end
                minimizeBtn.Text = "+"
            else
                -- Restore window
                local targetSize = UDim2.new(0, validatedConfig.Size[1], 0, validatedConfig.Size[2])
                local tween = Utils.CreateTween(mainContainer, {Size = targetSize}, 0.3)
                if tween then tween:Play() end
                minimizeBtn.Text = "−"
            end
        end)
        
        settingsBtn.MouseButton1Click:Connect(function()
            SoundSystem.PlaySound("Click", 0.3)
            Utils.CreateRipple(settingsBtn, settingsBtn.AbsoluteSize.X/2, settingsBtn.AbsoluteSize.Y/2)
            self:CreateNotification({
                Type = "Info",
                Title = "Settings",
                Message = "Settings panel opened",
                Duration = 3
            })
        end)
        
        -- Enhanced window destruction with proper cleanup
        function Window:Destroy()
            ErrorHandler.SafeCall(function()
                -- Cleanup all connections
                for _, connection in ipairs(self.Connections) do
                    if typeof(connection) == "RBXScriptConnection" then
                        connection:Disconnect()
                    elseif typeof(connection) == "Tween" then
                        connection:Cancel()
                    end
                end
                
                -- Remove from windows list
                for i, win in ipairs(ZynoxClient.Windows) do
                    if win == self then
                        table.remove(ZynoxClient.Windows, i)
                        break
                    end
                end
                
                -- Destroy GUI
                if screenGui and screenGui.Parent then
                    screenGui:Destroy()
                end
                
                SoundSystem.PlaySound("Click", 0.3)
            end)
        end
        
        -- Create Tab Function with enhanced functionality
        function Window:CreateTab(config)
            local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
                Name = "New Tab",
                Icon = "📄"
            })
            
            if not isValid then
                return nil
            end
            
            local Tab = {
                Name = validatedConfig.Name,
                Elements = {},
                Visible = false,
                Connections = {}
            }
            
            -- Tab Button
            local tabButton = Instance.new("TextButton")
            tabButton.Name = "TabButton_" .. Tab.Name
            tabButton.Size = UDim2.new(1, 0, 0, 50)
            tabButton.BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight
            tabButton.BackgroundTransparency = 0.2
            tabButton.Text = ""
            tabButton.Parent = tabContainer
            Utils.AddCorners(tabButton, 10)
            
            local tabIcon = Instance.new("TextLabel")
            tabIcon.Size = UDim2.new(0, 35, 0, 35)
            tabIcon.Position = UDim2.new(0, 10, 0, 7.5)
            tabIcon.BackgroundTransparency = 1
            tabIcon.Text = validatedConfig.Icon
            tabIcon.TextColor3 = ZynoxClient:GetTheme().TextDim
            tabIcon.TextSize = 18
            tabIcon.Font = Enum.Font.GothamBold
            tabIcon.Parent = tabButton
            
            local tabLabel = Instance.new("TextLabel")
            tabLabel.Size = UDim2.new(1, -55, 1, 0)
            tabLabel.Position = UDim2.new(0, 50, 0, 0)
            tabLabel.BackgroundTransparency = 1
            tabLabel.Text = Tab.Name
            tabLabel.TextColor3 = ZynoxClient:GetTheme().TextDim
            tabLabel.TextSize = 14
            tabLabel.Font = Enum.Font.Gotham
            tabLabel.TextXAlignment = Enum.TextXAlignment.Left
            tabLabel.Parent = tabButton
            
            -- Tab Content
            local tabContent = Instance.new("ScrollingFrame")
            tabContent.Name = "TabContent_" .. Tab.Name
            tabContent.Size = UDim2.new(1, 0, 1, 0)
            tabContent.BackgroundTransparency = 1
            tabContent.ScrollBarThickness = 8
            tabContent.ScrollBarImageColor3 = ZynoxClient:GetTheme().Primary
            tabContent.ScrollBarImageTransparency = 0.3
            tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
            tabContent.Visible = false
            tabContent.Parent = contentArea
            Utils.AddPadding(tabContent, 20)
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, 12)
            contentLayout.Parent = tabContent
            
            -- Auto-resize canvas
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
            end)
            
            Tab.Frame = tabContent
            
            -- Tab Selection with enhanced animations
            local tabConnection = tabButton.MouseButton1Click:Connect(function()
                SoundSystem.PlaySound("Click", 0.2)
                Utils.CreateRipple(tabButton, tabButton.AbsoluteSize.X/2, tabButton.AbsoluteSize.Y/2)
                
                -- Hide all tabs
                for _, tab in pairs(Window.Tabs) do
                    if tab.Frame then
                        tab.Frame.Visible = false
                        tab.Visible = false
                    end
                    
                    local btn = tabContainer:FindFirstChild("TabButton_" .. tab.Name)
                    if btn then
                        local btnIcon = btn:FindFirstChild("TextLabel")
                        local btnLabel = btn:GetChildren()
                        for _, child in ipairs(btnLabel) do
                            if child:IsA("TextLabel") and child ~= btnIcon then
                                child.TextColor3 = ZynoxClient:GetTheme().TextDim
                                break
                            end
                        end
                        if btnIcon then btnIcon.TextColor3 = ZynoxClient:GetTheme().TextDim end
                        Utils.CreateTween(btn, {BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight}, 0.2):Play()
                    end
                end
                
                -- Show current tab
                tabContent.Visible = true
                Tab.Visible = true
                Window.CurrentTab = Tab
                
                tabIcon.TextColor3 = ZynoxClient:GetTheme().Accent
                tabLabel.TextColor3 = ZynoxClient:GetTheme().Text
                Utils.CreateTween(tabButton, {BackgroundColor3 = ZynoxClient:GetTheme().Primary}, 0.2):Play()
            end)
            
            table.insert(Tab.Connections, tabConnection)
            
            -- Enhanced hover effects
            local hoverConnection1 = tabButton.MouseEnter:Connect(function()
                if not Tab.Visible then
                    Utils.CreateTween(tabButton, {BackgroundColor3 = ZynoxClient:GetTheme().Surface}, 0.2):Play()
                end
            end)
            
            local hoverConnection2 = tabButton.MouseLeave:Connect(function()
                if not Tab.Visible then
                    Utils.CreateTween(tabButton, {BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight}, 0.2):Play()
                end
            end)
            
            table.insert(Tab.Connections, hoverConnection1)
            table.insert(Tab.Connections, hoverConnection2)
            
            -- Enhanced UI Element Creation Functions
            function Tab:CreateButton(config)
                local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
                    Name = "Button",
                    Callback = function() end
                })
                
                if not isValid then
                    return nil
                end
                
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.Size = UDim2.new(1, 0, 0, 45)
                button.BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight
                button.BackgroundTransparency = 0.1
                button.Text = ""
                button.Parent = tabContent
                Utils.AddCorners(button, 12)
                
                local buttonGlow = Utils.AddGlow(button, ZynoxClient:GetTheme().Primary, 10)
                if buttonGlow then
                    buttonGlow.BackgroundTransparency = 1
                end
                
                local buttonLabel = Instance.new("TextLabel")
                buttonLabel.Size = UDim2.new(1, -20, 1, 0)
                buttonLabel.Position = UDim2.new(0, 10, 0, 0)
                buttonLabel.BackgroundTransparency = 1
                buttonLabel.Text = validatedConfig.Name
                buttonLabel.TextColor3 = ZynoxClient:GetTheme().Text
                buttonLabel.TextSize = 14
                buttonLabel.Font = Enum.Font.Gotham
                buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
                buttonLabel.Parent = button
                
                -- Enhanced button interactions
                button.MouseEnter:Connect(function()
                    SoundSystem.PlaySound("Hover", 0.1)
                    Utils.CreateTween(button, {BackgroundColor3 = ZynoxClient:GetTheme().Primary}, 0.2):Play()
                    Utils.CreateTween(buttonLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.2):Play()
                    if buttonGlow then
                        Utils.CreateTween(buttonGlow, {BackgroundTransparency = 0.6}, 0.2):Play()
                    end
                end)
                
                button.MouseLeave:Connect(function()
                    Utils.CreateTween(button, {BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight}, 0.2):Play()
                    Utils.CreateTween(buttonLabel, {TextColor3 = ZynoxClient:GetTheme().Text}, 0.2):Play()
                    if buttonGlow then
                        Utils.CreateTween(buttonGlow, {BackgroundTransparency = 1}, 0.2):Play()
                    end
                end)
                
                button.MouseButton1Click:Connect(function()
                    SoundSystem.PlaySound("Click", 0.3)
                    Utils.CreateRipple(button, button.AbsoluteSize.X/2, button.AbsoluteSize.Y/2)
                    
                    local clickTween = Utils.CreateTween(button, {Size = UDim2.new(1, -4, 0, 43)}, 0.1)
                    if clickTween then
                        clickTween:Play()
                        clickTween.Completed:Connect(function()
                            Utils.CreateTween(button, {Size = UDim2.new(1, 0, 0, 45)}, 0.1):Play()
                        end)
                    end
                    
                    ErrorHandler.SafeCall(validatedConfig.Callback)
                end)
                
                return button
            end
            
            function Tab:CreateToggle(config)
                local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
                    Name = "Toggle",
                    CurrentValue = false,
                    Callback = function() end
                })
                
                if not isValid then
                    return nil
                end
                
                local isToggled = validatedConfig.CurrentValue
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "ToggleFrame"
                toggleFrame.Size = UDim2.new(1, 0, 0, 50)
                toggleFrame.BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight
                toggleFrame.BackgroundTransparency = 0.1
                toggleFrame.Parent = tabContent
                Utils.AddCorners(toggleFrame, 12)
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(1, -80, 1, 0)
                toggleLabel.Position = UDim2.new(0, 15, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = validatedConfig.Name
                toggleLabel.TextColor3 = ZynoxClient:GetTheme().Text
                toggleLabel.TextSize = 14
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                local toggleSwitch = Instance.new("TextButton")
                toggleSwitch.Size = UDim2.new(0, 50, 0, 25)
                toggleSwitch.Position = UDim2.new(1, -65, 0.5, -12.5)
                toggleSwitch.BackgroundColor3 = isToggled and ZynoxClient:GetTheme().Success or ZynoxClient:GetTheme().Background
                toggleSwitch.Text = ""
                toggleSwitch.Parent = toggleFrame
                Utils.AddCorners(toggleSwitch, 12.5)
                
                local toggleKnob = Instance.new("Frame")
                toggleKnob.Size = UDim2.new(0, 21, 0, 21)
                toggleKnob.Position = isToggled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
                toggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                toggleKnob.Parent = toggleSwitch
                Utils.AddCorners(toggleKnob, 10.5)
                
                local knobGlow = Utils.AddGlow(toggleKnob, ZynoxClient:GetTheme().Accent, 8)
                if knobGlow then
                    knobGlow.BackgroundTransparency = isToggled and 0.7 or 1
                end
                
                toggleSwitch.MouseButton1Click:Connect(function()
                    SoundSystem.PlaySound("Click", 0.2)
                    isToggled = not isToggled
                    
                    local switchColor = isToggled and ZynoxClient:GetTheme().Success or ZynoxClient:GetTheme().Background
                    local knobPos = isToggled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
                    local glowTrans = isToggled and 0.7 or 1
                    
                    Utils.CreateTween(toggleSwitch, {BackgroundColor3 = switchColor}, 0.2):Play()
                    Utils.CreateTween(toggleKnob, {Position = knobPos}, 0.2, Animations.Easing.Bounce):Play()
                    if knobGlow then
                        Utils.CreateTween(knobGlow, {BackgroundTransparency = glowTrans}, 0.2):Play()
                    end
                    
                    ErrorHandler.SafeCall(validatedConfig.Callback, isToggled)
                end)
                
                return toggleFrame
            end
            
            function Tab:CreateSlider(config)
                local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
                    Name = "Slider",
                    Min = 0,
                    Max = 100,
                    Default = 50,
                    Suffix = "",
                    Callback = function() end
                })
                
                if not isValid then
                    return nil
                end
                
                local currentValue = validatedConfig.Default
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "SliderFrame"
                sliderFrame.Size = UDim2.new(1, 0, 0, 60)
                sliderFrame.BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight
                sliderFrame.BackgroundTransparency = 0.1
                sliderFrame.Parent = tabContent
                Utils.AddCorners(sliderFrame, 12)
                
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(1, -100, 0, 25)
                sliderLabel.Position = UDim2.new(0, 15, 0, 5)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = validatedConfig.Name
                sliderLabel.TextColor3 = ZynoxClient:GetTheme().Text
                sliderLabel.TextSize = 14
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 80, 0, 25)
                valueLabel.Position = UDim2.new(1, -95, 0, 5)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(currentValue) .. validatedConfig.Suffix
                valueLabel.TextColor3 = ZynoxClient:GetTheme().Accent
                valueLabel.TextSize = 14
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = sliderFrame
                
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Size = UDim2.new(1, -30, 0, 6)
                sliderTrack.Position = UDim2.new(0, 15, 0, 38)
                sliderTrack.BackgroundColor3 = ZynoxClient:GetTheme().Background
                sliderTrack.Parent = sliderFrame
                Utils.AddCorners(sliderTrack, 3)
                
                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((currentValue - validatedConfig.Min) / (validatedConfig.Max - validatedConfig.Min), 0, 1, 0)
                sliderFill.BackgroundColor3 = ZynoxClient:GetTheme().Primary
                sliderFill.Parent = sliderTrack
                Utils.AddCorners(sliderFill, 3)
                Utils.AddGradient(sliderFill, {ZynoxClient:GetTheme().Primary, ZynoxClient:GetTheme().Accent}, 45)
                
                local sliderKnob = Instance.new("Frame")
                sliderKnob.Size = UDim2.new(0, 18, 0, 18)
                sliderKnob.Position = UDim2.new((currentValue - validatedConfig.Min) / (validatedConfig.Max - validatedConfig.Min), -9, 0.5, -9)
                sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                sliderKnob.Parent = sliderTrack
                Utils.AddCorners(sliderKnob, 9)
                
                local knobGlow = Utils.AddGlow(sliderKnob, ZynoxClient:GetTheme().Primary, 12)
                if knobGlow then
                    knobGlow.BackgroundTransparency = 0.8
                end
                
                local dragging = false
                
                local function updateSlider(input)
                    local trackPos = sliderTrack.AbsolutePosition.X
                    local trackSize = sliderTrack.AbsoluteSize.X
                    local mouseX = input.Position.X
                    local relativeX = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
                    
                    currentValue = math.floor(validatedConfig.Min + (validatedConfig.Max - validatedConfig.Min) * relativeX)
                    valueLabel.Text = tostring(currentValue) .. validatedConfig.Suffix
                    
                    Utils.CreateTween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1):Play()
                    Utils.CreateTween(sliderKnob, {Position = UDim2.new(relativeX, -9, 0.5, -9)}, 0.1):Play()
                    
                    ErrorHandler.SafeCall(validatedConfig.Callback, currentValue)
                end
                
                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        SoundSystem.PlaySound("Click", 0.1)
                        updateSlider(input)
                        Utils.CreateTween(sliderKnob, {Size = UDim2.new(0, 22, 0, 22)}, 0.1):Play()
                        if knobGlow then
                            Utils.CreateTween(knobGlow, {BackgroundTransparency = 0.5}, 0.1):Play()
                        end
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
                        if knobGlow then
                            Utils.CreateTween(knobGlow, {BackgroundTransparency = 0.8}, 0.1):Play()
                        end
                    end
                end)
                
                return sliderFrame
            end
            
            function Tab:CreateDropdown(config)
                local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
                    Name = "Dropdown",
                    Options = {"Option 1", "Option 2", "Option 3"},
                    Default = "Option 1",
                    Callback = function() end
                })
                
                if not isValid then
                    return nil
                end
                
                local currentOption = validatedConfig.Default
                local isOpen = false
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "DropdownFrame"
                dropdownFrame.Size = UDim2.new(1, 0, 0, 45)
                dropdownFrame.BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight
                dropdownFrame.BackgroundTransparency = 0.1
                dropdownFrame.Parent = tabContent
                Utils.AddCorners(dropdownFrame, 12)
                
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
                dropdownLabel.Position = UDim2.new(0, 15, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = validatedConfig.Name
                dropdownLabel.TextColor3 = ZynoxClient:GetTheme().Text
                dropdownLabel.TextSize = 14
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Size = UDim2.new(0.5, -25, 0, 35)
                dropdownButton.Position = UDim2.new(0.5, 5, 0, 5)
                dropdownButton.BackgroundColor3 = ZynoxClient:GetTheme().Background
                dropdownButton.Text = ""
                dropdownButton.Parent = dropdownFrame
                Utils.AddCorners(dropdownButton, 8)
                
                local selectedLabel = Instance.new("TextLabel")
                selectedLabel.Size = UDim2.new(1, -30, 1, 0)
                selectedLabel.Position = UDim2.new(0, 10, 0, 0)
                selectedLabel.BackgroundTransparency = 1
                selectedLabel.Text = currentOption
                selectedLabel.TextColor3 = ZynoxClient:GetTheme().Text
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
                dropdownArrow.TextColor3 = ZynoxClient:GetTheme().TextDim
                dropdownArrow.TextSize = 10
                dropdownArrow.Font = Enum.Font.Gotham
                dropdownArrow.Parent = dropdownButton
                
                local optionsFrame = Instance.new("Frame")
                optionsFrame.Name = "OptionsFrame"
                optionsFrame.Size = UDim2.new(0.5, -25, 0, 0)
                optionsFrame.Position = UDim2.new(0.5, 5, 1, 5)
                optionsFrame.BackgroundColor3 = ZynoxClient:GetTheme().Surface
                optionsFrame.BackgroundTransparency = 0.1
                optionsFrame.Visible = false
                optionsFrame.ZIndex = 100
                optionsFrame.Parent = dropdownFrame
                Utils.AddCorners(optionsFrame, 8)
                Utils.AddGlassMorphism(optionsFrame, 5, 0.9)
                
                local optionsList = Instance.new("UIListLayout")
                optionsList.SortOrder = Enum.SortOrder.LayoutOrder
                optionsList.Padding = UDim.new(0, 2)
                optionsList.Parent = optionsFrame
                
                local function createOption(optionText, index)
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, 0, 0, 30)
                    optionButton.BackgroundColor3 = ZynoxClient:GetTheme().Surface
                    optionButton.BackgroundTransparency = 0.2
                    optionButton.Text = ""
                    optionButton.LayoutOrder = index
                    optionButton.Parent = optionsFrame
                    Utils.AddCorners(optionButton, 6)
                    
                    local optionLabel = Instance.new("TextLabel")
                    optionLabel.Size = UDim2.new(1, -20, 1, 0)
                    optionLabel.Position = UDim2.new(0, 10, 0, 0)
                    optionLabel.BackgroundTransparency = 1
                    optionLabel.Text = optionText
                    optionLabel.TextColor3 = ZynoxClient:GetTheme().Text
                    optionLabel.TextSize = 12
                    optionLabel.Font = Enum.Font.Gotham
                    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    optionLabel.Parent = optionButton
                    
                    optionButton.MouseEnter:Connect(function()
                        Utils.CreateTween(optionButton, {BackgroundColor3 = ZynoxClient:GetTheme().Primary}, 0.1):Play()
                        Utils.CreateTween(optionLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.1):Play()
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        Utils.CreateTween(optionButton, {BackgroundColor3 = ZynoxClient:GetTheme().Surface}, 0.1):Play()
                        Utils.CreateTween(optionLabel, {TextColor3 = ZynoxClient:GetTheme().Text}, 0.1):Play()
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        SoundSystem.PlaySound("Click", 0.2)
                        currentOption = optionText
                        selectedLabel.Text = optionText
                        
                        -- Close dropdown
                        isOpen = false
                        Utils.CreateTween(dropdownArrow, {Rotation = 0}, 0.2):Play()
                        Utils.CreateTween(optionsFrame, {Size = UDim2.new(0.5, -25, 0, 0)}, 0.2):Play()
                        
                        spawn(function()
                            wait(0.2)
                            optionsFrame.Visible = false
                        end)
                        
                        ErrorHandler.SafeCall(validatedConfig.Callback, optionText)
                    end)
                end
                
                -- Create option buttons
                for i, option in ipairs(validatedConfig.Options) do
                    createOption(option, i)
                end
                
                -- Update options frame size
                local totalHeight = #validatedConfig.Options * 32 - 2
                
                dropdownButton.MouseButton1Click:Connect(function()
                    SoundSystem.PlaySound("Click", 0.2)
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
                        
                        spawn(function()
                            wait(0.2)
                            optionsFrame.Visible = false
                        end)
                    end
                end)
                
                return dropdownFrame
            end
            
            function Tab:CreateTextbox(config)
                local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
                    Name = "Textbox",
                    Default = "",
                    PlaceholderText = "Enter text...",
                    Callback = function() end
                })
                
                if not isValid then
                    return nil
                end
                
                local textboxFrame = Instance.new("Frame")
                textboxFrame.Name = "TextboxFrame"
                textboxFrame.Size = UDim2.new(1, 0, 0, 50)
                textboxFrame.BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight
                textboxFrame.BackgroundTransparency = 0.1
                textboxFrame.Parent = tabContent
                Utils.AddCorners(textboxFrame, 12)
                
                local textboxLabel = Instance.new("TextLabel")
                textboxLabel.Size = UDim2.new(0.4, -10, 1, 0)
                textboxLabel.Position = UDim2.new(0, 15, 0, 0)
                textboxLabel.BackgroundTransparency = 1
                textboxLabel.Text = validatedConfig.Name
                textboxLabel.TextColor3 = ZynoxClient:GetTheme().Text
                textboxLabel.TextSize = 14
                textboxLabel.Font = Enum.Font.Gotham
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                textboxLabel.Parent = textboxFrame
                
                local textbox = Instance.new("TextBox")
                textbox.Size = UDim2.new(0.6, -25, 0, 35)
                textbox.Position = UDim2.new(0.4, 5, 0, 7.5)
                textbox.BackgroundColor3 = ZynoxClient:GetTheme().Background
                textbox.Text = validatedConfig.Default
                textbox.TextColor3 = ZynoxClient:GetTheme().Text
                textbox.TextSize = 12
                textbox.Font = Enum.Font.Gotham
                textbox.PlaceholderText = validatedConfig.PlaceholderText
                textbox.PlaceholderColor3 = ZynoxClient:GetTheme().TextDim
                textbox.ClearButtonOnFocus = false
                textbox.Parent = textboxFrame
                Utils.AddCorners(textbox, 8)
                Utils.AddPadding(textbox, 0, 0, 10, 10)
                
                local textboxBorder = Instance.new("UIStroke")
                textboxBorder.Color = ZynoxClient:GetTheme().Background
                textboxBorder.Thickness = 2
                textboxBorder.Parent = textbox
                
                textbox.Focused:Connect(function()
                    SoundSystem.PlaySound("Click", 0.1)
                    Utils.CreateTween(textboxBorder, {Color = ZynoxClient:GetTheme().Primary}, 0.2):Play()
                    Utils.CreateTween(textbox, {BackgroundColor3 = ZynoxClient:GetTheme().Surface}, 0.2):Play()
                end)
                
                textbox.FocusLost:Connect(function(enterPressed)
                    Utils.CreateTween(textboxBorder, {Color = ZynoxClient:GetTheme().Background}, 0.2):Play()
                    Utils.CreateTween(textbox, {BackgroundColor3 = ZynoxClient:GetTheme().Background}, 0.2):Play()
                    
                    if enterPressed then
                        SoundSystem.PlaySound("Success", 0.2)
                        ErrorHandler.SafeCall(validatedConfig.Callback, textbox.Text)
                    end
                end)
                
                return textboxFrame
            end
            
            function Tab:CreateLabel(config)
                local isValid, validatedConfig = ErrorHandler.ValidateConfig(config, {}, {
                    Text = "Label",
                    Color = ZynoxClient:GetTheme().Text,
                    Size = 14
                })
                
                if not isValid then
                    return nil
                end
                
                local labelFrame = Instance.new("Frame")
                labelFrame.Name = "LabelFrame"
                labelFrame.Size = UDim2.new(1, 0, 0, 35)
                labelFrame.BackgroundColor3 = ZynoxClient:GetTheme().SurfaceLight
                labelFrame.BackgroundTransparency = 0.1
                labelFrame.Parent = tabContent
                Utils.AddCorners(labelFrame, 12)
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -20, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = validatedConfig.Text
                label.TextColor3 = validatedConfig.Color
                label.TextSize = validatedConfig.Size
                label.Font = Enum.Font.Gotham
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextWrapped = true
                label.Parent = labelFrame
                
                return labelFrame
            end
            
            -- Cleanup function for tabs
            function Tab:Destroy()
                for _, connection in ipairs(self.Connections) do
                    if typeof(connection) == "RBXScriptConnection" then
                        connection:Disconnect()
                    end
                end
                
                if self.Frame and self.Frame.Parent then
                    self.Frame:Destroy()
                end
                
                local tabButton = tabContainer:FindFirstChild("TabButton_" .. self.Name)
                if tabButton then
                    tabButton:Destroy()
                end
            end
            
            Window.Tabs[Tab.Name] = Tab
            
            -- Auto-select first tab
            if next(Window.Tabs) and not Window.CurrentTab then
                wait(0.1)
                tabButton.MouseButton1Click()
            end
            
            return Tab
        end
        
        -- Store window elements
        Window.Elements.MainContainer = mainContainer
        Window.Elements.ScreenGui = screenGui
        Window.Elements.WindowFrame = windowFrame
        Window.Elements.Header = header
        Window.Elements.BlurFrame = blurFrame
        Window.Elements.Sidebar = sidebar
        Window.Elements.ContentArea = contentArea
        
        -- Initialize window
        AnimateWindowIn()
        
        -- Show welcome message after window is created
        spawn(function()
            wait(1)
            ZynoxClient:ShowAutoWelcome()
        end)
        
        -- Add to windows list
        table.insert(ZynoxClient.Windows, Window)
        
        return Window
    end)
    
    if success then
        return window
    else
        self:CreateNotification({
            Type = "Error",
            Title = "Window Creation Failed",
            Message = "Failed to create window. Check console for details.",
            Duration = 5
        })
        return nil
    end
end

-- Welcome message settings functions
function ZynoxClient:SetWelcomeEnabled(enabled)
    self.WelcomeSystem.Enabled = enabled
    self:SaveSettings()
end

function ZynoxClient:SetWelcomeOnFirstLaunch(enabled)
    self.WelcomeSystem.ShowOnFirstLaunch = enabled
    self:SaveSettings()
end

function ZynoxClient:SetWelcomeOnEveryLaunch(enabled)
    self.WelcomeSystem.ShowOnEveryLaunch = enabled
    self:SaveSettings()
end

function ZynoxClient:SetCustomWelcomeMessage(title, message, subMessage, icon)
    self.WelcomeSystem.Templates.Custom.Title = title or "Custom Welcome"
    self.WelcomeSystem.Templates.Custom.Message = message or "Your custom message here."
    self.WelcomeSystem.Templates.Custom.SubMessage = subMessage or "Customize this in settings."
    self.WelcomeSystem.Templates.Custom.Icon = icon or "💎"
    self:SaveSettings()
end

function ZynoxClient:ShowWelcome(messageType)
    self:CreateWelcomeMessage(messageType or "Custom")
end

function ZynoxClient:SetTheme(themeName)
    if Themes[themeName] then
        self.Settings.Theme = themeName
        self:SaveSettings()
        
        self:CreateNotification({
            Type = "Success",
            Title = "Theme Changed",
            Message = "Theme set to " .. themeName,
            Duration = 3
        })
    else
        self:CreateNotification({
            Type = "Error",
            Title = "Invalid Theme",
            Message = "Theme '" .. tostring(themeName) .. "' not found",
            Duration = 3
        })
    end
end

-- Initialize settings on load
ZynoxClient:LoadSettings()

-- Client-side cleanup when player leaves
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        ZynoxClient:SaveSettings()
        
        -- Cleanup all windows
        for _, window in ipairs(ZynoxClient.Windows) do
            if window.Destroy then
                window:Destroy()
            end
        end
        
        -- Cancel all active tweens
        for _, tween in ipairs(Animations.ActiveTweens) do
            if tween then
                tween:Cancel()
            end
        end
    end
end)

return ZynoxClient
