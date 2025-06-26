-- Zynox UI Library - Enhanced Tabs Version 3.1
-- Improved tab system with better visuals and animations

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
        Shadow = Color3.fromRGB(255, 0, 255),
        TabActive = Color3.fromRGB(255, 0, 255),
        TabHover = Color3.fromRGB(40, 20, 40),
        TabInactive = Color3.fromRGB(25, 25, 35),
        TabBorder = Color3.fromRGB(100, 0, 100)
    }
}

-- Background Animation System (keeping the same as before)
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
    -- Enhanced Sidebar with better styling
    self.sidebar = Instance.new("Frame")
    self.sidebar.Name = "EnhancedSidebar"
    self.sidebar.Size = UDim2.new(0, 220, 1, -45)
    self.sidebar.Position = UDim2.new(0, 0, 0, 45)
    self.sidebar.BackgroundColor3 = self.theme.Sidebar
    self.sidebar.BorderSizePixel = 0
    self.sidebar.ZIndex = 2
    self.sidebar.Parent = self.parent
    
    -- Add subtle gradient to sidebar
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
    
    -- Sidebar header
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
    
    -- Enhanced scrolling container
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
    
    -- Enhanced layout with better spacing
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = self.sidebarContainer
    
    -- Add padding to container
    local containerPadding = Instance.new("UIPadding")
    containerPadding.PaddingTop = UDim.new(0, 15)
    containerPadding.PaddingBottom = UDim.new(0, 15)
    containerPadding.PaddingLeft = UDim.new(0, 10)
    containerPadding.PaddingRight = UDim.new(0, 10)
    containerPadding.Parent = self.sidebarContainer
    
    -- Enhanced Tab Content Container
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContentContainer"
    self.tabContainer.Size = UDim2.new(1, -220, 1, -45)
    self.tabContainer.Position = UDim2.new(0, 220, 0, 45)
    self.tabContainer.BackgroundColor3 = self.theme.Background
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.ClipsDescendants = true
    self.tabContainer.ZIndex = 1
    self.tabContainer.Parent = self.parent
    
    -- Add subtle border between sidebar and content
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
    
    -- Create enhanced tab frame
    tab.frame = Instance.new("Frame")
    tab.frame.Name = name .. "TabContent"
    tab.frame.Size = UDim2.new(1, 0, 1, 0)
    tab.frame.BackgroundTransparency = 1
    tab.frame.Visible = false
    tab.frame.ZIndex = 1
    tab.frame.Parent = self.tabContainer
    
    -- Add fade transition frame
    local fadeFrame = Instance.new("Frame")
    fadeFrame.Name = "FadeFrame"
    fadeFrame.Size = UDim2.new(1, 0, 1, 0)
    fadeFrame.BackgroundColor3 = self.theme.Background
    fadeFrame.BackgroundTransparency = 1
    fadeFrame.BorderSizePixel = 0
    fadeFrame.ZIndex = 2
    fadeFrame.Parent = tab.frame
    
    -- Enhanced scrollable content with better styling
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
    
    -- Enhanced layout with better spacing
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.Parent = scrollFrame
    
    -- Add content padding
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 20)
    contentPadding.PaddingLeft = UDim.new(0, 5)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.Parent = scrollFrame
    
    tab.content = scrollFrame
    tab.fadeFrame = fadeFrame
    
    -- Create enhanced tab button
    tab.button = self:_createEnhancedTabButton(tab)
    
    table.insert(self.tabs, tab)
    self.tabButtons[name] = tab.button
    
    -- Auto-select first tab with animation
    if #self.tabs == 1 then
        task.spawn(function()
            task.wait(0.1) -- Small delay for UI to settle
            self:SwitchToTab(tab, false) -- No animation for first tab
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
    
    -- Enhanced styling with rounded corners and border
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.TabBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = button
    
    -- Icon container
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
    
    -- Text label with better positioning
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
    
    -- Active indicator
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
    
    -- Hover glow effect
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
    
    -- Store references for animations
    button.IconLabel = iconLabel
    button.TextLabel = textLabel
    button.ActiveIndicator = activeIndicator
    button.GlowFrame = glowFrame
    button.Stroke = stroke
    
    -- Enhanced hover effects
    local isHovering = false
    local isActive = false
    
    button.MouseEnter:Connect(function()
        if self.isAnimating then return end
        isHovering = true
        
        if not isActive then
            -- Hover animation
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
            -- Unhover animation
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
    
    -- Click functionality
    button.MouseButton1Click:Connect(function()
        if self.isAnimating then return end
        self:SwitchToTab(tab, true)
    end)
    
    -- Store state for reference
    button.IsActive = function() return isActive end
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
    
    animate = animate ~= false -- Default to true
    self.isAnimating = animate
    
    local previousTab = self.currentTab
    
    -- Update button states
    if previousTab and previousTab.button then
        previousTab.button.SetActive(false)
    end
    
    if targetTab.button then
        targetTab.button.SetActive(true)
    end
    
    if animate and previousTab then
        -- Smooth transition animation
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
        -- Instant switch
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
    
    -- Update sidebar colors
    if self.sidebar then
        self.sidebar.BackgroundColor3 = newTheme.Sidebar
    end
    
    if self.tabContainer then
        self.tabContainer.BackgroundColor3 = newTheme.Background
    end
    
    -- Update all tab buttons
    for _, tab in pairs(self.tabs) do
        if tab.button then
            -- Update button colors based on current state
            if tab == self.currentTab then
                tab.button.SetActive(true)
            else
                tab.button.SetActive(false)
            end
        end
    end
end

-- Main UI Class (Enhanced)
local UI = {}
UI.__index = UI

function ZynoxUI.new(config)
    local self = setmetatable({}, UI)
    
    self.config = {
        title = config.title or "Zynox UI",
        size = config.size or {900, 650}, -- Slightly larger for better tab display
        theme = config.theme or "Dark",
        draggable = config.draggable ~= false,
        resizable = config.resizable or false,
        showWelcome = config.showWelcome ~= false,
        saveConfig = config.saveConfig ~= false,
        configName = config.configName or "ZynoxConfig",
        keybind = config.keybind or Enum.KeyCode.RightControl,
        mobileSupport = config.mobileSupport ~= false,
        notifications = config.notifications ~= false,
        backgroundAnimation = config.backgroundAnimation or "gradient"
    }
    
    self.elements = {}
    self.isVisible = true
    self.savedConfig = {}
    self.backgroundAnimator = nil
    self.tabManager = nil
    
    self:_createUI()
    self:_setupKeybind()
    self:_setupMobileSupport()
    
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
    
    -- Create ScreenGui in CoreGui
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
    
    -- Enhanced Main Frame
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
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = self.mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[self.config.theme].Primary
    stroke.Thickness = 2
    stroke.Transparency = 0.3
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
    
    -- Initialize enhanced tab manager
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
    
    -- Enhanced gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Themes[self.config.theme].Primary),
        ColorSequenceKeypoint.new(1, Themes[self.config.theme].Secondary)
    })
    gradient.Rotation = 45
    gradient.Parent = self.topBar
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 250, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.config.title .. " v3.1"
    title.TextColor3 = Themes[self.config.theme].Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = self.topBar
    
    self:_createWindowControls()
