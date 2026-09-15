--[[
  ╔══════════════════════════════════════════════════════════════╗
  ║                THIÊNG CODEX - FRUIT SNIPER                    ║
  ║       Scan → Fly → Grab → Store (3 retries) → Hop          ║
  ╚══════════════════════════════════════════════════════════════╝
]]

repeat task.wait() until game:IsLoaded()

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local CommF   = Remotes:WaitForChild("CommF_", 9e9)
local Player  = Players.LocalPlayer

getgenv().AutoFruitSniper   = true
getgenv().FruitESP          = true
getgenv().TweenSpeed        = 300
getgenv().StoreRetries      = 3
getgenv().HopDelay          = 3
getgenv().ScanInterval      = 0.5
getgenv().AntiAFK           = true

local oldGui = Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("ThiengCodeXGUI")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThiengCodeXGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0, 15, 0, 15)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(100, 50, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
TitleBar.BackgroundTransparency = 0.4
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
TitleFix.BackgroundTransparency = 0.4
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ THIÊNG CODEX"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 28)
StatusLabel.Position = UDim2.new(0, 10, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⏳ Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Name = "LogFrame"
LogFrame.Size = UDim2.new(1, -20, 1, -80)
LogFrame.Position = UDim2.new(0, 10, 0, 74)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
LogFrame.BackgroundTransparency = 0.3
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 255)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogFrame.Parent = MainFrame

local LogCorner = Instance.new("UICorner", LogFrame)
LogCorner.CornerRadius = UDim.new(0, 6)

local LogLayout = Instance.new("UIListLayout", LogFrame)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 2)

local LogPadding = Instance.new("UIPadding", LogFrame)
LogPadding.PaddingTop = UDim.new(0, 4)
LogPadding.PaddingLeft = UDim.new(0, 6)
LogPadding.PaddingRight = UDim.new(0, 6)

local MSG_COLORS = {
  success = Color3.fromRGB(80, 255, 80),
  error   = Color3.fromRGB(255, 80, 80),
  warn    = Color3.fromRGB(255, 200, 50),
  info    = Color3.fromRGB(150, 180, 255),
  action  = Color3.fromRGB(0, 200, 255),
  fruit   = Color3.fromRGB(255, 100, 200),
  hop     = Color3.fromRGB(180, 130, 255),
}

local logOrder = 0

local function Notify(message, msgType, isStatus)
  msgType = msgType or "info"
  local color = MSG_COLORS[msgType] or MSG_COLORS.info
  
  if isStatus then
    StatusLabel.Text = message
    StatusLabel.TextColor3 = color
  end
  
  logOrder = logOrder + 1
  local LogEntry = Instance.new("TextLabel")
  LogEntry.Name = "Log_" .. logOrder
  LogEntry.LayoutOrder = logOrder
  LogEntry.Size = UDim2.new(1, 0, 0, 16)
  LogEntry.BackgroundTransparency = 1
  LogEntry.Text = os.date("%H:%M:%S") .. "  " .. message
  LogEntry.TextColor3 = color
  LogEntry.TextSize = 11
  LogEntry.Font = Enum.Font.Gotham
  LogEntry.TextXAlignment = Enum.TextXAlignment.Left
  LogEntry.TextWrapped = true
  LogEntry.AutomaticSize = Enum.AutomaticSize.Y
  LogEntry.Parent = LogFrame
  
  task.defer(function()
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.AbsoluteCanvasSize.Y)
  end)
  
  print("[ThiengCodeX] " .. message)
end

