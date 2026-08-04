-- ========================================================
-- Custom Roblox Executor UI (Clean & Fixed Edition)
-- Fully compatible wi Delta Mobile / PC
-- ========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 1. CONTAINER DETECTION
local ParentContainer
pcall(function()
    if gethui then
        ParentContainer = gethui()
    elseif game:GetService("CoreGui") then
        ParentContainer = game:GetService("CoreGui")
    end
end)

if not ParentContainer then
    ParentContainer = LocalPlayer:WaitForChild("PlayerGui")
end

-- ลบ UI เดิมหากเปิดค้างไว้
if ParentContainer:FindFirstChild("RedesignedExecutorUI") then
    ParentContainer:FindFirstChild("RedesignedExecutorUI"):Destroy()
end

-- --------------------------------------------------------
-- 2. LOCALIZATION & THEME (NO EMOJIS)
-- --------------------------------------------------------
local currentLang = "EN"

local Translations = {
    EN = {
        Title = "EXECUTOR",
        Open = "DELTA",
        Editor = "Editor",
        SaveCode = "Save Script",
        SavedScripts = "Saved",
        History = "History",
        Settings = "Settings",
        Discord = "Discord",
        Execute = "Execute",
        Clear = "Clear",
        Placeholder = "Coed...",
        SavePromptTitle = "Save Script",
        EnterName = "Enter script name:",
        SaveBtn = "Save",
        CopiedDiscord = "Discord link copied to clipboard!",
        SettingsTitle = "Settings",
        UIScale = "UI Scale",
        Language = "Language / ภาษา",
        HistoryTitle = "Execution History",
        SavedTitle = "Saved Scripts Library",
        Load = "Load",
        Delete = "Delete",
        ExecSuccess = "Script executed successfully!",
        ExecError = "Execution Error: ",
        EmptyCode = "Code box is empty!"
    },
    TH = {
        Title = "EXECUTOR",
        Open = "DELTA",
        Editor = "หน้าเขียนโค้ด",
        SaveCode = "บันทึกโค้ด",
        SavedScripts = "คลังสคริปต์",
        History = "ประวัติรัน",
        Settings = "ตั้งค่า",
        Discord = "ดิสคอร์ด",
        Execute = "รันสคริปต์",
        Clear = "เคลียร์",
        Placeholder = "เขียนโค้ด...",
        SavePromptTitle = "บันทึกสคริปต์",
        EnterName = "กรอกชื่อสคริปต์:",
        SaveBtn = "บันทึก",
        CopiedDiscord = "คัดลอกลิงก์ Discord แล้ว!",
        SettingsTitle = "ตั้งค่าระบบ UI",
        UIScale = "ขนาด UI",
        Language = "ภาษา / Language",
        HistoryTitle = "ประวัติการรันสคริปต์",
        SavedTitle = "คลังสคริปต์ที่บันทึกไว้",
        Load = "โหลด",
        Delete = "ลบ",
        ExecSuccess = "รันสคริปต์สำเร็จ!",
        ExecError = "เกิดข้อผิดพลาดในการรัน: ",
        EmptyCode = "ไม่มีโค้ดในช่องเขียน!"
    }
}

local function L(key)
    return (Translations[currentLang] and Translations[currentLang][key]) or key
end

local THEME = {
    BgMain      = Color3.fromRGB(15, 23, 42),
    BgSecondary = Color3.fromRGB(30, 41, 59),
    BgEditor    = Color3.fromRGB(10, 15, 28),
    Accent      = Color3.fromRGB(56, 189, 248),
    AccentDark  = Color3.fromRGB(2, 132, 199),
    TextMain    = Color3.fromRGB(255, 255, 255),
    TextMuted   = Color3.fromRGB(148, 163, 184)
}

-- --------------------------------------------------------
-- 3. STATE MANAGEMENT
-- --------------------------------------------------------
local SavedScripts = {}
local HistoryList = {}
local Tabs = {}
local activeTabIndex = 1
local tabCounter = 1

