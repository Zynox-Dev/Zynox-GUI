-- ZynoxUI Library
local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Main Library
local Library = {}
Library.__index = Library

-- Animation Settings
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local fastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Utility Functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createPadding(parent, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding.Top or 0)
    pad.PaddingBottom = UDim.new(0, padding.Bottom or 0)
    pad.PaddingLeft = UDim.new(0, padding.Left or 0)
    pad.PaddingRight = UDim.new(0, padding.Right or 0)
    pad.Parent = parent
    return pad
end

local function addHoverEffect(element, normalColor, hoverColor)
    element.MouseEnter:Connect(function()
        TweenService:Create(element, fastTween, {BackgroundColor3 = hoverColor}):Play()
    end)
    
    element.MouseLeave:Connect(function()
        TweenService:Create(element, fastTween, {BackgroundColor3 = normalColor}):Play()
    end)
end

-- Create Main Window
function Library:CreateWindow(config)
    local window = {}
    
    -- Default config
    config = config or {}
    config.Title = config.Title or "ZynoxUI"
    config.Size = config.Size or {320, 400}
    config.Theme = config.Theme or "Dark"
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZynoxUI_" .. config.Title
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, config.Size[1], 0, config.Size[2])
    mainFrame.Position = UDim2.new(0.5, -config.Size[1]/2, 0.5, -config.Size[2]/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    createCorner(mainFrame, 12)
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    createCorner(titleBar, 12)
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Center
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    createCorner(closeButton, 8)
    addHoverEffect(closeButton, Color3.fromRGB(255, 75, 75), Color3.fromRGB(255, 100, 100))
    
    -- Content Frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -50)
    contentFrame.Position = UDim2.new(0, 10, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 105)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = mainFrame
    
    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = contentFrame
    
    -- Update canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Window object
    window.ScreenGui = screenGui
    window.MainFrame = mainFrame
    window.ContentFrame = contentFrame
    window.Layout = layout
    window.ElementCount = 0
    
    -- Create Toggle
    function window:CreateToggle(config)
        config = config or {}
        config.Name = config.Name or "Toggle"
        config.Default = config.Default or false
        config.Callback = config.Callback or function() end
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "ToggleFrame"
        toggleFrame.Size = UDim2.new(1, 0, 0, 40)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.LayoutOrder = self.ElementCount
        toggleFrame.Parent = self.ContentFrame
        
        createCorner(toggleFrame, 8)
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -60, 1, 0)
        toggleLabel.Position = UDim2.new(0, 15, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = config.Name
        toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel.TextSize = 14
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        -- Toggle Switch
        local switchFrame = Instance.new("Frame")
        switchFrame.Size = UDim2.new(0, 45, 0, 22)
        switchFrame.Position = UDim2.new(1, -55, 0.5, -11)
        switchFrame.BackgroundColor3 = config.Default and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(60, 60, 65)
        switchFrame.BorderSizePixel = 0
        switchFrame.Parent = toggleFrame
        
        createCorner(switchFrame, 11)
        
        local switchButton = Instance.new("TextButton")
        switchButton.Size = UDim2.new(0, 18, 0, 18)
        switchButton.Position = config.Default and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
        switchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        switchButton.BorderSizePixel = 0
        switchButton.Text = ""
        switchButton.Parent = switchFrame
        
        createCorner(switchButton, 9)
        
        local isToggled = config.Default
        
        switchButton.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            
            local targetPos = isToggled and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
            local targetColor = isToggled and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(60, 60, 65)
            
            TweenService:Create(switchButton, tweenInfo, {Position = targetPos}):Play()
            TweenService:Create(switchFrame, tweenInfo, {BackgroundColor3 = targetColor}):Play()
            
            config.Callback(isToggled)
        end)
        
        self.ElementCount = self.ElementCount + 1
        
        return {
            Toggle = function(state)
                if state ~= nil and state ~= isToggled then
                    switchButton.MouseButton1Click:Fire()
                end
            end,
            GetState = function()
                return isToggled
            end
        }
    end
    
    -- Create Slider
    function window:CreateSlider(config)
        config = config or {}
        config.Name = config.Name or "Slider"
        config.Min = config.Min or 0
        config.Max = config.Max or 100
        config.Default = config.Default or config.Min
        config.Callback = config.Callback or function() end
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = "SliderFrame"
        sliderFrame.Size = UDim2.new(1, 0, 0, 50)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.LayoutOrder = self.ElementCount
        sliderFrame.Parent = self.ContentFrame
        
        createCorner(sliderFrame, 8)
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(1, -60, 0, 25)
        sliderLabel.Position = UDim2.new(0, 15, 0, 5)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = config.Name .. ": " .. config.Default
        sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderLabel.TextSize = 14
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        -- Slider Track
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Size = UDim2.new(1, -30, 0, 6)
        sliderTrack.Position = UDim2.new(0, 15, 1, -20)
        sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        sliderTrack.BorderSizePixel = 0
        sliderTrack.Parent = sliderFrame
        
        createCorner(sliderTrack, 3)
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderTrack
        
        createCorner(sliderFill, 3)
        
        local sliderKnob = Instance.new("TextButton")
        sliderKnob.Size = UDim2.new(0, 16, 0, 16)
        sliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
        sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderKnob.BorderSizePixel = 0
        sliderKnob.Text = ""
        sliderKnob.Parent = sliderTrack
        
        createCorner(sliderKnob, 8)
        
        local currentValue = config.Default
        local isDragging = false
        
        local function updateSlider()
            local percentage = (currentValue - config.Min) / (config.Max - config.Min)
            local fillSize = UDim2.new(percentage, 0, 1, 0)
            local knobPos = UDim2.new(percentage, -8, 0.5, -8)
            
            TweenService:Create(sliderFill, fastTween, {Size = fillSize}):Play()
            TweenService:Create(sliderKnob, fastTween, {Position = knobPos}):Play()
            
            sliderLabel.Text = config.Name .. ": " .. currentValue
        end
        
        local function onSliderInput(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                
                local connection
                connection = UserInputService.InputChanged:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                        local mousePos = input2.Position.X
                        local trackPos = sliderTrack.AbsolutePosition.X
                        local trackSize = sliderTrack.AbsoluteSize.X
                        local relativePos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                        
                        currentValue = math.floor(config.Min + (config.Max - config.Min) * relativePos)
                        updateSlider()
                        config.Callback(currentValue)
                    end
                end)
                
                local releaseConnection
                releaseConnection = UserInputService.InputEnded:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        connection:Disconnect()
                        releaseConnection:Disconnect()
                    end
                end)
            end
        end
        
        sliderKnob.InputBegan:Connect(onSliderInput)
        sliderTrack.InputBegan:Connect(onSliderInput)
        
        updateSlider()
        self.ElementCount = self.ElementCount + 1
        
        return {
            SetValue = function(value)
                currentValue = math.clamp(value, config.Min, config.Max)
                updateSlider()
                config.Callback(currentValue)
            end,
            GetValue = function()
                return currentValue
            end
        }
    end
    
    -- Create Dropdown
    function window:CreateDropdown(config)
        config = config or {}
        config.Name = config.Name or "Dropdown"
        config.Options = config.Options or {"Option 1", "Option 2"}
        config.Default = config.Default or config.Options[1]
        config.Callback = config.Callback or function() end
        
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = "DropdownFrame"
        dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.LayoutOrder = self.ElementCount
        dropdownFrame.Parent = self.ContentFrame
        
        createCorner(dropdownFrame, 8)
        
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Size = UDim2.new(0, 100, 1, 0)
        dropdownLabel.Position = UDim2.new(0, 15, 0, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = config.Name .. ":"
        dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownLabel.TextSize = 14
        dropdownLabel.Font = Enum.Font.Gotham
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0, 120, 0, 25)
        dropdownButton.Position = UDim2.new(1, -135, 0.5, -12.5)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Text = config.Default .. " ▼"
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.TextSize = 12
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
        dropdownButton.Parent = dropdownFrame
        
        createCorner(dropdownButton, 6)
        createPadding(dropdownButton, {Left = 10, Right = 10})
        addHoverEffect(dropdownButton, Color3.fromRGB(45, 45, 50), Color3.fromRGB(55, 55, 60))
        
        local dropdownMenu = Instance.new("ScrollingFrame")
        dropdownMenu.Size = UDim2.new(0, 120, 0, 0)
        dropdownMenu.Position = UDim2.new(1, -135, 1, 5)
        dropdownMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        dropdownMenu.BorderSizePixel = 0
        dropdownMenu.ScrollBarThickness = 4
        dropdownMenu.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 105)
        dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, 0)
        dropdownMenu.Visible = false
        dropdownMenu.Parent = dropdownFrame
        
        createCorner(dropdownMenu, 6)
        
        local menuLayout = Instance.new("UIListLayout")
        menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
        menuLayout.Parent = dropdownMenu
        
        local selectedOption = config.Default
        local isOpen = false
        
        -- Create options
        for i, option in ipairs(config.Options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            optionButton.TextSize = 11
            optionButton.Font = Enum.Font.Gotham
            optionButton.TextXAlignment = Enum.TextXAlignment.Left
            optionButton.LayoutOrder = i
            optionButton.Parent = dropdownMenu
            
            createPadding(optionButton, {Left = 10})
            
            addHoverEffect(optionButton, Color3.fromRGB(45, 45, 50), Color3.fromRGB(60, 60, 65))
            
            optionButton.MouseButton1Click:Connect(function()
                selectedOption = option
                dropdownButton.Text = option .. " ▼"
                
                isOpen = false
                TweenService:Create(dropdownMenu, tweenInfo, {
                    Size = UDim2.new(0, 120, 0, 0)
                }):Play()
                
                task.wait(0.3)
                dropdownMenu.Visible = false
                
                config.Callback(option)
            end)
        end
        
        -- Update canvas size
        menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, menuLayout.AbsoluteContentSize.Y)
        end)
        
        -- Toggle dropdown
        dropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            
            if isOpen then
                dropdownMenu.Visible = true
                local targetHeight = math.min(100, #config.Options * 25)
                TweenService:Create(dropdownMenu, tweenInfo, {
                    Size = UDim2.new(0, 120, 0, targetHeight)
                }):Play()
                dropdownButton.Text = string.gsub(dropdownButton.Text, "▼", "▲")
            else
                TweenService:Create(dropdownMenu, tweenInfo, {
                    Size = UDim2.new(0, 120, 0, 0)
                }):Play()
                dropdownButton.Text = string.gsub(dropdownButton.Text, "▲", "▼")
                
                task.wait(0.3)
                dropdownMenu.Visible = false
            end
        end)
        
        self.ElementCount = self.ElementCount + 1
        
        return {
            SetOption = function(option)
                if table.find(config.Options, option) then
                    selectedOption = option
                    dropdownButton.Text = option .. " ▼"
                    config.Callback(option)
                end
            end,
            GetOption = function()
                return selectedOption
            end
        }
    end
    
    -- Create Button
    function window:CreateButton(config)
        config = config or {}
        config.Name = config.Name or "Button"
        config.Callback = config.Callback or function() end
        
        local buttonFrame = Instance.new("TextButton")
        buttonFrame.Name = "ButtonFrame"
        buttonFrame.Size = UDim2.new(1, 0, 0, 35)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        buttonFrame.BorderSizePixel = 0
        buttonFrame.LayoutOrder = self.ElementCount
        buttonFrame.Text = config.Name
        buttonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
        buttonFrame.TextSize = 14
        buttonFrame.Font = Enum.Font.GothamBold
        buttonFrame.Parent = self.ContentFrame
        
        createCorner(buttonFrame, 8)
        addHoverEffect(buttonFrame, Color3.fromRGB(100, 150, 255), Color3.fromRGB(120, 170, 255))
        
        buttonFrame.MouseButton1Click:Connect(function()
            config.Callback()
        end)
        
        self.ElementCount = self.ElementCount + 1
        
        return {
            SetText = function(text)
                buttonFrame.Text = text
            end
        }
    end
    
    return window
end

-- Export Library
return Library
