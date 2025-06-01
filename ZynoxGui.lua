--[[
    Zynox UI - A Modern Roblox UI Library
    Created by Cascade AI
    
    Usage:
    local ZynoxUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/YourUsername/ZynoxUI/main/ZynoxUI.lua'))()
    
    local Window = ZynoxUI:CreateWindow({
        Name = "Zynox Example",
        LoadingTitle = "Zynox UI",
        LoadingSubtitle = "by Cascade AI",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "ZynoxUI",
            FileName = "ZynoxExample"
        }
    })
    
    local Tab = Window:CreateTab("Example Tab", "rbxassetid://7059346373")
    
    local Toggle = Tab:CreateToggle({
        Name = "Example Toggle",
        Description = "This is an example toggle",
        CurrentValue = false,
        Callback = function(Value)
            print(Value)
        end
    })
]]--

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenInfo_Normal = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Main ZynoxUI module
local ZynoxUI = {
    Windows = {},
    Flags = {},
    ConfigurationFolder = "ZynoxUI",
    ConfigurationSaving = false
}
-- Default theme
ZynoxUI.Theme = {
    -- Main colors
    Primary = Color3.fromRGB(22, 27, 34),       -- Dark blue-gray
    Secondary = Color3.fromRGB(48, 54, 61),     -- Medium blue-gray
    Accent = Color3.fromRGB(88, 166, 255),      -- Soft blue
    AccentDark = Color3.fromRGB(56, 139, 233),  -- Darker blue for gradients
    
    -- Text colors
    Text = Color3.fromRGB(255, 255, 255),       -- White
    TextDark = Color3.fromRGB(210, 210, 215),   -- Light gray
    TextMuted = Color3.fromRGB(160, 160, 180),  -- Muted text
    
    -- Background colors
    Background = Color3.fromRGB(30, 33, 40),    -- Dark background
    BackgroundLight = Color3.fromRGB(38, 41, 49), -- Lighter background for contrast
    
    -- Additional colors
    Success = Color3.fromRGB(87, 217, 163),     -- Green for success states
    Warning = Color3.fromRGB(255, 188, 66),     -- Orange for warnings
    Error = Color3.fromRGB(240, 71, 90),        -- Red for errors
    
    -- UI Element colors
    ButtonHover = Color3.fromRGB(58, 64, 74),   -- Button hover state
    ButtonActive = Color3.fromRGB(68, 74, 84),  -- Button active state
    InputField = Color3.fromRGB(35, 38, 45),    -- Input field background
    
    -- Corner radius
    CornerRadius = UDim.new(0, 8),              -- Consistent corner radius
    SmallCornerRadius = UDim.new(0, 6),         -- Smaller corner radius for buttons
    
    -- Padding
    Padding = UDim.new(0, 12)                   -- Consistent padding
}

-- Utilities
ZynoxUI.Utilities = {}

-- Create a gradient
function ZynoxUI.Utilities.CreateGradient(parent, colorStart, colorEnd, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorStart),
        ColorSequenceKeypoint.new(1, colorEnd)
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

-- Create a shadow
function ZynoxUI.Utilities.CreateShadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 30, 1, size or 30)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- Create a blur effect
function ZynoxUI.Utilities.CreateBlur(parent, size)
    local blur = Instance.new("BlurEffect")
    blur.Size = size or 10
    blur.Parent = parent
    return blur
end

-- Create a pulsing animation
function ZynoxUI.Utilities.CreatePulse(object, property, min, max, duration)
    local tweenInfo = TweenInfo.new(duration or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(object, tweenInfo, {[property] = max})
    tween:Play()
    return tween
end

-- Create hover effect for buttons
function ZynoxUI.Utilities.CreateHoverEffect(button, defaultColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo_Fast, {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo_Fast, {
            BackgroundColor3 = defaultColor
        }):Play()
    end)
end

-- Create ripple effect
function ZynoxUI.Utilities.CreateRipple(button)
    button.ClipsDescendants = true
    
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Parent = button
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.ZIndex = button.ZIndex + 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        
        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }):Play()
        
        game.Debris:AddItem(ripple, 1)
    end)
end