-- --------------------------------------------------------
-- 4. GUI INSTANCES
-- --------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RedesignedExecutorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = ParentContainer
end)

-- === NOTIFICATION SYSTEM ===
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 260, 0, 200)
NotifContainer.Position = UDim2.new(1, -270, 0, 25)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 100
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 6)
NotifLayout.Parent = NotifContainer

local function showNotification(msg, isError)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 36)
    notif.BackgroundColor3 = isError and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(16, 185, 129)
    notif.ZIndex = 101
    notif.Parent = NotifContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notif

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = msg
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 11
    label.Font = Enum.Font.SourceSansBold
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 102
    label.Parent = notif

    task.delay(3.5, function()
        if notif and notif.Parent then
            notif:Destroy()
        end
    end)
end

-- === MAIN FRAME ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 540, 0, 320)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = THEME.BgMain
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(51, 65, 85)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local MainScale = Instance.new("UIScale")
MainScale.Parent = MainFrame

-- === TOGGLE BUTTON ===
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0, 20, 0.4, 0)
ToggleButton.BackgroundColor3 = THEME.BgSecondary
ToggleButton.Image = "rbxassetid://123951224009948"
ToggleButton.ScaleType = Enum.ScaleType.Fit 
ToggleButton.Active = true
ToggleButton.Parent = ScreenGui


local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 16)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = THEME.Accent
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- แก้ไขระบบ Toggle ให้เปิด/ปิดหน้าต่างได้อย่างสมบูรณ์
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ระบบ Drag หน้าต่าง
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainFrame)
makeDraggable(ToggleButton)

-- === HEADER BAR ===
local HeaderBar = Instance.new("Frame")
HeaderBar.Size = UDim2.new(1, 0, 0, 38)
HeaderBar.BackgroundColor3 = THEME.BgSecondary
HeaderBar.Parent = MainFrame

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 200, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = L("Title")
HeaderTitle.TextColor3 = THEME.Accent
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Font = Enum.Font.SourceSansBold
HeaderTitle.TextSize = 15
HeaderTitle.Parent = HeaderBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = THEME.TextMain
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = HeaderBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- === SIDEBAR ===
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Color3.fromRGB(2, 6, 23)
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

local sidebarBtns = {}

local function createSidebarBtn(key, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = THEME.BgSecondary
    btn.TextColor3 = THEME.TextMain
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = L(key)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.Parent = Sidebar
    
    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 10)
    btnPadding.Parent = btn

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    sidebarBtns[key] = btn
    return btn
end

local EditorNavBtn   = createSidebarBtn("Editor", 1)
local SaveNavBtn     = createSidebarBtn("SaveCode", 2)
local SavedNavBtn    = createSidebarBtn("SavedScripts", 3)
local HistoryNavBtn  = createSidebarBtn("History", 4)
local SettingsNavBtn = createSidebarBtn("Settings", 5)
local DiscordNavBtn  = createSidebarBtn("Discord", 6)

-- === TAB BAR ===
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -128, 0, 32)
TabContainer.Position = UDim2.new(0, 124, 0, 42)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Size = UDim2.new(1, -36, 1, 0)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 0
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.Parent = TabContainer

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabScroll

local AddTabBtn = Instance.new("TextButton")
AddTabBtn.Size = UDim2.new(0, 30, 0, 30)
AddTabBtn.Position = UDim2.new(1, -30, 0, 0)
AddTabBtn.BackgroundColor3 = THEME.BgSecondary
AddTabBtn.Text = "+"
AddTabBtn.TextColor3 = THEME.Accent
AddTabBtn.TextSize = 18
AddTabBtn.Font = Enum.Font.SourceSansBold
AddTabBtn.Parent = TabContainer

local AddTabCorner = Instance.new("UICorner")
AddTabCorner.CornerRadius = UDim.new(0, 6)
AddTabCorner.Parent = AddTabBtn

