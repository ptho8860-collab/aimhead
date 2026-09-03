-- =====================================================================
-- PHUOCTHOPC CONTROL HUB - V8.1 SILENT AIM & FULL UTILITY EDITION
-- =====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local camera = workspace.CurrentCamera

-- DỌN DẸP SCRIPT CŨ NẾU CHẠY LẠI
if _G.PhuocThoCleanUp then
    pcall(_G.PhuocThoCleanUp)
end

-- TRẠNG THÁI TÍNH NĂNG
local silentAimEnabled = true
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
local aimSmoothness = 0.2
local defaultHitboxSize = Vector3.new(2, 2, 1)

-- MÀU SẮC MM2 & VISUALS
local colorMurderer = Color3.fromRGB(255, 0, 50)
local colorSheriff = Color3.fromRGB(0, 150, 255)
local colorHero = Color3.fromRGB(255, 220, 0)
local colorInnocent = Color3.fromRGB(0, 255, 120)
local colorDroppedGun = Color3.fromRGB(255, 170, 0)

-- HOOK SILENT AIM (BẺ HƯỚNG BẮN)
local function getMousePos()
    local mouseLoc = UserInputService:GetMouseLocation()
    local guiInset = GuiService:GetGuiInset()
    return Vector2.new(mouseLoc.X, mouseLoc.Y - guiInset.Y)
end

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

-- Hook Metatable
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
-- UI CREATION
-- =====================================================================
local Window = Rayfield:CreateWindow({
   Name = "PHUOCTHOPC CONTROL HUB v8.1",
   LoadingTitle = "PhuocThoPC Hub Loading...",
   LoadingSubtitle = "by PhuocThoPC System",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local TabCombat = Window:CreateTab("⚔️ Combat & Aim", 4483362458)
local TabMovement = Window:CreateTab("🏃 Movement", 4483362458)
local TabVisuals = Window:CreateTab("👁️ Visuals (ESP)", 4483362458)
local TabMM2 = Window:CreateTab("🔪 MM2 Utility", 4483362458)
local TabSystem = Window:CreateTab("⚙️ System", 4483362458)

-- COMBAT
TabCombat:CreateToggle({
   Name = "🎯 Đạn Đuổi / Silent Aim (Bắn/Phóng Dao Tự Trúng)",
   CurrentValue = silentAimEnabled,
   Callback = function(Value) silentAimEnabled = Value end,
})

TabCombat:CreateToggle({
   Name = "AimLock Head (Giữ phím E để khóa mục tiêu)",
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

-- MOVEMENT
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

-- VISUALS
TabVisuals:CreateToggle({
   Name = "ESP Highlight / Box",
   CurrentValue = boxEspEnabled,
   Callback = function(Value) boxEspEnabled = Value end,
})

TabVisuals:CreateToggle({
   Name = "ESP Line / Tracer (Đường kẻ chân)",
   CurrentValue = tracerEspEnabled,
   Callback = function(Value) tracerEspEnabled = Value end,
})

-- MM2 UTILITY
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
       local gunPart = nil
       for _, obj in pairs(workspace:GetChildren()) do
           if obj:IsA("Tool") and (obj.Name == "GunDrop" or obj.Name:lower():find("gun")) then
               gunPart = obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
               break
           elseif obj:IsA("BasePart") and obj.Name == "GunDrop" then
               gunPart = obj
               break
           end
       end
       local char = player.Character
       local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
       if gunPart and root then
           root.CFrame = gunPart.CFrame + Vector3.new(0, 2, 0)
           Rayfield:Notify({ Title = "MM2 Teleport", Content = "Đã dịch chuyển tới vị trí súng!", Duration = 2 })
       else
           Rayfield:Notify({ Title = "MM2 Teleport", Content = "Hiện không có súng nào rơi trên map!", Duration = 2 })
       end
   end,
})

-- SYSTEM
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
-- CORE LOGIC & ESP SYSTEM
-- =====================================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.NumSides = 60
fovCircle.Visible = false

-- LƯU TRỮ VẼ ESP TRACER
local tracers = {}

local function getRoleColor(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return colorInnocent end
    local char = targetPlayer.Character
    local backpack = targetPlayer:FindFirstChild("Backpack")
    
    local hasKnife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    
    if hasKnife then return colorMurderer end
    if hasGun then return colorSheriff end
    return colorInnocent
end

-- QUẢN LÝ DỌN DẸP SYSTEM
_G.PhuocThoCleanUp = function()
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    for _, tracer in pairs(tracers) do
        pcall(function() tracer:Remove() end)
    end
    tracers = {}
    
    -- Restored Hitboxes
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = defaultHitboxSize
            v.Character.HumanoidRootPart.Transparency = 1
        end
    end
end

-- ANTI-AFK & JUMP CONNECTION
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

-- VÒNG LẶP RENDER (PRE-RENDER)
RunService.PreRender:Connect(function(deltaTime)
    local mousePos = UserInputService:GetMouseLocation()

    -- 1. FOV Circle Update
    if fovCircle then
        fovCircle.Position = mousePos
        fovCircle.Radius = fovRadius
        fovCircle.Visible = silentAimEnabled or aimlockEnabled
    end

    local myChar = player.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    
    -- 2. Movement Logic
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

    -- 3. Aimlock (Nhấn giữ phím E)
    if aimlockEnabled and UserInputService:IsKeyDown(Enum.KeyCode.E) then
        local targetHead = getClosestHeadToMouse()
        if targetHead then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetHead.Position), aimSmoothness)
        end
    end

    -- 4. Hitbox Extender & ESP Processing Loop
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local tChar = targetPlayer.Character
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChildOfClass("Humanoid")
            
            if tRoot and tHum and tHum.Health > 0 then
                -- Hitbox logic
                if hitboxEnabled then
                    tRoot.Size = Vector3.new(hitboxSizeValue, hitboxSizeValue, hitboxSizeValue)
                    tRoot.Transparency = 0.7
                    tRoot.CanCollide = false
                else
                    tRoot.Size = defaultHitboxSize
                    tRoot.Transparency = 1
                end

                -- Highlight / Box ESP Logic
                local highlight = tChar:FindFirstChild("PhuocThoHighlight")
                if boxEspEnabled or mm2RoleEspEnabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "PhuocThoHighlight"
                        highlight.Parent = tChar
                    end
                    highlight.Enabled = true
                    highlight.FillColor = mm2RoleEspEnabled and getRoleColor(targetPlayer) or Color3.fromRGB(255, 255, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                elseif highlight then
                    highlight.Enabled = false
                end

                -- Tracer Line Logic
                if tracerEspEnabled then
                    if not tracers[targetPlayer] then
                        tracers[targetPlayer] = Drawing.new("Line")
                        tracers[targetPlayer].Thickness = 1.5
                        tracers[targetPlayer].Transparency = 0.8
                    end
                    
                    local line = tracers[targetPlayer]
                    local screenPos, onScreen = camera:WorldToViewportPoint(tRoot.Position)
                    if onScreen then
                        line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        line.To = Vector2.new(screenPos.X, screenPos.Y)
                        line.Color = mm2RoleEspEnabled and getRoleColor(targetPlayer) or Color3.fromRGB(255, 255, 255)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                elseif tracers[targetPlayer] then
                    tracers[targetPlayer].Visible = false
                end
            end
        end
    end
end)