-- Window Creation
function ZynoxUI:CreateWindow(options)
    options = options or {}
    
    -- Default options
    local windowOptions = {
        Name = options.Name or "Zynox UI",
        LoadingTitle = options.LoadingTitle or "Zynox UI",
        LoadingSubtitle = options.LoadingSubtitle or "Zynox UI",
        ConfigurationSaving = options.ConfigurationSaving or {
            Enabled = false,
            FolderName = self.ConfigurationFolder,
            FileName = "Config"
        }
    }
    
    -- Set up configuration saving
    if windowOptions.ConfigurationSaving.Enabled then
        self.ConfigurationSaving = true
        self.ConfigurationFolder = windowOptions.ConfigurationSaving.FolderName
        self.ConfigurationFile = windowOptions.ConfigurationSaving.FileName
        
        -- Create folder if it doesn't exist
        pcall(function()
            if not isfolder(self.ConfigurationFolder) then
                makefolder(self.ConfigurationFolder)
            end
        end)
    end
    
    -- Create window object
    local Window = {}
    Window.Tabs = {}
    Window.TabsObjects = {}
    Window.Name = windowOptions.Name
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynoxUI_" .. HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Try to parent to CoreGui if possible (for exploits)
    local success, result = pcall(function()
        ScreenGui.Parent = CoreGui
        return true
    end)
    
    if not success then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    Window.ScreenGui = ScreenGui
    
    -- Create main frame
    local Frame = Instance.new("Frame")
    Frame.Name = "MainFrame"
    Frame.Size = UDim2.new(0, 790, 0, 455)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = self.Theme.Primary
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    
    -- Add rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = self.Theme.CornerRadius
    UICorner.Parent = Frame
    
    -- Add shadow
    self.Utilities.CreateShadow(Frame, 30, 0.5)
    
    -- Create title frame
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Name = "TitleFrame"
    TitleFrame.Size = UDim2.new(1, 0, 0, 48)
    TitleFrame.BackgroundColor3 = self.Theme.Accent
    TitleFrame.BorderSizePixel = 0
    TitleFrame.ZIndex = 2
    TitleFrame.Parent = Frame
    
    -- Add rounded corners to title frame
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = self.Theme.CornerRadius
    TitleCorner.Parent = TitleFrame
    
    -- Fix the bottom corners of title frame
    local TitleFrameBottomFix = Instance.new("Frame")
    TitleFrameBottomFix.Name = "BottomFix"
    TitleFrameBottomFix.Size = UDim2.new(1, 0, 0, 10)
    TitleFrameBottomFix.Position = UDim2.new(0, 0, 1, -10)
    TitleFrameBottomFix.BackgroundColor3 = self.Theme.Accent
    TitleFrameBottomFix.BorderSizePixel = 0
    TitleFrameBottomFix.ZIndex = 2
    TitleFrameBottomFix.Parent = TitleFrame
    
    -- Add gradient to title frame
    self.Utilities.CreateGradient(TitleFrame, self.Theme.Accent, self.Theme.AccentDark, 45)
    self.Utilities.CreateGradient(TitleFrameBottomFix, self.Theme.Accent, self.Theme.AccentDark, 45)
    
    -- Title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -100, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = windowOptions.Name
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 22
    TitleText.TextColor3 = self.Theme.Primary
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 3
    TitleText.Parent = TitleFrame
    
    Window.TitleText = TitleText
    Window.Frame = Frame
    
    -- Close Button with improved styling
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 36, 0, 36)
    CloseButton.Position = UDim2.new(1, 0, 0.5, 0)
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.BackgroundColor3 = self.Theme.Primary
    CloseButton.BackgroundTransparency = 0.2
    CloseButton.Text = ""
    CloseButton.TextColor3 = self.Theme.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.ZIndex = 3
    CloseButton.Parent = TitleFrame
    
    -- Add rounded corners to close button
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = self.Theme.SmallCornerRadius
    CloseCorner.Parent = CloseButton
    
    -- Close icon (X)
    local CloseIcon = Instance.new("Frame")
    CloseIcon.Name = "CloseIcon"
    CloseIcon.Size = UDim2.new(0, 14, 0, 14)
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.ZIndex = 3
    CloseIcon.Parent = CloseButton
    
    -- Create X shape with two lines
    local Line1 = Instance.new("Frame")
    Line1.Size = UDim2.new(0, 14, 0, 2)
    Line1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Line1.AnchorPoint = Vector2.new(0.5, 0.5)
    Line1.BackgroundColor3 = self.Theme.Text
    Line1.BorderSizePixel = 0
    Line1.Rotation = 45
    Line1.ZIndex = 3
    Line1.Parent = CloseIcon
    
    local Line2 = Instance.new("Frame")
    Line2.Size = UDim2.new(0, 14, 0, 2)
    Line2.Position = UDim2.new(0.5, 0, 0.5, 0)
    Line2.AnchorPoint = Vector2.new(0.5, 0.5)
    Line2.BackgroundColor3 = self.Theme.Text
    Line2.BorderSizePixel = 0
    Line2.Rotation = -45
    Line2.ZIndex = 3
    Line2.Parent = CloseIcon
    
    -- Add hover effect to close button
    self.Utilities.CreateHoverEffect(CloseButton, self.Theme.Primary, self.Theme.ButtonHover)
    
    -- Minimize Button with improved styling
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 36, 0, 36)
    MinimizeButton.Position = UDim2.new(1, -44, 0.5, 0)
    MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    MinimizeButton.BackgroundColor3 = self.Theme.Primary
    MinimizeButton.BackgroundTransparency = 0.2
    MinimizeButton.Text = ""
    MinimizeButton.TextColor3 = self.Theme.Text
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.ZIndex = 3
    MinimizeButton.Parent = TitleFrame
    
    -- Add rounded corners to minimize button
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = self.Theme.SmallCornerRadius
    MinimizeCorner.Parent = MinimizeButton
    
    -- Minimize icon (line)
    local MinimizeIcon = Instance.new("Frame")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Size = UDim2.new(0, 12, 0, 2)
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinimizeIcon.BackgroundColor3 = self.Theme.Text
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.ZIndex = 3
    MinimizeIcon.Parent = MinimizeButton
    
    -- Add hover effect to minimize button
    self.Utilities.CreateHoverEffect(MinimizeButton, self.Theme.Primary, self.Theme.ButtonHover)
    
    -- Close button functionality with animations
    CloseButton.MouseButton1Click:Connect(function()
        -- Fade out all elements
        for _, child in pairs(Frame:GetChildren()) do
            if child:IsA("GuiObject") then
                TweenService:Create(child, TweenInfo_Fast, {
                    BackgroundTransparency = 1
                }):Play()
            end
        end
        
        -- Shrink animation
        local shrinkTween = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        
        -- Play animations
        shrinkTween:Play()
        
        -- Destroy after animation completes
        shrinkTween.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
        
        -- Add particle effect on close
        local particles = Instance.new("Frame")
        particles.Size = UDim2.new(0, 0, 0, 0)
        particles.Position = UDim2.new(0.5, 0, 0.5, 0)
        particles.AnchorPoint = Vector2.new(0.5, 0.5)
        particles.BackgroundTransparency = 1
        particles.ZIndex = 10
        particles.Parent = Frame
        
        -- Create particle effect
        for i = 1, 10 do
            local particle = Instance.new("Frame")
            particle.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
            particle.Position = UDim2.new(0.5, 0, 0.5, 0)
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            particle.BackgroundColor3 = self.Theme.Accent
            particle.BorderSizePixel = 0
            particle.ZIndex = 10
            particle.Parent = particles
            
            local angle = math.rad(math.random(0, 360))
            local distance = math.random(100, 300)
            
            TweenService:Create(particle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, math.cos(angle) * distance, 0.5, math.sin(angle) * distance),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
        end
    end)
    
    -- Minimize button functionality with smooth animation
    local isMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            -- Save the content for restoration
            for _, child in pairs(Frame:GetChildren()) do
                if child ~= TitleFrame and child:IsA("GuiObject") then
                    TweenService:Create(child, TweenInfo_Fast, {
                        BackgroundTransparency = 1,
                        TextTransparency = 1,
                        ImageTransparency = 1
                    }):Play()
                end
            end
            
            -- Minimize with bounce effect
            TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 790, 0, 48)
            }):Play()
            
            -- Change minimize icon to maximize
            TweenService:Create(MinimizeIcon, TweenInfo_Fast, {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        else
            -- Restore with bounce effect
            TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 790, 0, 455)
            }):Play()
            
            -- Fade content back in with slight delay
            delay(0.2, function()
                for _, child in pairs(Frame:GetChildren()) do
                    if child ~= TitleFrame and child:IsA("GuiObject") then
                        TweenService:Create(child, TweenInfo_Normal, {
                            BackgroundTransparency = 0,
                            TextTransparency = 0,
                            ImageTransparency = 0
                        }):Play()
                    end
                end
            end)
            
            -- Change maximize icon back to minimize
            TweenService:Create(MinimizeIcon, TweenInfo_Fast, {
                Size = UDim2.new(0, 12, 0, 2),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        end
    end)
    
    -- Create tabs frame
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Name = "TabsFrame"
    TabsFrame.Size = UDim2.new(0, 120, 0, 326)
    TabsFrame.Position = UDim2.new(0, 0, 0, 48)
    TabsFrame.BackgroundColor3 = self.Theme.Secondary
    TabsFrame.BorderSizePixel = 0
    TabsFrame.ZIndex = 2
    TabsFrame.Parent = Frame
    
    -- Add gradient to tabs frame
    self.Utilities.CreateGradient(TabsFrame, self.Theme.Secondary, Color3.fromRGB(
        self.Theme.Secondary.R * 255 - 5,
        self.Theme.Secondary.G * 255 - 5,
        self.Theme.Secondary.B * 255 - 5
    ), 135)
    
    -- Tabs Frame Corner
    local TabsCorner = Instance.new("UICorner")
    TabsCorner.CornerRadius = self.Theme.CornerRadius
    TabsCorner.Parent = TabsFrame
    
    -- Fix the right corners of tabs frame
    local TabsFrameRightFix = Instance.new("Frame")
    TabsFrameRightFix.Name = "RightFix"
    TabsFrameRightFix.Size = UDim2.new(0, 10, 1, 0)
    TabsFrameRightFix.Position = UDim2.new(1, -10, 0, 0)
    TabsFrameRightFix.BackgroundColor3 = self.Theme.Secondary
    TabsFrameRightFix.BorderSizePixel = 0
    TabsFrameRightFix.ZIndex = 2
    TabsFrameRightFix.Parent = TabsFrame
    
    -- Apply gradient to right fix
    self.Utilities.CreateGradient(TabsFrameRightFix, self.Theme.Secondary, Color3.fromRGB(
        self.Theme.Secondary.R * 255 - 5,
        self.Theme.Secondary.G * 255 - 5,
        self.Theme.Secondary.B * 255 - 5
    ), 135)
    
    -- Add inner shadow effect to tabs frame
    local TabsInnerShadow = Instance.new("Frame")
    TabsInnerShadow.Name = "InnerShadow"
    TabsInnerShadow.Size = UDim2.new(1, 0, 1, 0)
    TabsInnerShadow.BackgroundTransparency = 1
    TabsInnerShadow.ZIndex = 2
    TabsInnerShadow.Parent = TabsFrame
    
    -- Tabs Container (scrolling frame)
    local TabsContainer = Instance.new("ScrollingFrame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Size = UDim2.new(1, -16, 1, 0)
    TabsContainer.Position = UDim2.new(0, 8, 0, 0)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.BorderSizePixel = 0
    TabsContainer.ScrollBarThickness = 4
    TabsContainer.ScrollBarImageColor3 = self.Theme.Accent
    TabsContainer.ScrollBarImageTransparency = 0.5
    TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
    TabsContainer.ZIndex = 3
    TabsContainer.Parent = TabsFrame
    
    -- Modern scrolling behavior
    TabsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    TabsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabsContainer.ElasticBehavior = Enum.ElasticBehavior.Always
    TabsContainer.ScrollBarInset = Enum.ScrollBarInset.ScrollBar
    
    -- Tab List Layout with improved spacing
    local TabsListLayout = Instance.new("UIListLayout")
    TabsListLayout.Padding = UDim.new(0, 8)
    TabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabsListLayout.Parent = TabsContainer
    
    -- Add padding to tabs container
    local TabsContainerPadding = Instance.new("UIPadding")
    TabsContainerPadding.PaddingTop = UDim.new(0, 8)
    TabsContainerPadding.PaddingBottom = UDim.new(0, 8)
    TabsContainerPadding.Parent = TabsContainer
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -120, 1, -48)
    ContentFrame.Position = UDim2.new(0, 120, 0, 48)
    ContentFrame.BackgroundColor3 = self.Theme.Background
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ZIndex = 1
    ContentFrame.Parent = Frame
    
    -- Add gradient to content frame
    self.Utilities.CreateGradient(ContentFrame, self.Theme.Background, Color3.fromRGB(
        self.Theme.Background.R * 255 + 5,
        self.Theme.Background.G * 255 + 5,
        self.Theme.Background.B * 255 + 5
    ), 45)
    
    -- Store references
    Window.TabsFrame = TabsFrame
    Window.TabsContainer = TabsContainer
    Window.ContentFrame = ContentFrame
    
    -- Tab creation function
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Elements = {}
        Tab.Name = name
        Tab.Icon = icon or ""
        
        -- Create tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Size = UDim2.new(1, -16, 0, 36)
        TabButton.BackgroundColor3 = self.Parent.Theme.ButtonHover
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.ZIndex = 3
        TabButton.Parent = self.TabsContainer
        
        -- Add rounded corners
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = self.Parent.Theme.SmallCornerRadius
        TabCorner.Parent = TabButton
        
        -- Tab icon
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 8, 0.5, 0)
        TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = icon or ""
        TabIcon.ImageColor3 = self.Parent.Theme.TextDark
        TabIcon.ZIndex = 3
        TabIcon.Parent = TabButton
        
        -- Tab text
        local TabText = Instance.new("TextLabel")
        TabText.Name = "Text"
        TabText.Size = UDim2.new(1, icon and -36 or -16, 1, 0)
        TabText.Position = UDim2.new(0, icon and 36 or 8, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = name
        TabText.Font = Enum.Font.GothamSemibold
        TabText.TextSize = 14
        TabText.TextColor3 = self.Parent.Theme.TextDark
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.ZIndex = 3
        TabText.Parent = TabButton
        
        -- Active indicator
        local ActiveIndicator = Instance.new("Frame")
        ActiveIndicator.Name = "ActiveIndicator"
        ActiveIndicator.Size = UDim2.new(0, 4, 0.7, 0)
        ActiveIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        ActiveIndicator.AnchorPoint = Vector2.new(0, 0.5)
        ActiveIndicator.BackgroundColor3 = self.Parent.Theme.Accent
        ActiveIndicator.BorderSizePixel = 0
        ActiveIndicator.ZIndex = 3
        ActiveIndicator.Visible = false
        ActiveIndicator.Parent = TabButton
        
        -- Add rounded corners to indicator
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = ActiveIndicator
        
        -- Create tab content container
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = self.Parent.Theme.Accent
        TabContent.ScrollBarImageTransparency = 0.5
        TabContent.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        TabContent.ZIndex = 2
        TabContent.Visible = false
        TabContent.Parent = self.ContentFrame
        
        -- Modern scrolling behavior
        TabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        -- Add list layout to tab content
        local ContentListLayout = Instance.new("UIListLayout")
        ContentListLayout.Padding = UDim.new(0, 10)
        ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ContentListLayout.Parent = TabContent
        
        -- Add padding to content
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 15)
        ContentPadding.PaddingBottom = UDim.new(0, 15)
        ContentPadding.PaddingLeft = UDim.new(0, 15)
        ContentPadding.PaddingRight = UDim.new(0, 15)
        ContentPadding.Parent = TabContent
        
        -- Store references
        Tab.Button = TabButton
        Tab.Icon = TabIcon
        Tab.Text = TabText
        Tab.Indicator = ActiveIndicator
        Tab.Content = TabContent
        
        -- Tab selection function
        local function SelectTab()
            -- Deselect all tabs
            for _, otherTab in pairs(self.TabsObjects) do
                if otherTab ~= Tab then
                    -- Hide content
                    if otherTab.Content.Visible then
                        TweenService:Create(otherTab.Content, TweenInfo_Fast, {
                            Position = UDim2.new(0.1, 0, 0, 0),
                            BackgroundTransparency = 1
                        }):Play()
                        
                        delay(0.15, function()
                            otherTab.Content.Visible = false
                        end)
                    end
                    
                    -- Reset button styling
                    TweenService:Create(otherTab.Button, TweenInfo_Fast, {
                        BackgroundTransparency = 1
                    }):Play()
                    
                    TweenService:Create(otherTab.Text, TweenInfo_Fast, {
                        TextColor3 = self.Parent.Theme.TextDark
                    }):Play()
                    
                    TweenService:Create(otherTab.Icon, TweenInfo_Fast, {
                        ImageColor3 = self.Parent.Theme.TextDark
                    }):Play()
                    
                    otherTab.Indicator.Visible = false
                end
            end
            
            -- Select this tab
            Tab.Content.Position = UDim2.new(-0.1, 0, 0, 0)
            Tab.Content.Visible = true
            
            -- Animate content in
            TweenService:Create(Tab.Content, TweenInfo_Normal, {
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 0
            }):Play()
            
            -- Style button as active
            TweenService:Create(Tab.Button, TweenInfo_Fast, {
                BackgroundTransparency = 0.8
            }):Play()
            
            TweenService:Create(Tab.Text, TweenInfo_Fast, {
                TextColor3 = self.Parent.Theme.Accent
            }):Play()
            
            TweenService:Create(Tab.Icon, TweenInfo_Fast, {
                ImageColor3 = self.Parent.Theme.Accent
            }):Play()
            
            Tab.Indicator.Visible = true
            
            -- Add pulsing animation to indicator
            self.Parent.Utilities.CreatePulse(Tab.Indicator, "Transparency", 0.4, 0, 1.5)
        end
        
        -- Connect tab button
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        -- Add hover effect
        TabButton.MouseEnter:Connect(function()
            if not Tab.Content.Visible then
                TweenService:Create(TabButton, TweenInfo_Fast, {
                    BackgroundTransparency = 0.9
                }):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not Tab.Content.Visible then
                TweenService:Create(TabButton, TweenInfo_Fast, {
                    BackgroundTransparency = 1
                }):Play()
            end
        end)
        
        -- Add ripple effect
        self.Parent.Utilities.CreateRipple(TabButton)
        
        -- Add to tabs collection
        table.insert(self.Tabs, name)
        self.TabsObjects[name] = Tab
        
        -- Select first tab by default
        if #self.Tabs == 1 then
            SelectTab()
        end
        
        -- Methods for creating UI elements
        function Tab:CreateToggle(options)
            options = options or {}
            
            -- Default options
            local toggleOptions = {
                Name = options.Name or "Toggle",
                Description = options.Description or "",
                CurrentValue = options.CurrentValue or false,
                Callback = options.Callback or function() end,
                Flag = options.Flag or nil
            }
            
            -- Save flag if provided
            if toggleOptions.Flag then
                self.Window.Flags[toggleOptions.Flag] = toggleOptions.CurrentValue
            end
            
            -- Create toggle container
            local ToggleContainer = Instance.new("Frame")
            ToggleContainer.Name = "Toggle_" .. toggleOptions.Name
            ToggleContainer.Size = UDim2.new(1, 0, 0, 50) -- Height depends on description
            ToggleContainer.BackgroundColor3 = self.Window.Theme.Secondary
            ToggleContainer.BackgroundTransparency = 0.8
            ToggleContainer.BorderSizePixel = 0
            ToggleContainer.Parent = self.Container
            
            -- Apply corner radius
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = self.Window.Theme.SmallCornerRadius
            ToggleCorner.Parent = ToggleContainer
            
            -- Toggle padding
            local TogglePadding = Instance.new("UIPadding")
            TogglePadding.PaddingTop = UDim.new(0, 10)
            TogglePadding.PaddingBottom = UDim.new(0, 10)
            TogglePadding.PaddingLeft = UDim.new(0, 12)
            TogglePadding.PaddingRight = UDim.new(0, 12)
            TogglePadding.Parent = ToggleContainer
            
            -- Toggle title
            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.Name = "Title"
            ToggleTitle.Size = UDim2.new(1, -60, 0, 18)
            ToggleTitle.Position = UDim2.new(0, 0, 0, 0)
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Text = toggleOptions.Name
            ToggleTitle.TextColor3 = self.Window.Theme.Text
            ToggleTitle.TextSize = 16
            ToggleTitle.Font = Enum.Font.GothamMedium
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToggleTitle.Parent = ToggleContainer
            
            -- Adjust container height based on description
            local hasDescription = toggleOptions.Description ~= ""
            if hasDescription then
                ToggleContainer.Size = UDim2.new(1, 0, 0, 65)
                
                -- Toggle description
                local ToggleDescription = Instance.new("TextLabel")
                ToggleDescription.Name = "Description"
                ToggleDescription.Size = UDim2.new(1, -60, 0, 16)
                ToggleDescription.Position = UDim2.new(0, 0, 0, 22)
                ToggleDescription.BackgroundTransparency = 1
                ToggleDescription.Text = toggleOptions.Description
                ToggleDescription.TextColor3 = self.Window.Theme.TextMuted
                ToggleDescription.TextSize = 14
                ToggleDescription.Font = Enum.Font.Gotham
                ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
                ToggleDescription.TextWrapped = true
                ToggleDescription.Parent = ToggleContainer
            end
            
            -- Toggle switch background
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Size = UDim2.new(0, 40, 0, 22)
            ToggleFrame.Position = UDim2.new(1, -40, 0, 0)
            ToggleFrame.AnchorPoint = Vector2.new(1, 0)
            ToggleFrame.BackgroundColor3 = self.Window.Theme.InputField
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = ToggleContainer
            
            -- Apply corner radius to toggle frame
            local ToggleFrameCorner = Instance.new("UICorner")
            ToggleFrameCorner.CornerRadius = UDim.new(1, 0)
            ToggleFrameCorner.Parent = ToggleFrame
            
            -- Create toggle indicator
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "Indicator"
            ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            ToggleIndicator.Position = UDim2.new(0, 3, 0, 3)
            ToggleIndicator.BackgroundColor3 = self.Window.Theme.Text
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleFrame
            
            -- Apply corner radius to indicator
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(1, 0)
            IndicatorCorner.Parent = ToggleIndicator
            
            -- Make the entire container clickable
            ToggleContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Toggle the value
                    toggleOptions.CurrentValue = not toggleOptions.CurrentValue
                    
                    -- Update visual state
                    UpdateToggleVisual(toggleOptions.CurrentValue)
                    
                    -- Save to flags
                    if toggleOptions.Flag then
                        self.Window.Flags[toggleOptions.Flag] = toggleOptions.CurrentValue
                    end
                    
                    -- Call the callback
                    toggleOptions.Callback(toggleOptions.CurrentValue)
                end
            end)
            
            -- Add hover effect
            ToggleContainer.MouseEnter:Connect(function()
                TweenService:Create(ToggleContainer, TweenInfo_Fast, {
                    BackgroundTransparency = 0.7
                }):Play()
            end)
            
            ToggleContainer.MouseLeave:Connect(function()
                TweenService:Create(ToggleContainer, TweenInfo_Fast, {
                    BackgroundTransparency = 0.8
                }):Play()
            end)
            
            -- Function to update the visual state of the toggle
            function UpdateToggleVisual(value)
                local targetPosition = value and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
                local targetColor = value and self.Window.Theme.Accent or self.Window.Theme.Text
                local frameColor = value and self.Window.Theme.Accent or self.Window.Theme.InputField
                frameColor = value and Color3.fromRGB(
                    self.Window.Theme.Accent.R * 255 - 40,
                    self.Window.Theme.Accent.G * 255 - 40,
                    self.Window.Theme.Accent.B * 255 - 40
                ) or self.Window.Theme.InputField
                
                TweenService:Create(ToggleIndicator, TweenInfo_Normal, {
                    Position = targetPosition,
                    BackgroundColor3 = self.Window.Theme.Text
                }):Play()
                
                TweenService:Create(ToggleFrame, TweenInfo_Normal, {
                    BackgroundColor3 = frameColor
                }):Play()
            end
            
            -- Set initial state
            UpdateToggleVisual(toggleOptions.CurrentValue)
            
            -- Toggle API
            local ToggleAPI = {}
            
            function ToggleAPI:Set(value)
                toggleOptions.CurrentValue = value
                UpdateToggleVisual(value)
                
                -- Save to flags
                if toggleOptions.Flag then
                    self.Window.Flags[toggleOptions.Flag] = value
                end
                
                -- Call the callback
                toggleOptions.Callback(value)
            end
            
            return ToggleAPI
        end
        
        function Tab:CreateButton(options)
            options = options or {}
            
            -- Default options
            local buttonOptions = {
                Name = options.Name or "Button",
                Description = options.Description or "",
                Callback = options.Callback or function() end
            }
            
            -- Create button container
            local ButtonContainer = Instance.new("Frame")
            ButtonContainer.Name = "Button_" .. buttonOptions.Name
            ButtonContainer.Size = UDim2.new(1, 0, 0, 50) -- Height depends on description
            ButtonContainer.BackgroundColor3 = self.Window.Theme.Secondary
            ButtonContainer.BackgroundTransparency = 0.8
            ButtonContainer.BorderSizePixel = 0
            ButtonContainer.Parent = self.Container
            
            -- Apply corner radius
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = self.Window.Theme.SmallCornerRadius
            ButtonCorner.Parent = ButtonContainer
            
            -- Button padding
            local ButtonPadding = Instance.new("UIPadding")
            ButtonPadding.PaddingTop = UDim.new(0, 10)
            ButtonPadding.PaddingBottom = UDim.new(0, 10)
            ButtonPadding.PaddingLeft = UDim.new(0, 12)
            ButtonPadding.PaddingRight = UDim.new(0, 12)
            ButtonPadding.Parent = ButtonContainer
            
            -- Button title
            local ButtonTitle = Instance.new("TextLabel")
            ButtonTitle.Name = "Title"
            ButtonTitle.Size = UDim2.new(1, 0, 0, 18)
            ButtonTitle.Position = UDim2.new(0, 0, 0, 0)
            ButtonTitle.BackgroundTransparency = 1
            ButtonTitle.Text = buttonOptions.Name
            ButtonTitle.TextColor3 = self.Window.Theme.Text
            ButtonTitle.TextSize = 16
            ButtonTitle.Font = Enum.Font.GothamMedium
            ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
            ButtonTitle.Parent = ButtonContainer
            
            -- Adjust container height based on description
            local hasDescription = buttonOptions.Description ~= ""
            if hasDescription then
                ButtonContainer.Size = UDim2.new(1, 0, 0, 65)
                
                -- Button description
                local ButtonDescription = Instance.new("TextLabel")
                ButtonDescription.Name = "Description"
                ButtonDescription.Size = UDim2.new(1, 0, 0, 16)
                ButtonDescription.Position = UDim2.new(0, 0, 0, 22)
                ButtonDescription.BackgroundTransparency = 1
                ButtonDescription.Text = buttonOptions.Description
                ButtonDescription.TextColor3 = self.Window.Theme.TextMuted
                ButtonDescription.TextSize = 14
                ButtonDescription.Font = Enum.Font.Gotham
                ButtonDescription.TextXAlignment = Enum.TextXAlignment.Left
                ButtonDescription.TextWrapped = true
                ButtonDescription.Parent = ButtonContainer
            end
            
            -- Actual button element
            local ButtonElement = Instance.new("TextButton")
            ButtonElement.Name = "ButtonElement"
            ButtonElement.Size = UDim2.new(0, 100, 0, 30)
            ButtonElement.Position = UDim2.new(1, -100, 0.5, 0)
            ButtonElement.AnchorPoint = Vector2.new(1, 0.5)
            ButtonElement.BackgroundColor3 = self.Window.Theme.Accent
            ButtonElement.BorderSizePixel = 0
            ButtonElement.Text = "Execute"
            ButtonElement.TextColor3 = self.Window.Theme.Text
            ButtonElement.TextSize = 14
            ButtonElement.Font = Enum.Font.GothamBold
            ButtonElement.AutoButtonColor = false
            ButtonElement.Parent = ButtonContainer
            
            -- Apply corner radius to button element
            local ButtonElementCorner = Instance.new("UICorner")
            ButtonElementCorner.CornerRadius = self.Window.Theme.SmallCornerRadius
            ButtonElementCorner.Parent = ButtonElement
            
            -- Add gradient to button
            self.Window.Utilities.CreateGradient(ButtonElement, self.Window.Theme.Accent, self.Window.Theme.AccentDark, 45)
            
            -- Add ripple effect to button
            self.Window.Utilities.CreateRipple(ButtonElement)
            
            -- Button click functionality
            ButtonElement.MouseButton1Click:Connect(function()
                -- Visual feedback
                local originalSize = ButtonElement.Size
                local originalPosition = ButtonElement.Position
                
                -- Click animation - slight shrink
                TweenService:Create(ButtonElement, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 95, 0, 28),
                    Position = UDim2.new(1, -97.5, 0.5, 0)
                }):Play()
                
                -- Execute callback
                buttonOptions.Callback()
                
                -- Restore original size after a short delay
                delay(0.1, function()
                    TweenService:Create(ButtonElement, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = originalSize,
                        Position = originalPosition
                    }):Play()
                end)
            end)
            
            -- Container hover effect
            ButtonContainer.MouseEnter:Connect(function()
                TweenService:Create(ButtonContainer, TweenInfo_Fast, {
                    BackgroundTransparency = 0.7
                }):Play()
            end)
            
            ButtonContainer.MouseLeave:Connect(function()
                TweenService:Create(ButtonContainer, TweenInfo_Fast, {
                    BackgroundTransparency = 0.8
                }):Play()
            end)
            
            -- Button hover effect
            ButtonElement.MouseEnter:Connect(function()
                TweenService:Create(ButtonElement, TweenInfo_Fast, {
                    BackgroundColor3 = self.Window.Theme.AccentDark
                }):Play()
            end)
            
            ButtonElement.MouseLeave:Connect(function()
                TweenService:Create(ButtonElement, TweenInfo_Fast, {
                    BackgroundColor3 = self.Window.Theme.Accent
                }):Play()
            end)
            
            -- Button API
            local ButtonAPI = {}
            
            -- Method to fire the button's callback
            function ButtonAPI:Fire()
                buttonOptions.Callback()
            end
            
            return ButtonAPI
        end
        
        function Tab:CreateSlider(options)
            options = options or {}
            
            -- Default options
            local sliderOptions = {
                Name = options.Name or "Slider",
                Description = options.Description or "",
                Range = options.Range or {0, 100},
                Increment = options.Increment or 1,
                CurrentValue = options.CurrentValue or 50,
                ValueSuffix = options.ValueSuffix or "",
                Callback = options.Callback or function() end,
                Flag = options.Flag or nil
            }
            
            -- Validate slider values
            sliderOptions.CurrentValue = math.clamp(sliderOptions.CurrentValue, sliderOptions.Range[1], sliderOptions.Range[2])
            
            -- Save flag if provided
            if sliderOptions.Flag then
                self.Window.Flags[sliderOptions.Flag] = sliderOptions.CurrentValue
            end
            
            -- Create slider container
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Name = "Slider_" .. sliderOptions.Name
            SliderContainer.Size = UDim2.new(1, 0, 0, 60) -- Height depends on description
            SliderContainer.BackgroundColor3 = self.Window.Theme.Secondary
            SliderContainer.BackgroundTransparency = 0.8
            SliderContainer.BorderSizePixel = 0
            SliderContainer.Parent = self.Container
            
            -- Apply corner radius
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = self.Window.Theme.SmallCornerRadius
            SliderCorner.Parent = SliderContainer
            
            -- Slider padding
            local SliderPadding = Instance.new("UIPadding")
            SliderPadding.PaddingTop = UDim.new(0, 10)
            SliderPadding.PaddingBottom = UDim.new(0, 10)
            SliderPadding.PaddingLeft = UDim.new(0, 12)
            SliderPadding.PaddingRight = UDim.new(0, 12)
            SliderPadding.Parent = SliderContainer
            
            -- Slider title
            local SliderTitle = Instance.new("TextLabel")
            SliderTitle.Name = "Title"
            SliderTitle.Size = UDim2.new(1, -50, 0, 18)
            SliderTitle.Position = UDim2.new(0, 0, 0, 0)
            SliderTitle.BackgroundTransparency = 1
            SliderTitle.Text = sliderOptions.Name
            SliderTitle.TextColor3 = self.Window.Theme.Text
            SliderTitle.TextSize = 16
            SliderTitle.Font = Enum.Font.GothamMedium
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
            SliderTitle.Parent = SliderContainer
            
            -- Slider current value display
            local SliderValue = Instance.new("TextLabel")
            SliderValue.Name = "Value"
            SliderValue.Size = UDim2.new(0, 40, 0, 18)
            SliderValue.Position = UDim2.new(1, -40, 0, 0)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(sliderOptions.CurrentValue) .. sliderOptions.ValueSuffix
            SliderValue.TextColor3 = self.Window.Theme.Accent
            SliderValue.TextSize = 16
            SliderValue.Font = Enum.Font.GothamBold
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = SliderContainer
            
            -- Adjust container height based on description
            local hasDescription = sliderOptions.Description ~= ""
            if hasDescription then
                SliderContainer.Size = UDim2.new(1, 0, 0, 75)
                
                -- Slider description
                local SliderDescription = Instance.new("TextLabel")
                SliderDescription.Name = "Description"
                SliderDescription.Size = UDim2.new(1, 0, 0, 16)
                SliderDescription.Position = UDim2.new(0, 0, 0, 22)
                SliderDescription.BackgroundTransparency = 1
                SliderDescription.Text = sliderOptions.Description
                SliderDescription.TextColor3 = self.Window.Theme.TextMuted
                SliderDescription.TextSize = 14
                SliderDescription.Font = Enum.Font.Gotham
                SliderDescription.TextXAlignment = Enum.TextXAlignment.Left
                SliderDescription.TextWrapped = true
                SliderDescription.Parent = SliderContainer
            end
            
            -- Slider background
            local SliderBackground = Instance.new("Frame")
            SliderBackground.Name = "Background"
            SliderBackground.Size = UDim2.new(1, 0, 0, 8)
            SliderBackground.Position = UDim2.new(0, 0, 1, -18)
            SliderBackground.BackgroundColor3 = self.Window.Theme.InputField
            SliderBackground.BorderSizePixel = 0
            SliderBackground.Parent = SliderContainer
            
            -- Apply corner radius to slider background
            local SliderBackgroundCorner = Instance.new("UICorner")
            SliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
            SliderBackgroundCorner.Parent = SliderBackground
            
            -- Slider fill
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new(0, 0, 1, 0) -- Will be updated based on value
            SliderFill.BackgroundColor3 = self.Window.Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBackground
            
            -- Apply corner radius to slider fill
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill
            
            -- Add gradient to slider fill
            self.Window.Utilities.CreateGradient(SliderFill, self.Window.Theme.Accent, self.Window.Theme.AccentDark, 45)
            
            -- Slider knob
            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.Size = UDim2.new(0, 16, 0, 16)
            SliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
            SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderKnob.BackgroundColor3 = self.Window.Theme.Text
            SliderKnob.BorderSizePixel = 0
            SliderKnob.ZIndex = 2
            SliderKnob.Parent = SliderFill
            
            -- Apply corner radius to knob
            local SliderKnobCorner = Instance.new("UICorner")
            SliderKnobCorner.CornerRadius = UDim.new(1, 0)
            SliderKnobCorner.Parent = SliderKnob
            
            -- Function to update the slider's visual state
            local function UpdateSliderVisual(value)
                -- Calculate the slider percentage
                local minValue = sliderOptions.Range[1]
                local maxValue = sliderOptions.Range[2]
                local valueRange = maxValue - minValue
                local percentage = (value - minValue) / valueRange
                
                -- Update slider fill size
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                
                -- Update value display
                SliderValue.Text = tostring(value) .. sliderOptions.ValueSuffix
            end
            
            -- Function to process slider input
            local function ProcessSliderInput(input)
                local sliderPosition = math.clamp(
                    (input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X,
                    0,
                    1
                )
                
                -- Calculate the actual value based on range and increment
                local minValue = sliderOptions.Range[1]
                local maxValue = sliderOptions.Range[2]
                local valueRange = maxValue - minValue
                local rawValue = minValue + (valueRange * sliderPosition)
                
                -- Apply increment
                local increment = sliderOptions.Increment
                local value = math.floor(rawValue / increment + 0.5) * increment
                
                -- Clamp to range
                value = math.clamp(value, minValue, maxValue)
                
                -- Update current value
                if value ~= sliderOptions.CurrentValue then
                    sliderOptions.CurrentValue = value
                    
                    -- Update visual
                    UpdateSliderVisual(value)
                    
                    -- Save to flags
                    if sliderOptions.Flag then
                        self.Window.Flags[sliderOptions.Flag] = value
                    end
                    
                    -- Call the callback
                    sliderOptions.Callback(value)
                end
            end
            
            -- Handle slider interaction
            local isDragging = false
            
            SliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    ProcessSliderInput(input)
                end
            end)
            
            SliderBackground.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    ProcessSliderInput(input)
                end
            end)
            
            -- Add hover effect to slider container
            SliderContainer.MouseEnter:Connect(function()
                TweenService:Create(SliderContainer, TweenInfo_Fast, {
                    BackgroundTransparency = 0.7
                }):Play()
            end)
            
            SliderContainer.MouseLeave:Connect(function()
                TweenService:Create(SliderContainer, TweenInfo_Fast, {
                    BackgroundTransparency = 0.8
                }):Play()
            end)
            
            -- Set initial slider state
            UpdateSliderVisual(sliderOptions.CurrentValue)
            
            -- Slider API
            local SliderAPI = {}
            
            function SliderAPI:Set(value)
                -- Validate and clamp the value
                value = math.clamp(value, sliderOptions.Range[1], sliderOptions.Range[2])
                
                -- Apply increment
                local increment = sliderOptions.Increment
                value = math.floor(value / increment + 0.5) * increment
                
                -- Update current value
                sliderOptions.CurrentValue = value
                
                -- Update visual
                UpdateSliderVisual(value)
                
                -- Save to flags
                if sliderOptions.Flag then
                    self.Window.Flags[sliderOptions.Flag] = value
                end
                
                -- Call the callback
                sliderOptions.Callback(value)
                
                return self
            end
            
            function SliderAPI:GetValue()
                return sliderOptions.CurrentValue
            end
            
            return SliderAPI
        end
        
        return Tab
    end
    
    -- Return the Window object with methods for creating tabs
    return Window
