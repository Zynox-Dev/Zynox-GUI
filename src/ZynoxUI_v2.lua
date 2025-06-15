-- ZynoxUI v2
-- Fully fledged window + tab system with built-in ScriptBlox search tab
-- Author: Cascade (auto-generated)
--
-- Load with:
--   local ZynoxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/<GITHUB_USERNAME>/ZynoxUI/main/src/ZynoxUI_v2.lua"))()

local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local UIS            = game:GetService("UserInputService")
local CoreGui        = game:GetService("CoreGui")

local create do
    function create(class, props)
        local inst = Instance.new(class)
        for k, v in pairs(props) do inst[k] = v end
        return inst
    end
end

---------------------------------------------------------------------
-- Helper: fancy button style --------------------------------------
---------------------------------------------------------------------
local function styliseButton(btn)
    local normal = Color3.fromRGB(45,45,45)
    local hover  = Color3.fromRGB(65,65,65)
    btn.BackgroundColor3 = normal
    btn.AutoButtonColor  = false
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normal}):Play()
    end)
end

---------------------------------------------------------------------
-- Toggle prototype -------------------------------------------------
---------------------------------------------------------------------
local function makeToggle(parent, opts)
    opts = opts or {}
    local outer = create("Frame",{
        Size = UDim2.new(1,-20,0,28),
        BackgroundTransparency = 1,
        Parent = parent
    })
    local label = create("TextLabel",{
        Size = UDim2.new(0.6,0,1,0),
        BackgroundTransparency = 1,
        Text = opts.text or "Toggle",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = outer
    })
    local bg = create("Frame",{
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,0,0.5,0),
        Size = UDim2.new(0,40,0,18),
        BackgroundColor3 = Color3.fromRGB(60,60,60),
        BorderSizePixel = 0,
        Parent = outer
    })
    local knob = create("Frame",{
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new(0,1,0,1),
        BackgroundColor3 = Color3.fromRGB(200,200,200),
        BorderSizePixel = 0,
        Parent = bg
    })
    local state = false
    local function set(val)
        state = val
        local tgtPos = val and UDim2.new(1,-17,0,1) or UDim2.new(0,1,0,1)
        local tgtCol = val and Color3.fromRGB(0,170,85) or Color3.fromRGB(60,60,60)
        TweenService:Create(knob,TweenInfo.new(0.15,Enum.EasingStyle.Sine),{Position=tgtPos}):Play()
        TweenService:Create(bg,TweenInfo.new(0.15,Enum.EasingStyle.Sine),{BackgroundColor3=tgtCol}):Play()
        if opts.callback then task.spawn(opts.callback,state) end
    end
    bg.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then set(not state) end
    end)
    set(false)
    return {Set=set,Get=function() return state end}
end

---------------------------------------------------------------------
-- Tab object -------------------------------------------------------
---------------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Tab:AddButton(opts)
    opts = opts or {}
    local btn = create("TextButton",{
        Size = UDim2.new(1,-20,0,28),
        BackgroundColor3 = Color3.fromRGB(45,45,45),
        BorderSizePixel = 0,
        Text = opts.text or "Button",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.new(1,1,1),
        Parent = self._container
    })
    styliseButton(btn)
    if typeof(opts.callback)=="function" then
        btn.MouseButton1Click:Connect(opts.callback)
    end
    return btn
end

function Tab:AddToggle(opts)
    return makeToggle(self._container, opts)
end

