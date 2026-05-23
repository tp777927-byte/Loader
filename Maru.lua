-- MaruLib v1.0
-- Usage: loadstring(game:HttpGet("YOUR_RAW_URL"))()
-- Supports PC & Mobile

local MaruLib = {}
MaruLib.__index = MaruLib

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Detect Mobile
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Theme
local Theme = {
    Background     = Color3.fromRGB(28, 28, 30),
    Secondary      = Color3.fromRGB(36, 36, 38),
    Tab            = Color3.fromRGB(48, 48, 52),
    TabSelected    = Color3.fromRGB(62, 62, 68),
    Accent         = Color3.fromRGB(180, 60, 60),
    Text           = Color3.fromRGB(230, 230, 230),
    SubText        = Color3.fromRGB(150, 150, 155),
    Toggle_On      = Color3.fromRGB(70, 190, 90),
    Toggle_Off     = Color3.fromRGB(80, 80, 85),
    Slider_Bar     = Color3.fromRGB(55, 55, 60),
    Slider_Fill    = Color3.fromRGB(180, 60, 60),
    Dropdown_BG    = Color3.fromRGB(42, 42, 46),
    Border         = Color3.fromRGB(60, 60, 65),
    Shadow         = Color3.fromRGB(10, 10, 12),
}

-- Utility
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function MakePadding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 6)
    p.PaddingBottom = UDim.new(0, b or 6)
    p.PaddingLeft   = UDim.new(0, l or 10)
    p.PaddingRight  = UDim.new(0, r or 10)
    p.Parent = parent
    return p
end

local function Label(parent, text, size, color, xalign)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextSize = size or 14
    l.TextColor3 = color or Theme.Text
    l.Font = Enum.Font.GothamBold
    l.BackgroundTransparency = 1
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.Size = UDim2.new(1, 0, 0, size and size + 6 or 20)
    l.Parent = parent
    return l
end

