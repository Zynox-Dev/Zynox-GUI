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
        Glow = Color3.fromRGB(0, 170, 255),
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
    
    self.Elements.ScreenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = CoreGui
    })
    
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
    
    self.Elements.MainFrame = create("Frame", {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Elements.ScreenGui,
        ZIndex = 1
    })
    
    createGlowEffect(self.Elements.MainFrame, self.Theme.Glow, 0.9)
    
    applyCorner(self.Elements.MainFrame)
    
    self.Elements.Topbar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Topbar,
        BorderSizePixel = 0,
        Parent = self.Elements.MainFrame
    })
    
    applyCorner(self.Elements.Topbar, UDim.new(0, 8, 0, 0))
    
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
    
    self.Elements.Content = create("Frame", {
        Size = UDim2.new(1, -40, 1, -70),
        Position = UDim2.new(0, 20, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.Elements.MainFrame
    })
    
    self.Elements.ScrollFrame = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Accent,
        ScrollBarImageTransparency = 0.7,
        Parent = self.Elements.Content
    })
    
    self.Elements.ListLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = self.Elements.ScrollFrame
    })
    
    self.Elements.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Elements.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.Elements.ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Draggable window
    local dragging = false
    local dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        self.Elements.MainFrame.Position = newPos
        shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 10, newPos.Y.Scale, newPos.Y.Offset - 10)
    end
    
    self.Elements.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Elements.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.Elements.Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateDrag(input)
        end
    end)
    
    -- Return the window object
    return self
end

-- Button
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
    
    local glow = createGlowEffect(button, self.Theme.Glow, 0.95, UDim2.new(1, 10, 1, 10))
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.ZIndex = 0
    
    applyCorner(button)
    
    local originalColor = button.BackgroundColor3
    local hoverColor = self.Theme.ButtonHover
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 50)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.8
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor,
            Position = UDim2.new(0, 0, 0, 3),
            Size = UDim2.new(1, 0, 0, 44)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.95
        }):Play()
    end)
    
    if type(callback) == "function" then
        button.MouseButton1Click:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.95, 0, 0, 42)
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(1, 0, 0, 44)
            }):Play()
            callback()
        end)
    end
    
    return button
end

-- Toggle (full, finished!)
function Window:CreateToggle(text, defaultState, callback)
    local state = defaultState or false

    local toggleContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })

    local toggleFrame = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = self.Theme.Toggle,
        Text = text or "Toggle",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = toggleContainer
    })

    local toggleGlow = createGlowEffect(toggleFrame, self.Theme.Glow, 0.95)
    applyCorner(toggleFrame)

    toggleFrame.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and self.Theme.ToggleAccent or self.Theme.Toggle
        local targetTransparency = state and 0.8 or 0.95
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleGlow, TweenInfo.new(0.2), {ImageTransparency = targetTransparency}):Play()
        if callback then
            callback(state)
        end
    end)

    return toggleFrame
end

return Zynox
