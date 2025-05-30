-- ZynoxUI - A modern UI library for Roblox
-- Version: 3.0.0

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Main ZynoxUI table
local Zynox = {}
Zynox.__index = Zynox
Zynox.Version = "3.0.0"

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
    self.Theme = options.Theme or "Dark"
    
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
        BackgroundColor3 = Zynox.Theme[self.Theme].Background,
        BorderSizePixel = 0,
        Parent = self.Elements.ScreenGui
    })
    
    applyCorner(self.Elements.MainFrame)
    
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
    
    self.Elements.MainFrame.InputBegan:Connect(function(input)
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
    
    self.Elements.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateDrag(input)
        end
    end)
    
    return self
end

-- Add destroy method
function Window:Destroy()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    if self.Elements.ScreenGui then
        self.Elements.ScreenGui:Destroy()
    end
end

return Zynox
