-- Zynox UI Library - Easy-to-use Roblox GUI Library
-- Version 2.0 - Modular and Simplified

local ZynoxUI = {}
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Default theme
local Theme = {
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
    Error = Color3.fromRGB(220, 53, 69)
}

-- Main UI Class
local UI = {}
UI.__index = UI

function ZynoxUI.new(config)
    local self = setmetatable({}, UI)
    
    -- Configuration with defaults
    self.config = {
        title = config.title or "Zynox UI",
        size = config.size or {850, 550},
        theme = config.theme or Theme,
        draggable = config.draggable ~= false,
        resizable = config.resizable or false,
        showWelcome = config.showWelcome ~= false
    }
    
    self.tabs = {}
    self.currentTab = nil
    self.elements = {}
    
    self:_createUI()
    if self.config.showWelcome then
        self:_showWelcome()
    end
    
    return self
end

function UI:_createUI()
    -- Remove existing UI
    local existing = Player.PlayerGui:FindFirstChild("ZynoxUI")
    if existing then existing:Destroy() end
    
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ZynoxUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = Player.PlayerGui
    
    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, self.config.size[1], 0, self.config.size[2])
    self.mainFrame.Position = UDim2.new(0.5, -self.config.size[1]/2, 0.5, -self.config.size[2]/2)
    self.mainFrame.BackgroundColor3 = self.config.theme.Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui
    
    -- Styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 2
    stroke.Transparency = 0.8
    stroke.Parent = self.mainFrame
    
    self:_createTopBar()
    self:_createSidebar()
    self:_createTabContainer()
    self:_setupDragging()
    self:_setupAnimations()
end

function UI:_createTopBar()
    self.topBar = Instance.new("Frame")
    self.topBar.Name = "TopBar"
    self.topBar.Size = UDim2.new(1, 0, 0, 40)
    self.topBar.BackgroundColor3 = self.config.theme.Surface
    self.topBar.BorderSizePixel = 0
    self.topBar.Parent = self.mainFrame
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.config.theme.Primary),
        ColorSequenceKeypoint.new(1, self.config.theme.Secondary)
    })
    gradient.Rotation = 90
    gradient.Parent = self.topBar
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.config.title
    title.TextColor3 = self.config.theme.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.topBar
    
    self:_createWindowControls()
end

function UI:_createWindowControls()
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 46, 1, 0)
    closeBtn.Position = UDim2.new(1, -46, 0, 0)
    closeBtn.BackgroundColor3 = self.config.theme.Surface
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = self.config.theme.Text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = self.topBar
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 46, 1, 0)
    minimizeBtn.Position = UDim2.new(1, -92, 0, 0)
    minimizeBtn.BackgroundColor3 = self.config.theme.Surface
    minimizeBtn.Text = "–"
    minimizeBtn.TextColor3 = self.config.theme.Text
    minimizeBtn.TextSize = 22
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = self.topBar
    
    -- Button functionality
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    local isMinimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
        isMinimized = not isMinimized
    end)
    
    -- Hover effects
    self:_addHoverEffect(closeBtn, self.config.theme.Error)
    self:_addHoverEffect(minimizeBtn, Color3.fromRGB(60, 60, 70))
end

function UI:_createSidebar()
    self.sidebar = Instance.new("Frame")
    self.sidebar.Name = "Sidebar"
    self.sidebar.Size = UDim2.new(0, 200, 1, -40)
    self.sidebar.Position = UDim2.new(0, 0, 0, 40)
    self.sidebar.BackgroundColor3 = self.config.theme.Sidebar
    self.sidebar.BorderSizePixel = 0
    self.sidebar.Parent = self.mainFrame
    
    -- Sidebar container
    self.sidebarContainer = Instance.new("ScrollingFrame")
    self.sidebarContainer.Size = UDim2.new(1, 0, 1, 0)
    self.sidebarContainer.BackgroundTransparency = 1
    self.sidebarContainer.ScrollBarThickness = 4
    self.sidebarContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    self.sidebarContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.sidebarContainer.Parent = self.sidebar
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = self.sidebarContainer
end

function UI:_createTabContainer()
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContainer"
    self.tabContainer.Size = UDim2.new(1, -200, 1, -40)
    self.tabContainer.Position = UDim2.new(0, 200, 0, 40)
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

function UI:AddButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = self.config.theme.Surface
    button.Text = text
    button.TextColor3 = self.config.theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = tab.content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    self:_addHoverEffect(button, self.config.theme.Primary)
    
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
    label.TextColor3 = self.config.theme.Text
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
        local goalColor = isToggled and self.config.theme.Accent or Color3.fromRGB(50, 50, 58)
        
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
    label.TextColor3 = self.config.theme.Text
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
    fill.BackgroundColor3 = self.config.theme.Accent
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

-- Helper Methods
function UI:_createSidebarButton(text, icon, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    button.Text = "  " .. icon .. "  " .. text
    button.TextColor3 = self.config.theme.TextSecondary
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.Parent = self.sidebarContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    self:_addHoverEffect(button, self.config.theme.Primary)
    
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
        BackgroundColor3 = self.config.theme.Primary
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
    welcomeFrame.BackgroundColor3 = self.config.theme.Background
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
    text.TextColor3 = self.config.theme.Text
    text.TextSize = 24
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.Parent = welcomeFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.config.theme.Primary),
        ColorSequenceKeypoint.new(1, self.config.theme.Secondary)
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

-- Public Methods
function UI:Close()
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
            Size = UDim2.new(0, self.config.size[1], 0, 40)
        }):Play()
    end
end

function UI:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        self.config.theme[key] = value
    end
    -- You could add theme update logic here
end

return ZynoxUI
