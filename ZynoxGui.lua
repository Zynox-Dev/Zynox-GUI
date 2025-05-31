-- ZynoxUI.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI

local theme = {
    Primary = Color3.fromRGB(30, 30, 36),
    Secondary = Color3.fromRGB(25, 25, 30),
    Text = Color3.fromRGB(220, 220, 220),
    Accent = Color3.fromRGB(0, 120, 215)
}

function ZynoxUI:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "Zynox Hub"

    local self = setmetatable({}, ZynoxUI)

    -- ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ZynoxUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = CoreGui

    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 700, 0, 500)
    self.mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    self.mainFrame.BackgroundColor3 = theme.Primary
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = self.mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainFrame

    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = theme.Text
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamSemibold
    titleText.Parent = titleBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 1, 0)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = theme.Text
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    closeButton.MouseButton1Click:Connect(function()
        self.screenGui:Destroy()
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = theme.Secondary
    sidebar.BorderSizePixel = 0
    sidebar.Parent = self.mainFrame

    -- User Info
    local userInfo = Instance.new("Frame")
    userInfo.Name = "UserInfo"
    userInfo.Size = UDim2.new(1, -20, 0, 80)
    userInfo.Position = UDim2.new(0, 10, 0, 10)
    userInfo.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    userInfo.BorderSizePixel = 0
    userInfo.Parent = sidebar

    local userCorner = Instance.new("UICorner")
    userCorner.CornerRadius = UDim.new(0, 6)
    userCorner.Parent = userInfo

    local player = Players.LocalPlayer
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Name = "WelcomeText"
    welcomeText.Size = UDim2.new(1, -20, 0, 40)
    welcomeText.Position = UDim2.new(0, 10, 0, 20)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Text = "Welcome,\n" .. player.Name
    welcomeText.TextColor3 = theme.Text
    welcomeText.TextSize = 16
    welcomeText.TextXAlignment = Enum.TextXAlignment.Left
    welcomeText.TextYAlignment = Enum.TextYAlignment.Top
    welcomeText.Font = Enum.Font.Gotham
    welcomeText.Parent = userInfo

    -- Navigation Buttons & content container
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Size = UDim2.new(1, -180, 1, -50)
    self.contentFrame.Position = UDim2.new(0, 160, 0, 50)
    self.contentFrame.BackgroundColor3 = theme.Primary
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.Parent = self.mainFrame

    self.navButtons = {}

    local navButtons = {
        {Name = "Home", Position = 1, Callback = function() self:ShowHome() end},
        {Name = "Scripts", Position = 2, Callback = function() self:ShowScripts() end},
        {Name = "Settings", Position = 3, Callback = function() self:ShowSettings() end}
    }

    local buttonHeight = 36
    local buttonPadding = 8

    for _, btn in ipairs(navButtons) do
        local button = Instance.new("TextButton")
        button.Name = btn.Name .. "Button"
        button.Size = UDim2.new(1, -20, 0, buttonHeight)
        button.Position = UDim2.new(0, 10, 0, 110 + ((buttonHeight + buttonPadding) * (btn.Position - 1)))
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        button.BorderSizePixel = 0
        button.Text = "   " .. btn.Name
        button.TextColor3 = theme.Text
        button.TextSize = 14
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Font = Enum.Font.Gotham
        button.AutoButtonColor = false
        button.Parent = sidebar

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 52)
            }):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            }):Play()
        end)

        button.MouseButton1Click:Connect(btn.Callback)

        self.navButtons[btn.Name] = button
    end

    -- Dragging
    self:MakeDraggable(titleBar, self.mainFrame)

    -- Show home screen default
    self:ShowHome()

    -- Open animation
    self.mainFrame.Position = UDim2.new(0.5, -350, 0.4, -250)
    self.mainFrame.BackgroundTransparency = 1
    TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -350, 0.5, -250),
        BackgroundTransparency = 0
    }):Play()

    return self
end

function ZynoxUI:MakeDraggable(dragGui, targetGui)
    local dragging, dragInput, dragStart, startPos

    dragGui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = targetGui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragGui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetGui.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function ZynoxUI:ClearContent()
    for _, child in ipairs(self.contentFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

function ZynoxUI:ShowHome()
    self:ClearContent()
    local welcome = Instance.new("TextLabel")
    welcome.Text = "Welcome to Zynox"
    welcome.Size = UDim2.new(1, -40, 0, 40)
    welcome.Position = UDim2.new(0, 20, 0, 20)
    welcome.BackgroundTransparency = 1
    welcome.TextColor3 = theme.Text
    welcome.TextSize = 24
    welcome.TextXAlignment = Enum.TextXAlignment.Left
    welcome.Font = Enum.Font.GothamBold
    welcome.Parent = self.contentFrame

    local desc = Instance.new("TextLabel")
    desc.Text = "Select an option from the sidebar to get started"
    desc.Size = UDim2.new(1, -40, 0, 30)
    desc.Position = UDim2.new(0, 20, 0, 70)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(180, 180, 190)
    desc.TextSize = 16
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Font = Enum.Font.Gotham
    desc.Parent = self.contentFrame
end

function ZynoxUI:ShowScripts()
    self:ClearContent()
    local title = Instance.new("TextLabel")
    title.Text = "Available Scripts"
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.TextColor3 = theme.Text
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = self.contentFrame

    local scripts = {
        {Name = "Infinite Jump", Description = "Jump infinitely in the air"},
        {Name = "Speed Hack", Description = "Run faster than normal"},
        {Name = "No Clip", Description = "Walk through walls"}
    }

    for i, scriptInfo in ipairs(scripts) do
        local button = Instance.new("TextButton")
        button.Name = scriptInfo.Name .. "Button"
        button.Size = UDim2.new(1, -40, 0, 40)
        button.Position = UDim2.new(0, 20, 0, 80 + (i-1) * 50)
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
        button.BorderSizePixel = 0
        button.Text = scriptInfo.Name
        button.TextColor3 = theme.Text
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextYAlignment = Enum.TextYAlignment.Top
        button.Parent = self.contentFrame

        local desc = Instance.new("TextLabel")
        desc.Text = scriptInfo.Description
        desc.Size = UDim2.new(1, -10, 0, 20)
        desc.Position = UDim2.new(0, 10, 0, 20)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(180, 180, 190)
        desc.TextSize = 12
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Font = Enum.Font.Gotham
        desc.Parent = button

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 52)
            }):Play()
        end)

        button.MouseButton1Click:Connect(function()
            print("Executing: " .. scriptInfo.Name)
            -- Add your script execution code here
        end)
    end
end

function ZynoxUI:ShowSettings()
    self:ClearContent()
    local label = Instance.new("TextLabel")
    label.Text = "Settings will go here."
    label.Size = UDim2.new(1, -40, 0, 30)
    label.Position = UDim2.new(0, 20, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = theme.Text
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = self.contentFrame
end

return ZynoxUI