-- === EDITOR AREA ===
local EditorContainer = Instance.new("Frame")
EditorContainer.Size = UDim2.new(1, -128, 1, -120)
EditorContainer.Position = UDim2.new(0, 124, 0, 76)
EditorContainer.BackgroundColor3 = THEME.BgEditor
EditorContainer.Parent = MainFrame

local EditorCorner = Instance.new("UICorner")
EditorCorner.CornerRadius = UDim.new(0, 8)
EditorCorner.Parent = EditorContainer

local EditorStroke = Instance.new("UIStroke")
EditorStroke.Color = Color3.fromRGB(30, 41, 59)
EditorStroke.Thickness = 1
EditorStroke.Parent = EditorContainer

local CodeTextBox = Instance.new("TextBox")
CodeTextBox.Size = UDim2.new(1, -12, 1, -12)
CodeTextBox.Position = UDim2.new(0, 6, 0, 6)
CodeTextBox.BackgroundTransparency = 1
CodeTextBox.TextColor3 = Color3.fromRGB(226, 232, 240)
CodeTextBox.TextXAlignment = Enum.TextXAlignment.Left
CodeTextBox.TextYAlignment = Enum.TextYAlignment.Top
CodeTextBox.ClearTextOnFocus = false
CodeTextBox.MultiLine = true
CodeTextBox.TextSize = 13
CodeTextBox.Font = Enum.Font.Code
CodeTextBox.PlaceholderText = L("Placeholder")
CodeTextBox.PlaceholderColor3 = THEME.TextMuted
CodeTextBox.Text = ""
CodeTextBox.Parent = EditorContainer

-- === BOTTOM ACTION BAR ===
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, -128, 0, 34)
BottomBar.Position = UDim2.new(0, 124, 1, -38)
BottomBar.BackgroundTransparency = 1
BottomBar.Parent = MainFrame

local BottomLayout = Instance.new("UIListLayout")
BottomLayout.FillDirection = Enum.FillDirection.Horizontal
BottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
BottomLayout.Padding = UDim.new(0, 8)
BottomLayout.Parent = BottomBar

local function createBottomBtn(key, color, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width or 120, 1, 0)
    btn.BackgroundColor3 = color or THEME.BgSecondary
    btn.TextColor3 = THEME.TextMain
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = L(key)
    btn.Parent = BottomBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    sidebarBtns[key] = btn
    return btn
end

-- ปรับปุ่มล่าง เหลือเพียง Execute และ Clear
local ExecuteBtn = createBottomBtn("Execute", THEME.AccentDark, 140)
local ClearBtn   = createBottomBtn("Clear", THEME.BgSecondary, 100)

-- --------------------------------------------------------
-- MODAL CREATOR
-- --------------------------------------------------------
local function createModal(titleText)
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.ZIndex = 20
    Overlay.Parent = MainFrame
    
    local Modal = Instance.new("Frame")
    Modal.AnchorPoint = Vector2.new(0.5, 0.5)
    Modal.Size = UDim2.new(0, 320, 0, 200)
    Modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    Modal.BackgroundColor3 = THEME.BgSecondary
    Modal.ZIndex = 21
    Modal.Parent = Overlay
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Modal
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 28)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = THEME.TextMain
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    Title.ZIndex = 22
    Title.Parent = Modal
    
    local CloseBtnModal = Instance.new("TextButton")
    CloseBtnModal.Size = UDim2.new(0, 24, 0, 24)
    CloseBtnModal.Position = UDim2.new(1, -28, 0, 5)
    CloseBtnModal.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    CloseBtnModal.Text = "X"
    CloseBtnModal.TextColor3 = THEME.TextMain
    CloseBtnModal.TextSize = 13
    CloseBtnModal.Font = Enum.Font.SourceSansBold
    CloseBtnModal.ZIndex = 22
    CloseBtnModal.Parent = Modal

    local CloseCornerModal = Instance.new("UICorner")
    CloseCornerModal.CornerRadius = UDim.new(0, 4)
    CloseCornerModal.Parent = CloseBtnModal
    
    CloseBtnModal.MouseButton1Click:Connect(function()
        Overlay:Destroy()
    end)
    
    return Overlay, Modal