end
-- Return the ZynoxUI module
return ZynoxUI

-- Close Button Corner
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = Theme.SmallCornerRadius
CloseCorner.Parent = CloseButton

-- Close Button Icon
local CloseIcon = Instance.new("ImageLabel")
CloseIcon.Name = "CloseIcon"
CloseIcon.Size = UDim2.new(0, 16, 0, 16)
CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Image = "rbxassetid://7072725342" -- X icon
CloseIcon.ImageColor3 = Theme.Text
CloseIcon.ZIndex = 4
CloseIcon.Parent = CloseButton

-- Add hover effect to close button
Utilities.CreateHoverEffect(CloseButton, Theme.Primary, Theme.Error, Theme.Error)

-- Minimize Button with improved styling
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 36, 0, 36)
MinimizeButton.Position = UDim2.new(1, -44, 0.5, 0)
MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
MinimizeButton.BackgroundColor3 = Theme.Primary
MinimizeButton.BackgroundTransparency = 0.2
MinimizeButton.Text = ""
MinimizeButton.TextColor3 = Theme.Text
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 24
MinimizeButton.ZIndex = 3
MinimizeButton.AutoButtonColor = false -- We'll handle hover effects manually
MinimizeButton.Parent = TitleFrame

-- Minimize Button Corner
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = Theme.SmallCornerRadius
MinimizeCorner.Parent = MinimizeButton