-- Dragging (PC + Mobile)
local function MakeDraggable(frame, dragHandle)
    local dragging, dragStart, startPos = false, nil, nil
    local handle = dragHandle or frame

    local function beginDrag(pos)
        dragging = true
        dragStart = pos
        startPos = frame.Position
    end
    local function doDrag(pos)
        if dragging then
            local delta = pos - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
    local function endDrag() dragging = false end

    -- PC
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            beginDrag(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            doDrag(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then endDrag() end
    end)

    -- Mobile
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            beginDrag(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            doDrag(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then endDrag() end
    end)
end

------------------------------------------------------------
-- CreateWindow
------------------------------------------------------------
function MaruLib:CreateWindow(config)
    config = config or {}
    local Title   = config.Title   or "MaruLib"
    local Size    = config.Size    or (IsMobile and UDim2.new(0,340,0,420) or UDim2.new(0,520,0,380))
    local Icon    = config.Icon    or ""  -- optional rbxassetid

    local Window = {}
    local Tabs = {}
    local CurrentTab = nil

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MaruLib_" .. Title
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = Size
    Main.Position = UDim2.new(0.5, -(Size.X.Offset/2), 0.5, -(Size.Y.Offset/2))
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    MakeCorner(Main, 12)
    MakeStroke(Main, Theme.Border, 1)

    -- Drop shadow
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 18, 1, 18)
    Shadow.Position = UDim2.new(0, -9, 0, -9)
    Shadow.BackgroundColor3 = Theme.Shadow
    Shadow.BackgroundTransparency = 0.55
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = Main.ZIndex - 1
    Shadow.Parent = Main
    MakeCorner(Shadow, 16)

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 44)
    TopBar.BackgroundColor3 = Theme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main
    MakeCorner(TopBar, 12)

    -- fix bottom corners of topbar
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1,0,0,12)
    TopBarFix.Position = UDim2.new(0,0,1,-12)
    TopBarFix.BackgroundColor3 = Theme.Secondary
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar

    -- Icon
    if Icon ~= "" then
        local Ico = Instance.new("ImageLabel")
        Ico.Size = UDim2.new(0,26,0,26)
        Ico.Position = UDim2.new(0,10,0.5,-13)
        Ico.BackgroundTransparency = 1
        Ico.Image = Icon
        Ico.Parent = TopBar
    end

    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1,-80,1,0)
    TitleLabel.Position = UDim2.new(0, Icon~="" and 42 or 12, 0, 0)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,28,0,28)
    CloseBtn.Position = UDim2.new(1,-36,0.5,-14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200,55,55)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.TextSize = 13
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    MakeCorner(CloseBtn, 6)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0, Size.X.Offset, 0, 0)}, 0.2)
        task.delay(0.22, function() ScreenGui:Destroy() end)
    end)

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,28,0,28)
    MinBtn.Position = UDim2.new(1,-68,0.5,-14)
    MinBtn.BackgroundColor3 = Color3.fromRGB(80,80,88)
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Theme.Text
    MinBtn.TextSize = 16
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TopBar
    MakeCorner(MinBtn, 6)
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, {Size = UDim2.new(0, Size.X.Offset, 0, 44)}, 0.25)
        else
            Tween(Main, {Size = Size}, 0.25)
        end
    end)

    MakeDraggable(Main, TopBar)

    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -20, 0, 34)
    TabBar.Position = UDim2.new(0, 10, 0, 48)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0,6)
    TabLayout.Parent = TabBar

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1,-20, 1, -100)
    ContentArea.Position = UDim2.new(0,10,0,90)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = Main

    -- Status bar (right side like image)
    local StatusBar = Instance.new("Frame")
    StatusBar.Name = "StatusBar"
    StatusBar.Size = UDim2.new(0.4, 0, 1, 0)
    StatusBar.Position = UDim2.new(0.6, 0, 0, 0)
    StatusBar.BackgroundColor3 = Theme.Secondary
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = ContentArea
    MakeCorner(StatusBar, 8)
    local StatusTitle = Label(StatusBar, "Status Server", 13, Theme.SubText, Enum.TextXAlignment.Center)
    StatusTitle.Position = UDim2.new(0,0,0,8)

    -- Elements container (left side)
    local ElementsFrame = Instance.new("ScrollingFrame")
    ElementsFrame.Name = "Elements"
    ElementsFrame.Size = UDim2.new(0.57, 0, 1, 0)
    ElementsFrame.BackgroundTransparency = 1
    ElementsFrame.BorderSizePixel = 0
    ElementsFrame.ScrollBarThickness = 2
    ElementsFrame.ScrollBarImageColor3 = Theme.Accent
    ElementsFrame.CanvasSize = UDim2.new(0,0,0,0)
    ElementsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ElementsFrame.Parent = ContentArea

    local ElementsLayout = Instance.new("UIListLayout")
    ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ElementsLayout.Padding = UDim.new(0,8)
    ElementsLayout.Parent = ElementsFrame

    MakePadding(ElementsFrame, 4, 4, 2, 2)

    ------------------------------------------------------------
    -- Tab Functions
    ------------------------------------------------------------
    local function SelectTab(tabData)
        if CurrentTab == tabData then return end
        if CurrentTab then
            Tween(CurrentTab.Button, {BackgroundColor3 = Theme.Tab}, 0.15)
            CurrentTab.Button.TextColor3 = Theme.SubText
            CurrentTab.Page.Visible = false
        end
        CurrentTab = tabData
        Tween(CurrentTab.Button, {BackgroundColor3 = Theme.TabSelected}, 0.15)
        CurrentTab.Button.TextColor3 = Theme.Text
        CurrentTab.Page.Visible = true
    end

    function Window:AddTab(tabName)
        local TabData = {Elements = {}}

        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Text = tabName
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = Theme.SubText
        TabBtn.BackgroundColor3 = Theme.Tab
        TabBtn.BorderSizePixel = 0
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.Size = UDim2.new(0,60,1,0)
        TabBtn.Parent = TabBar
        MakeCorner(TabBtn, 7)
        MakePadding(TabBtn, 0,0,12,12)

        -- Tab Page (reuse ElementsFrame logic per tab)
        -- For simplicity we swap ElementsFrame's children
        local Page = Instance.new("Frame")
        Page.Name = "Page_"..tabName
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = ElementsFrame

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0,8)
        PageLayout.Parent = Page

        TabData.Button = TabBtn
        TabData.Page   = Page
        TabData.Layout = PageLayout
        table.insert(Tabs, TabData)

        TabBtn.MouseButton1Click:Connect(function() SelectTab(TabData) end)
        if #Tabs == 1 then SelectTab(TabData) end

        --------------------------------------------------
        -- Element Builders
        --------------------------------------------------
        local Tab = {}

        -- Label / Separator
        function Tab:AddLabel(text)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1,0,0,22)
            f.BackgroundTransparency = 1
            f.Parent = Page
            Label(f, text, 13, Theme.SubText)
            return f
        end

        -- Button
        function Tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,34)
            Btn.BackgroundColor3 = Theme.Tab
            Btn.Text = text
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 13
            Btn.BorderSizePixel = 0
            Btn.Parent = Page
            MakeCorner(Btn, 7)
            MakeStroke(Btn, Theme.Border)
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.Accent}, 0.1)
                task.delay(0.15, function() Tween(Btn, {BackgroundColor3 = Theme.Tab}, 0.15) end)
                if callback then callback() end
            end)
            return Btn
        end

        -- Toggle
        function Tab:AddToggle(text, default, callback)
            local state = default or false

            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1,0,0,34)
            Row.BackgroundColor3 = Theme.Secondary
            Row.BorderSizePixel = 0
            Row.Parent = Page
            MakeCorner(Row, 7)
            MakeStroke(Row, Theme.Border)

            local Lbl = Label(Row, text, 13, Theme.Text)
            Lbl.Position = UDim2.new(0,10,0,0)
            Lbl.Size = UDim2.new(1,-60,1,0)
            Lbl.TextYAlignment = Enum.TextYAlignment.Center

            -- Track
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0,38,0,20)
            Track.Position = UDim2.new(1,-48,0.5,-10)
            Track.BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off
            Track.BorderSizePixel = 0
            Track.Parent = Row
            MakeCorner(Track, 10)

            -- Knob
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0,16,0,16)
            Knob.Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
            Knob.BackgroundColor3 = Color3.new(1,1,1)
            Knob.BorderSizePixel = 0
            Knob.Parent = Track
            MakeCorner(Knob, 8)

            local function SetState(s)
                state = s
                Tween(Track, {BackgroundColor3 = s and Theme.Toggle_On or Theme.Toggle_Off}, 0.2)
                Tween(Knob, {Position = s and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}, 0.2)
                if callback then callback(s) end
            end

            Row.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    SetState(not state)
                end
            end)

            local ToggleObj = {}
            function ToggleObj:Set(v) SetState(v) end
            function ToggleObj:Get() return state end
            return ToggleObj
        end

        -- Slider
        function Tab:AddSlider(text, min, max, default, callback)
            min = min or 0; max = max or 100; default = default or min
            local value = default

            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1,0,0,50)
            Row.BackgroundColor3 = Theme.Secondary
            Row.BorderSizePixel = 0
            Row.Parent = Page
            MakeCorner(Row, 7)
            MakeStroke(Row, Theme.Border)

            -- Top row: label + value
            local TopRow = Instance.new("Frame")
            TopRow.Size = UDim2.new(1,-16,0,22)
            TopRow.Position = UDim2.new(0,8,0,6)
            TopRow.BackgroundTransparency = 1
            TopRow.Parent = Row

            local Lbl = Label(TopRow, text, 13, Theme.Text)
            Lbl.Size = UDim2.new(1,-30,1,0)

            local ValLbl = Label(TopRow, tostring(value), 13, Theme.SubText, Enum.TextXAlignment.Right)
            ValLbl.Size = UDim2.new(0,28,1,0)
            ValLbl.Position = UDim2.new(1,-28,0,0)

            -- Track
            local TrackBg = Instance.new("Frame")
            TrackBg.Size = UDim2.new(1,-16,0,6)
            TrackBg.Position = UDim2.new(0,8,0,34)
            TrackBg.BackgroundColor3 = Theme.Slider_Bar
            TrackBg.BorderSizePixel = 0
            TrackBg.ClipsDescendants = true
            TrackBg.Parent = Row
            MakeCorner(TrackBg, 3)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
            Fill.BackgroundColor3 = Theme.Slider_Fill
            Fill.BorderSizePixel = 0
            Fill.Parent = TrackBg
            MakeCorner(Fill, 3)

            -- Knob
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0,14,0,14)
            Knob.AnchorPoint = Vector2.new(0.5,0.5)
            Knob.Position = UDim2.new((value-min)/(max-min),0,0.5,0)
            Knob.BackgroundColor3 = Theme.Slider_Fill
            Knob.BorderSizePixel = 0
            Knob.ZIndex = 5
            Knob.Parent = TrackBg
            MakeCorner(Knob, 7)

            local sliding = false

            local function UpdateSlider(inputPos)
                local abs = TrackBg.AbsolutePosition
                local sz  = TrackBg.AbsoluteSize
                local rel = math.clamp((inputPos.X - abs.X) / sz.X, 0, 1)
                value = math.floor(min + (max-min)*rel)
                ValLbl.Text = tostring(value)
                Tween(Fill,  {Size = UDim2.new(rel,0,1,0)}, 0.05)
                Tween(Knob,  {Position = UDim2.new(rel,0,0.5,0)}, 0.05)
                if callback then callback(value) end
            end

            TrackBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateSlider(i.Position)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(i.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            local SliderObj = {}
            function SliderObj:Set(v)
                value = math.clamp(v,min,max)
                local rel = (value-min)/(max-min)
                ValLbl.Text = tostring(value)
                Tween(Fill,  {Size = UDim2.new(rel,0,1,0)}, 0.1)
                Tween(Knob,  {Position = UDim2.new(rel,0,0.5,0)}, 0.1)
                if callback then callback(value) end
            end
            function SliderObj:Get() return value end
            return SliderObj
        end

        -- Dropdown
        function Tab:AddDropdown(text, options, default, callback)
            options = options or {}
            local selected = default or options[1] or ""
            local open = false

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1,0,0,34)
            Container.BackgroundTransparency = 1
            Container.ClipsDescendants = false
            Container.Parent = Page

            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1,0,0,34)
            Row.BackgroundColor3 = Theme.Secondary
            Row.BorderSizePixel = 0
            Row.Parent = Container
            MakeCorner(Row, 7)
            MakeStroke(Row, Theme.Border)

            local Lbl = Label(Row, text, 13, Theme.Text)
            Lbl.Position = UDim2.new(0,10,0,0)
            Lbl.Size = UDim2.new(0.5,0,1,0)
            Lbl.TextYAlignment = Enum.TextYAlignment.Center

            local SelBtn = Instance.new("TextButton")
            SelBtn.Size = UDim2.new(0.45,0,0,24)
            SelBtn.Position = UDim2.new(0.5,0,0.5,-12)
            SelBtn.BackgroundColor3 = Theme.Dropdown_BG
            SelBtn.Text = selected .. " ▾"
            SelBtn.TextColor3 = Theme.Text
            SelBtn.Font = Enum.Font.Gotham
            SelBtn.TextSize = 12
            SelBtn.BorderSizePixel = 0
            SelBtn.Parent = Row
            MakeCorner(SelBtn, 5)

            -- Dropdown list
            local DropList = Instance.new("Frame")
            DropList.Size = UDim2.new(0.45,0,0,0)
            DropList.Position = UDim2.new(0.5,0,1,2)
            DropList.BackgroundColor3 = Theme.Dropdown_BG
            DropList.BorderSizePixel = 0
            DropList.ClipsDescendants = true
            DropList.ZIndex = 10
            DropList.Parent = Row
            MakeCorner(DropList, 5)
            MakeStroke(DropList, Theme.Border)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = DropList

            local function SetSelected(opt)
                selected = opt
                SelBtn.Text = opt .. " ▾"
                if callback then callback(opt) end
            end

            for _, opt in ipairs(options) do
                local Opt = Instance.new("TextButton")
                Opt.Size = UDim2.new(1,0,0,28)
                Opt.BackgroundTransparency = 1
                Opt.Text = opt
                Opt.TextColor3 = Theme.Text
                Opt.Font = Enum.Font.Gotham
                Opt.TextSize = 12
                Opt.BorderSizePixel = 0
                Opt.ZIndex = 11
                Opt.Parent = DropList
                Opt.MouseButton1Click:Connect(function()
                    SetSelected(opt)
                    open = false
                    Tween(DropList, {Size = UDim2.new(0.45,0,0,0)}, 0.15)
                end)
            end

            local listH = #options * 28
            SelBtn.MouseButton1Click:Connect(function()
                open = not open
                Tween(DropList, {Size = UDim2.new(0.45,0,0, open and listH or 0)}, 0.2)
            end)

            local DDObj = {}
            function DDObj:Set(v) SetSelected(v) end
            function DDObj:Get() return selected end
            return DDObj
        end

        -- TextBox Input
        function Tab:AddInput(text, placeholder, callback)
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1,0,0,34)
            Row.BackgroundColor3 = Theme.Secondary
            Row.BorderSizePixel = 0
            Row.Parent = Page
            MakeCorner(Row, 7)
            MakeStroke(Row, Theme.Border)

            local Lbl = Label(Row, text, 13, Theme.Text)
            Lbl.Position = UDim2.new(0,10,0,0)
            Lbl.Size = UDim2.new(0.4,0,1,0)
            Lbl.TextYAlignment = Enum.TextYAlignment.Center

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(0.52,0,0,24)
            Box.Position = UDim2.new(0.46,0,0.5,-12)
            Box.BackgroundColor3 = Theme.Dropdown_BG
            Box.Text = ""
            Box.PlaceholderText = placeholder or "..."
            Box.PlaceholderColor3 = Theme.SubText
            Box.TextColor3 = Theme.Text
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 12
            Box.BorderSizePixel = 0
            Box.ClearTextOnFocus = false
            Box.Parent = Row
            MakeCorner(Box, 5)
            MakePadding(Box,0,0,6,6)

            Box.FocusLost:Connect(function(enter)
                if enter and callback then callback(Box.Text) end
            end)

            return Box
        end

        -- StatusServer setter
        function Tab:SetStatus(text, color)
            local Lbl = Instance.new("TextLabel")
            Lbl.Text = "● " .. text
            Lbl.TextColor3 = color or Theme.Toggle_On
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 12
            Lbl.BackgroundTransparency = 1
            Lbl.Size = UDim2.new(1,-10,0,20)
            Lbl.Position = UDim2.new(0,5,0,30)
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = StatusBar
        end

        return Tab
    end

    -- Open animation
    Main.Size = UDim2.new(0, Size.X.Offset, 0, 0)
    Tween(Main, {Size = Size}, 0.28, Enum.EasingStyle.Back)

    return Window
end

return MaruLib
