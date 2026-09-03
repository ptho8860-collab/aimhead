-- =====================================================================
-- PHUOCTHOPC CONTROL HUB - V8.1 SILENT AIM EDITION
-- =====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local camera = workspace.CurrentCamera

-- DỌN DẸP DRAWING CŨ NẾU RE-EXECUTE
if _G.PhuocThoCleanUp then
    pcall(_G.PhuocThoCleanUp)
end

-- TRẠNG THÁI TÍNH NĂNG
local silentAimEnabled = true -- ĐẠN ĐUỔI
local aimlockEnabled = false
local skeletonEspEnabled = false
local boxEspEnabled = false
local tracerEspEnabled = false
local mm2RoleEspEnabled = true
local droppedGunEspEnabled = true
local hitboxEnabled = false
local flyEnabled = false
local speedEnabled = false
local infJumpEnabled = false
local noclipEnabled = false
local antiAfkEnabled = true

-- CẤU HÌNH THÔNG SỐ
local flySpeed = 50
local walkSpeedValue = 50
local hitboxSizeValue = 18
local fovRadius = 140
local aimSmoothness = 0.35
local predictionAmount = 0.08
local defaultHitboxSize = Vector3.new(2, 2, 1)

-- MÀU SẮC CHUẨN MM2
local colorMurderer = Color3.fromRGB(255, 0, 50)
local colorSheriff = Color3.fromRGB(0, 150, 255)
local colorHero = Color3.fromRGB(255, 220, 0)
local colorInnocent = Color3.fromRGB(0, 255, 120)
local colorDroppedGun = Color3.fromRGB(255, 170, 0)

-- =====================================================================
-- 1. SILENT AIM HOOK (CƠ CHẾ BẺ HƯỚNG ĐẠN / DAO)
-- =====================================================================
local function getClosestHeadToMouse()
    local closestHead = nil
    local shortestDistance = fovRadius
    local mousePos = UserInputService:GetMouseLocation()

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local head = v.Character.Head
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestHead = head
                    end
                end
            end
        end
    end
    return closestHead
end

-- Hook Metatable để can thiệp Raycast bắn súng
local gmt = getrawmetatable and getrawmetatable(game)
if gmt and setreadonly then
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall
    gmt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if silentAimEnabled and not checkcaller() then
            if method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                local targetHead = getClosestHeadToMouse()
                if targetHead then
                    if method == "Raycast" and args[1] and args[2] then
                        local origin = args[1]
                        args[2] = (targetHead.Position - origin).Unit * 1000
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end