---------------------------------------------------------------------
-- ScriptBlox integration ------------------------------------------
---------------------------------------------------------------------
local function makeScriptBloxTab(tab)
    -- Search bar
    local bar = create("Frame",{
        Size = UDim2.new(1,-20,0,32),
        BackgroundTransparency=1,
        Parent = tab._container
    })
    local box = create("TextBox",{
        PlaceholderText = "Search ScriptBlox...",
        ClearTextOnFocus = false,
        Size = UDim2.new(0.7,0,1,0),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
        BorderSizePixel = 0,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = bar
    })
    local go = create("TextButton",{
        Text = "Search",
        Size = UDim2.new(0.3,-4,1,0),
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,0,0,0),
        BackgroundColor3 = Color3.fromRGB(70,70,70),
        BorderSizePixel = 0,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = bar
    })
    styliseButton(go)

    -- Results list
    local scroll = create("ScrollingFrame",{
        Size = UDim2.new(1,-20,1,-42),
        Position = UDim2.new(0,0,0,36),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        BackgroundTransparency = 1,
        Parent = tab._container
    })
    local list = create("UIListLayout",{Parent=scroll,Padding=UDim.new(0,4)})

    local function addResult(item)
        local btn = create("TextButton",{
            Size = UDim2.new(1,-10,0,28),
            BackgroundColor3 = Color3.fromRGB(50,50,50),
            BorderSizePixel = 0,
            Text = item.name or "Unnamed Script",
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Parent = scroll
        })
        styliseButton(btn)
        btn.MouseButton1Click:Connect(function()
            local src = item.script or item.source or ""
            if src=="" then return end
            -- Execute script
            loadstring(src)()
        end)
    end

    local function search(q)
        for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        local url = "https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(q)
        local ok,res = pcall(HttpService.GetAsync,HttpService,url,false)
        if not ok then return end
        local data = HttpService:JSONDecode(res)
        if not data.result then return end
        for _,entry in ipairs(data.result) do
            addResult({name=entry.title or "Script", script=entry.content or entry.script})
        end
        task.wait()
        scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y+8)
    end

    go.MouseButton1Click:Connect(function()
        if #box.Text>2 then search(box.Text) end
    end)
end

---------------------------------------------------------------------
-- Window object ----------------------------------------------------
---------------------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:AddTab(name)
    assert(type(name)=="string","AddTab expects a name string")
    -- Tab button
    local btn = create("TextButton",{
        Size = UDim2.new(0,100,1,0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.new(1,1,1),
        Parent = self._tabBar
    })

    local page = create("Frame",{
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self._pages
    })
    create("UIListLayout",{Parent=page,Padding=UDim.new(0,6)})

    local tabObj = setmetatable({_button=btn,_container=page},Tab)

    local function activate()
        for _,t in pairs(self._tabs) do t._container.Visible=false t._button.BackgroundTransparency=1 end
        page.Visible=true
        btn.BackgroundTransparency=0.6
    end
    btn.MouseButton1Click:Connect(activate)

    table.insert(self._tabs,tabObj)
    if #self._tabs==1 then activate() end
    return tabObj
end

---------------------------------------------------------------------
-- Library root -----------------------------------------------------
---------------------------------------------------------------------
local ZynoxUI = {}

function ZynoxUI:WindowCreate(title)
    title = title or "Zynox UI"

    local gui = CoreGui:FindFirstChild("ZynoxUIv2") or create("ScreenGui",{
        Name = "ZynoxUIv2", Parent = CoreGui, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    })

    local window = create("Frame",{
        Size = UDim2.new(0,460,0,320),
        Position = UDim2.new(0.5,-230,0.5,-160),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        BorderSizePixel = 0,
        Parent = gui,
        BackgroundTransparency = 1
    })
    TweenService:Create(window,TweenInfo.new(0.25),{BackgroundTransparency=0}):Play()

    -- Dragging
    local dragging,offset
    window.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true offset=i.Position-window.Position end
    end)
    window.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            window.Position=UDim2.new(0, i.Position.X-offset.X, 0, i.Position.Y-offset.Y)
        end
    end)

    -- Title
    create("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.new(1,1,1),Parent=window})

    -- Tab bar
    local tabBar = create("Frame",{Position=UDim2.new(0,0,0,32),Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(25,25,25),BorderSizePixel=0,Parent=window})
    create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Parent=tabBar})

    -- Pages container
    local pages = create("Frame",{Position=UDim2.new(0,0,0,62),Size=UDim2.new(1,0,1,-62),BackgroundTransparency=1,Parent=window})

    local selfWindow = setmetatable({_tabBar=tabBar,_pages=pages,_tabs={}},Window)

    -- Default tabs
    local mainTab = selfWindow:AddTab("Main")
    selfWindow._main = mainTab
    local sbTab = selfWindow:AddTab("ScriptBlox")
    makeScriptBloxTab(sbTab)

    -- Convenience wrappers delegate to main tab
    function selfWindow:AddButton(opts) return self._main:AddButton(opts) end
    function selfWindow:AddToggle(opts) return self._main:AddToggle(opts) end

    return selfWindow
end

-- Alias
ZynoxUI.WindowsCreate=ZynoxUI.WindowCreate

return setmetatable({}, {__index=ZynoxUI})