-- Minimize Button Icon
local MinimizeIcon = Instance.new("Frame")
MinimizeIcon.Name = "MinimizeIcon"
MinimizeIcon.Size = UDim2.new(0, 12, 0, 2)
MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizeIcon.BackgroundColor3 = Theme.Text
MinimizeIcon.BorderSizePixel = 0
MinimizeIcon.ZIndex = 4
MinimizeIcon.Parent = MinimizeButton

-- Add hover effect to minimize button
Utilities.CreateHoverEffect(MinimizeButton, Theme.Primary, Theme.ButtonHover, Theme.ButtonActive)

-- Tabs Frame
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(0, 120, 0, 326) -- Reduced width from 148 to 120
TabsFrame.Position = UDim2.new(0, 0, 0, 48)
TabsFrame.BackgroundColor3 = Theme.Secondary
TabsFrame.BorderSizePixel = 0
TabsFrame.ZIndex = 2
TabsFrame.Parent = Frame

-- Add gradient to tabs frame
Utilities.CreateGradient(TabsFrame, Theme.Secondary, Color3.fromRGB(
    Theme.Secondary.R * 255 - 5,
    Theme.Secondary.G * 255 - 5,
    Theme.Secondary.B * 255 - 5
), 135)

-- Tabs Frame Corner
local TabsCorner = Instance.new("UICorner")
TabsCorner.CornerRadius = Theme.CornerRadius
TabsCorner.Parent = TabsFrame

