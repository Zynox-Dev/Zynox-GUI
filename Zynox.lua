local TweenService = game:GetService("TweenService")

local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI
ZynoxUI.Version = "1.0.0"

-- Destroy any existing ZynoxUI in CoreGui
pcall(function()
    local existing = game:GetService("CoreGui"):FindFirstChild("ZynoxUI")
    if existing then
        existing:Destroy()
    end
end)

ZynoxUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(35, 35, 35),
        ButtonHover = Color3.fromRGB(45, 45, 45),
        Toggle = Color3.fromRGB(40, 40, 40),
        ToggleAccent = Color3.fromRGB(0, 120, 215),
        Input = Color3.fromRGB(30, 30, 30),
        Dropdown = Color3.fromRGB(35, 35, 35),
        Slider = Color3.fromRGB(40, 40, 40),
        SliderFill = Color3.fromRGB(0, 120, 215),
    },
}

local function create(class, properties)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

-- Welcome Message Function
local function showWelcomeMessage(title, message, theme)
    local notification = create("ScreenGui", {
        Name = "WelcomeNotification",
        ResetOnSpawn = false
    })

    local mainFrame = create("Frame", {
        Name = "NotificationFrame",
        Size = UDim2.new(0, 300, 0, 120),
        Position = UDim2.new(1, -320, 1, -140),
        BackgroundColor3 = ZynoxUI.Themes[theme].Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(1, 1),
    })

    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = mainFrame})

    local titleLabel = create("TextLabel", {
        Text = title or "Welcome to ZynoxUI",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -30, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local messageLabel = create("TextLabel", {
        Text = message or "Thanks for using ZynoxUI!",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextTransparency = 0.3,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 45),
        Size = UDim2.new(1, -30, 1, -60),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    local closeButton = create("TextButton", {
        Text = "×",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
    })

    titleLabel.Parent = mainFrame
    messageLabel.Parent = mainFrame
    closeButton.Parent = mainFrame
    mainFrame.Parent = notification

    -- Animation In
    mainFrame.Position = UDim2.new(2, -320, 1, -140)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 1, -140)
    }):Play()

    -- Close Button
    closeButton.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(2, -320, 1, -140)
        })
        tween.Completed:Connect(function() notification:Destroy() end)
        tween:Play()
    end)

    -- Auto-Close
    task.delay(5, function()
        if notification.Parent then
            closeButton.MouseButton1Click:Fire()
        end
    end)

    notification.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    return notification
end

-- Create Window Function
function ZynoxUI:CreateWindow(title, options)
    options = options or {}
    local theme = options.Theme or "Dark"
    local window = {}

    local screenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui"),
        Enabled = false,
    })

    local mainFrame = create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -225),
        BackgroundColor3 = ZynoxUI.Themes[theme].Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
    })

    local topbar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = ZynoxUI.Themes[theme].Topbar,
        BorderSizePixel = 0,
    })

    local titleLabel = create("TextLabel", {
        Text = title or "ZynoxUI",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 18,
        Font = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local tabsContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
    })

    topbar.Parent = mainFrame
    titleLabel.Parent = topbar
    tabsContainer.Parent = mainFrame
    mainFrame.Parent = screenGui

    -- Window animation
    screenGui.Enabled = true
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -250, 0.5, -175),
    }):Play()

    -- Show Welcome Message if specified
    if options.WelcomeMessage then
        showWelcomeMessage(options.WelcomeMessage.Title, options.WelcomeMessage.Description, theme)
    end

    -- Dragging (same as before)
    -- ...

    -- Tab creation (same as before)
    -- ...

    return window
end

return ZynoxUI
