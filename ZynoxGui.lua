-- ZynoxUI - A modern UI library for Roblox
-- Version: 3.0.2

local ZynoxUI = {
    Version = "3.0.2"
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Utility Functions
local function create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function applyCorner(instance, radius)
    local corner = create("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 8)
    corner.Parent = instance
    return corner
end

local function createGlowEffect(parent, color, transparency, size)
    local glow = create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://4996891970",
        ImageColor3 = color or Color3.fromRGB(0, 170, 255),
        ImageTransparency = transparency or 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        Size = size or UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        ZIndex = -1,
        Parent = parent
    })
    return glow
end

-- Theme
ZynoxUI.Theme = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(35, 35, 35),
        ButtonHover = Color3.fromRGB(45, 45, 45),
        Toggle = Color3.fromRGB(40, 40, 40),
        ToggleAccent = Color3.fromRGB(0, 120, 215),
        Accent = Color3.fromRGB(0, 120, 215),
        Border = Color3.fromRGB(60, 60, 60),
        Glow = Color3.fromRGB(0, 170, 255),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

-- Window Class
local Window = {}
Window.__index = Window

function ZynoxUI:CreateWindow(title, options)
    options = options or {}
    local self = setmetatable({}, Window)
    
    self.Elements = {}
    self.Connections = {}
    self.ThemeName = options.Theme or "Dark"
    self.Theme = Zynox.Theme[self.ThemeName] or Zynox.Theme["Dark"]
    
    -- Create main UI container
    self.Elements.ScreenGui = create("ScreenGui", {
        Name = "ZynoxUI",
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = CoreGui
    })
    
    -- Create shadow effect
    self.Elements.Shadow = create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -260, 0.5, -210),
        Size = UDim2.new(0, 520, 0, 440),
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.9,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = 0,
        Parent = self.Elements.ScreenGui
    })
    
    -- Create main frame
    self.Elements.MainFrame = create("Frame", {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Elements.ScreenGui,
        ZIndex = 1
    })
    
    -- Add glow effect
    createGlowEffect(self.Elements.MainFrame, self.Theme.Glow, 0.9)
    applyCorner(self.Elements.MainFrame)
    
    -- Create top bar
    self.Elements.Topbar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Topbar,
        BorderSizePixel = 0,
        Parent = self.Elements.MainFrame
    })
    
    applyCorner(self.Elements.Topbar, UDim.new(0, 8, 0, 0))
    
    -- Add title
    self.Elements.Title = create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "ZynoxUI",
        TextColor3 = self.Theme.Text,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Parent = self.Elements.Topbar
    })
    
    -- Create content area
    self.Elements.Content = create("Frame", {
        Size = UDim2.new(1, -40, 1, -70),
        Position = UDim2.new(0, 20, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.Elements.MainFrame
    })
    
    -- Add scrolling frame
    self.Elements.ScrollFrame = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Accent,
        ScrollBarImageTransparency = 0.7,
        Parent = self.Elements.Content
    })
    
    -- Add list layout
    self.Elements.ListLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = self.Elements.ScrollFrame
    })
    
    -- Update scroll frame size when content changes
    self.Elements.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Elements.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.Elements.ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Make window draggable
    local dragging = false
    local dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        self.Elements.MainFrame.Position = newPos
        -- Update shadow position with proper offset from main frame
        self.Elements.Shadow.Position = UDim2.new(
            newPos.X.Scale,
            newPos.X.Offset - 5,  -- Reduced from 10 to 5 for better visual balance
            newPos.Y.Scale,
            newPos.Y.Offset - 5   -- Reduced from 10 to 5 for better visual balance
        )
    end
    
    self.Elements.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Elements.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.Elements.Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateDrag(input)
        end
    end)
    
    return self
end

-- Button Creation
function Window:CreateButton(text, callback)
    local buttonContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })
    
    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = self.Theme.Button,
        Text = text or "Button",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        Parent = buttonContainer
    })
    
    -- Add glow effect
    local glow = createGlowEffect(button, self.Theme.Glow, 0.95, UDim2.new(1, 10, 1, 10))
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.ZIndex = 0
    
    applyCorner(button)
    
    -- Hover effects
    local originalColor = button.BackgroundColor3
    local hoverColor = self.Theme.ButtonHover
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 50)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.8
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor,
            Position = UDim2.new(0, 0, 0, 3),
            Size = UDim2.new(1, 0, 0, 44)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.95
        }):Play()
    end)
    
    -- Click handler
    if type(callback) == "function" then
        button.MouseButton1Click:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.95, 0, 0, 42)
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(1, 0, 0, 44)
            }):Play()
            callback()
        end)
    end
    
    return button
end