end

-- --------------------------------------------------------
-- TAB LOGIC
-- --------------------------------------------------------
local function updateTabs()
    for index, tabData in ipairs(Tabs) do
        if index == activeTabIndex then
            tabData.Button.BackgroundColor3 = THEME.BgSecondary
            tabData.Stroke.Color = THEME.Accent
            CodeTextBox.Text = tabData.Content
        else
            tabData.Button.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
            tabData.Stroke.Color = Color3.fromRGB(30, 41, 59)
        end
    end
    TabScroll.CanvasSize = UDim2.new(0, #Tabs * 105, 0, 0)
end

local function addTab(scriptText)
    local tabName = "Tab " .. tabCounter
    tabCounter = tabCounter + 1
    
    local TabBtn = Instance.new("Frame")
    TabBtn.Size = UDim2.new(0, 95, 1, 0)
    TabBtn.BackgroundColor3 = THEME.BgSecondary
    TabBtn.Parent = TabScroll
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabBtn
    
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Thickness = 1.2
    TabStroke.Parent = TabBtn
    
    local TabText = Instance.new("TextButton")
    TabText.Size = UDim2.new(1, -22, 1, 0)
    TabText.BackgroundTransparency = 1
    TabText.Text = tabName
    TabText.TextColor3 = THEME.TextMain
    TabText.TextSize = 11
    TabText.Font = Enum.Font.SourceSansBold
    TabText.Parent = TabBtn
    
    local CloseTab = Instance.new("TextButton")
    CloseTab.Size = UDim2.new(0, 18, 1, 0)
    CloseTab.Position = UDim2.new(1, -18, 0, 0)
    CloseTab.BackgroundTransparency = 1
    CloseTab.Text = "X"
    CloseTab.TextColor3 = Color3.fromRGB(239, 68, 68)
    CloseTab.TextSize = 12
    CloseTab.Font = Enum.Font.SourceSansBold
    CloseTab.Parent = TabBtn
    
    local newTab = {
        Button = TabBtn,
        Stroke = TabStroke,
        Content = scriptText or "",
        Name = tabName
    }
    table.insert(Tabs, newTab)
    local currentIndex = #Tabs
    
    TabText.MouseButton1Click:Connect(function()
        activeTabIndex = currentIndex
        updateTabs()
    end)
    
    CloseTab.MouseButton1Click:Connect(function()
        if #Tabs > 1 then
            TabBtn:Destroy()
            table.remove(Tabs, currentIndex)
            activeTabIndex = math.clamp(activeTabIndex, 1, #Tabs)
            updateTabs()
        end
    end)
    
    activeTabIndex = currentIndex
    updateTabs()
end

AddTabBtn.MouseButton1Click:Connect(function()
    addTab("")
end)

CodeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    if Tabs[activeTabIndex] then
        Tabs[activeTabIndex].Content = CodeTextBox.Text
    end
end)

addTab("")

-- --------------------------------------------------------
-- SCRIPT EXECUTION ENGINE (รองรับ Code และ loadstring)
-- --------------------------------------------------------
local function runLuauCode(codeStr)
    if not codeStr or codeStr:gsub("%s+", "") == "" then
        showNotification(L("EmptyCode"), true)
        return
    end

    local cleanCode = codeStr:match("^%s*(.-)%s*$")

    -- กรณีผู้ใช้วางเพียงลิงก์ URL (https://...) โดยตรง ระบบจะดึง HttpGet และแปลงเป็น loadstring
    if cleanCode:match("^https?://") then
        if game and game.HttpGet then
            local successFetch, scriptContent = pcall(function()
                return game:HttpGet(cleanCode)
            end)
            if successFetch and scriptContent then
                cleanCode = scriptContent
            else
                showNotification(L("ExecError") .. "ไม่สามารถดึงข้อมูลจาก URL ได้", true)
                return
            end
        end
    end

    -- บันทึกประวัติ
    if #HistoryList == 0 or HistoryList[1] ~= codeStr then
        table.insert(HistoryList, 1, codeStr)
        if #HistoryList > 20 then
            table.remove(HistoryList, #HistoryList)
        end
    end

    -- Compile และรันสคริปต์ (รองรับทั้ง Code และ loadstring(...)())
    local func, loadErr = loadstring(cleanCode)
    if not func then
        showNotification(L("ExecError") .. tostring(loadErr or "Syntax Error"), true)
        return
    end

    local success, execErr = pcall(function()
        task.spawn(func)
    end)

    if success then
        showNotification(L("ExecSuccess"), false)
    else
        showNotification(L("ExecError") .. tostring(execErr), true)
    end
end

-- --------------------------------------------------------
-- BUTTON ACTIONS
-- --------------------------------------------------------

-- 1. ปุ่ม Execute
ExecuteBtn.MouseButton1Click:Connect(function()
    runLuauCode(CodeTextBox.Text)
end)

-- 2. ปุ่ม Clear
ClearBtn.MouseButton1Click:Connect(function()
    CodeTextBox.Text = ""
    if Tabs[activeTabIndex] then
        Tabs[activeTabIndex].Content = ""
    end
end)

-- 3. เมนูบันทึกสคริปต์
SaveNavBtn.MouseButton1Click:Connect(function()
    local overlay, modal = createModal(L("SavePromptTitle"))
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 40)
    Label.BackgroundTransparency = 1
    Label.Text = L("EnterName")
    Label.TextColor3 = THEME.TextMuted
    Label.TextSize = 12
    Label.ZIndex = 22
    Label.Parent = modal
    
    local NameInput = Instance.new("TextBox")
    NameInput.Size = UDim2.new(1, -30, 0, 32)
    NameInput.Position = UDim2.new(0, 15, 0, 65)
    NameInput.BackgroundColor3 = THEME.BgEditor
    NameInput.TextColor3 = THEME.TextMain
    NameInput.Text = "Script " .. (#SavedScripts + 1)
    NameInput.ZIndex = 22
    NameInput.Parent = modal
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = NameInput
    
    local ConfirmBtn = Instance.new("TextButton")
    ConfirmBtn.Size = UDim2.new(0, 100, 0, 32)
    ConfirmBtn.Position = UDim2.new(0.5, -50, 0, 130)
    ConfirmBtn.BackgroundColor3 = THEME.AccentDark
    ConfirmBtn.TextColor3 = THEME.TextMain
    ConfirmBtn.Text = L("SaveBtn")
    ConfirmBtn.Font = Enum.Font.SourceSansBold
    ConfirmBtn.ZIndex = 22
    ConfirmBtn.Parent = modal
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ConfirmBtn
    
    ConfirmBtn.MouseButton1Click:Connect(function()
        if NameInput.Text ~= "" then
            table.insert(SavedScripts, {
                Name = NameInput.Text,
                Code = CodeTextBox.Text
            })
            showNotification("บันทึก: " .. NameInput.Text, false)
            overlay:Destroy()
        end
    end)
end)

-- 4. เมนูคลังสคริปต์
SavedNavBtn.MouseButton1Click:Connect(function()
    local overlay, modal = createModal(L("SavedTitle"))
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -45)
    Scroll.Position = UDim2.new(0, 10, 0, 38)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ZIndex = 22
    Scroll.Parent = modal
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = Scroll
    
    for i, item in ipairs(SavedScripts) do
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -8, 0, 36)
        Card.BackgroundColor3 = THEME.BgEditor
        Card.ZIndex = 22
        Card.Parent = Scroll
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 6)
        CardCorner.Parent = Card
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -100, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = item.Name
        Title.TextColor3 = THEME.TextMain
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextSize = 12
        Title.ZIndex = 22
        Title.Parent = Card
        
        local LoadBtn = Instance.new("TextButton")
        LoadBtn.Size = UDim2.new(0, 42, 0, 24)
        LoadBtn.Position = UDim2.new(1, -92, 0.5, -12)
        LoadBtn.BackgroundColor3 = THEME.AccentDark
        LoadBtn.Text = L("Load")
        LoadBtn.TextColor3 = THEME.TextMain
        LoadBtn.Font = Enum.Font.SourceSansBold
        LoadBtn.TextSize = 11
        LoadBtn.ZIndex = 22
        LoadBtn.Parent = Card
        
        local LoadCorner = Instance.new("UICorner")
        LoadCorner.CornerRadius = UDim.new(0, 4)
        LoadCorner.Parent = LoadBtn
        
        LoadBtn.MouseButton1Click:Connect(function()
            CodeTextBox.Text = item.Code
            showNotification("โหลด: " .. item.Name, false)
            overlay:Destroy()
        end)
        
        local DelBtn = Instance.new("TextButton")
        DelBtn.Size = UDim2.new(0, 42, 0, 24)
        DelBtn.Position = UDim2.new(1, -46, 0.5, -12)
        DelBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        DelBtn.Text = L("Delete")
        DelBtn.TextColor3 = THEME.TextMain
        DelBtn.Font = Enum.Font.SourceSansBold
        DelBtn.TextSize = 11
        DelBtn.ZIndex = 22
        DelBtn.Parent = Card
        
        local DelCorner = Instance.new("UICorner")
        DelCorner.CornerRadius = UDim.new(0, 4)
        DelCorner.Parent = DelBtn
        
        DelBtn.MouseButton1Click:Connect(function()
            table.remove(SavedScripts, i)
            overlay:Destroy()
        end)
    end
end)

