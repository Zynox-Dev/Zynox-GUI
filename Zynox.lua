-- Library Table
local Zynox = {}

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Destroy previous GUI
local oldGUI = PlayerGui:FindFirstChild("ZynoxGUI")
if oldGUI then
    oldGUI:Destroy()
end

-- Create Window
function Zynox:CreateWindow()
    local Window = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynoxGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 800, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ScreenGui

    local TopFrame = Instance.new("Frame")
    TopFrame.Size = UDim2.new(1, 0, 0, 30)
    TopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopFrame.BorderSizePixel = 0
    TopFrame.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Zynox"
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

    -- Clear Content
    local function clearContent()
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
    end

    -- Create Sidebar Button
    function Window:CreateSidebar(name, callback)
        local y = #SideFrame:GetChildren() * 50
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, y)
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

    -- Create Toggle
    function Window:CreateToggle(name, defaultState, parent, callback)
        local toggled = defaultState or false
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 200, 0, 40)
        Toggle.Position = UDim2.new(0, 20, 0, #parent:GetChildren() * 50)
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

    -- Create Button
    function Window:CreateButton(name, parent, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 200, 0, 40)
        Button.Position = UDim2.new(0, 20, 0, #parent:GetChildren() * 50)
        Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.Parent = parent

        Button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    -- Draggable
    local dragging, dragInput, dragStart, startPos
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

    return Window
end

return Zynox