local function Get_Fruit(Fruit)
  if Fruit == "Rocket Fruit" then return "Rocket-Rocket"
  elseif Fruit == "Spin Fruit" then return "Spin-Spin"
  elseif Fruit == "Chop Fruit" then return "Chop-Chop"
  elseif Fruit == "Spring Fruit" then return "Spring-Spring"
  elseif Fruit == "Bomb Fruit" then return "Bomb-Bomb"
  elseif Fruit == "Smoke Fruit" then return "Smoke-Smoke"
  elseif Fruit == "Spike Fruit" then return "Spike-Spike"
  elseif Fruit == "Flame Fruit" then return "Flame-Flame"
  elseif Fruit == "Falcon Fruit" then return "Falcon-Falcon"
  elseif Fruit == "Ice Fruit" then return "Ice-Ice"
  elseif Fruit == "Sand Fruit" then return "Sand-Sand"
  elseif Fruit == "Dark Fruit" then return "Dark-Dark"
  elseif Fruit == "Ghost Fruit" then return "Ghost-Ghost"
  elseif Fruit == "Diamond Fruit" then return "Diamond-Diamond"
  elseif Fruit == "Light Fruit" then return "Light-Light"
  elseif Fruit == "Rubber Fruit" then return "Rubber-Rubber"
  elseif Fruit == "Barrier Fruit" then return "Barrier-Barrier"
  elseif Fruit == "Magma Fruit" then return "Magma-Magma"
  elseif Fruit == "Quake Fruit" then return "Quake-Quake"
  elseif Fruit == "Buddha Fruit" then return "Buddha-Buddha"
  elseif Fruit == "Love Fruit" then return "Love-Love"
  elseif Fruit == "Spider Fruit" then return "Spider-Spider"
  elseif Fruit == "Sound Fruit" then return "Sound-Sound"
  elseif Fruit == "Phoenix Fruit" then return "Phoenix-Phoenix"
  elseif Fruit == "Portal Fruit" then return "Portal-Portal"
  elseif Fruit == "Rumble Fruit" then return "Rumble-Rumble"
  elseif Fruit == "Pain Fruit" then return "Pain-Pain"
  elseif Fruit == "Blizzard Fruit" then return "Blizzard-Blizzard"
  elseif Fruit == "Gravity Fruit" then return "Gravity-Gravity"
  elseif Fruit == "Mammoth Fruit" then return "Mammoth-Mammoth"
  elseif Fruit == "T-Rex Fruit" then return "T-Rex-T-Rex"
  elseif Fruit == "Dough Fruit" then return "Dough-Dough"
  elseif Fruit == "Shadow Fruit" then return "Shadow-Shadow"
  elseif Fruit == "Venom Fruit" then return "Venom-Venom"
  elseif Fruit == "Control Fruit" then return "Control-Control"
  elseif Fruit == "Spirit Fruit" then return "Spirit-Spirit"
  elseif Fruit == "Dragon Fruit" then return "Dragon-Dragon"
  elseif Fruit == "Leopard Fruit" then return "Leopard-Leopard"
  elseif Fruit == "Kitsune Fruit" then return "Kitsune-Kitsune" end
end

local block = Instance.new("Part", workspace)
block.Size         = Vector3.new(1, 1, 1)
block.Name         = "ThiengCodeX_Platform"
block.Anchored     = true
block.CanCollide   = false
block.CanTouch     = false
block.Transparency = 1

local IsFarming = false

