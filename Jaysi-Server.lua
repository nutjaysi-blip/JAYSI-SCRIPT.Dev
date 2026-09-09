-- ตรวจความพร้อมของเกม
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ป้องกันรันซ้ำ
if CoreGui:FindFirstChild("RobloxServerBrowser") then
    CoreGui.RobloxServerBrowser:Destroy()
end

-- สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxServerBrowser"
ScreenGui.Parent = CoreGui

-- ==================== ปุ่มเปิด-ปิด UI (Toggle Button) ====================
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.Size = UDim2.new(0, 52, 0, 52) -- ขยายขนาดขึ้น
ToggleBtn.Image = "rbxassetid://123951224009948"

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleBtn

-- เพิ่มขอบสีฟ้าให้ปุ่มไอคอน
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 162, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

-- ==================== หน้าต่างหลัก (Main Frame) ====================
local MainFrame = Instance.new("ImageLabel")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- พื้นหลังสีดำทับ
MainFrame.BackgroundTransparency = 0.4 -- ความโปร่งใส
MainFrame.Image = "rbxassetid://124215910892153"
MainFrame.ImageTransparency = 0.25 -- ปรับรูปพื้นหลังให้กลมกลืน
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- เพิ่มขอบสีฟ้าให้กับหน้าต่างหลัก UI
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 162, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- หัวข้อหน้าต่าง
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Server Browser"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- ==================== ปุ่มเลือกหมวดหมู่ ====================
local HighBtn = Instance.new("TextButton")
HighBtn.Name = "HighBtn"
HighBtn.Parent = MainFrame
HighBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
HighBtn.Position = UDim2.new(0, 20, 0, 50)
HighBtn.Size = UDim2.new(0, 175, 0, 35)
HighBtn.Font = Enum.Font.GothamBold
HighBtn.Text = "คนเยอะ (High)"
HighBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HighBtn.TextSize = 13
Instance.new("UICorner", HighBtn).CornerRadius = UDim.new(0, 6)

local LowBtn = Instance.new("TextButton")
LowBtn.Name = "LowBtn"
LowBtn.Parent = MainFrame
LowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
LowBtn.Position = UDim2.new(0, 205, 0, 50)
LowBtn.Size = UDim2.new(0, 175, 0, 35)
LowBtn.Font = Enum.Font.GothamBold
LowBtn.Text = "คนน้อย (Low)"
LowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LowBtn.TextSize = 13
Instance.new("UICorner", LowBtn).CornerRadius = UDim.new(0, 6)

-- ==================== พื้นที่แสดงรายการเซิร์ฟเวอร์ ====================
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 20, 0, 95)
ScrollingFrame.Size = UDim2.new(0, 360, 0, 235)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- ฟังก์ชันดึงข้อมูล Server จาก Roblox API
local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and result then
        return result.data
    end
    return {}
end

-- ฟังก์ชันเคลียร์รายการเก่า
local function clearList()
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

-- ฟังก์ชันแสดงผลเซิร์ฟเวอร์ตามหมวดหมู่
local function loadServers(category)
    clearList()
    local servers = getServers()
    
    -- คัดกรองและจัดเรียงข้อมูล
    table.sort(servers, function(a, b)
        if category == "High" then
            return a.playing > b.playing -- คนมากไปน้อย
        else
            return a.playing < b.playing -- น้อยไปมาก
        end
    end)

    for _, srv in ipairs(servers) do
        if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
            -- สร้างกรอบแต่ละเซิร์ฟเวอร์ (ปรับเป็นทรงแคปซูลและโปร่งใส)
            local Item = Instance.new("Frame")
            Item.Parent = ScrollingFrame
            Item.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Item.BackgroundTransparency = 0.45 -- โปร่งใสนิดๆ
            Item.Size = UDim2.new(1, 0, 0, 45)
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(1, 0) -- ทรงแคปซูล
            ItemCorner.Parent = Item

            local ItemStroke = Instance.new("UIStroke")
            ItemStroke.Color = Color3.fromRGB(0, 162, 255)
            ItemStroke.Transparency = 0.5
            ItemStroke.Thickness = 1
            ItemStroke.Parent = Item

            -- ข้อความบอกจำนวนคน
            local InfoLabel = Instance.new("TextLabel")
            InfoLabel.Parent = Item
            InfoLabel.BackgroundTransparency = 1
            InfoLabel.Position = UDim2.new(0, 15, 0, 0)
            InfoLabel.Size = UDim2.new(0, 230, 1, 0)
            InfoLabel.Font = Enum.Font.Gotham
            InfoLabel.Text = "Players: " .. srv.playing .. " / " .. srv.maxPlayers .. " | Ping: " .. (srv.ping or "N/A")
            InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            InfoLabel.TextSize = 12
            InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

            -- ปุ่มกด Join
            local JoinBtn = Instance.new("TextButton")
            JoinBtn.Parent = Item
            JoinBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            JoinBtn.Position = UDim2.new(1, -90, 0.5, -15)
            JoinBtn.Size = UDim2.new(0, 75, 0, 30)
            JoinBtn.Font = Enum.Font.GothamBold
            JoinBtn.Text = "JOIN"
            JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            JoinBtn.TextSize = 12
            Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(1, 0) -- ปุ่ม Join ทรงแคปซูลด้วยเพื่อให้เข้ากัน

            -- กดปุ่มแล้ววาปไปเซิร์ฟนั้น
            JoinBtn.MouseButton1Click:Connect(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
            end)
        end
    end
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- ==================== ระบบสลับปุ่มกดและการเปิดปิด ====================
local currentCategory = "High"

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        loadServers(currentCategory)
    end
end)

HighBtn.MouseButton1Click:Connect(function()
    currentCategory = "High"
    HighBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    LowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    loadServers("High")
end)

LowBtn.MouseButton1Click:Connect(function()
    currentCategory = "Low"
    LowBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    HighBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    loadServers("Low")
end)
