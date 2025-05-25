-- [Zynox UI Framework with Advanced Elements] --
local Zynox = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")

-- Utility Functions
local function animate(obj, props, time, style, dir)
    local ti = TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, ti, props):Play()
end

local function clearContent(contentFrame)
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

-- Main CreateWindow
function Zynox:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Zynox UI"
    local oldGUI = PlayerGui:FindFirstChild("ZynoxGUI")
    if oldGUI then oldGUI:Destroy() end

    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "ZynoxGUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 600, 0, 300)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    main.BackgroundTransparency = 1
    animate(main, {BackgroundTransparency = 0.2}, 0.7, Enum.EasingStyle.Back)

    local top = Instance.new("Frame", main)
    top.Size = UDim2.new(1, 0, 0, 30)
    top.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local titleLbl = Instance.new("TextLabel", top)
    titleLbl.Size = UDim2.new(1, 0, 1, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 18

    local side = Instance.new("Frame", main)
    side.Size = UDim2.new(0, 150, 1, -30)
    side.Position = UDim2.new(0, 0, 0, 30)
    side.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -150, 1, -30)
    content.Position = UDim2.new(0, 150, 0, 30)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    function Zynox:CreateSidebar(name, callback)
        local y = #side:GetChildren() * 45
        local btn = Instance.new("TextButton", side)
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16

        btn.MouseButton1Click:Connect(function()
            clearContent(content)
            callback(content)
        end)
    end

    -- Buttons, Toggles, Sliders, Dropdowns, Textboxes, Notifications
    function Zynox:CreateButton(name, parent, callback)
        local y = #parent:GetChildren() * 45
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function() animate(btn, {BackgroundColor3 = Color3.fromRGB(90, 90, 90)}) end)
        btn.MouseLeave:Connect(function() animate(btn, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}) end)
    end

    function Zynox:CreateToggle(name, default, parent, callback)
        local y = #parent:GetChildren() * 45
        local state = default or false
        local tgl = Instance.new("TextButton", parent)
        tgl.Size = UDim2.new(0, 200, 0, 40)
        tgl.Position = UDim2.new(0, 20, 0, y)
        tgl.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        tgl.Text = name .. ": " .. (state and "ON" or "OFF")
        tgl.TextColor3 = Color3.fromRGB(255, 255, 255)
        tgl.Font = Enum.Font.Gotham
        tgl.TextSize = 16

        tgl.MouseButton1Click:Connect(function()
            state = not state
            animate(tgl, {BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)})
            tgl.Text = name .. ": " .. (state and "ON" or "OFF")
            if callback then callback(state) end
        end)
    end

    function Zynox:CreateSlider(name, min, max, default, parent, callback)
        local y = #parent:GetChildren() * 60
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0, 240, 0, 50)
        frame.Position = UDim2.new(0, 20, 0, y)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = name .. ": " .. tostring(default)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14

        local slider = Instance.new("Frame", frame)
        slider.Size = UDim2.new(1, 0, 0, 10)
        slider.Position = UDim2.new(0, 0, 0, 30)
        slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

        local fill = Instance.new("Frame", slider)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

        local dragging = false
        slider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.Position then
                local pct = math.clamp((i.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                local val = math.floor(min + (max - min) * pct)
                label.Text = name .. ": " .. val
                if callback then callback(val) end
            end
        end)
    end

    function Zynox:CreateDropdown(name, options, parent, callback)
        local y = #parent:GetChildren() * 45
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = name .. ": [Select]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16

        btn.MouseButton1Click:Connect(function()
            for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("TextButton") and v.Name == "DropdownOption" then v:Destroy() end
            end
            for i, option in ipairs(options) do
                local opt = Instance.new("TextButton", parent)
                opt.Name = "DropdownOption"
                opt.Size = UDim2.new(0, 200, 0, 30)
                opt.Position = btn.Position + UDim2.new(0, 0, 0, 40 * i)
                opt.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                opt.Text = option
                opt.TextColor3 = Color3.fromRGB(255, 255, 255)
                opt.Font = Enum.Font.Gotham
                opt.TextSize = 14
                opt.MouseButton1Click:Connect(function()
                    btn.Text = name .. ": " .. option
                    for _, v in ipairs(parent:GetChildren()) do
                        if v.Name == "DropdownOption" then v:Destroy() end
                    end
                    if callback then callback(option) end
                end)
            end
        end)
    end

    function Zynox:CreateTextbox(name, default, parent, callback)
        local y = #parent:GetChildren() * 60
        local box = Instance.new("TextBox", parent)
        box.Size = UDim2.new(0, 200, 0, 40)
        box.Position = UDim2.new(0, 20, 0, y)
        box.Text = default or ""
        box.PlaceholderText = name
        box.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.Gotham
        box.TextSize = 16
        box.FocusLost:Connect(function()
            if callback then callback(box.Text) end
        end)
    end

    function Zynox:Notify(text)
        local msg = Instance.new("TextLabel", gui)
        msg.Size = UDim2.new(0, 300, 0, 40)
        msg.Position = UDim2.new(0.5, -150, 0, -50)
        msg.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        msg.TextColor3 = Color3.fromRGB(255, 255, 255)
        msg.Font = Enum.Font.Gotham
        msg.TextSize = 16
        msg.Text = text
        msg.AnchorPoint = Vector2.new(0.5, 0)
        msg.BackgroundTransparency = 1
        animate(msg, {BackgroundTransparency = 0.2, Position = UDim2.new(0.5, -150, 0, 20)}, 0.4)
        task.delay(3, function() animate(msg, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -150, 0, -50)}, 0.4) task.delay(0.4, function() msg:Destroy() end) end)
    end

    return Zynox
end

return Zynox
