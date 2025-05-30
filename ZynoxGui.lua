-- ZynoxUI - A modern UI library for Roblox
-- Version: 3.0.2 (Enhanced with Glow Effects)

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Main ZynoxUI table
local Zynox = {}
Zynox.__index = Zynox
Zynox.Version = "3.0.2"

-- Enhanced theme with glow colors
Zynox.Theme = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(35, 35, 35),
        ButtonHover = Color3.fromRGB(45, 45, 45),
        Toggle = Color3.fromRGB(40, 40, 40),
        ToggleAccent = Color3.fromRGB(0, 120, 215),
        Accent = Color3.fromRGB(0, 120, 215),
        Border = Color3.fromRGB(60, 60, 60),
        Glow = Color3.fromRGB(0, 170, 255), -- New glow color
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

-- Utility Functions
local function create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function applyCorner(instance, radius)
    local corner = create("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 8)
    corner.Parent = instance
    return corner
end

-- Create glow effect
local function createGlowEffect(parent, color, transparency, size)
    local glow = create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://4996891970",
        ImageColor3 = color or Color3.fromRGB(0, 170, 255),
        ImageTransparency = transparency or 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        Size = size or UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        ZIndex = -1,
        Parent = parent
    })
    return glow
end

-- Window class
local Window = {}
Window.__index = Window

function Zynox:CreateWindow(title, options)
    options = options or {}
    local self = setmetatable({}, Window)
    
    self.Elements = {}
    self.Connections = {}
    self.ThemeName = options.Theme or "Dark"
    self.Theme = Zynox.Theme[self.ThemeName] or Zynox.Theme["Dark"]
    
    -- Create main UI container
    self.Elements.ScreenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = CoreGui
    })
    
    -- Create drop shadow
    local shadow = create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -260, 0.5, -210),
        Size = UDim2.new(0, 520, 0, 440),
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.9,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = 0,
        Parent = self.Elements.ScreenGui
    })
    
    -- Create main window frame with glow
    self.Elements.MainFrame = create("Frame", {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Elements.ScreenGui,
        ZIndex = 1
    })
    
    -- Add glow effect
    createGlowEffect(self.Elements.MainFrame, self.Theme.Glow, 0.9)
    
    -- Add subtle gradient
    local gradient = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
        }),
        Rotation = 90,
        Parent = self.Elements.MainFrame
    })
    
    applyCorner(self.Elements.MainFrame)
    
    -- Add topbar with gradient
    self.Elements.Topbar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Topbar,
        BorderSizePixel = 0,
        Parent = self.Elements.MainFrame
    })
    
    applyCorner(self.Elements.Topbar, UDim.new(0, 8, 0, 0))
    
    -- Add title with glow effect
    self.Elements.Title = create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "ZynoxUI",
        TextColor3 = self.Theme.Text,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Parent = self.Elements.Topbar
    })
    
    -- Add content frame with padding
    self.Elements.Content = create("Frame", {
        Size = UDim2.new(1, -40, 1, -70),
        Position = UDim2.new(0, 20, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.Elements.MainFrame
    })
    
    -- Add scrolling frame for content
    self.Elements.ScrollFrame = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Accent,
        ScrollBarImageTransparency = 0.7,
        Parent = self.Elements.Content
    })
    
    -- Add UIListLayout for automatic element arrangement
    self.Elements.ListLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = self.Elements.ScrollFrame
    })
    
    -- Update scroll frame size when content changes
    self.Elements.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Elements.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.Elements.ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Add window dragging
    local dragging = false
    local dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        self.Elements.MainFrame.Position = newPosition
        shadow.Position = UDim2.new(
            newPosition.X.Scale,
            newPosition.X.Offset - 10,
            newPosition.Y.Scale,
            newPosition.Y.Offset - 10
        )
    end
    
    local dragConn1 = self.Elements.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Elements.MainFrame.Position
            local dragConn2
            dragConn2 = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if dragConn2 then
                        dragConn2:Disconnect()
                    end
                end
            end)
            table.insert(self.Connections, dragConn2)
        end
    end)
    
    local dragConn3 = self.Elements.Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateDrag(input)
        end
    end)
    
    -- Track connections for cleanup
    table.insert(self.Connections, dragConn1)
    table.insert(self.Connections, dragConn3)
    
    -- Store the window for later reference
    Zynox.Windows = Zynox.Windows or {}
    table.insert(Zynox.Windows, self)
    
    -- Add subtle pulse animation to glow
    local glow = self.Elements.MainFrame:FindFirstChild("Glow")
    if glow then
        local pulseIn = TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            ImageTransparency = 0.85
        })
        local pulseOut = TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            ImageTransparency = 0.95
        })
        pulseIn:Play()
        pulseOut:Play()
    end
    
    return self