-- =====================================================================
-- 2. KHỞI TẠO RAYFIELD WINDOW UI
-- =====================================================================
local Window = Rayfield:CreateWindow({
   Name = "PHUOCTHOPC CONTROL HUB v8.1",
   LoadingTitle = "PhuocThoPC Hub Loading...",
   LoadingSubtitle = "by PhuocThoPC System",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- TAB CHỨC NĂNG
local TabCombat = Window:CreateTab("⚔️ Combat & Aim", 4483362458)
local TabMovement = Window:CreateTab("🏃 Movement", 4483362458)
local TabVisuals = Window:CreateTab("👁️ Visuals (ESP)", 4483362458)
local TabMM2 = Window:CreateTab("🔪 MM2 Utility", 4483362458)
local TabSystem = Window:CreateTab("⚙️ System", 4483362458)

-- --- TAB 1: COMBAT & AIM ---
TabCombat:CreateToggle({
   Name = "🎯 Đạn Đuổi / Silent Aim (Bắn/Phóng Dao Tự Trúng)",
   CurrentValue = silentAimEnabled,
   Callback = function(Value) 
       silentAimEnabled = Value 
       Rayfield:Notify({ Title = "Combat", Content = Value and "Đã BẬT Đạn Đuổi!" or "Đã TẮT Đạn Đuổi!", Duration = 2 })
   end,
})

TabCombat:CreateToggle({
   Name = "AimLock Head (Giữ phím E / Tự xoay cam)",
   CurrentValue = aimlockEnabled,
   Callback = function(Value) aimlockEnabled = Value end,
})

TabCombat:CreateSlider({
   Name = "Vùng ngắm Silent Aim / Aimlock (FOV)",
   Range = {30, 400},
   Increment = 10,
   CurrentValue = fovRadius,
   Callback = function(Value) fovRadius = Value end,
})

TabCombat:CreateDivider()

TabCombat:CreateToggle({
   Name = "Hitbox Extend (Phóng to thân/đầu)",
   CurrentValue = hitboxEnabled,
   Callback = function(Value) hitboxEnabled = Value end,
})

TabCombat:CreateSlider({
   Name = "Kích thước Hitbox",
   Range = {2, 50},
   Increment = 1,
   CurrentValue = hitboxSizeValue,
   Callback = function(Value) hitboxSizeValue = Value end,
})

-- --- TAB 2: MOVEMENT ---
TabMovement:CreateToggle({
   Name = "Speed Hack (Chạy nhanh)",
   CurrentValue = speedEnabled,
   Callback = function(Value) speedEnabled = Value end,
})

TabMovement:CreateSlider({
   Name = "Tốc độ chạy (WalkSpeed)",
   Range = {16, 200},
   Increment = 2,
   CurrentValue = walkSpeedValue,
   Callback = function(Value) walkSpeedValue = Value end,
})

TabMovement:CreateDivider()

TabMovement:CreateToggle({
   Name = "Fly Mode (Bay)",
   CurrentValue = flyEnabled,
   Callback = function(Value) flyEnabled = Value end,
})

TabMovement:CreateSlider({
   Name = "Tốc độ bay (Fly Speed)",
   Range = {10, 300},
   Increment = 10,
   CurrentValue = flySpeed,
   Callback = function(Value) flySpeed = Value end,
})

TabMovement:CreateToggle({
   Name = "Noclip (Xuyên tường)",
   CurrentValue = noclipEnabled,
   Callback = function(Value) noclipEnabled = Value end,
})

TabMovement:CreateToggle({
   Name = "Infinite Jump (Nhảy vô tận)",
   CurrentValue = infJumpEnabled,
   Callback = function(Value) infJumpEnabled = Value end,
})

-- --- TAB 3: VISUALS (ESP) ---
TabVisuals:CreateToggle({
   Name = "ESP Box + Thanh HP + Tên",
   CurrentValue = boxEspEnabled,
   Callback = function(Value) boxEspEnabled = Value end,
})

TabVisuals:CreateToggle({
   Name = "ESP Skeleton (Khung xương)",
   CurrentValue = skeletonEspEnabled,
   Callback = function(Value) skeletonEspEnabled = Value end,
})

TabVisuals:CreateToggle({
   Name = "ESP Line / Tracer (Đường kẻ chân)",
   CurrentValue = tracerEspEnabled,
   Callback = function(Value) tracerEspEnabled = Value end,
})

-- --- TAB 4: MM2 UTILITY ---
TabMM2:CreateToggle({
   Name = "MM2 Role Detector (Soi Vai Trò)",
   CurrentValue = mm2RoleEspEnabled,
   Callback = function(Value) mm2RoleEspEnabled = Value end,
})

TabMM2:CreateToggle({
   Name = "ESP Súng Rơi (Dropped Gun)",
   CurrentValue = droppedGunEspEnabled,
   Callback = function(Value) droppedGunEspEnabled = Value end,
})

TabMM2:CreateButton({
   Name = "⚡ Dịch chuyển tới Súng Rơi (TP Gun)",
   Callback = function()
       local gun = nil
       for _, obj in pairs(workspace:GetChildren()) do
           if obj:IsA("Tool") and (obj.Name == "GunDrop" or obj.Name:lower():find("gun")) then gun = obj break end
       end
       local char = player.Character
       local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
       if gun and root then
           local gunPart = gun:FindFirstChildOfClass("BasePart") or gun.PrimaryPart or gun
           root.CFrame = gunPart.CFrame + Vector3.new(0, 2, 0)
           Rayfield:Notify({ Title = "MM2 Teleport", Content = "Đã dịch chuyển tới vị trí súng!", Duration = 2 })
       else
           Rayfield:Notify({ Title = "MM2 Teleport", Content = "Hiện không có súng nào rơi trên map!", Duration = 2 })
       end
   end,
})

-- --- TAB 5: SYSTEM ---
TabSystem:CreateToggle({
   Name = "Anti-AFK (Chống văng 20 phút)",
   CurrentValue = antiAfkEnabled,
   Callback = function(Value) antiAfkEnabled = Value end,
})

TabSystem:CreateButton({
   Name = "Dọn dẹp & Tắt Hub",
   Callback = function()
       if _G.PhuocThoCleanUp then _G.PhuocThoCleanUp() end
       Rayfield:Destroy()
   end,
})

-- =====================================================================
-- 3. CORE LOOP & RENDER LOGIC
-- =====================================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.NumSides = 60
fovCircle.Visible = false

player.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.PreRender:Connect(function(deltaTime)
    local mousePos = UserInputService:GetMouseLocation()

    if fovCircle then
        fovCircle.Position = mousePos
        fovCircle.Radius = fovRadius
        fovCircle.Visible = silentAimEnabled or aimlockEnabled
    end

    local myChar = player.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    
    if myChar then
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speedEnabled and walkSpeedValue or 16 end
        
        if noclipEnabled then
            for _, part in pairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        if flyEnabled and myRoot then
            hum.PlatformStand = true
            local moveDir = Vector3.zero
            local camCF = camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then myRoot.CFrame = myRoot.CFrame + (moveDir.Unit * flySpeed * deltaTime) end
            myRoot.AssemblyLinearVelocity = Vector3.zero
        elseif hum and hum.PlatformStand then
            hum.PlatformStand = false
        end
    end
end)
