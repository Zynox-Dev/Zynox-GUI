-- Zynox GUI Framework - Clean & Animated
local Zynox = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

function Zynox:CreateWindow(options)
    options = options or {}
    local TitleText = options.Title or "Zynox UI"

    -- Remove old
    local oldGUI = PlayerGui:FindFirstChild("ZynoxGUI")
    if oldGUI then oldGUI:Destroy() end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynoxGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 300)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 8)

    -- Animate Main Frame
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        BackgroundTransparency = 0.05,
        Size = UDim2.new(0, 600, 0, 350)
    }):Play()

    -- Top Bar (Drag)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopText = Instance.new("TextLabel")
    TopText.Size = UDim2.new(1, 0, 1, 0)
    TopText.BackgroundTransparency = 1
    TopText.Text = TitleText
    TopText.Font = Enum.Font.GothamBold
    TopText.TextSize = 18
    TopText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TopText.Parent = TopBar

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -35)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -140, 1, -35)
    Content.Position = UDim2.new(0, 140, 0, 35)
    Content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Content.BorderSizePixel = 0
    Content.Parent = MainFrame

    -- Draggable
    local dragging, dragInput, startPos, startDrag
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            startDrag = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startPos
            MainFrame.Position = UDim2.new(
                startDrag.X.Scale, startDrag.X.Offset + delta.X,
                startDrag.Y.Scale, startDrag.Y.Offset + delta.Y
            )
        end
    end)

    -- Sidebar Buttons
    function Zynox:CreateSidebar(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 42)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Parent = Sidebar

        btn.MouseButton1Click:Connect(function()
            for _, child in ipairs(Content:GetChildren()) do
                if child:IsA("GuiObject") then child:Destroy() end
            end
            callback(Content)
        end)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 90, 90)}):Play()
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
    end

    -- Content Buttons
    function Zynox:CreateButton(text, parent, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0, 20, 0, #parent:GetChildren() * 45)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Parent = parent

        btn.MouseButton1Click:Connect(callback)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        end)
    end

    return Zynox
end

function Zynox:ShowWelcome(title, desc, callback)
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "ZynoxWelcome"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 350, 0, 180)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1

    local UICorner = Instance.new("UICorner", frame)
    UICorner.CornerRadius = UDim.new(0, 8)

    local mainText = Instance.new("TextLabel", frame)
    mainText.Text = title or "Welcome to Zynox UI"
    mainText.TextSize = 24
    mainText.Font = Enum.Font.GothamBold
    mainText.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainText.Position = UDim2.new(0.5, 0, 0, 30)
    mainText.AnchorPoint = Vector2.new(0.5, 0)
    mainText.BackgroundTransparency = 1
    mainText.TextTransparency = 1

    local descText = Instance.new("TextLabel", frame)
    descText.Text = desc or "Enjoy using the interface!"
    descText.TextSize = 18
    descText.Font = Enum.Font.Gotham
    descText.TextColor3 = Color3.fromRGB(200, 200, 200)
    descText.Position = UDim2.new(0.5, 0, 0, 80)
    descText.AnchorPoint = Vector2.new(0.5, 0)
    descText.BackgroundTransparency = 1
    descText.TextTransparency = 1

    -- Animations
    local tweenIn = TweenInfo.new(0.6, Enum.EasingStyle.Quad)
    TweenService:Create(frame, tweenIn, {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(mainText, tweenIn, {TextTransparency = 0}):Play()
    TweenService:Create(descText, tweenIn, {TextTransparency = 0}):Play()

    task.delay(4, function()
        local tweenOut = TweenInfo.new(0.6, Enum.EasingStyle.Quad)
        TweenService:Create(frame, tweenOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(mainText, tweenOut, {TextTransparency = 1}):Play()
        TweenService:Create(descText, tweenOut, {TextTransparency = 1}):Play()
        task.wait(0.7)
        gui:Destroy()
        if callback then callback() end
    end)
end

return Zynox
