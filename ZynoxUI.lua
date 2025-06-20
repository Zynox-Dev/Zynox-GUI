-- ZynoxUI Modernized
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ZynoxUI = {}

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- Create UI Root
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Create("ScreenGui", {
    Name = "ZynoxUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    Parent = CoreGui
})

-- Main Window
local Main = Create("Frame", {
    Name = "Main",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    Size = UDim2.new(0, 800, 0, 500),
    Position = UDim2.new(0.5, -400, 0.5, -250),
    AnchorPoint = Vector2.new(0.5, 0.5)
})
Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})
Create("UIStroke", {Parent = Main, Color = Color3.fromRGB(60, 60, 60), Thickness = 1})

-- Top Bar
local TopBar = Create("Frame", {
    Name = "TopBar",
    Parent = Main,
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    Size = UDim2.new(1, 0, 0, 40)
})
Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TopBar})

local Title = Create("TextLabel", {
    Name = "Title",
    Parent = TopBar,
    BackgroundTransparency = 1,
    Text = "Zynox UI",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(1, 0, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Center
})

-- Dragging
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)\n
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tabs Sidebar
local Tabs = Create("Frame", {
    Name = "Tabs",
    Parent = Main,
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Size = UDim2.new(0, 160, 1, -40),
    Position = UDim2.new(0, 0, 0, 40)
})
Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Tabs})

local TabList = Create("UIListLayout", {
    Parent = Tabs,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6)
})

-- Tab Content Area
local Content = Create("Frame", {
    Name = "Content",
    Parent = Main,
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    Size = UDim2.new(1, -160, 1, -40),
    Position = UDim2.new(0, 160, 0, 40)
})
Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Content})

-- Tab API
function ZynoxUI:CreateTab(name)
    local TabButton = Create("TextButton", {
        Parent = Tabs,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Size = UDim2.new(1, -10, 0, 32),
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabButton})

    local TabFrame = Create("Frame", {
        Name = name,
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })

    local TabLayout = Create("UIListLayout", {
        Parent = TabFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    TabButton.MouseButton1Click:Connect(function()
        for _, frame in ipairs(Content:GetChildren()) do
            if frame:IsA("Frame") then frame.Visible = false end
        end
        TabFrame.Visible = true
    end)

    return {
        AddButton = function(self, buttonText, callback)
            local Button = Create("TextButton", {
                Parent = TabFrame,
                Text = buttonText,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Size = UDim2.new(1, -20, 0, 30),
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Button})
            Button.MouseButton1Click:Connect(callback)
        end
    }
end

return ZynoxUI
