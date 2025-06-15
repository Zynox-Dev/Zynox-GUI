-- ZynoxUI.lua
-- Core library module for creating simple UI windows.
-- v0.1 – skeleton implementation
--
-- Usage (after requiring / loading this module):
--   local ZynoxUI = require(path.to.ZynoxUI)
--   local win = ZynoxUI:WindowCreate("My Window")
--   win:AddButton{ text = "Press", callback = function() print("Pressed") end }

local ZynoxUI = {}
ZynoxUI.__index = ZynoxUI

-- Internal helper to create UI instances with properties quickly
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

--[[
    ZynoxUI:WindowCreate(title : string?) -> Window
    Creates a draggable window with the given title and returns a Window object
    that can be used to add controls.
]]
function ZynoxUI:WindowCreate(title)
    assert(typeof(title) == "string" or title == nil, "WindowCreate expects title (string) or nil")

    -- Make sure we only place one ScreenGui per library instance
    local gui = game:GetService("CoreGui"):FindFirstChild("ZynoxUI")
        or create("ScreenGui", {
            Name = "ZynoxUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = game:GetService("CoreGui")
        })

    -- Main window frame
    local frame = create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, 420, 0, 260),
        Position = UDim2.new(0.5, -210, 0.5, -130),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = gui
    })

    -- Simple drag support
    pcall(function()
        local UIS = game:GetService("UserInputService")
        local dragging, dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)
    end)

    -- Title bar
    create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = title or "Zynox UI",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.new(1, 1, 1),
        Parent = frame
    })

    -- Internal vertical layout for controls
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = frame
    })
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    --------------------------------------------------------------------
    -- Window object
    --------------------------------------------------------------------
    local Window = {}
    Window.__index = Window

    -- Adds a button
    function Window:AddButton(opts)
        opts = opts or {}
        local btn = create("TextButton", {
            Size = UDim2.new(1, -20, 0, 28),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Text = opts.text or "Button",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.new(1, 1, 1),
            AutoButtonColor = true,
            Parent = frame
        })
        if typeof(opts.callback) == "function" then
            btn.MouseButton1Click:Connect(opts.callback)
        end
        return btn
    end

    -- Simple alias for Rayfield-style naming
    Window.AddButton = Window.AddButton -- keep original

    setmetatable(Window, Window)
    return setmetatable({}, Window)
end

-- Rayfield-style alias (plural “WindowsCreate”) so existing scripts work
ZynoxUI.WindowsCreate = ZynoxUI.WindowCreate

return setmetatable({}, ZynoxUI)