end

-- Enhanced button with glow effect
function Window:CreateButton(text, callback)
    local buttonContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })
    
    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = self.Theme.Button,
        Text = text or "Button",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        Parent = buttonContainer
    })
    
    -- Add glow effect
    local glow = createGlowEffect(button, self.Theme.Glow, 0.95, UDim2.new(1, 10, 1, 10))
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.ZIndex = 0
    
    applyCorner(button)
    
    -- Button hover effects
    local originalColor = button.BackgroundColor3
    local hoverColor = self.Theme.ButtonHover
    
    local enterConn = button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 50)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.8
        }):Play()
    end)
    
    local leaveConn = button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor,
            Position = UDim2.new(0, 0, 0, 3),
            Size = UDim2.new(1, 0, 0, 44)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.95
        }):Play()
    end)
    
    -- Button click handler
    local clickConn
    if type(callback) == "function" then
        clickConn = button.MouseButton1Click:Connect(function()
            -- Add click animation
            local originalSize = button.Size
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.95, 0, 0, 42)
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = originalSize
            }):Play()
            callback()
        end)
    end
    
    -- Track connections for cleanup
    table.insert(self.Connections, enterConn)
    table.insert(self.Connections, leaveConn)
    if clickConn then
        table.insert(self.Connections, clickConn)
    end
    
    return button
end

-- Enhanced toggle with glow effect
function Window:CreateToggle(text, defaultState, callback)
    local toggleContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })
    
    local toggleFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundTransparency = 1,
        Parent = toggleContainer
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text or "Toggle",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        Parent = toggleFrame
    })
    
    local toggleOuter = create("Frame", {
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, 0, 0.5, -13),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = self.Theme.Toggle,
        Parent = toggleFrame
    })
    
    -- Add glow to toggle
    local toggleGlow = createGlowEffect(toggleOuter, self.Theme.Glow, 0.95, UDim2.new(1, 6, 1, 6))
    toggleGlow.Position = UDim2.new(0, -3, 0, -3)
    toggleGlow.ZIndex = -1
    
    local toggleInner = create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 3, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = toggleOuter
    })
    
    applyCorner(toggleOuter, UDim.new(1, 0))
    applyCorner(toggleInner, UDim.new(1, 0))
    
    local state = defaultState or false
    
    local function updateToggle()
        local targetPosition = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local targetColor = state and self.Theme.ToggleAccent or self.Theme.Toggle
        local targetGlowTransparency = state and 0.8 or 0.95
        
        TweenService:Create(toggleOuter, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor
        }):Play()
        
        TweenService:Create(toggleInner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPosition
        }):Play()
        
        TweenService:Create(toggleGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = targetGlowTransparency
        }):Play()
        
        if callback then
            task.spawn(callback, state)
        end
    end
    
    -- Toggle on click with animation
    local toggleConn = toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            -- Add click animation
            TweenService:Create(toggleFrame, TweenInfo.new(0.1), {
                Position = UDim2.new(0, 0, 0, 5)
            }):Play()
            task.wait(0.1)
            TweenService:Create(toggleFrame, TweenInfo.new(0.1), {
                Position = UDim2.new(0, 0, 0, 3)
            }):Play()
            updateToggle()
        end
    end)
    
    -- Track connection for cleanup
    table.insert(self.Connections, toggleConn)
    
    -- Set initial state
    toggleInner.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    toggleOuter.BackgroundColor3 = state and self.Theme.ToggleAccent or self.Theme.Toggle
    toggleGlow.ImageTransparency = state and 0.8 or 0.95
    
    -- Return toggle API
    return {
        SetState = function(_, newState)
            if state ~= newState then
                state = newState
                updateToggle()
            end
        end,
        GetState = function()
            return state
        end
    }
end

-- Add destroy method with cleanup
function Window:Destroy()
    -- Disconnect all connections
    for _, connection in ipairs(self.Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    
    -- Clean up UI elements
    if self.Elements.ScreenGui then
        self.Elements.ScreenGui:Destroy()
    end
    
    -- Remove from windows table
    if Zynox.Windows then
        for i, window in ipairs(Zynox.Windows) do
            if window == self then
                table.remove(Zynox.Windows, i)
                break
            end
        end
    end
end

return Zynox
