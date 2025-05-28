--[[
    Zynox UI Library
    A premium, modern UI library for Roblox
    Features:
    - Sleek, modern design
    - Smooth animations
    - Custom themes
    - Advanced components
    - Mobile-friendly
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Theme system
local Themes = {
    Dark = {
        Main = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 35),
        Text = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(0, 170, 255),  -- Bright blue accent
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Border = Color3.fromRGB(50, 50, 60),
        Hover = Color3.fromRGB(40, 40, 45),
        ToggleOn = Color3.fromRGB(0, 200, 83),
        ToggleOff = Color3.fromRGB(80, 80, 90)
    },
    Light = {
        Main = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(250, 250, 255),
        Text = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(0, 150, 230),
        Success = Color3.fromRGB(46, 125, 50),
        Warning = Color3.fromRGB(255, 143, 0),
        Error = Color3.fromRGB(211, 47, 47),
        Border = Color3.fromRGB(200, 200, 210),
        Hover = Color3.fromRGB(225, 225, 230),
        ToggleOn = Color3.fromRGB(76, 175, 80),
        ToggleOff = Color3.fromRGB(170, 170, 180)
    }
}

local Zynox = {
    Theme = Themes.Dark, -- Default theme
    Windows = {},
    Version = "1.0.0"
}

-- Animation presets
local Animations = {
    ButtonHover = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Toggle = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    WindowOpen = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    WindowClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    FadeIn = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    FadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
}

-- Utility functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function CreateGradient(parent, color)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(0, 0, 0), 0.1))
    })
    gradient.Rotation = 90
    gradient.Parent = parent
    return gradient
end

-- Create a new window
function Zynox:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Zynox UI"
    local size = options.Size or Vector2.new(320, 450)
    local position = options.Position or Vector2.new(0.5, 0.5)
    local theme = options.Theme and Themes[options.Theme] or self.Theme
    
    -- Create UI instances
    local screenGui = Create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })
    
    -- Main container
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, size.X, 0, size.Y),
        Position = UDim2.new(position.X, -size.X/2, position.Y, -size.Y/2),
        BackgroundColor3 = theme.Main,
        BackgroundTransparency = 0.1,
        Parent = screenGui
    })
    
    -- Add UI corners
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = mainFrame
    })
    
    -- Add subtle gradient
    local gradient = CreateGradient(mainFrame, theme.Main)
    
    -- Add glow effect
    local glow = Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4996891970",
        ImageColor3 = theme.Accent,
        ImageTransparency = 0.9,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        ZIndex = 0,
        Parent = mainFrame
    })
    
    -- Title bar with gradient
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.Secondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    local titleGradient = CreateGradient(titleBar, theme.Secondary)
    
    local titleCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = titleBar
    })
    
    -- Title text with subtle glow
    local titleText = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0,
        Parent = titleBar
    })
    
    -- Close button with hover effect
    local closeButton = Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -36, 0, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })
    
    -- Content frame with subtle scrollbar
    local contentFrame = Create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -56),
        Position = UDim2.new(0, 10, 0, 46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Accent,
        ScrollBarImageTransparency = 0.7,
        ScrollBarBorderSizePixel = 0,
        Parent = mainFrame
    })
    
    local listLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = contentFrame
    })
    
    -- Dragging functionality
    local dragging = false
    local dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateDrag(input)
        end
    end)
    
    -- Close button functionality with animation
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(255, 80, 80)
        }):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            TextColor3 = theme.Text
        }):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, Animations.WindowClose, {
            Position = UDim2.new(0.5, -size.X/2, 1.5, -size.Y/2)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 1
        }):Play()
        task.wait(0.2)
        screenGui:Destroy()
    end)
    
    -- Animation on open
    mainFrame.Position = UDim2.new(0.5, -size.X/2, 1.5, -size.Y/2)
    mainFrame.BackgroundTransparency = 1
    titleBar.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    
    TweenService:Create(mainFrame, Animations.WindowOpen, {
        Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    }):Play()
    
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.1
    }):Play()
    
    TweenService:Create(titleBar, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.1
    }):Play()
    
    TweenService:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0.9
    }):Play()
    
    -- Window methods
    local window = {
        ScreenGui = screenGui,
        Content = contentFrame,
        Theme = theme,
        MainFrame = mainFrame
    }
    
    function window:CreateButton(options)
        options = options or {}
        local button = Create("TextButton", {
            Name = "Button",
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Text = options.Text or "Button",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            Parent = self.Content
        })
        
        local corner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = button
        })
        
        -- Add gradient
        local buttonGradient = CreateGradient(button, theme.Accent)
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(button, Animations.ButtonHover, {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0.98, 0, 0, 42)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, Animations.ButtonHover, {
                BackgroundTransparency = 0,
                Size = UDim2.new(1, 0, 0, 42)
            }):Play()
        end)
        
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.96, 0, 0, 40)
            }):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.98, 0, 0, 42)
            }):Play()
        end)
        
        if options.Callback and type(options.Callback) == "function" then
            button.MouseButton1Click:Connect(function()
                options.Callback()
            end)
        end
        
        return button
    end
    
    -- ... (rest of the component functions remain the same)
    
    -- Add more components here (toggles, sliders, etc.)
    
    table.insert(Zynox.Windows, window)
    return window
end

-- Example usage:
local function Example()
    local window = Zynox:CreateWindow({
        Title = "Zynox UI Example",
        Size = Vector2.new(340, 500),
        Theme = "Dark"
    })
    
    -- Add example components here
end

-- Uncomment to show example
-- Example()

return Zynox
