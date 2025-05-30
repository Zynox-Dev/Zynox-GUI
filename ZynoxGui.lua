-- ZynoxUI - A modern UI library for Roblox
-- Version: 3.0.1 (Improved)

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

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

-- Main ZynoxUI table
local Zynox = {}
Zynox.__index = Zynox
Zynox.Version = "3.0.1"

-- Default theme
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
        Border = Color3.fromRGB(60, 60, 60)
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
    
    -- Create main window frame
    self.Elements.MainFrame = create("Frame", {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Elements.ScreenGui
    })
    
    applyCorner(self.Elements.MainFrame)
    
    -- Add window title
    self.Elements.Title = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "ZynoxUI",
        TextColor3 = self.Theme.Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Parent = self.Elements.MainFrame
    })
    
    -- Add content frame
    self.Elements.Content = create("Frame", {
        Size = UDim2.new(1, -40, 1, -60),
        Position = UDim2.new(0, 20, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Elements.MainFrame
    })
    
    -- Add UIListLayout for automatic element arrangement
    self.Elements.ListLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.Elements.Content
    })
    
    -- Add window dragging
    local dragging = false
    local dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        self.Elements.MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    local dragConn1
    local dragConn2
    
    dragConn1 = self.Elements.Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Elements.MainFrame.Position
            dragConn2 = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragConn2:Disconnect()
                end
            end)
        end
    end)
    
    local dragConn3 = self.Elements.Title.InputChanged:Connect(function(input)
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
    
    return self
end

-- Add button creation method
function Window:CreateButton(text, callback)
    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Button,
        Text = text or "Button",
        TextColor3 = self.Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamSemibold,
        Parent = self.Elements.Content,
        AutoButtonColor = false
    })
    
    applyCorner(button)
    
    -- Button hover effects
    local originalColor = button.BackgroundColor3
    local hoverColor = self.Theme.ButtonHover
    
    local enterConn = button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    
    local leaveConn = button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
    
    -- Button click handler
    local clickConn
    if type(callback) == "function" then
        clickConn = button.MouseButton1Click:Connect(callback)
    end
    
    -- Track connections for cleanup
    table.insert(self.Connections, enterConn)
    table.insert(self.Connections, leaveConn)
    if clickConn then
        table.insert(self.Connections, clickConn)
    end
    
    return button
end

-- Add toggle creation method
function Window:CreateToggle(text, defaultState, callback)
    local toggleFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = self.Elements.Content
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
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, 0, 0.5, -12),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = self.Theme.Toggle,
        Parent = toggleFrame
    })
    
    local toggleInner = create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 2, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = toggleOuter
    })
    
    applyCorner(toggleOuter, UDim.new(1, 0)) -- Full rounded corners
    applyCorner(toggleInner, UDim.new(1, 0)) -- Full rounded corners
    
    local state = defaultState or false
    
    local function updateToggle()
        local targetPosition = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local targetColor = state and self.Theme.ToggleAccent or self.Theme.Toggle
        
        TweenService:Create(toggleOuter, TweenInfo.new(0.3), {
            BackgroundColor3 = targetColor
        }):Play()
        
        TweenService:Create(toggleInner, TweenInfo.new(0.3), {
            Position = targetPosition
        }):Play()
        
        if callback then
            callback(state)
        end
    end
    
    -- Toggle on click
    local toggleConn = toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateToggle()
        end
    end)
    
    -- Track connection for cleanup
    table.insert(self.Connections, toggleConn)
    
    -- Set initial state
    updateToggle()
    
    -- Return toggle API
    return {
        SetState = function(self, newState)
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

-- Add destroy method
function Window:Destroy()
    for _, connection in ipairs(self.Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    if self.Elements.ScreenGui then
        self.Elements.ScreenGui:Destroy()
    end
end

return Zynox
