-- ZynoxUI - A modern UI library for Roblox
-- Version: 1.1.0

-- Service caching for better performance
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI
ZynoxUI.Version = "1.1.0"

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
        TextSize = 26,  -- Welcome Title (was 20)
        Font = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -30, 0, 30),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = mainFrame
    })

    local messageLabel = create("TextLabel", {
        Text = message or "Thanks for using ZynoxUI!",
        TextColor3 = ZynoxUI.Themes[theme].Text,
        TextSize = 22,  -- Welcome Message (was 18)
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
        TextSize = 32,  -- Welcome Close (×) (was 28)
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
-- Validates and returns the theme colors, falls back to Dark theme if invalid
local function getThemeColors(themeName)
    local theme = ZynoxUI.Themes[themeName or "Dark"]
    if not theme then
        warn(string.format("Theme '%s' not found, falling back to Dark theme", tostring(themeName)))
        theme = ZynoxUI.Themes.Dark
    end
    return theme
end

function ZynoxUI:CreateWindow(title, options)
    options = options or {}
    local themeName = options.Theme or "Dark"
    local theme = getThemeColors(themeName)
    local window = {}
    local tabCount = 0
    local currentTab = nil
    local activeTweens = {}
    local connections = {}
    
    -- Cleanup function to prevent memory leaks
    local function cleanup()
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
        table.clear(connections)
        
        for _, tween in pairs(activeTweens) do
            tween:Cancel()
        end
        table.clear(activeTweens)
    end
    
    -- Track a tween for proper cleanup
    local function trackTween(instance, tweenInfo, properties)
        local tween = TweenService:Create(instance, tweenInfo, properties)
        activeTweens[instance] = tween
        tween.Completed:Connect(function()
            activeTweens[instance] = nil
        end)
        tween:Play()
        return tween
    end

    -- Create the main UI container
    local screenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
        DisplayOrder = 100,  -- Ensure it appears on top
        Parent = CoreGui
    })
    
    -- Store reference for cleanup
    window._gui = screenGui

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
        TextSize = 28,  -- Window Title (was 22)
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

    -- Enhanced dragging with better input handling
    do
        local dragging = false
        local dragStart, startPos
        local lastDragTime = 0
        local DRAG_DEBOUNCE = 1/60  -- 60 FPS
        
        -- Handle drag start
        local function onInputBegan(input, gameProcessed)
            if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            -- Connect to input changed/ended only when needed
            local inputChanged, inputEnded
            
            inputEnded = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    if inputChanged then
                        inputChanged:Disconnect()
                    end
                    inputEnded:Disconnect()
                end
            end)
            
            inputChanged = UserInputService.InputChanged:Connect(function(moveInput)
                if not dragging or moveInput.UserInputType ~= Enum.UserInputType.MouseMovement then
                    return
               
                -- Simple debouncing
                local now = tick()
                if now - lastDragTime < DRAG_DEBOUNCE then
                    return
                end
                lastDragTime = now
                
                -- Calculate new position
                local delta = moveInput.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                
                -- Apply position update
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, 
                    newX,
                    startPos.Y.Scale, 
                    newY
                )
            end)
            
            -- Store connections for cleanup
            table.insert(connections, inputEnded)
            if inputChanged then
                table.insert(connections, inputChanged)
            end
        end
        
        -- Connect input handlers
        local topbarInput = topbar.InputBegan:Connect(onInputBegan)
        table.insert(connections, topbarInput)
        
        -- Add keyboard accessibility
        local titleLabel = topbar:FindFirstChildWhichIsA("TextLabel")
        if titleLabel then
            titleLabel.InputBegan:Connect(function(input, gameProcessed)
                if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
                    onInputBegan(InputObject.new("InputObject", Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin), false)
                end
            end)
        end
    end

    -- Tabs
    function window:CreateTab(name)
        tabCount = tabCount + 1
        local tab = {}
        
        local tabButton = create("TextButton", {
            Text = name,
            TextColor3 = ZynoxUI.Themes[theme].Text,
            TextSize = 20,  -- Tab Buttons (was 14)
            Font = Enum.Font.Gotham,
            Size = UDim2.new(0, 140, 1, 0),  -- Increased width for tab buttons
            Position = UDim2.new(0, 10 + ((tabCount - 1) * 150), 0, 0),  -- Increased spacing between tabs
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
                TextSize = 22,  -- Button Text
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, -20, 0, 45),  -- Increased height for better text visibility
                BackgroundColor3 = ZynoxUI.Themes[theme].Button,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Parent = content
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

        function tab:CreateToggle(opts)
            opts = opts or {}
            local defaultValue = opts.Default or false
            local toggleState = defaultValue
            local toggleId = "toggle_"..tostring(math.random(1, 10000))
            
            local toggleFrame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 40),
                BackgroundTransparency = 1,
                Parent = content,
                Name = "ToggleContainer"
            })
            
            -- Make the frame focusable for keyboard navigation
            local function setFocusable(frame, focusable)
                frame.Active = focusable
                frame.Selectable = focusable
            end
            
            setFocusable(toggleFrame, true)
            
            local label = create("TextLabel", {
                Text = opts.Text or "Toggle",
                TextColor3 = theme.Text,
                TextSize = 22,
                Font = Enum.Font.Gotham,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -80, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame,
                Name = "ToggleLabel",
                TextWrapped = true
            })
            
            -- Add accessibility attributes
            local function updateAccessibility()
                local stateText = toggleState and "checked" or "unchecked"
                local description = string.format("%s is %s", opts.Text or "Toggle", stateText)
                
                -- These would be used by screen readers
                toggleFrame:SetAttribute("aria-label", description)
                toggleFrame:SetAttribute("aria-checked", toggleState)
                toggleFrame:SetAttribute("role", "switch")
            end
            
            updateAccessibility()
            
            local toggleOuter = create("Frame", {
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -60, 0.5, -12.5),
                BackgroundColor3 = theme.Toggle,
                Parent = toggleFrame,
                Name = "ToggleSwitch",
                AnchorPoint = Vector2.new(1, 0.5)
            })
            
            create("UICorner", {
                CornerRadius = UDim.new(0, 12.5),
                Parent = toggleOuter
            })
            
            local toggleInner = create("Frame", {
                Size = UDim2.new(0, 21, 0, 21),
                Position = UDim2.new(0, 2, 0.5, -10.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = toggleOuter
            })
            
            create("UICorner", {
                CornerRadius = UDim.new(0, 10.5),
                Parent = toggleInner
            })
            
            local function updateToggle(instant)
                local tweenInfo = instant and TweenInfo.new(0) or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if toggleState then
                    trackTween(toggleInner, tweenInfo, {
                        Position = UDim2.new(0, 27, 0.5, -10.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    })
                    trackTween(toggleOuter, tweenInfo, {
                        BackgroundColor3 = theme.ToggleAccent
                    })
                else
                    trackTween(toggleInner, tweenInfo, {
                        Position = UDim2.new(0, 2, 0.5, -10.5),
                        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    })
                    trackTween(toggleOuter, tweenInfo, {
                        BackgroundColor3 = theme.Toggle
                    })
                end
                
                updateAccessibility()
                
                -- Fire any state change events
                if opts.OnStateChanged then
                    opts.OnStateChanged(toggleState)
                end
            end
            
            -- Set initial state (instantly, no animation)
            updateToggle(true)
            
            local function toggleStateWithFeedback(newValue)
                if toggleState ~= newValue then
                    toggleState = newValue
                    updateToggle()
                    if opts.Callback then
                        opts.Callback(toggleState)
                    end
                end
            end
            
            local function onClick()
                toggleStateWithFeedback(not toggleState)
            end
            
            -- Mouse click handling
            local function onInputBegan(input, gameProcessed)
                if gameProcessed then return end
                
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onClick()
                end
            end
            
            -- Keyboard handling
            local function onKeyPress(input, gameProcessed)
                if gameProcessed then return end
                
                if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
                    onClick()
                end
            end
            
            -- Connect input events
            local function connectInputs()
                local conn1 = toggleOuter.InputBegan:Connect(onInputBegan)
                local conn2 = label.InputBegan:Connect(onInputBegan)
                local conn3 = toggleFrame.InputBegan:Connect(onKeyPress)
                
                -- Store connections for cleanup
                table.insert(connections, conn1)
                table.insert(connections, conn2)
                table.insert(connections, conn3)
            end
            
            connectInputs()
            
            -- Add visual feedback for focus
            toggleFrame.MouseEnter:Connect(function()
                if not toggleFrame:IsFocused() then
                    toggleFrame.BackgroundColor3 = theme.ButtonHover
                    toggleFrame.BackgroundTransparency = 0.9
                end
            end)
            
            toggleFrame.MouseLeave:Connect(function()
                if not toggleFrame:IsFocused() then
                    toggleFrame.BackgroundTransparency = 1
                end
            end)
            
            toggleFrame.Focused:Connect(function()
                toggleFrame.BackgroundColor3 = theme.ButtonHover
                toggleFrame.BackgroundTransparency = 0.9
            end)
            
            toggleFrame.FocusLost:Connect(function()
                toggleFrame.BackgroundTransparency = 1
            end)
            
            local toggle = {}
            
            function toggle:SetValue(value, instant)
                if type(value) ~= "boolean" then return end
                if toggleState ~= value then
                    toggleState = value
                    updateToggle(not instant)
                end
            end
            
            function toggle:GetValue()
                return toggleState
            end
            
            function toggle:Toggle()
                toggleStateWithFeedback(not toggleState)
                return toggleState
            end
            
            -- Add destroy method to clean up connections
            function toggle:Destroy()
                -- Cleanup is handled by the parent window's cleanup
            end
            
            -- Call the callback immediately if requested
            if opts.CallOnCreate and opts.Callback then
                task.defer(function()
                    opts.Callback(toggleState)
                end)
            end
            
            return toggle
        end

        -- Make first tab active by default
        if tabCount == 1 then
            currentTab = tab
        end

        return tab
    end

    -- Add destroy method
    function window:Destroy()
        cleanup()
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end
    
    -- Add a method to change theme
    function window:SetTheme(newThemeName)
        local newTheme = getThemeColors(newThemeName)
        -- TODO: Implement theme switching logic
        -- This would involve updating all UI elements to use the new theme colors
    end
    
    -- Show welcome message if enabled
    if options.WelcomeMessage ~= false then
        showWelcomeMessage(
            options.WelcomeTitle or "Welcome to ZynoxUI!", 
            options.WelcomeText or "Thanks for using ZynoxUI, hope you enjoy!", 
            theme
        )
    end
    
    -- Clean up when the window is destroyed
    screenGui.Destroying:Connect(cleanup)
    
    return window
end

return ZynoxUI