-- Fix the top corners of tabs frame
local TabsFrameTopFix = Instance.new("Frame")
TabsFrameTopFix.Name = "TopFix"
TabsFrameTopFix.Size = UDim2.new(1, 0, 0, 10)
TabsFrameTopFix.Position = UDim2.new(0, 0, 0, 0)
TabsFrameTopFix.BackgroundColor3 = Theme.Secondary
TabsFrameTopFix.BorderSizePixel = 0
TabsFrameTopFix.ZIndex = 2
TabsFrameTopFix.Parent = TabsFrame

-- Apply gradient to top fix
Utilities.CreateGradient(TabsFrameTopFix, Theme.Secondary, Color3.fromRGB(
    Theme.Secondary.R * 255 - 5,
    Theme.Secondary.G * 255 - 5,
    Theme.Secondary.B * 255 - 5
), 135)

-- Fix the right side of tabs frame
local TabsFrameRightFix = Instance.new("Frame")
TabsFrameRightFix.Name = "RightFix"
TabsFrameRightFix.Size = UDim2.new(0, 10, 1, 0)
TabsFrameRightFix.Position = UDim2.new(1, -10, 0, 0)
TabsFrameRightFix.BackgroundColor3 = Theme.Secondary
TabsFrameRightFix.BorderSizePixel = 0
TabsFrameRightFix.ZIndex = 2
TabsFrameRightFix.Parent = TabsFrame