-- 5. เมนูประวัติ
HistoryNavBtn.MouseButton1Click:Connect(function()
    local overlay, modal = createModal(L("HistoryTitle"))
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -45)
    Scroll.Position = UDim2.new(0, 10, 0, 38)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ZIndex = 22
    Scroll.Parent = modal
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = Scroll
    
    for i, codeText in ipairs(HistoryList) do
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -8, 0, 36)
        Card.BackgroundColor3 = THEME.BgEditor
        Card.ZIndex = 22
        Card.Parent = Scroll
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 6)
        CardCorner.Parent = Card
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -55, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = string.sub(codeText, 1, 28) .. "..."
        Title.TextColor3 = THEME.TextMuted
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Font = Enum.Font.Code
        Title.TextSize = 10
        Title.ZIndex = 22
        Title.Parent = Card
        
        local LoadBtn = Instance.new("TextButton")
        LoadBtn.Size = UDim2.new(0, 42, 0, 24)
        LoadBtn.Position = UDim2.new(1, -48, 0.5, -12)
        LoadBtn.BackgroundColor3 = THEME.AccentDark
        LoadBtn.Text = L("Load")
        LoadBtn.TextColor3 = THEME.TextMain
        LoadBtn.Font = Enum.Font.SourceSansBold
        LoadBtn.TextSize = 11
        LoadBtn.ZIndex = 22
        LoadBtn.Parent = Card
        
        local LoadCorner = Instance.new("UICorner")
        LoadCorner.CornerRadius = UDim.new(0, 4)
        LoadCorner.Parent = LoadBtn
        
        LoadBtn.MouseButton1Click:Connect(function()
            CodeTextBox.Text = codeText
            showNotification("โหลดประวัติเก่าเรียบร้อย", false)
            overlay:Destroy()
        end)
    end