-- Toggle Creation
function Window:CreateToggle(text, defaultState, callback)
    local state = defaultState or false

    local toggleContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })

    local toggleFrame = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = self.Theme.Toggle,
        Text = text or "Toggle",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = toggleContainer
    })

    local toggleGlow = createGlowEffect(toggleFrame, self.Theme.Glow, 0.95)
    applyCorner(toggleFrame)

    toggleFrame.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and self.Theme.ToggleAccent or self.Theme.Toggle
        local targetTransparency = state and 0.8 or 0.95
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleGlow, TweenInfo.new(0.2), {ImageTransparency = targetTransparency}):Play()
        if callback then
            callback(state)
        end
    end)

    return {
        SetState = function(value)
            if type(value) == "boolean" and value ~= state then
                state = value
                local targetColor = state and self.Theme.ToggleAccent or self.Theme.Toggle
                local targetTransparency = state and 0.8 or 0.95
                TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(toggleGlow, TweenInfo.new(0.2), {ImageTransparency = targetTransparency}):Play()
                if callback then
                    callback(state)
                end
            end
        end,
        GetState = function()
            return state
        end
    }
end

-- Tab System
function Window:CreateTabSystem()
    local tabSystem = {
        Tabs = {},
        CurrentTab = nil,
        Elements = {}
    }
    
    -- Create tab container
    tabSystem.Elements.Container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })
    
    -- Add tab list layout
    tabSystem.Elements.ListLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabSystem.Elements.Container
    })
    
    -- Add padding
    tabSystem.Elements.Padding = create("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = tabSystem.Elements.Container
    })
    
    -- Create content container
    tabSystem.Elements.Content = create("Frame", {
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })
    
    -- Add scroll frame for tab content
    tabSystem.Elements.ScrollFrame = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Accent,
        ScrollBarImageTransparency = 0.7,
        Parent = tabSystem.Elements.Content
    })
    
    -- Add layout for tab content
    tabSystem.Elements.ContentLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = tabSystem.Elements.ScrollFrame
    })
    
    -- Update scroll frame size when content changes
    tabSystem.Elements.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabSystem.Elements.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 
            tabSystem.Elements.ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Method to add a new tab
    function tabSystem:AddTab(name)
        local tab = {
            Name = name or "Tab " .. (#self.Tabs + 1),
            Elements = {}
        }
        
        -- Create tab button
        tab.Elements.Button = create("TextButton", {
            Size = UDim2.new(0, 100, 1, 0),
            BackgroundColor3 = self.Theme.Button,
            Text = tab.Name,
            TextColor3 = self.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            AutoButtonColor = false,
            Parent = self.Elements.Container
        })
        
        applyCorner(tab.Elements.Button, UDim.new(0, 6))
        
        -- Create tab content
        tab.Content = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = tabSystem.Elements.Content
        })
        
        -- Add glow effect
        local glow = createGlowEffect(tab.Elements.Button, self.Theme.Glow, 0.95)
        glow.ZIndex = -1
        
        -- Tab selection logic
        local function selectTab()
            -- Deselect all tabs
            for _, otherTab in ipairs(self.Tabs) do
                if otherTab ~= tab then
                    TweenService:Create(otherTab.Elements.Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = self.Theme.Button,
                        TextColor3 = self.Theme.Text
                    }):Play()
                    otherTab.Elements.Content.Visible = false
                end
            end
            
            -- Select this tab
            TweenService:Create(tab.Elements.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.Accent,
                TextColor3 = Color3.new(1, 1, 1)
            }):Play()
            
            tab.Elements.Content.Visible = true
            self.CurrentTab = tab
        end
        
        -- Button interactions
        tab.Elements.Button.MouseEnter:Connect(function()
            if self.CurrentTab ~= tab then
                TweenService:Create(tab.Elements.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = self.Theme.ButtonHover
                }):Play()
            end
        end)
        
        tab.Elements.Button.MouseLeave:Connect(function()
            if self.CurrentTab ~= tab then
                TweenService:Create(tab.Elements.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = self.Theme.Button
                }):Play()
            end
        end)
        
        tab.Elements.Button.MouseButton1Click:Connect(selectTab)
        
        -- Add tab to the list
        table.insert(self.Tabs, tab)
        
        -- Select first tab
        if #self.Tabs == 1 then
            selectTab()
        end
        
        return {
            Content = tab.Elements.Content,
            Button = tab.Elements.Button
        }
    end
    
    -- Add some spacing after the tab system
    local spacer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 1,
        Parent = self.Elements.ScrollFrame
    })
    
    return tabSystem
end

-- Destroy method
function Window:Destroy()
    if self.Elements.ScreenGui then
        self.Elements.ScreenGui:Destroy()
    end
end

-- Set up metatable
ZynoxUI.__index = ZynoxUI

return ZynoxUI