-- Apply gradient to right fix
Utilities.CreateGradient(TabsFrameRightFix, Theme.Secondary, Color3.fromRGB(
    Theme.Secondary.R * 255 - 5,
    Theme.Secondary.G * 255 - 5,
    Theme.Secondary.B * 255 - 5
), 135)

-- Add inner shadow effect to tabs frame
local TabsInnerShadow = Instance.new("Frame")
TabsInnerShadow.Name = "InnerShadow"
TabsInnerShadow.Size = UDim2.new(1, 0, 1, 0)
TabsInnerShadow.BackgroundTransparency = 1
TabsInnerShadow.ZIndex = 2
TabsInnerShadow.ClipsDescendants = true
TabsInnerShadow.Parent = TabsFrame

-- Left inner shadow
local LeftShadow = Instance.new("Frame")
LeftShadow.Name = "LeftShadow"
LeftShadow.Size = UDim2.new(0, 15, 1, 0)
LeftShadow.Position = UDim2.new(0, 0, 0, 0)
LeftShadow.BorderSizePixel = 0
LeftShadow.ZIndex = 3
LeftShadow.Parent = TabsInnerShadow
Utilities.CreateGradient(LeftShadow, Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0), 0, {0.7, 1})

-- Tabs Container with improved scrolling
local TabsContainer = Instance.new("ScrollingFrame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -16, 1, 0) -- Adjusted for better padding
TabsContainer.Position = UDim2.new(0, 8, 0, 0) -- Centered
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.ScrollBarThickness = 3 -- Thinner scrollbar
TabsContainer.ScrollBarImageColor3 = Theme.Accent
TabsContainer.ScrollBarImageTransparency = 0.3 -- Semi-transparent scrollbar
TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
TabsContainer.ZIndex = 3
TabsContainer.Parent = TabsFrame

-- Modern scrolling behavior
TabsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
TabsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabsContainer.ElasticBehavior = Enum.ElasticBehavior.Always
TabsContainer.ScrollBarInset = Enum.ScrollBarInset.ScrollBar

-- Tab List Layout with improved spacing
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 8) -- Increased spacing between tabs
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabsContainer

-- Tab Padding
local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 12) -- Increased top padding
TabPadding.PaddingBottom = UDim.new(0, 12) -- Increased bottom padding
TabPadding.Parent = TabsContainer

-- Welcome User Frame
local WelcomeUserFrame = Instance.new("Frame")
WelcomeUserFrame.Name = "WelcomeUserFrame"
WelcomeUserFrame.Size = UDim2.new(0, 120, 0, 81) -- Adjusted width to match TabsFrame
WelcomeUserFrame.Position = UDim2.new(0, 0, 1, -81)
WelcomeUserFrame.BackgroundColor3 = Theme.BackgroundLight -- Using theme color
WelcomeUserFrame.BorderSizePixel = 0
WelcomeUserFrame.ZIndex = 2
WelcomeUserFrame.Parent = Frame

-- Add gradient to welcome frame
Utilities.CreateGradient(WelcomeUserFrame, Theme.BackgroundLight, Color3.fromRGB(
    Theme.BackgroundLight.R * 255 + 10,
    Theme.BackgroundLight.G * 255 + 10,
    Theme.BackgroundLight.B * 255 + 10
), 45)

-- Welcome Frame Corner
local WelcomeCorner = Instance.new("UICorner")
WelcomeCorner.CornerRadius = Theme.CornerRadius
WelcomeCorner.Parent = WelcomeUserFrame

-- Fix the top corners of welcome frame
local WelcomeFrameTopFix = Instance.new("Frame")
WelcomeFrameTopFix.Name = "TopFix"
WelcomeFrameTopFix.Size = UDim2.new(1, 0, 0, 10)
WelcomeFrameTopFix.Position = UDim2.new(0, 0, 0, 0)
WelcomeFrameTopFix.BackgroundColor3 = Theme.BackgroundLight
WelcomeFrameTopFix.BorderSizePixel = 0
WelcomeFrameTopFix.ZIndex = 2
WelcomeFrameTopFix.Parent = WelcomeUserFrame

-- Apply gradient to top fix
Utilities.CreateGradient(WelcomeFrameTopFix, Theme.BackgroundLight, Color3.fromRGB(
    Theme.BackgroundLight.R * 255 + 10,
    Theme.BackgroundLight.G * 255 + 10,
    Theme.BackgroundLight.B * 255 + 10
), 45)

-- Fix the right side of welcome frame
local WelcomeFrameRightFix = Instance.new("Frame")
WelcomeFrameRightFix.Name = "RightFix"
WelcomeFrameRightFix.Size = UDim2.new(0, 10, 1, 0)
WelcomeFrameRightFix.Position = UDim2.new(1, -10, 0, 0)
WelcomeFrameRightFix.BackgroundColor3 = Theme.BackgroundLight
WelcomeFrameRightFix.BorderSizePixel = 0
WelcomeFrameRightFix.ZIndex = 2
WelcomeFrameRightFix.Parent = WelcomeUserFrame

-- Apply gradient to right fix
Utilities.CreateGradient(WelcomeFrameRightFix, Theme.BackgroundLight, Color3.fromRGB(
    Theme.BackgroundLight.R * 255 + 10,
    Theme.BackgroundLight.G * 255 + 10,
    Theme.BackgroundLight.B * 255 + 10
), 45)

-- User avatar display
local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Name = "UserAvatar"
UserAvatar.Size = UDim2.new(0, 36, 0, 36)
UserAvatar.Position = UDim2.new(0.5, 0, 0, 8)
UserAvatar.AnchorPoint = Vector2.new(0.5, 0)
UserAvatar.BackgroundColor3 = Theme.Primary
UserAvatar.BackgroundTransparency = 0.5
UserAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=100&h=100"
UserAvatar.ZIndex = 3
UserAvatar.Parent = WelcomeUserFrame

-- Avatar corner
local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0) -- Circle
AvatarCorner.Parent = UserAvatar

-- Avatar stroke
local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Theme.Accent
AvatarStroke.Thickness = 2
AvatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
AvatarStroke.Parent = UserAvatar

-- Welcome Text
local WelcomeText = Instance.new("TextLabel")
WelcomeText.Name = "WelcomeText"
WelcomeText.Size = UDim2.new(1, 0, 0, 16)
WelcomeText.Position = UDim2.new(0, 0, 0, 48)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Text = "Welcome,"
WelcomeText.Font = Enum.Font.GothamSemibold
WelcomeText.TextSize = 12
WelcomeText.TextColor3 = Theme.TextMuted
WelcomeText.TextXAlignment = Enum.TextXAlignment.Center
WelcomeText.ZIndex = 3
WelcomeText.Parent = WelcomeUserFrame

-- Player Name Text
local PlayerNameText = Instance.new("TextLabel")
PlayerNameText.Name = "PlayerNameText"
PlayerNameText.Size = UDim2.new(1, 0, 0, 18)
PlayerNameText.Position = UDim2.new(0, 0, 0, 60)
PlayerNameText.BackgroundTransparency = 1
PlayerNameText.Text = Player.DisplayName
PlayerNameText.Font = Enum.Font.GothamBold
PlayerNameText.TextSize = 14
PlayerNameText.TextColor3 = Theme.Accent
PlayerNameText.TextXAlignment = Enum.TextXAlignment.Center
PlayerNameText.ZIndex = 3
PlayerNameText.Parent = WelcomeUserFrame

-- Add subtle pulse animation to avatar
Utilities.CreatePulse(AvatarStroke, "Transparency", 0.2, 0.8, 2)

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, -48) -- Adjusted to match new TabsFrame width
ContentFrame.Position = UDim2.new(0, 120, 0, 48) -- Adjusted to match new TabsFrame width
ContentFrame.BackgroundColor3 = Theme.Background
ContentFrame.BorderSizePixel = 0
ContentFrame.ZIndex = 2
ContentFrame.Parent = Frame

-- Add subtle gradient to content frame
Utilities.CreateGradient(ContentFrame, Theme.Background, Color3.fromRGB(
    Theme.Background.R * 255 + 5,
    Theme.Background.G * 255 + 5,
    Theme.Background.B * 255 + 5
), 135)

-- Add padding to content frame
local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = Theme.Padding
ContentPadding.PaddingBottom = Theme.Padding
ContentPadding.PaddingLeft = Theme.Padding
ContentPadding.PaddingRight = Theme.Padding
ContentPadding.Parent = ContentFrame

-- Create tab pages
local TabPages = {}
local TabButtons = {}

