local ZynoxUI = {}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

function ZynoxUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Zynox UI"
    local welcome = config.WelcomeText or ("Welcome " .. Player.Name)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynoxUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 800, 0, 500)
    MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Name = "Main"
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 8)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 16
    CloseButton.Parent = TopBar

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local WelcomeText = Instance.new("TextLabel")
    WelcomeText.Size = UDim2.new(0, 200, 0, 30)
    WelcomeText.Position = UDim2.new(0, 10, 0, 50)
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    WelcomeText.Font = Enum.Font.Gotham
    WelcomeText.Text = welcome
    WelcomeText.TextSize = 14
    WelcomeText.Parent = MainFrame

    local TabsFrame = Instance.new("Frame")
    TabsFrame.Size = UDim2.new(0, 150, 1, -50)
    TabsFrame.Position = UDim2.new(0, 0, 0, 90)
    TabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabsFrame.BorderSizePixel = 0
    TabsFrame.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -160, 1, -50)
    ContentFrame.Position = UDim2.new(0, 160, 0, 90)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Name = "Content"
    ContentFrame.Parent = MainFrame

    local tabStorage = {}

    function ZynoxUI:CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 40)
        TabButton.Position = UDim2.new(0, 5, 0, (#TabsFrame:GetChildren() - 1) * 45)
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.Parent = TabsFrame

        local TabContent = Instance.new("Frame")
        TabContent.Visible = false
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Name = name
        TabContent.Parent = ContentFrame

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentFrame:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = false
                end
            end
            TabContent.Visible = true
        end)

        local layout = Instance.new("UIListLayout", TabContent)
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local TabAPI = {}

        function TabAPI:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 400, 0, 40)
            Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Button.Text = text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.Parent = TabContent

            local corner = Instance.new("UICorner", Button)
            corner.CornerRadius = UDim.new(0, 6)

            Button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        return TabAPI
    end

    return ZynoxUI
end

return ZynoxUI
