-- ==========================================================
-- JAYSI SCRIPT HUB | INSTANT PROMPT & INFINITE JUMP HUB
-- ==========================================================

local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("JaysiPromptHub") then
    CoreGui.JaysiPromptHub:Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- ตัวแปรสถานะระบบ
_G.InstantPromptActive = true
_G.InfiniteJumpActive = false

-- สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JaysiPromptHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- ปุ่มเปิด/ปิด UI แบบไม่มีรูปภาพ (ใช้ Text รูปสายฟ้า ⚡ ลากขยับได้อิสระ)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Name = "ToggleButton"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleButton.Size = UDim2.new(0, 52, 0, 52)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 22
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)

local ToggleStroke = Instance.new("UIStroke", ToggleButton)
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2

local ToggleGradient = Instance.new("UIGradient", ToggleButton)
ToggleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 220))
})
ToggleGradient.Rotation = 45

-- หน้าต่างหลัก UI (ขยายขนาดความสูงขึ้นเล็กน้อยเพื่อให้พอดีกับปุ่มใหม่)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
MainFrame.BackgroundTransparency = 0.05
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 230)
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 190, 255)
MainStroke.Thickness = 2

-- หัวข้อ UI
local TopBar = Instance.new("Frame", MainFrame)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 26, 44)
TopBar.Size = UDim2.new(1, 0, 0, 38)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0, 240, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚡ JAYSI SCRIPT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -10)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- เนื้อหาด้านใน (จัดเรียงด้วย UIListLayout)
local Content = Instance.new("Frame", MainFrame)
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 15, 0, 48)
Content.Size = UDim2.new(1, -30, 1, -58)

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

-- ปุ่มที่ 1: ระบบกดปุ่ม ProximityPrompt ทันที
local TogglePromptBtn = Instance.new("TextButton", Content)
TogglePromptBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TogglePromptBtn.Size = UDim2.new(1, 0, 0, 40)
TogglePromptBtn.Font = Enum.Font.GothamBold
TogglePromptBtn.Text = "ระบบกดปุ่มทันที: เปิดอยู่"
TogglePromptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TogglePromptBtn.TextSize = 11
Instance.new("UICorner", TogglePromptBtn).CornerRadius = UDim.new(0, 8)

TogglePromptBtn.MouseButton1Click:Connect(function()
    _G.InstantPromptActive = not _G.InstantPromptActive
    if _G.InstantPromptActive then
        TogglePromptBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        TogglePromptBtn.Text = "ระบบกดปุ่มทันที: เปิดอยู่"
    else
        TogglePromptBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
        TogglePromptBtn.Text = "ระบบกดปุ่มทันที: ปิดอยู่"
    end
end)

-- ปุ่มที่ 2: ระบบกระโดดไม่จำกัด (Infinite Jump)
local ToggleJumpBtn = Instance.new("TextButton", Content)
ToggleJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
ToggleJumpBtn.Size = UDim2.new(1, 0, 0, 40)
ToggleJumpBtn.Font = Enum.Font.GothamBold
ToggleJumpBtn.Text = "ระบบกระโดดไม่จำกัด: ปิดอยู่"
ToggleJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleJumpBtn.TextSize = 11
Instance.new("UICorner", ToggleJumpBtn).CornerRadius = UDim.new(0, 8)

ToggleJumpBtn.MouseButton1Click:Connect(function()
    _G.InfiniteJumpActive = not _G.InfiniteJumpActive
    if _G.InfiniteJumpActive then
        ToggleJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        ToggleJumpBtn.Text = "ระบบกระโดดไม่จำกัด: เปิดอยู่"
    else
        ToggleJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
        ToggleJumpBtn.Text = "ระบบกระโดดไม่จำกัด: ปิดอยู่"
    end
end)

-- ==================== ระบบการทำงานภายใน ====================

-- 1. ระบบกดปุ่ม ProximityPrompt ทันที
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.InstantPromptActive then
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 999
                    end
                end
            end)
        end
    end
end)

-- 2. ระบบกระโดดไม่จำกัด (Infinite Jump Logic)
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJumpActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end)

-- ==================== ควบคุมเปิด/ปิด หน้าต่าง UI ====================
local isOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ระบบลากไอคอนปุ่มเปิด/ปิด (Draggable ToggleButton)
local tDragging, tDragInput, tStartPos, tDragStart
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = true
        tDragStart = input.Position
        tStartPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then tDragging = false end
        end)
    end
end)
ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        tDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == tDragInput and tDragging then
        local delta = input.Position - tDragStart
        ToggleButton.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)

-- ระบบลากหน้าต่างหลัก (Draggable MainFrame)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local val = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + val.X, startPos.Y.Scale, startPos.Y.Offset + val.Y)
    end
end)
