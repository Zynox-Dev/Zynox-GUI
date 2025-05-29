--[[ 
    ZynoxUI - A modern UI library for Roblox
    Inspired by Rayfield UI
    Author: YourNameHere
    Version: 1.0.0

    Features:
    - Draggable window with a customizable theme
    - Tab system with buttons (extendable)
    - Lightweight and modular
--]]

local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI
ZynoxUI.Version = "1.0.0"

-- Themes (Dark by default, more can be added)
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

-- Utility: Create Roblox instances with properties
local function create(class, properties)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

-- Create a new UI window
function ZynoxUI:CreateWindow(title, options)
    options = options or {}
    local theme = options.Theme or "Dark"
    local window = {}

    -- Main UI Elements
    local screenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
    })

    local mainFrame = create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = ZynoxUI.Themes[theme].Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = ZynoxUI.Themes[theme].Topbar,
        BorderSizePixel = 0,
    })

    local titleLabel = create("TextLabel", {
        Name = "Title",
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
        Name = "TabsContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
    })

    -- Parent hierarchy
    topbar.Parent = mainFrame
    titleLabel.Parent = topbar
    tabsContainer.Parent = mainFrame
    mainFrame.Parent = screenGui

    -- Dragging functionality
    do
        local dragging, dragInput, dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

        topbar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    -- Tab system
    function window:CreateTab(name)
        local tab = {}

        local tabButton = create("TextButton", {
            Name = name .. "Tab",
            Text = name,
            TextColor3 = ZynoxUI.Themes[theme].Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            BackgroundColor3 = ZynoxUI.Themes[theme].Topbar,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 100, 0, 30),
            Position = UDim2.new(0, 10 + (#tabsContainer:GetChildren() - 1) * 105, 0, 5),
            AutoButtonColor = false,
        })

        local tabContent = create("ScrollingFrame", {
            Name = name .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ZynoxUI.Themes[theme].ToggleAccent,
            Visible = false,
        })

        tabButton.Parent = mainFrame
        tabContent.Parent = tabsContainer

        -- Tab switching logic
        tabButton.MouseButton1Click:Connect(function()
            for _, content in ipairs(tabsContainer:GetChildren()) do
                if content:IsA("ScrollingFrame") then
                    content.Visible = false
                end
            end
            tabContent.Visible = true

            for _, btn in ipairs(mainFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = ZynoxUI.Themes[theme].Topbar
                end
            end
            tabButton.BackgroundColor3 = ZynoxUI.Themes[theme].Background
        end)

        -- Show the first tab by default
        if #tabsContainer:GetChildren() == 1 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = ZynoxUI.Themes[theme].Background
        end

        -- Add buttons to tab
        function tab:CreateButton(options)
            options = options or {}
            local buttonFrame = create("TextButton", {
                Name = options.Name or "Button",
                Text = options.Text or "Button",
                TextColor3 = ZynoxUI.Themes[theme].Text,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                BackgroundColor3 = ZynoxUI.Themes[theme].Button,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0, 10 + (#tabContent:GetChildren() * 45)),
                AutoButtonColor = false,
            })

            create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = buttonFrame,
            })

            -- Hover effects
            buttonFrame.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(buttonFrame, TweenInfo.new(0.2), {
                    BackgroundColor3 = ZynoxUI.Themes[theme].ButtonHover,
                }):Play()
            end)

            buttonFrame.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(buttonFrame, TweenInfo.new(0.2), {
                    BackgroundColor3 = ZynoxUI.Themes[theme].Button,
                }):Play()
            end)

            if options.Callback then
                buttonFrame.MouseButton1Click:Connect(options.Callback)
            end

            buttonFrame.Parent = tabContent
            tabContent.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tabContent:GetChildren() * 45))

            return buttonFrame
        end

        return tab
    end

    -- Attach UI to PlayerGui
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    return window
end

return ZynoxUI
