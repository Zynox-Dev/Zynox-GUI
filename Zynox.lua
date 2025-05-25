-- Zynox GUI Framework (Enhanced)
local Zynox = {}

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function CreateTween(instance, properties, time, style, direction)
    TweenService:Create(instance, TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties):Play()
end

function Zynox:CreateWindow(options)
    options = options or {}
    local TitleText = options.Title or "Zynox"

    local oldGUI = PlayerGui:FindFirstChild("ZynoxGUI")
    if oldGUI then oldGUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynoxGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 300)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Animate MainFrame In
    CreateTween(MainFrame, {BackgroundTransparency = 0.2, Size = UDim2.new(0, 700, 0, 350)}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local TopFrame = Instance.new("Frame")
    TopFrame.Size = UDim2.new(1, 0, 0, 30)
    TopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopFrame.BorderSizePixel = 0
    TopFrame.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = TopFrame

    local SideFrame = Instance.new("Frame")
    SideFrame.Size = UDim2.new(0, 150, 1, -30)
    SideFrame.Position = UDim2.new(0, 0, 0, 30)
    SideFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SideFrame.BorderSizePixel = 0
    SideFrame.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -150, 1, -30)
    ContentFrame.Position = UDim2.new(0, 150, 0, 30)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame

    local function clearContent()
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
    end

    function Zynox:CreateSidebar(name, callback)
        local positionY = #SideFrame:GetChildren() * 45
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, positionY)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Parent = SideFrame

        btn.MouseButton1Click:Connect(function()
            clearContent()
            callback(ContentFrame)
            CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.3)
            task.delay(0.3, function()
                CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.3)
            end)
        end)

        btn.MouseEnter:Connect(function()
            CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(90, 90, 90)}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.2)
        end)
    end

    function Zynox:CreateButton(name, parent, callback)
        local y = #parent:GetChildren() * 45
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Parent = parent

        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function()
            CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(90, 90, 90)}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.2)
        end)
    end

    function Zynox:CreateToggle(name, defaultState, parent, callback)
        local toggled = defaultState or false
        local y = #parent:GetChildren() * 45

        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 200, 0, 40)
        Toggle.Position = UDim2.new(0, 20, 0, y)
        Toggle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        Toggle.Text = name .. ": " .. (toggled and "ON" or "OFF")
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Font = Enum.Font.Gotham
        Toggle.TextSize = 16
        Toggle.Parent = parent

        Toggle.MouseButton1Click:Connect(function()
            toggled = not toggled
            CreateTween(Toggle, {BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)}, 0.2)
            Toggle.Text = name .. ": " .. (toggled and "ON" or "OFF")
            if callback then callback(toggled) end
        end)
    end

    -- Draggable Smooth
    local dragging, dragStart, startPos
    TopFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return Zynox
end

-- Welcome Animation (unchanged for now)
-- [Keep your existing ShowWelcome function here]

return Zynox
