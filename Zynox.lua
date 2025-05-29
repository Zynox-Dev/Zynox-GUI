-- ZynoxUI (Fixed version)

local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI
ZynoxUI.Version = "1.0.0"

-- Clean existing UI
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "ZynoxUI" then
            v:Destroy()
        end
    end
end)

-- Theme
ZynoxUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(35, 35, 35),
        ButtonHover = Color3.fromRGB(45, 45, 45),
        Toggle = Color3.fromRGB(40, 40, 40),
        ToggleAccent = Color3.fromRGB(0, 120, 215),
    }
}

-- Utility
local function create(class, properties)
    local inst = Instance.new(class)
    for p, v in pairs(properties) do
        inst[p] = v
    end
    return inst
end

-- Welcome Message
local function showWelcomeMessage(title, message, theme)
    local notification = create("ScreenGui", {
        Name = "WelcomeNotification",
        ResetOnSpawn = false
    })

    local mainFrame = create("Frame", {
        Size = UDim2.new(0, 300, 0, 120),
        Position = UDim2.new(1, 20, 1, -140),
        BackgroundColor3 = ZynoxUI.Themes[theme].Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(1, 1),
        Parent = notification
    })

    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = mainFrame })

    create("TextLabel", {
        Text = title or "Welcome!",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -30, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = mainFrame
    })

    local messageLabel = create("TextLabel", {
        Text = message or "Thanks for using ZynoxUI!",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 45),
        Size = UDim2.new(1, -30, 1, -60),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = mainFrame
    })

    local closeButton = create("TextButton", {
        Text = "×",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Parent = mainFrame
    })

    local ts = game:GetService("TweenService")
    mainFrame.Position = UDim2.new(2, 0, 1, -140)
    ts:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { 
        Position = UDim2.new(1, -20, 1, -140) 
    }):Play()

    local function close()
        local tween = ts:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { 
            Position = UDim2.new(2, 0, 1, -140) 
        })
        tween.Completed:Connect(function() 
            notification:Destroy() 
        end)
        tween:Play()
    end

    closeButton.MouseButton1Click:Connect(close)
    task.delay(5, function() 
        if notification.Parent then 
            close() 
        end 
    end)

    notification.Parent = game:GetService("CoreGui")
    return notification
end

-- Create window
function ZynoxUI:CreateWindow(title, options)
    options = options or {}
    local theme = options.Theme or "Dark"
    local window = {}
    local tabCount = 0
    local currentTab = nil

    local screenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    local mainFrame = create("Frame", {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = ZynoxUI.Themes[theme].Background,
        BorderSizePixel = 0,
        Parent = screenGui
    })

    create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainFrame
    })

    local topbar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = ZynoxUI.Themes[theme].Topbar,
        BorderSizePixel = 0,
        Parent = mainFrame
    })

    create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = topbar
    })

    create("TextLabel", {
        Text = title or "ZynoxUI",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 18,
        Font = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar
    })

    local tabButtonsContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })

    local tabsContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -80),
        Parent = mainFrame
    })

    -- Dragging
    do
        local dragging, dragStart, startPos
        topbar.InputBegan:Connect(function(input)
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
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Tabs
    function window:CreateTab(name)
        tabCount = tabCount + 1
        local tab = {}
        
        local tabButton = create("TextButton", {
            Text = name,
            TextColor3 = ZynoxUI.Themes[theme].Text,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(0, 100, 1, 0),
            Position = UDim2.new(0, 10 + ((tabCount - 1) * 105), 0, 0),
            BackgroundColor3 = tabCount == 1 and ZynoxUI.Themes[theme].Background or ZynoxUI.Themes[theme].Topbar,
            BorderSizePixel = 0,
            Parent = tabButtonsContainer
        })

        local content = create("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ZynoxUI.Themes[theme].ToggleAccent,
            BackgroundTransparency = 1,
            Visible = tabCount == 1,
            Parent = tabsContainer
        })

        local uiListLayout = create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = content
        })

        uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
        end)

        tabButton.MouseButton1Click:Connect(function()
            for _, tabContent in ipairs(tabsContainer:GetChildren()) do
                if tabContent:IsA("ScrollingFrame") then
                    tabContent.Visible = false
                end
            end
            
            for _, btn in ipairs(tabButtonsContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = ZynoxUI.Themes[theme].Topbar
                end
            end
            
            content.Visible = true
            tabButton.BackgroundColor3 = ZynoxUI.Themes[theme].Background
        end)

        function tab:CreateButton(opts)
            opts = opts or {}
            local button = create("TextButton", {
                Text = opts.Text or "Button",
                TextColor3 = ZynoxUI.Themes[theme].Text,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = ZynoxUI.Themes[theme].Button,
                Parent = content,
                AutoButtonColor = false
            })

            create("UICorner", { 
                CornerRadius = UDim.new(0, 6), 
                Parent = button 
            })

            -- Hover effects
            button.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = ZynoxUI.Themes[theme].ButtonHover
                }):Play()
            end)

            button.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = ZynoxUI.Themes[theme].Button
                }):Play()
            end)

            if opts.Callback then 
                button.MouseButton1Click:Connect(opts.Callback) 
            end

            return button
        end

        -- Make first tab active by default
        if tabCount == 1 then
            currentTab = tab
        end

        return tab
    end

    showWelcomeMessage("Welcome to ZynoxUI!", "Thanks for using ZynoxUI, hope you enjoy!", theme)
    return window
end

return ZynoxUI