-- Function to create a new tab with modern design
local function CreateTab(name, icon, order)
    -- Create tab button container for better styling
    local TabButtonContainer = Instance.new("Frame")
    TabButtonContainer.Name = name .. "TabContainer"
    TabButtonContainer.Size = UDim2.new(0, 100, 0, 38) -- Slightly taller for shadow
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.LayoutOrder = order
    TabButtonContainer.ZIndex = 3
    TabButtonContainer.Parent = TabsContainer
    
    -- Create tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 35) -- Full width of container
    TabButton.Position = UDim2.new(0, 0, 0, 0)
    TabButton.BackgroundColor3 = Theme.Primary
    TabButton.Text = ""
    TabButton.AutoButtonColor = false -- We'll handle hover effects manually
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 12
    TabButton.TextColor3 = Theme.Text
    TabButton.ZIndex = 3
    TabButton.Parent = TabButtonContainer
    
    -- Tab Button Corner
    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = Theme.SmallCornerRadius
    TabButtonCorner.Parent = TabButton
    
    -- Add subtle shadow to tab button
    Utilities.CreateShadow(TabButton, 15, 0.85)
    
    -- Tab Icon
    local TabIcon = Instance.new("ImageLabel")
    TabIcon.Name = "Icon"
    TabIcon.Size = UDim2.new(0, 16, 0, 16)
    TabIcon.Position = UDim2.new(0, 12, 0.5, 0)
    TabIcon.AnchorPoint = Vector2.new(0, 0.5)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = icon or "rbxassetid://7059346373" -- Default icon if none provided
    TabIcon.ImageColor3 = Theme.Text
    TabIcon.ZIndex = 4
    TabIcon.Parent = TabButton
    
    -- Tab Text Label for better alignment
    local TabText = Instance.new("TextLabel")
    TabText.Name = "TabText"
    TabText.Size = UDim2.new(1, -40, 1, 0) -- Leave space for icon
    TabText.Position = UDim2.new(0, 36, 0, 0) -- Position after icon
    TabText.BackgroundTransparency = 1
    TabText.Text = name
    TabText.Font = Enum.Font.GothamSemibold
    TabText.TextSize = 12
    TabText.TextColor3 = Theme.Text
    TabText.TextXAlignment = Enum.TextXAlignment.Left
    TabText.ZIndex = 4
    TabText.Parent = TabButton
    
    -- Add indicator bar (hidden by default, shown when active)
    local ActiveIndicator = Instance.new("Frame")
    ActiveIndicator.Name = "ActiveIndicator"
    ActiveIndicator.Size = UDim2.new(0, 3, 0.7, 0)
    ActiveIndicator.Position = UDim2.new(0, 3, 0.5, 0)
    ActiveIndicator.AnchorPoint = Vector2.new(0, 0.5)
    ActiveIndicator.BackgroundColor3 = Theme.Accent
    ActiveIndicator.BorderSizePixel = 0
    ActiveIndicator.ZIndex = 5
    ActiveIndicator.Visible = false
    ActiveIndicator.Parent = TabButton
    
    -- Indicator corner
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 2)
    IndicatorCorner.Parent = ActiveIndicator
    
    -- Create tab page with fade-in animation capability
    local TabPage = Instance.new("Frame")
    TabPage.Name = name .. "Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ZIndex = 2
    TabPage.Parent = ContentFrame
    
    -- Add hover effect to tab button
    Utilities.CreateHoverEffect(TabButton, Theme.Primary, Theme.ButtonHover)
    
    -- Add to tables
    TabPages[name] = TabPage
    TabButtons[name] = TabButton
    
    return TabPage, TabButton
end

-- Function to select a tab with smooth transitions
local function SelectTab(name)
    -- Store currently active tab for transition
    local previousTab = nil
    for tabName, tabPage in pairs(TabPages) do
        if tabPage.Visible then
            previousTab = tabName
            break
        end
    end
    
    -- Don't do anything if selecting the already active tab
    if previousTab == name then return end
    
    -- Prepare the new tab page for fade-in
    if previousTab then
        -- Fade out current tab
        local currentPage = TabPages[previousTab]
        local currentButton = TabButtons[previousTab]
        
        -- Deactivate current tab button
        TweenService:Create(currentButton, TweenInfo_Fast, {
            BackgroundColor3 = Theme.Primary
        }):Play()
        
        -- Update text color
        TweenService:Create(currentButton:FindFirstChild("TabText"), TweenInfo_Fast, {
            TextColor3 = Theme.Text
        }):Play()
        
        -- Update icon color
        TweenService:Create(currentButton:FindFirstChild("Icon"), TweenInfo_Fast, {
            ImageColor3 = Theme.Text
        }):Play()
        
        -- Hide active indicator
        local indicator = currentButton:FindFirstChild("ActiveIndicator")
        if indicator then
            indicator.Visible = false
        end
        
        -- Fade out current page
        TweenService:Create(currentPage, TweenInfo_Fast, {
            Position = UDim2.new(0.05, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        -- After a short delay, hide the old page and show the new one
        delay(0.15, function()
            currentPage.Visible = false
            
            -- Show and fade in the new page
            local newPage = TabPages[name]
            newPage.Position = UDim2.new(-0.05, 0, 0, 0)
            newPage.BackgroundTransparency = 1
            newPage.Visible = true
            
            TweenService:Create(newPage, TweenInfo_Normal, {
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
        end)
    else
        -- No previous tab, just show the new one
        local newPage = TabPages[name]
        newPage.Visible = true
    end
    
    -- Activate new tab button
    local newButton = TabButtons[name]
    
    -- Update button appearance with gradient
    TweenService:Create(newButton, TweenInfo_Fast, {
        BackgroundColor3 = Theme.Accent
    }):Play()
    
    -- Update text color
    TweenService:Create(newButton:FindFirstChild("TabText"), TweenInfo_Fast, {
        TextColor3 = Theme.Primary
    }):Play()
    
    -- Update icon color
    TweenService:Create(newButton:FindFirstChild("Icon"), TweenInfo_Fast, {
        ImageColor3 = Theme.Primary
    }):Play()
    
    -- Show and animate active indicator
    local indicator = newButton:FindFirstChild("ActiveIndicator")
    if indicator then
        indicator.Size = UDim2.new(0, 3, 0, 0)
        indicator.Visible = true
        
        TweenService:Create(indicator, TweenInfo_Normal, {
            Size = UDim2.new(0, 3, 0.7, 0)
        }):Play()
        
        -- Add pulsing animation to active indicator
        Utilities.CreatePulse(indicator, "Transparency", 0, 0.3, 1.5)
    end
end

-- Create default tabs
local HomeTab, HomeButton = CreateTab("Home", "rbxassetid://3926305904", 1)
local SettingsTab, SettingsButton = CreateTab("Settings", "rbxassetid://3926307971", 2)
local CreditsTab, CreditsButton = CreateTab("Credits", "rbxassetid://3926305904", 3)

-- Set up tab button functionality
HomeButton.MouseButton1Click:Connect(function()
    SelectTab("Home")
end)

SettingsButton.MouseButton1Click:Connect(function()
    SelectTab("Settings")
end)

CreditsButton.MouseButton1Click:Connect(function()
    SelectTab("Credits")
end)

-- Home Tab Content
local HomeTitle = Instance.new("TextLabel")
HomeTitle.Name = "HomeTitle"
HomeTitle.Size = UDim2.new(1, 0, 0, 40)
HomeTitle.Position = UDim2.new(0, 0, 0, 20)
HomeTitle.BackgroundTransparency = 1
HomeTitle.Text = "Welcome to Zynox UI"
HomeTitle.Font = Enum.Font.GothamBold
HomeTitle.TextSize = 24
HomeTitle.TextColor3 = Theme.Text
HomeTitle.Parent = HomeTab

local HomeDescription = Instance.new("TextLabel")
HomeDescription.Name = "HomeDescription"
HomeDescription.Size = UDim2.new(1, -40, 0, 60)
HomeDescription.Position = UDim2.new(0, 20, 0, 70)
HomeDescription.BackgroundTransparency = 1
HomeDescription.Text = "This is a modern UI framework for your Roblox games. Customize it to fit your needs!"
HomeDescription.Font = Enum.Font.Gotham
HomeDescription.TextSize = 16
HomeDescription.TextColor3 = Theme.TextDark
HomeDescription.TextWrapped = true
HomeDescription.TextXAlignment = Enum.TextXAlignment.Left
HomeDescription.Parent = HomeTab

-- Settings Tab Content
local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Name = "SettingsTitle"
SettingsTitle.Size = UDim2.new(1, 0, 0, 40)
SettingsTitle.Position = UDim2.new(0, 0, 0, 20)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 24
SettingsTitle.TextColor3 = Theme.Text
SettingsTitle.Parent = SettingsTab

-- Create a modern toggle setting with animations
local function CreateToggle(parent, name, description, defaultState, position)
    -- Main toggle container with shadow
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, -40, 0, 70) -- Slightly taller for better spacing
    ToggleFrame.Position = position
    ToggleFrame.BackgroundColor3 = Theme.BackgroundLight
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.ZIndex = 2
    ToggleFrame.Parent = parent
    
    -- Add subtle gradient to toggle frame
    Utilities.CreateGradient(ToggleFrame, Theme.BackgroundLight, Color3.fromRGB(
        Theme.BackgroundLight.R * 255 + 5,
        Theme.BackgroundLight.G * 255 + 5,
        Theme.BackgroundLight.B * 255 + 5
    ), 45)
    
    -- Add shadow to toggle frame
    Utilities.CreateShadow(ToggleFrame, 20, 0.8)
    
    -- Rounded corners
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = Theme.CornerRadius
    ToggleCorner.Parent = ToggleFrame
    
    -- Add padding inside toggle frame
    local TogglePadding = Instance.new("UIPadding")
    TogglePadding.PaddingTop = UDim.new(0, 12)
    TogglePadding.PaddingBottom = UDim.new(0, 12)
    TogglePadding.PaddingLeft = UDim.new(0, 15)
    TogglePadding.PaddingRight = UDim.new(0, 15)
    TogglePadding.Parent = ToggleFrame
    
    -- Toggle title with icon
    local ToggleIcon = Instance.new("ImageLabel")
    ToggleIcon.Name = "Icon"
    ToggleIcon.Size = UDim2.new(0, 18, 0, 18)
    ToggleIcon.Position = UDim2.new(0, 0, 0, 0)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Image = "rbxassetid://7072706318" -- Generic settings icon
    ToggleIcon.ImageColor3 = Theme.Accent
    ToggleIcon.ZIndex = 3
    ToggleIcon.Parent = ToggleFrame
    
    local ToggleTitle = Instance.new("TextLabel")
    ToggleTitle.Name = "Title"
    ToggleTitle.Size = UDim2.new(1, -90, 0, 20)
    ToggleTitle.Position = UDim2.new(0, 26, 0, -2)
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Text = name
    ToggleTitle.Font = Enum.Font.GothamSemibold
    ToggleTitle.TextSize = 15
    ToggleTitle.TextColor3 = Theme.Text
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.ZIndex = 3
    ToggleTitle.Parent = ToggleFrame
    
    local ToggleDescription = Instance.new("TextLabel")
    ToggleDescription.Name = "Description"
    ToggleDescription.Size = UDim2.new(1, -90, 0, 20)
    ToggleDescription.Position = UDim2.new(0, 26, 0, 20)
    ToggleDescription.BackgroundTransparency = 1
    ToggleDescription.Text = description
    ToggleDescription.Font = Enum.Font.Gotham
    ToggleDescription.TextSize = 13
    ToggleDescription.TextColor3 = Theme.TextMuted
    ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDescription.TextWrapped = true
    ToggleDescription.ZIndex = 3
    ToggleDescription.Parent = ToggleFrame
    
    -- Modern toggle switch
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 24)
    ToggleButton.Position = UDim2.new(1, -50, 0, 8)
    ToggleButton.AnchorPoint = Vector2.new(0, 0)
    ToggleButton.BackgroundColor3 = defaultState and Theme.Accent or Theme.Secondary
    ToggleButton.ZIndex = 3
    ToggleButton.Parent = ToggleFrame
    
    -- Add gradient to toggle button
    if defaultState then
        Utilities.CreateGradient(ToggleButton, Theme.Accent, Theme.AccentDark, 45)
    end
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
    ToggleButtonCorner.Parent = ToggleButton
    
    -- Toggle circle with shadow
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
    ToggleCircle.Position = defaultState and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    ToggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.ZIndex = 4
    ToggleCircle.Parent = ToggleButton
    
    -- Add shadow to circle
    local CircleShadow = Instance.new("ImageLabel")
    CircleShadow.Name = "Shadow"
    CircleShadow.Size = UDim2.new(1, 6, 1, 6)
    CircleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    CircleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    CircleShadow.BackgroundTransparency = 1
    CircleShadow.Image = "rbxassetid://5554236805"
    CircleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    CircleShadow.ImageTransparency = 0.6
    CircleShadow.ScaleType = Enum.ScaleType.Slice
    CircleShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    CircleShadow.ZIndex = 3
    CircleShadow.Parent = ToggleCircle
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCircleCorner.Parent = ToggleCircle
    
    -- Make the entire toggle frame clickable
    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Visual feedback on click
            TweenService:Create(ToggleFrame, TweenInfo_Fast, {
                BackgroundColor3 = Theme.ButtonHover
            }):Play()
        end
    end)
    
    ToggleFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Reset background
            TweenService:Create(ToggleFrame, TweenInfo_Fast, {
                BackgroundColor3 = Theme.BackgroundLight
            }):Play()
        end
    end)
    
    -- Toggle functionality with improved animations
    local isOn = defaultState
    
    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isOn = not isOn
            
            -- Animate the toggle with bounce effect
            if isOn then
                -- First move slightly past the target position
                TweenService:Create(ToggleCircle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, -20, 0.5, 0)
                }):Play()
                
                -- Then bounce back to the correct position
                delay(0.15, function()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -22, 0.5, 0)
                    }):Play()
                end)
                
                -- Change color with gradient
                TweenService:Create(ToggleButton, TweenInfo_Fast, {
                    BackgroundColor3 = Theme.Accent
                }):Play()
                
                -- Add gradient
                local gradient = Utilities.CreateGradient(ToggleButton, Theme.Accent, Theme.AccentDark, 45)
                
                -- Ripple effect
                local ripple = Instance.new("Frame")
                ripple.Name = "Ripple"
                ripple.Size = UDim2.new(0, 10, 0, 10)
                ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ripple.BackgroundTransparency = 0.7
                ripple.ZIndex = 2
                ripple.Parent = ToggleButton
                
                local rippleCorner = Instance.new("UICorner")
                rippleCorner.CornerRadius = UDim.new(1, 0)
                rippleCorner.Parent = ripple
                
                TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(2, 0, 2, 0),
                    BackgroundTransparency = 1
                }):Play()
                
                game.Debris:AddItem(ripple, 0.5)
            else
                -- First move slightly past the target position
                TweenService:Create(ToggleCircle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 4, 0.5, 0)
                }):Play()
                
                -- Then bounce back to the correct position
                delay(0.15, function()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 2, 0.5, 0)
                    }):Play()
                end)
                
                -- Change color
                TweenService:Create(ToggleButton, TweenInfo_Fast, {
                    BackgroundColor3 = Theme.Secondary
                }):Play()
                
                -- Remove gradient if it exists
                for _, child in pairs(ToggleButton:GetChildren()) do
                    if child:IsA("UIGradient") then
                        child:Destroy()
                    end
                end
            end
        end
    end)
    
    return ToggleFrame, function() return isOn end