end)

-- 6. เมนูตั้งค่า
local function updateAllText()
    HeaderTitle.Text = L("Title")
    CodeTextBox.PlaceholderText = L("Placeholder")
    
    for key, btn in pairs(sidebarBtns) do
        btn.Text = L(key)
    end
end

SettingsNavBtn.MouseButton1Click:Connect(function()
    local overlay, modal = createModal(L("SettingsTitle"))
    
    local LangLabel = Instance.new("TextLabel")
    LangLabel.Size = UDim2.new(0, 110, 0, 28)
    LangLabel.Position = UDim2.new(0, 15, 0, 45)
    LangLabel.BackgroundTransparency = 1
    LangLabel.Text = L("Language") .. ":"
    LangLabel.TextColor3 = THEME.TextMain
    LangLabel.TextXAlignment = Enum.TextXAlignment.Left
    LangLabel.Font = Enum.Font.SourceSansBold
    LangLabel.ZIndex = 22
    LangLabel.Parent = modal
    
    local LangToggle = Instance.new("TextButton")
    LangToggle.Size = UDim2.new(0, 95, 0, 28)
    LangToggle.Position = UDim2.new(1, -110, 0, 45)
    LangToggle.BackgroundColor3 = THEME.AccentDark
    LangToggle.Text = currentLang == "EN" and "English" or "ไทย"
    LangToggle.TextColor3 = THEME.TextMain
    LangToggle.Font = Enum.Font.SourceSansBold
    LangToggle.ZIndex = 22
    LangToggle.Parent = modal
    
    local LangCorner = Instance.new("UICorner")
    LangCorner.CornerRadius = UDim.new(0, 6)
    LangCorner.Parent = LangToggle
    
    LangToggle.MouseButton1Click:Connect(function()
        currentLang = (currentLang == "EN") and "TH" or "EN"
        LangToggle.Text = currentLang == "EN" and "English" or "ไทย"
        updateAllText()
    end)
    
    local ScaleLabel = Instance.new("TextLabel")
    ScaleLabel.Size = UDim2.new(0, 110, 0, 28)
    ScaleLabel.Position = UDim2.new(0, 15, 0, 85)
    ScaleLabel.BackgroundTransparency = 1
    ScaleLabel.Text = L("UIScale") .. ":"
    ScaleLabel.TextColor3 = THEME.TextMain
    ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ScaleLabel.Font = Enum.Font.SourceSansBold
    ScaleLabel.ZIndex = 22
    ScaleLabel.Parent = modal
    
    local ScaleBtn = Instance.new("TextButton")
    ScaleBtn.Size = UDim2.new(0, 95, 0, 28)
    ScaleBtn.Position = UDim2.new(1, -110, 0, 85)
    ScaleBtn.BackgroundColor3 = THEME.BgMain
    ScaleBtn.Text = string.format("%.1fx", MainScale.Scale)
    ScaleBtn.TextColor3 = THEME.TextMain
    ScaleBtn.Font = Enum.Font.SourceSansBold
    ScaleBtn.ZIndex = 22
    ScaleBtn.Parent = modal
    
    local ScaleCorner = Instance.new("UICorner")
    ScaleCorner.CornerRadius = UDim.new(0, 6)
    ScaleCorner.Parent = ScaleBtn
    
    ScaleBtn.MouseButton1Click:Connect(function()
        if MainScale.Scale >= 1.2 then
            MainScale.Scale = 0.75
        else
            MainScale.Scale = MainScale.Scale + 0.15
        end
        ScaleBtn.Text = string.format("%.1fx", MainScale.Scale)
    end)
end)

-- 7. เมนูดิสคอร์ด
DiscordNavBtn.MouseButton1Click:Connect(function()
    local link = "https://discord.gg/GR4B2vgMrf"
    if setclipboard then
        setclipboard(link)
    elseif syn and syn.write_clipboard then
        syn.write_clipboard(link)
    end
    showNotification(L("CopiedDiscord"), false)
end)

showNotification("Executor พร้อมใช้งานเรียบร้อยแล้ว", false)
