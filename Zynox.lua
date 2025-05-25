-- Zynox GUI Framework
local Zynox = {}

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Core CreateWindow function
function Zynox:CreateWindow(options)
    options = options or {}
    local TitleText = options.Title or "Zynox"

    local oldGUI = PlayerGui:FindFirstChild("ZynoxGUI")
    if oldGUI then
        oldGUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynoxGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 300)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

-- Animate MainFrame In
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TweenService:Create(MainFrame, tweenInfo, {
    Size = UDim2.new(0, 800, 0, 400),
    Position = UDim2.new(0.5, -400, 0.5, -200),
    BackgroundTransparency = 0.2
}):Play()


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
            if child:IsA("GuiObject") then
                child:Destroy()
            end
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
            Toggle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            Toggle.Text = name .. ": " .. (toggled and "ON" or "OFF")
            if callback then callback(toggled) end
        end)
    end

    local dragging = false
    local dragInput, dragStart, startPos

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

    TopFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return Zynox
end

-- ShowWelcome with callback
function Zynox:ShowWelcome(titleText, descriptionText, callback)
    local oldWelcome = PlayerGui:FindFirstChild("ZynoxWelcome")
    if oldWelcome then oldWelcome:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynoxWelcome"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 150)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundTransparency = 1
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)

    local MainText = Instance.new("TextLabel")
    MainText.Size = UDim2.new(1, -20, 0, 40)
    MainText.Position = UDim2.new(0, 10, 0, 10)
    MainText.BackgroundTransparency = 1
    MainText.Text = titleText or "Welcome!"
    MainText.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainText.TextSize = 24
    MainText.Font = Enum.Font.GothamBold
    MainText.TextWrapped = true
    MainText.TextTransparency = 1
    MainText.Parent = Frame

    local DescText = Instance.new("TextLabel")
    DescText.Size = UDim2.new(1, -20, 0, 30)
    DescText.Position = UDim2.new(0, 10, 0, 60)
    DescText.BackgroundTransparency = 1
    DescText.Text = descriptionText or "Enjoy the features!"
    DescText.TextColor3 = Color3.fromRGB(180, 180, 180)
    DescText.TextSize = 18
    DescText.Font = Enum.Font.Gotham
    DescText.TextWrapped = true
    DescText.TextTransparency = 1
    DescText.Parent = Frame

    local Credit = Instance.new("TextLabel")
    Credit.Size = UDim2.new(1, -20, 0, 20)
    Credit.Position = UDim2.new(0, 10, 1, -30)
    Credit.BackgroundTransparency = 1
    Credit.Text = "Powered by Zynox UI"
    Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
    Credit.TextSize = 14
    Credit.Font = Enum.Font.Gotham
    Credit.TextTransparency = 1
    Credit.Parent = Frame

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Frame, tweenInfo, {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(MainText, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(DescText, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(Credit, tweenInfo, {TextTransparency = 0}):Play()

    task.delay(4, function()
        local tweenOutInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(Frame, tweenOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(MainText, tweenOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(DescText, tweenOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(Credit, tweenOutInfo, {TextTransparency = 1}):Play()

        task.delay(1, function()
            ScreenGui:Destroy()
            if callback then callback() end
        end)
    end)
end

return Zynox