end

-- Add toggle settings
CreateToggle(SettingsTab, "Notifications", "Enable or disable notifications", true, UDim2.new(0, 20, 0, 70))
CreateToggle(SettingsTab, "Sounds", "Enable or disable UI sounds", true, UDim2.new(0, 20, 0, 140))
CreateToggle(SettingsTab, "Animations", "Enable or disable UI animations", true, UDim2.new(0, 20, 0, 210))

-- Credits Tab Content
local CreditsTitle = Instance.new("TextLabel")
CreditsTitle.Name = "CreditsTitle"
CreditsTitle.Size = UDim2.new(1, 0, 0, 40)
CreditsTitle.Position = UDim2.new(0, 0, 0, 20)
CreditsTitle.BackgroundTransparency = 1
CreditsTitle.Text = "Credits"
CreditsTitle.Font = Enum.Font.GothamBold
CreditsTitle.TextSize = 24
CreditsTitle.TextColor3 = Theme.Text
CreditsTitle.Parent = CreditsTab

local CreditsText = Instance.new("TextLabel")
CreditsText.Name = "CreditsText"
CreditsText.Size = UDim2.new(1, -40, 0, 100)
CreditsText.Position = UDim2.new(0, 20, 0, 70)
CreditsText.BackgroundTransparency = 1
CreditsText.Text = "UI Design: FelSSJ\nEnhanced by: Cascade AI\nVersion: 1.0.0\n\nThanks for using Zynox UI!"
CreditsText.Font = Enum.Font.Gotham
CreditsText.TextSize = 16
CreditsText.TextColor3 = Theme.TextDark
CreditsText.TextXAlignment = Enum.TextXAlignment.Left
CreditsText.TextYAlignment = Enum.TextYAlignment.Top
CreditsText.Parent = CreditsTab

-- Make the UI draggable
local isDragging = false
local dragStart = nil
local startPos = nil

TitleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Close button functionality with animation
CloseButton.MouseButton1Click:Connect(function()
    -- Fade out animation before destroying
    local fadeOutTween = TweenService:Create(ScreenGui, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    -- Shrink animation
    local shrinkTween = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    })
    
    -- Play animations
    shrinkTween:Play()
    
    -- Destroy after animation completes
    shrinkTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Add particle effect on close
    local particles = Instance.new("Frame")
    particles.Size = UDim2.new(0, 0, 0, 0)
    particles.Position = UDim2.new(0.5, 0, 0.5, 0)
    particles.AnchorPoint = Vector2.new(0.5, 0.5)
    particles.BackgroundTransparency = 1
    particles.ZIndex = 10
    particles.Parent = Frame
    
    -- Create particle effect
    for i = 1, 10 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
        particle.Position = UDim2.new(0.5, 0, 0.5, 0)
        particle.AnchorPoint = Vector2.new(0.5, 0.5)
        particle.BackgroundColor3 = Theme.Accent
        particle.BorderSizePixel = 0
        particle.ZIndex = 10
        particle.Parent = particles
        
        local angle = math.rad(math.random(0, 360))
        local distance = math.random(100, 300)
        
        TweenService:Create(particle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, math.cos(angle) * distance, 0.5, math.sin(angle) * distance),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
end)

-- Minimize button functionality with smooth animation
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Save the content for restoration
        for _, child in pairs(Frame:GetChildren()) do
            if child ~= TitleFrame and child:IsA("GuiObject") then
                TweenService:Create(child, TweenInfo_Fast, {
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    ImageTransparency = 1
                }):Play()
            end
        end
        
        -- Minimize with bounce effect
        TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 790, 0, 48)
        }):Play()
        
        -- Change minimize icon to maximize
        TweenService:Create(MinimizeIcon, TweenInfo_Fast, {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    else
        -- Restore with bounce effect
        TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 790, 0, 455)
        }):Play()
        
        -- Fade content back in with slight delay
        delay(0.2, function()
            for _, child in pairs(Frame:GetChildren()) do
                if child ~= TitleFrame and child:IsA("GuiObject") then
                    TweenService:Create(child, TweenInfo_Normal, {
                        BackgroundTransparency = 0,
                        TextTransparency = 0,
                        ImageTransparency = 0
                    }):Play()
                end
            end
        end)
        
        -- Change maximize icon back to minimize
        TweenService:Create(MinimizeIcon, TweenInfo_Fast, {
            Size = UDim2.new(0, 12, 0, 2),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    end
end)

-- Select the default tab
SelectTab("Home")

-- Parent the ScreenGui to PlayerGui
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Return the API for external use
return {
    ScreenGui = ScreenGui,
    MainFrame = Frame,
    SelectTab = SelectTab,
    CreateTab = CreateTab,
    Theme = Theme
}