task.spawn(function()
  repeat task.wait() until Player.Character and Player.Character.PrimaryPart
  block.CFrame = Player.Character.PrimaryPart.CFrame
  
  while task.wait() do
    pcall(function()
      if IsFarming then
        if block and block.Parent == workspace then
          local plrPP = Player.Character and Player.Character.PrimaryPart
          if plrPP and (plrPP.Position - block.Position).Magnitude <= 200 then
            plrPP.CFrame = block.CFrame
          else
            block.CFrame = plrPP.CFrame
          end
        end
        local plrChar = Player.Character
        if plrChar then
          for _, part in pairs(plrChar:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
          end
          if plrChar:FindFirstChild("Stun") then plrChar.Stun.Value = 0 end
          if plrChar:FindFirstChild("Busy") then plrChar.Busy.Value = false end
        end
      else
        local plrChar = Player.Character
        if plrChar then
          for _, part in pairs(plrChar:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
          end
        end
      end
    end)
  end
end)

local function TweenToPosition(targetCFrame)
  local plrPP = Player.Character and Player.Character.PrimaryPart
  if not plrPP then return end
  local distance = (plrPP.Position - targetCFrame.p).Magnitude
  local speed = getgenv().TweenSpeed or 300
  local tweenTime = distance / speed
  if tweenTime < 0.1 then tweenTime = 0.1 end
  
  local tween = TweenService:Create(block, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
  tween:Play()
  tween.Completed:Wait()
end

local function FruitFind()
  local fruits = workspace:GetChildren()
  local FruitDistance = math.huge
  local FoundFruit = nil
  
  for _, fruit in pairs(fruits) do
    local plrPP = Player and Player.Character and Player.Character.PrimaryPart
    local isTool = fruit and fruit:IsA("Tool") and fruit:FindFirstChild("Handle")
    local isFruitNamed = fruit and string.find(fruit.Name, "Fruit") and fruit:FindFirstChild("Handle")
    
    if plrPP and isTool and (plrPP.Position - isTool.Position).Magnitude <= FruitDistance then
      FruitDistance = (plrPP.Position - isTool.Position).Magnitude
      FoundFruit = fruit
    elseif plrPP and isFruitNamed and (plrPP.Position - isFruitNamed.Position).Magnitude <= FruitDistance then
      FruitDistance = (plrPP.Position - isFruitNamed.Position).Magnitude
      FoundFruit = fruit
    end
  end
  return FoundFruit
end

local function AddESP(Part, ESPColor)
  if Part and Part:FindFirstChild("ThiengCodeX_ESP") then return end
  local Folder = Instance.new("Folder", Part)
  Folder.Name = "ThiengCodeX_ESP"
  local BBG = Instance.new("BillboardGui", Folder)
  BBG.Adornee = Part
  BBG.Size = UDim2.new(0, 120, 0, 50)
  BBG.StudsOffset = Vector3.new(0, 3, 0)
  BBG.AlwaysOnTop = true
  local TL = Instance.new("TextLabel", BBG)
  TL.BackgroundTransparency = 1
  TL.Size = UDim2.new(1, 0, 1, 0)
  TL.TextSize = 14
  TL.Font = Enum.Font.GothamBold
  TL.TextColor3 = ESPColor or Color3.fromRGB(255, 0, 0)
  TL.TextStrokeTransparency = 0
  TL.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  TL.Text = "..."
  TL.ZIndex = 15
  
  task.spawn(function()
    while task.wait(0.5) do
      pcall(function()
        if not Part or not Part.Parent then Folder:Destroy() return end
        local plrPP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if plrPP and Part then
          local distance = math.floor((plrPP.Position - Part.Position).Magnitude)
          local fruitName = Part.Parent and Part.Parent.Name or "Unknown"
          TL.Text = "🍎 " .. fruitName .. " [" .. tostring(distance) .. " studs]"
        end
      end)
    end
  end)
end

task.spawn(function()
  while getgenv().AutoFruitSniper do task.wait(1)
    if getgenv().FruitESP then
      for _, obj in pairs(workspace:GetChildren()) do
        pcall(function()
          if obj and obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            AddESP(obj.Handle, Color3.fromRGB(255, 50, 50))
          elseif obj and string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
            AddESP(obj.Handle, Color3.fromRGB(255, 50, 50))
          end
        end)
      end
    end
  end
end)

local function FindFruitInInventory()
  local plrChar = Player and Player.Character
  local plrBag  = Player and Player.Backpack
  if plrChar then
    for _, tool in pairs(plrChar:GetChildren()) do
      if tool:IsA("Tool") and tool:FindFirstChild("Fruit") then return tool end
    end
  end
  if plrBag then
    for _, tool in pairs(plrBag:GetChildren()) do
      if tool:IsA("Tool") and tool:FindFirstChild("Fruit") then return tool end
    end
  end
  return nil
end

local function StoreFruitWithRetry(fruitTool)
  local maxRetries = getgenv().StoreRetries or 3
  local fruitId = Get_Fruit(fruitTool.Name)
  if not fruitId then Notify("❌ Unknown fruit: " .. fruitTool.Name, "error") return false end
  
  Notify("📦 Storing: " .. fruitTool.Name .. " (" .. fruitId .. ")", "action", true)
  for attempt = 1, maxRetries do
    Notify("📦 Store attempt " .. attempt .. "/" .. maxRetries .. "...", "warn", true)
    local success, result = pcall(function() return CommF:InvokeServer("StoreFruit", fruitId, fruitTool) end)
    if success and result == true then
      Notify("✅ STORED " .. fruitTool.Name .. "!", "success", true)
      return true
    else
      task.wait(1)
    end
  end
  return false
end

local CurrentPlaceId = game.PlaceId
local CurrentSea = "Unknown"
pcall(function()
  local Locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
  if Locations then
    if Locations:FindFirstChild("Hydra Island") or Locations:FindFirstChild("Floating Turtle") then CurrentSea = "Sea 3"
    elseif Locations:FindFirstChild("Kingdom of Rose") or Locations:FindFirstChild("Green Zone") then CurrentSea = "Sea 2"
    else CurrentSea = "Sea 1" end
  end
end)

local function ServerHop()
  Notify("🔄 Starting server hop...", "hop", true)
  while true do
    local apiUrl = "https://games.roblox.com/v1/games/" .. CurrentPlaceId .. "/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100"
    local Server, Next, pageAttempts = nil, nil, 0
    pcall(function()
      repeat task.wait(0.5)
        pageAttempts = pageAttempts + 1
        local raw = game:HttpGet(apiUrl .. ((Next and "&cursor=" .. Next) or ""))
        local Servers = HttpService:JSONDecode(raw)
        if Servers and Servers.data then
          for _, server in pairs(Servers.data) do
            if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < (server.maxPlayers - 1) then
              Server = server
              break
            end
          end
          Next = Servers.nextPageCursor
        end
      until Server or not Next or pageAttempts >= 5
    end)
    
    if Server then
      pcall(function() ReplicatedStorage:WaitForChild("__ServerBrowser"):InvokeServer("teleport", Server.id) end)
      task.wait(5)
      TeleportService:TeleportToPlaceInstance(CurrentPlaceId, Server.id, Player)
      task.wait(5)
    else
      TeleportService:Teleport(CurrentPlaceId, Player)
      task.wait(5)
    end
  end
end

task.spawn(function()
  while getgenv().AntiAFK do task.wait(60)
    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
  end
end)

local function WaitForCharacter()
  local char = Player.Character or Player.CharacterAdded:Wait()
  repeat task.wait() until char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid")
  task.wait(1)
  block.CFrame = char.HumanoidRootPart.CFrame
  return char
end

Notify("⚡ Thiêng CodeX Active!", "success", true)
task.wait(1)

task.spawn(function()
  while getgenv().AutoFruitSniper do
    WaitForCharacter()
    local fruit = FruitFind()
    if fruit then
      local fruitHandle = fruit:FindFirstChild("Handle")
      Notify("🍎 FOUND: " .. fruit.Name, "fruit", true)
      
      IsFarming = true
      TweenToPosition(CFrame.new(fruitHandle.Position + Vector3.new(0, 5, 0)))
      TweenToPosition(fruitHandle.CFrame)
      
      local plrPP = Player.Character and Player.Character.PrimaryPart
      if plrPP and fruitHandle then
        for i = 1, 10 do
          if not fruit.Parent or fruit.Parent ~= workspace then break end
          plrPP.CFrame = fruitHandle.CFrame
          block.CFrame = fruitHandle.CFrame
          task.wait(0.2)
        end
      end
      task.wait(1)
      
      local inventoryFruit = FindFruitInInventory()
      if inventoryFruit then StoreFruitWithRetry(inventoryFruit) end
      IsFarming = false
      
      task.wait(getgenv().HopDelay)
      ServerHop()
      break
    else
      Notify("❌ No fruit, hopping...", "error", true)
      task.wait(getgenv().HopDelay)
      ServerHop()
      break
    end
  end
end)
