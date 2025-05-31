-- Zynox.lua
-- Enhanced Zynox UI Library
-- Version: 1.0.0

local Zynox = {}
Zynox.__index = Zynox

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Constants
local DEFAULT_THEME = {
    Primary = Color3.fromRGB(30, 30, 36),
    Secondary = Color3.fromRGB(25, 25, 30),
    Tertiary = Color3.fromRGB(35, 35, 42),
    Accent = Color3.fromRGB(0, 120, 215),
    Text = Color3.fromRGB(220, 220, 220),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    Success = Color3.fromRGB(76, 209, 55),
    Warning = Color3.fromRGB(255, 193, 7),
    Error = Color3.fromRGB(255, 71, 87)
}

-- Utility Functions
local function create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function createRoundedFrame(properties)
    local frame = create("Frame", properties)
    local corner = create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = frame
    })
    return frame, corner
end

-- Zynox Class
function Zynox.new(options)
    options = options or {}
    local self = setmetatable({}, Zynox)
    
    -- Initialize properties
    self.theme = options.theme or DEFAULT_THEME
    self.size = options.size or UDim2.new(0, 720, 0, 480)
    self.position = options.position or UDim2.new(0.5, -360, 0.5, -240)
    self.title = options.title or "Zynox"
    self.minSize = options.minSize or UDim2.new(0, 400, 0, 300)
    
    -- Create UI
    self:createUI()
    self:setupDragging()
    self:setupResize()
    
    return self
end

function Zynox:createUI()
    -- Main ScreenGui
    self.screenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    -- Main Container
    self.mainFrame, _ = createRoundedFrame({
        Name = "MainFrame",
        Size = self.size,
        Position = self.position,
        BackgroundColor3 = self.theme.Primary,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        Parent = self.screenGui
    })

    -- Title Bar
    self.titleBar = createRoundedFrame({
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.theme.Secondary,
        Parent = self.mainFrame
    })
    self.titleBar.UICorner.CornerRadius = UDim.new(0, 8, 0, 0)

    -- Title Text
    self.titleText = create("TextLabel", {
        Name = "TitleText",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = self.title,
        TextColor3 = self.theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        Parent = self.titleBar
    })

    -- Close Button
    self.closeButton = create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = self.theme.Text,
        TextSize = 28,
        Font = Enum.Font.GothamBold,
        Parent = self.titleBar
    })

    -- Sidebar
    self:createSidebar()
    
    -- Content Frame
    self.contentFrame = create("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -180, 1, -50),
        Position = UDim2.new(0, 160, 0, 50),
        BackgroundColor3 = self.theme.Primary,
        BorderSizePixel = 0,
        Parent = self.mainFrame
    })

    -- Initialize default content
    self:setupDefaultContent()
end

function Zynox:createSidebar()
    self.sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = self.theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.mainFrame
    })

    -- User Info
    self.userInfo = createRoundedFrame({
        Name = "UserInfo",
        Size = UDim2.new(1, -20, 0, 80),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = self.theme.Tertiary,
        Parent = self.sidebar
    })

    local player = Players.LocalPlayer
    local displayName = player.DisplayName ~= player.Name and player.DisplayName or player.Name
    self.userName = create("TextLabel", {
        Name = "UserName",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 20),
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = self.theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Font = Enum.Font.GothamSemibold,
        Parent = self.userInfo
    })

    self.userId = create("TextLabel", {
        Name = "UserId",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        Text = "ID: " .. tostring(player.UserId),
        TextColor3 = self.theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        Parent = self.userInfo
    })

    -- Navigation
    self.navButtons = {}
    self:addNavButton("Home", 1, "rbxassetid://6031075931")
    self:addNavButton("Scripts", 2, "rbxassetid://6031075927")
    self:addNavButton("Settings", 3, "rbxassetid://6031075938")
end

function Zynox:addNavButton(name, position, iconId)
    local button = create("TextButton", {
        Name = name .. "Button",
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 110 + (position - 1) * 46),
        BackgroundColor3 = self.theme.Tertiary,
        BorderSizePixel = 0,
        Text = "   " .. name,
        TextColor3 = self.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        Parent = self.sidebar
    })

    local corner = create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button
    })

    -- Add icon if provided
    if iconId then
        local icon = create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = self.theme.Text,
            Parent = button
        })
    end

    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 52)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.theme.Tertiary
        }):Play()
    end)

    table.insert(self.navButtons, {
        Name = name,
        Button = button
    })

    return button
end

function Zynox:setupDefaultContent()
    -- Clear existing content
    for _, child in ipairs(self.contentFrame:GetChildren()) do
        if child:IsA("UIBase") then
            child:Destroy()
        end
    end

    -- Add welcome message
    local welcomeLabel = create("TextLabel", {
        Name = "WelcomeLabel",
        Size = UDim2.new(1, -40, 0, 60),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "Welcome to Zynox",
        TextColor3 = self.theme.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Parent = self.contentFrame
    })

    local description = create("TextLabel", {
        Name = "Description",
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, 80),
        BackgroundTransparency = 1,
        Text = "Select an option from the sidebar to get started",
        TextColor3 = self.theme.TextSecondary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Font = Enum.Font.Gotham,
        Parent = self.contentFrame
    })
end

function Zynox:setupDragging()
    local dragging = false
    local dragStart
    local startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        self.mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateInput(input)
        end
    end)
end

function Zynox:setupResize()
    local resizeHandle = create("Frame", {
        Name = "ResizeHandle",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Parent = self.mainFrame
    })

    local resizeIcon = create("ImageLabel", {
        Name = "ResizeIcon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031068421",
        ImageColor3 = self.theme.TextSecondary,
        Parent = resizeHandle
    })

    local isResizing = false
    local startPos
    local startSize

    local function updateSize(input)
        local delta = input.Position - startPos
        local newSize = UDim2.new(
            startSize.X.Scale,
            math.max(self.minSize.X.Offset, startSize.X.Offset + delta.X),
            startSize.Y.Scale,
            math.max(self.minSize.Y.Offset, startSize.Y.Offset + delta.Y)
        )
        self.mainFrame.Size = newSize
    end

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = true
            startPos = input.Position
            startSize = self.mainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                end
            end)
        end
    end)

    resizeHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isResizing then
            updateSize(input)
        end
    end)
end

function Zynox:show()
    self.screenGui.Enabled = true
    -- Add show animation
    self.mainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
    self.mainFrame.BackgroundTransparency = 1
    TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -self.size.X.Offset/2, 0.5, -self.size.Y.Offset/2),
        BackgroundTransparency = 0
    }):Play()
end

function Zynox:hide()
    -- Add hide animation
    TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 1
    }):Play()
    wait(0.3)
    self.screenGui.Enabled = false
end

function Zynox:destroy()
    self.screenGui:Destroy()
end

-- Close button functionality
function Zynox:setupCloseButton()
    self.closeButton.MouseButton1Click:Connect(function()
        self:hide()
    end)
end

-- Initialize
function Zynox:init()
    self:setupCloseButton()
    self:show()
end

return Zynox
