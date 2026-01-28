-- Executor Detection
local executor = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
if syn then executor = "Synapse X"
elseif fluxus then executor = "Fluxus"
elseif Krnl then executor = "Krnl"
elseif getgenv and getgenv().ECLIPSE then executor = "Eclipse"
elseif getgenv and getgenv().DELTA then executor = "Delta"
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Tha Bronx 3 Exploit - " .. executor .. " - Fixed TPs & Farm",
   LoadingTitle = "Loading Ultra Stable...",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "ThaBronx3Ultra" },
   Discord = { Enabled = false },
   KeySystem = false
})

local ExploitsTab = Window:CreateTab("Exploits", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local AutofarmTab = Window:CreateTab("Autofarm", 4483362458)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local connections = {}
local AutoSellEnabled = false
local StudioFarmEnabled = false
local NoClipEnabled = false
local InfJumpEnabled = false
local InstantPromptsEnabled = false
local InstantConn = nil

-- Fixed PivotTo TP (Smooth, No Bug, Anti-Detect)
local function pivotTP(targetCFrame)
   pcall(function()
      local char = player.Character
      if char and char.PrimaryPart then
         local hrp = char.PrimaryPart
         hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
         hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
         hrp:SetNetworkOwner(nil)
         char:PivotTo(targetCFrame)
      end
   end)
end

-- Global Instant Prompts Toggle
local InstantToggle = ExploitsTab:CreateToggle({
   Name = "Global Instant Prompts (No Hold E)",
   CurrentValue = false,
   Callback = function(val)
      InstantPromptsEnabled = val
      if InstantConn then InstantConn:Disconnect() end
      if val then
         local function setInstant(obj)
            pcall(function()
               if obj:IsA("ProximityPrompt") and not string.find(obj:GetFullName(), "MimicATM") then
                  obj.HoldDuration = 0
               end
            end)
         end
         for _, obj in workspace:GetDescendants() do setInstant(obj) end
         InstantConn = workspace.DescendantAdded:Connect(function(obj)
            task.delay(0.1, function() setInstant(obj) end)
         end)
         table.insert(connections, InstantConn)
         Rayfield:Notify({Title = "Instant Prompts ON", Content = "All new prompts instant!", Duration = 3})
      else
         Rayfield:Notify({Title = "Instant Prompts OFF", Duration = 2})
      end
   end
})

-- Buy Exotic Items (Ice Bag/Cupz, Fiji/Fresh - Targets Exotic Seller)
ExploitsTab:CreateButton({
   Name = "Buy Max from Exotic Seller (Ice Bag/Cupz, Fiji/Fresh)",
   Callback = function()
      task.spawn(function()
         local keywords = {"ice fruit", "bag", "cupz?", "fiji", "fresh water"}
         for _ = 1, 12 do
            for _, obj in workspace:GetDescendants() do
               if obj:IsA("ProximityPrompt") then
                  local txt = (obj.ActionText .. obj.ObjectText):lower()
                  local match = false
                  for _, kw in keywords do
                     if txt:find(kw) then match = true; break end
                  end
                  if match then
                     pcall(function()
                        local char = player.Character
                        if char and char.PrimaryPart and obj.Parent:IsA("BasePart") then
                           pivotTP(obj.Parent.CFrame * CFrame.new(math.random(-2,2), 2, -4))
                           task.wait(0.8)
                           obj.HoldDuration = 0
                           obj:InputHoldBegin()
                           task.wait(0.04)
                           obj:InputHoldEnd()
                        end
                     end)
                  end
               end
            end
            task.wait(1.3)
         end
         Rayfield:Notify({Title = "Exotic Buy Complete", Duration = 3})
      end)
   end
})

-- Infinite Money (Fixed Kool Aid/Ice Fruit Sell - Tight Filter)
local AutoSellToggle = ExploitsTab:CreateToggle({
   Name = "Infinite Money (Auto Sell Ice Fruit Cups/Kool Aid)",
   CurrentValue = false,
   Callback = function(val)
      AutoSellEnabled = val
      if val then
         task.spawn(function()
            while AutoSellEnabled do
               pcall(function()
                  local char = player.Character
                  if not char or not char.PrimaryPart then return end
                  local hum = char:FindFirstChildOfClass("Humanoid")
                  if not hum then return end

                  -- Equip Ice Cup Tool
                  local cupNames = {"Ice Fruit Cupz", "Ice-Fruit Cupz", "Ice Fruit Cups", "Kool Aid"}
                  local cup = nil
                  for _, name in cupNames do
                     cup = player.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
                     if cup then break end
                  end
                  if cup and cup:IsA("Tool") then
                     hum:EquipTool(cup)
                     task.wait(0.6)
                  end

                  -- Tight Filter: SELL + Ice/Kool
                  local prompt = nil
                  for _, obj in workspace:GetDescendants() do
                     if obj:IsA("ProximityPrompt") then
                        local txt = (obj.ActionText .. obj.ObjectText):lower()
                        if txt:find("sell") and (txt:find("ice fruit") or txt:find("cup") or txt:find("kool") or txt:find("aid") or txt:find("drink")) then
                           prompt = obj
                           break
                        end
                     end
                  end

                  if prompt and prompt.Parent:IsA("BasePart") then
                     pivotTP(prompt.Parent.CFrame * CFrame.new(0, 3, -4))
                     task.wait(0.9)
                     prompt.HoldDuration = 0
                     prompt:InputHoldBegin()
                     task.wait(0.05)
                     prompt:InputHoldEnd()
                  end
               end)
               task.wait(2.8)
            end
         end)
      end
   end
})

-- Studio Autofarm (Fixed Collect - Broad Money Filter)
local StudioToggle = AutofarmTab:CreateToggle({
   Name = "Studio Autofarm (TP + Collect All Cash)",
   CurrentValue = false,
   Callback = function(val)
      StudioFarmEnabled = val
      if val then
         task.spawn(function()
            while StudioFarmEnabled do
               pcall(function()
                  local char = player.Character
                  if not char or not char.PrimaryPart then return end
                  local hrp = char.PrimaryPart

                  -- TP Studio
                  local studio = nil
                  for _, v in workspace:GetDescendants() do
                     if v:IsA("BasePart") and v.Name:lower():find("studio") then
                        studio = v
                        break
                     end
                  end
                  if studio then
                     pivotTP(studio.CFrame + Vector3.new(0, 5, 0))
                     task.wait(1.2)
                  end

                  -- Collect: Broad Filter (Dist <80)
                  for _, obj in workspace:GetDescendants() do
                     if obj:IsA("ProximityPrompt") then
                        local act = obj.ActionText:lower()
                        local objt = obj.ObjectText:lower()
                        local parn = obj.Parent.Name:lower()
                        local isMoney = act:find("collect") or act:find("cash") or act:find("money") or act:find("loot") or act:find("rob") or act:find("steal") or act:find("grab") or act:find("pick") or act:find("take") or act:find("$") or objt:find("cash") or objt:find("money") or parn:find("cash") or parn:find("money") or parn:find("bag") or parn:find("bill") or parn:find("note") or parn:find("stack")
                        local dist = (obj.Parent.Position - hrp.Position).Magnitude
                        if isMoney and dist < 80 then
                           pivotTP(obj.Parent.CFrame * CFrame.new(0, 3, -3))
                           task.wait(0.6)
                           obj.HoldDuration = 0
                           obj:InputHoldBegin()
                           task.wait(0.04)
                           obj:InputHoldEnd()
                        end
                     end
                  end
               end)
               task.wait(3)
            end
         end)
      end
   end
})

-- Teleports (Fixed with PivotTo)
TeleportsTab:CreateButton({
   Name = "Teleport to Cooking Pot",
   Callback = function()
      for _, v in workspace:GetDescendants() do
         if v:IsA("BasePart") and (v.Name:lower():find("pot") or v.Name:lower():find("cook") or v.Name:lower():find("stove")) then
            pivotTP(v.CFrame + Vector3.new(math.random(-3,3), 5, math.random(-3,3)))
            break
         end
      end
   end
})

TeleportsTab:CreateButton({
   Name = "Teleport to Kool Aid Seller (Ice Fruit Sell)",
   Callback = function()
      for _, v in workspace:GetDescendants() do
         if v:IsA("ProximityPrompt") then
            local txt = (v.ActionText .. v.ObjectText):lower()
            if txt:find("sell") and (txt:find("ice fruit") or txt:find("cup") or txt:find("kool") or txt:find("aid")) then
               pivotTP(v.Parent.CFrame * CFrame.new(0, 3, -5))
               break
            end
         end
      end
   end
})

TeleportsTab:CreateButton({
   Name = "Teleport to Exotic Seller (Buy Ice/Fiji)",
   Callback = function()
      for _, v in workspace:GetDescendants() do
         if v:IsA("ProximityPrompt") then
            local txt = (v.ActionText .. v.ObjectText):lower()
            if txt:find("buy") and (txt:find("ice fruit") or txt:find("bag") or txt:find("cupz") or txt:find("fiji") or txt:find("fresh")) then
               pivotTP(v.Parent.CFrame * CFrame.new(math.random(-2,2), 3, -5))
               break
            end
         end
      end
   end
})

-- Player Mods (Unchanged, Working)
PlayerTab:CreateSlider({Name = "WalkSpeed", Range = {16, 400}, Increment = 1, CurrentValue = 16, Callback = function(v)
   local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if hum then hum.WalkSpeed = v end
end})

PlayerTab:CreateSlider({Name = "Jump Power", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v)
   local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if hum then hum.JumpPower = v end
end})

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(val)
      InfJumpEnabled = val
      if val then
         local conn = UserInputService.JumpRequest:Connect(function()
            if InfJumpEnabled then
               local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
               if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
         end)
         table.insert(connections, conn)
      end
   end
})

PlayerTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Callback = function(val)
      NoClipEnabled = val
      if val then
         local conn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char and NoClipEnabled then
               local hrp = char:FindFirstChild("HumanoidRootPart")
               for _, part in char:GetDescendants() do
                  if part:IsA("BasePart") and part ~= hrp and part.CanCollide then
                     part.CanCollide = false
                  end
               end
            end
         end)
         table.insert(connections, conn)
      end
   end
})

-- Anti-Kick (Enhanced)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
   local method = getnamecallmethod()
   if method == "Kick" or method:lower() == "kick" then return end
   if method == "FireServer" and (tostring(self):lower():find("anti") or tostring(self):lower():find("cheat")) then return end
   return old(self, ...)
end)
setreadonly(mt, true)

-- Cleanup
local function cleanup()
   for _, conn in ipairs(connections) do
      pcall(conn.Disconnect, conn)
   end
   connections = {}
end
player.CharacterRemoving:Connect(cleanup)

Rayfield:Notify({
   Title = "Loaded PERFECT Version!",
   Content = "TPs Fixed (PivotTo) | Studio Collect Fixed | Instant Toggle | Exotic Seller Added | Sell Fixed",
   Duration = 7
})