end

function UI:_createWindowControls()
    -- Window controls (same as before but with updated Z-index)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 140, 1, 0)
    controlsFrame.Position = UDim2.new(1, -140, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.ZIndex = 6
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
    themeBtn.ZIndex = 7
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
    minimizeBtn.ZIndex = 7
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
    closeBtn.ZIndex = 7
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
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Enhanced hover effects
    self:_addHoverEffect(themeBtn, Themes[self.config.theme].Primary)
    self:_addHoverEffect(minimizeBtn, Themes[self.config.theme].Warning)
    self:_addHoverEffect(closeBtn, Themes[self.config.theme].Error)
end

-- Public Methods (Updated to use TabManager)
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
    end
    
    return {
        Set = function(newText) label.Text = newText end,
        Get = function() return label.Text end,
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
    
    -- Enhanced hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Themes[self.config.theme].Primary
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0,
            Thickness = 2
        }):Play()
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
        button.MouseButton1Click:Connect(callback)
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
    end)
    
    updateToggle()
    return {Set = function(value) isToggled = value; updateToggle() end, Get = function() return isToggled end}
end

-- Helper Methods
function UI:_addHoverEffect(button, hoverColor)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
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
    text.Text = "🎉 Welcome to " .. self.config.title .. "!\nEnhanced Tab System v3.1"
    text.TextColor3 = Themes[self.config.theme].Text
    text.TextSize = 18
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
end

function UI:SetTheme(themeName)
    if not Themes[themeName] then return end
    
    self.config.theme = themeName
    local newTheme = Themes[themeName]
    
    -- Update tab manager theme
    if self.tabManager then
        self.tabManager:UpdateTheme(newTheme)
    end
    
    -- Update background animation
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
    
    -- Update main frame colors
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
end

return ZynoxUI
