local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))() 
local Window = Rayfield:CreateWindow({ 
Name = "Project P58", 
LoadingTitle = "", 
LoadingSubtitle = "", 
ConfigurationSaving = { 
Enabled = true, 
FolderName = "RayfieldConfig", 
FileName = "ProjectP58Config" 
}, 
Discord = { 
Enabled = true, 
Invite = "https://discord.gg/3cMRMVgffD", 
RememberJoins = true 
}, 
KeySystem = true, 
KeySettings = { 
Title = "Project P58 Key system", 
Subtitle = "Key System", 
Note = "Join https://discord.gg/3cMRMVgffD for the key", 
FileName = "Key", 
SaveKey = true, 
GrabKeyFromSite = false, 
Key = {"P58ADMIN", "K2A9P7F3ML"} 
} 
}) 
local MainTab = Window:CreateTab("Main", 4483362458) 
local TeleportsTab = Window:CreateTab("Teleports", 4483362458) 
local MiscTab = Window:CreateTab("Misc", 4483362458) 
local FarmsTab = Window:CreateTab("Farms", 4483362458) 
local QuickBuyTab = Window:CreateTab("Quick Buy", 4483362458)
local Players = cloneref(game:GetService("Players")) 
local RunService = cloneref(game:GetService("RunService")) 
local UserInputService = cloneref(game:GetService("UserInputService")) 
local Lighting = cloneref(game:GetService("Lighting")) 
local Workspace = cloneref(game:GetService("Workspace")) 
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")) 
local LocalPlayer = Players.LocalPlayer 
-- Movement variables 
local movementEnabled = false 
local currentWalkSpeed = 16 
local fastFallSpeed = -50 
local moveConnection = nil 
local DeathFrame = nil 
local ModFlags = { 
InfiniteHunger = false, 
InfiniteStamina = false, 
InfiniteSleep = false, 
DisableCameraBobbing = false, 
DisableBloodEffects = false, 
NoFallDamage = false, 
NoJumpCooldown = false, 
NoRentPay = false, 
DisableCameras = false, 
NoKnockback = false, 
RespawnWhereYouDied = false, 
InfiniteJump = false, 
InstantInteraction = false, 
} 
-- Dupe variables 
local running = false 
local Character, Backpack 
local function updateCharacter() 
Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
Backpack = LocalPlayer:WaitForChild("Backpack") 
end 
updateCharacter() 
LocalPlayer.CharacterAdded:Connect(function() 
updateCharacter() 
end) 
local function getPing() 
local total = 0 
local samples = 5 
for i = 1, samples do 
local t0 = tick() 
local temp = Instance.new("BoolValue") 
temp.Parent = ReplicatedStorage 
temp.Name = "PingTest_" .. tostring(math.random(10000, 99999)) 
task.wait(0.1) 
local t1 = tick() 
temp:Destroy() 
total = total + (t1 - t0) * 1000 
end 
return math.clamp(total / samples, 50, 300) 
end 
local function countGuns(toolName) 
local count = 0 
for _, item in ipairs(Backpack:GetChildren()) do 
if item.Name == toolName then count = count + 1 end 
end 
if Character then 
for _, item in ipairs(Character:GetChildren()) do 
if item:IsA("Tool") and item.Name == toolName then count = count + 1 end 
end 
end 
return count 
end 
local function dupeOne(desiredDupes) 
desiredDupes = desiredDupes or 1 
local Tool = Character:FindFirstChildOfClass("Tool") or Backpack:FindFirstChildOfClass("Tool") 
if not Tool then Rayfield:Notify({Title="Dupe Error",Content="Equip a gun first!",Duration=4}) return false end 
Tool.Parent = Backpack 
task.wait(0.3) 
local ToolName = Tool.Name 
local initialCount = countGuns(ToolName) 
local ping = getPing() 
local baseDelay = 0.2 + (ping / 300) * 0.05 
local maxRetries = 3 
local success = false 
for attempt = 1, maxRetries do 
local ToolIds = {} 
local conn; conn = ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item) 
if item.Name == ToolName then 
local owner = item:WaitForChild("owner", 2) 
if owner and owner.Value == LocalPlayer.Name then 
table.insert(ToolIds, item:GetAttribute("SpecialId")) 
end 
end 
end) 
for i = 1, desiredDupes + 1 do 
task.spawn(function() ReplicatedStorage.ListWeaponRemote:FireServer(ToolName, 99999) end) 
task.wait(0.05 + (ping / 1000)) 
end 
task.wait(baseDelay) 
task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Store", ToolName) end) 
task.wait(2 + (ping / 200)) 
task.wait(1) 
conn:Disconnect() 
for _, id in ipairs(ToolIds) do 
task.spawn(function() ReplicatedStorage.BuyItemRemote:FireServer(ToolName, "Remove", id) end) 
task.wait(0.1) 
end 
for i = 1, #ToolIds do 
task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Grab", ToolName) end) 
task.wait(0.15 + (ping / 500)) 
end 
task.wait(1.5) 
local newCount = countGuns(ToolName) 
if newCount > initialCount then 
success = true 
Rayfield:Notify({ Title = "Dupe Success", Content = "Duplicated " .. (newCount - initialCount) .. " gun(s) — check your backpack", Duration = 4, Image = 4483362458 }) 
break 
else 
Rayfield:Notify({ Title = "Dupe Retry", Content = "Attempt " .. attempt .. " failed, retrying...", Duration = 2 }) 
task.wait(1) 
end 
end 
return success 
end 
task.spawn(function() 
while true do 
if running then 
dupeOne(2) 
task.wait(2 + math.random(0.5, 1.5)) 
else 
task.wait(0.1) 
end 
end 
end) 
local function FadeIn(duration) end 
local function FadeOut(duration) end 
local function teleportTo(cf) 
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
local hrp = char:WaitForChild("HumanoidRootPart") 
local hum = char:WaitForChild("Humanoid") 
hum:ChangeState(0) 
repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos") 
hrp.Anchored = true 
hrp.CFrame = cf 
hrp.AssemblyLinearVelocity = Vector3.zero 
hrp.AssemblyAngularVelocity = Vector3.zero 
task.defer(function() 
hrp.Anchored = false 
hrp.AssemblyLinearVelocity = Vector3.zero 
hrp.AssemblyAngularVelocity = Vector3.zero 
hum:ChangeState(2) 
end) 
end 
local function getHumanoid() 
local char = LocalPlayer.Character 
return char and char:FindFirstChildOfClass("Humanoid") 
end 
local function isGrounded(hrp) 
local rayOrigin = hrp.Position 
local rayDirection = Vector3.new(0, -5, 0) 
local raycastParams = RaycastParams.new() 
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist 
raycastParams.FilterDescendantsInstances = {LocalPlayer.Character} 
local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams) 
return raycastResult ~= nil 
end 
local function keepUpright() 
local char = LocalPlayer.Character 
if char and char:FindFirstChild("HumanoidRootPart") then 
local hrp = char.HumanoidRootPart 
hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)) 
end 
end 
local function teleportForward(distance) 
local char = LocalPlayer.Character 
if not char then return end 
local hrp = char:FindFirstChild("HumanoidRootPart") 
local humanoid = char:FindFirstChildOfClass("Humanoid") 
if not hrp or not humanoid then return end 
humanoid:ChangeState(0) 
repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos") 
local origin = hrp.Position 
local direction = hrp.CFrame.LookVector * distance 
local rayParams = RaycastParams.new() 
rayParams.FilterDescendantsInstances = {char} 
rayParams.FilterType = Enum.RaycastFilterType.Blacklist 
local raycastResult = Workspace:Raycast(origin, direction, rayParams) 
local teleportPos = raycastResult and (raycastResult.Position - hrp.CFrame.LookVector * 2) or (origin + direction) 
if not isGrounded(hrp) then 
hrp.Velocity = Vector3.new(hrp.Velocity.X, fastFallSpeed, hrp.Velocity.Z) 
else 
hrp.Velocity = Vector3.zero 
end 
hrp.CFrame = CFrame.new(teleportPos, teleportPos + hrp.CFrame.LookVector) 
keepUpright() 
end 
local function startWalkLoop() 
if moveConnection then moveConnection:Disconnect() end 
moveConnection = RunService.Heartbeat:Connect(function(dt) 
if movementEnabled then 
local humanoid = getHumanoid() 
if humanoid then 
keepUpright() 
if humanoid.MoveDirection.Magnitude > 0 then 
teleportForward(currentWalkSpeed * dt) 
else 
local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
if hrp and not isGrounded(hrp) then 
hrp.Velocity = Vector3.new(hrp.Velocity.X, fastFallSpeed, hrp.Velocity.Z) 
end 
end 
end 
end 
end) 
end 
-- Classic NoClip 
local NoclipConnection = nil 
local Clip = true 
local function noclip() 
Clip = false 
local function Nocl() 
if not Clip and LocalPlayer.Character then 
for _, v in pairs(LocalPlayer.Character:GetDescendants()) do 
if v:IsA("BasePart") and v.CanCollide then 
v.CanCollide = false 
end 
end 
end 
end 
if NoclipConnection then NoclipConnection:Disconnect() end 
NoclipConnection = RunService.Stepped:Connect(Nocl) 
end 
local function clip() 
if NoclipConnection then 
NoclipConnection:Disconnect() 
NoclipConnection = nil 
end 
Clip = true 
end 
-- ─────────────────────────────────────────────── 
-- Main Tab - Exotic Shop 
-- ─────────────────────────────────────────────── 
MainTab:CreateSection("Exotic Shop") 
MainTab:CreateButton({ 
Name = 'Buy All Ingredients', 
Callback = function() 
local remote = ReplicatedStorage:WaitForChild("ExoticShopRemote") 
pcall(function() 
remote:InvokeServer("Ice-Fruit Bag") 
remote:InvokeServer("Ice-Fruit Cupz") 
remote:InvokeServer("FijiWater") 
remote:InvokeServer("FreshWater") 
end) 
Rayfield:Notify({ 
Title = "Project P58", 
Content = "Bought all ingredients.", 
Duration = 3, 
Image = 4483362458, 
}) 
end, 
}) 
MainTab:CreateButton({ 
Name = "Teleport to Penthouse", 
Callback = function() 
teleportTo(CFrame.new(-181.86 + 2, 397.14, -587.99)) 
Rayfield:Notify({Title="Teleport", Content="Moved to Penthouse", Duration=2.5}) 
end, 
}) 
MainTab:CreateButton({ 
Name = "Teleport to Sell Juice", 
Callback = function() 
teleportTo(CFrame.new(-71.63, 287.06, -319.95)) 
Rayfield:Notify({Title="Teleport", Content="Moved to Sell Juice", Duration=2.5}) 
end, 
}) 
MainTab:CreateSection("Money Dupe") 
MainTab:CreateButton({ 
Name = 'Dupe', 
Callback = function() 
local IceFruitSellPart = Workspace:FindFirstChild("IceFruit Sell") 
if not IceFruitSellPart then Rayfield:Notify({Title="Error", Content="IceFruit Sell part not found.", Duration=3}) return end 
local prompt = IceFruitSellPart:FindFirstChildOfClass("ProximityPrompt") 
if not prompt then Rayfield:Notify({Title="Error", Content="ProximityPrompt not found.", Duration=3}) return end 
Rayfield:Notify({Title="Dupe", Content="Starting Cupz Money Method... (5000 attempts)", Duration=5}) 
for i = 1, 5000 do 
task.spawn(function() 
prompt:InputHoldBegin() 
prompt:InputHoldEnd() 
end) 
end 
Rayfield:Notify({Title="Dupe", Content="Cupz Money Method completed! Check your cash.", Duration=4}) 
end, 
}) 
MainTab:CreateSection("Gun Dupe") 
MainTab:CreateButton({ 
Name = 'Dupe Gun (Single)', 
Callback = function() 
dupeOne() 
end, 
}) 
MainTab:CreateToggle({ 
Name = 'Auto Dupe Gun', 
CurrentValue = false, 
Flag = "AutoDupeGunToggle", 
Callback = function(Value) 
running = Value 
Rayfield:Notify({ 
Title = Value and "Auto Dupe Started" or "Auto Dupe Stopped", 
Content = Value and "Equip gun & wait..." or "Stopped", 
Duration = 3.5, 
Image = 4483362458 
}) 
end, 
}) 
-- ─────────────────────────────────────────────── 
-- Teleports Tab 
-- ─────────────────────────────────────────────── 
TeleportsTab:CreateSection("Locations") 
TeleportsTab:CreateButton({ 
Name = "🏦 Bank", 
Callback = function() 
teleportTo(CFrame.new(-225.791, 283.810, -1215.357, -0.999, 0, -0.048, 0, 1, 0, 0.048, 0, -0.999)) 
Rayfield:Notify({Title="Teleported", Content="🏦 Bank", Duration=2.5}) 
end, 
}) 
TeleportsTab:CreateButton({ 
Name = "🚗Dealership", 
Callback = function() 
teleportTo(CFrame.new(-374.002, 253.280, -1233.570,0.089, 0.000, 0.996,0.000, 1.000, -0.000,-0.996, 0.000, 0.089)) 
Rayfield:Notify({Title="Teleported", Content="🚗Dealership", Duration=2.5}) 
end, 
}) 
TeleportsTab:CreateButton({ 
Name = "💰Market", 
Callback = function() 
teleportTo(CFrame.new(-375.529, 334.314, -553.617,0.075, 0.000, 0.997,0.000, 1.000, -0.000,-0.997, 0.000, 0.075)) 
Rayfield:Notify({Title="Teleported", Content="💰Market", Duration=2.5}) 
end, 
}) 
TeleportsTab:CreateButton({ 
Name = "🏢Apartment", 
Callback = function() 
teleportTo(CFrame.new(-605.746, 356.494, -692.597,-0.160, 0.000, -0.987,0.000, 1.000, 0.000,0.987, -0.000, -0.160)) 
Rayfield:Notify({Title="Teleported", Content="🏢Apartment", Duration=2.5}) 
end, 
}) 
TeleportsTab:CreateButton({ 
Name = "🔫Gunstore 1", 
Callback = function() 
teleportTo(CFrame.new(-1019.643, 253.815, -792.597,0.029, 0.000, -1.000,-0.000, 1.000, 0.000,1.000, 0.000, 0.029)) 
Rayfield:Notify({Title="Teleported", Content="🔫Gunstore 1", Duration=2.5}) 
end, 
}) 
TeleportsTab:CreateButton({ 
Name = "🔫Gunstore 2", 
Callback = function() 
teleportTo(CFrame.new(-221.934, 283.803, -792.848,1.000, -0.000, 0.004,0.000, 1.000, 0.000,-0.004, -0.000, 1.000)) 
Rayfield:Notify({Title="Teleported", Content="🔫Gunstore 2", Duration=2.5}) 
end, 
}) 
TeleportsTab:CreateButton({ 
Name = "🗝️Safe", 
Callback = function() 
teleportTo(CFrame.new(68516.609, 52941.688, -691.030,-1.000, -0.000, -0.006,-0.000, 1.000, -0.000,0.006, -0.000, -1.000)) 
Rayfield:Notify({Title="Teleported", Content="🗝️Safe", Duration=2.5}) 
end, 
}) 
-- ─────────────────────────────────────────────── 
-- Misc Tab 
-- ─────────────────────────────────────────────── 
local MiscBox = MiscTab:CreateSection("Misc") 
MiscTab:CreateToggle({ 
Name = "No Clip", 
CurrentValue = false, 
Callback = function(Value) 
if Value then noclip() else clip() end 
end 
}) 
MiscTab:CreateToggle({ 
Name = "Infinite Stamina", 
CurrentValue = false, 
Flag = "InfiniteStamina", 
Callback = function(v) ModFlags.InfiniteStamina = v end 
}) 
MiscTab:CreateToggle({ 
Name = "Infinite Hunger", 
CurrentValue = false, 
Flag = "InfiniteHunger", 
Callback = function(v) ModFlags.InfiniteHunger = v end 
}) 
MiscTab:CreateToggle({ 
Name = "Infinite Sleep", 
CurrentValue = false, 
Flag = "InfiniteSleep", 
Callback = function(v) ModFlags.InfiniteSleep = v end 
}) 
MiscTab:CreateToggle({ 
Name = "Instant Interaction", 
CurrentValue = false, 
Flag = "InstantInteraction", 
Callback = function(Value) 
ModFlags.InstantInteraction = Value 
if Value then 
for _, v in ipairs(workspace:GetDescendants()) do 
if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end 
end 
workspace.DescendantAdded:Connect(function(v) 
if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end 
end) 
end 
end}) 
MiscTab:CreateToggle({ 
Name = "Disable Camera Bobbing", 
CurrentValue = false, 
Flag = "DisableCameraBobbing", 
Callback = function(v) ModFlags.DisableCameraBobbing = v end 
}) 
MiscTab:CreateToggle({ 
Name = "Disable Blood Effects", 
CurrentValue = false, 
Flag = "DisableBloodEffects", 
Callback = function(v) ModFlags.DisableBloodEffects = v end 
}) 
MiscTab:CreateToggle({ 
Name = "No Fall Damage", 
CurrentValue = false, 
Flag = "NoFallDamage", 
Callback = function(v) ModFlags.NoFallDamage = v end 
}) 
MiscTab:CreateToggle({ 
Name = "No Jump Cooldown", 
CurrentValue = false, 
Flag = "NoJumpCooldown", 
Callback = function(v) ModFlags.NoJumpCooldown = v end 
}) 
MiscTab:CreateToggle({ 
Name = "No Rent Pay", 
CurrentValue = false, 
Flag = "NoRentPay", 
Callback = function(v) ModFlags.NoRentPay = v end 
}) 
MiscTab:CreateToggle({ 
Name = "Disable Cameras", 
CurrentValue = false, 
Flag = "DisableCameras", 
Callback = function(v) ModFlags.DisableCameras = v end 
}) 
MiscTab:CreateToggle({ 
Name = "No Knockback", 
CurrentValue = false, 
Flag = "NoKnockback", 
Callback = function(v) ModFlags.NoKnockback = v end 
}) 
MiscTab:CreateToggle({ 
Name = "Respawn Where You Died", 
CurrentValue = false, 
Flag = "RespawnWhereYouDied", 
Callback = function(v) ModFlags.RespawnWhereYouDied = v end 
}) 
MiscTab:CreateToggle({ 
Name = "Infinite Jump", 
CurrentValue = false, 
Flag = "InfiniteJump", 
Callback = function(v) ModFlags.InfiniteJump = v end 
}) 
MiscTab:CreateSlider({ 
Name = "Walk Speed", 
Range = {16, 500}, 
Increment = 1, 
CurrentValue = 16, 
Flag = "WalkSpeed", 
Callback = function(Value) 
currentWalkSpeed = Value 
end, 
}) 
MiscTab:CreateToggle({ 
Name = "Movement Speed", 
CurrentValue = false, 
Flag = "MovementSpeed", 
Callback = function(Value) 
movementEnabled = Value 
if Value then 
startWalkLoop() 
else 
if moveConnection then moveConnection:Disconnect() moveConnection = nil end 
end 
end, 
}) 
-- ─────────────────────────────────────────────── 
-- Farms Tab 
-- ─────────────────────────────────────────────── 
local FarmsBox = FarmsTab:CreateSection("Auto Farms") 
FarmsTab:CreateButton({ 
Name = 'Studio Farm', 
Callback = function() 
FadeIn(0.3) 
local RunService = game:GetService('RunService') 
local Players = game:GetService('Players') 
local LocalPlayer = Players.LocalPlayer 
local function updateCharacterReferences() 
local playerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
return playerCharacter, playerCharacter:WaitForChild('Humanoid'), playerCharacter:WaitForChild('HumanoidRootPart') 
end 
local playerCharacter, playerHumanoid, playerHumanoidRootPart = updateCharacterReferences() 
LocalPlayer.CharacterAdded:Connect(function() 
playerCharacter, playerHumanoid, playerHumanoidRootPart = updateCharacterReferences() 
end) 
local FreeFallLoop 
local function UpdateFreeFall(state) 
if state then 
if not FreeFallLoop then 
FreeFallLoop = RunService.Heartbeat:Connect(function() 
if playerHumanoid then 
playerHumanoid:ChangeState(Enum.HumanoidStateType.FallingDown) 
end 
end) 
end 
else 
if FreeFallLoop then 
FreeFallLoop:Disconnect() 
FreeFallLoop = nil 
end 
if playerHumanoid then 
playerHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp) 
end 
end 
end 
local function teleportTo(cframe) 
if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then 
LocalPlayer.Character.HumanoidRootPart.CFrame = cframe 
end 
end 
local function robStudio(studioPay) 
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
local rootPart = character:FindFirstChild('HumanoidRootPart') 
if not rootPart then return end 
local OldCFrameStudio = rootPart.CFrame 
local studioPath = workspace.StudioPay.Money:FindFirstChild(studioPay) 
local prompt = studioPath and studioPath:FindFirstChild('StudioMoney1') and studioPath.StudioMoney1:FindFirstChild('Prompt') 
if prompt then 
teleportTo(prompt.Parent.CFrame + Vector3.new(0, 2, 0)) 
task.wait(0.1) 
prompt.HoldDuration = 0 
prompt.RequiresLineOfSight = false 
pcall(function() fireproximityprompt(prompt, 0) end) 
end 
task.wait(0.5) 
teleportTo(OldCFrameStudio) 
end 
UpdateFreeFall(true) 
task.wait(2) 
for _, pay in ipairs({'StudioPay1', 'StudioPay2', 'StudioPay3'}) do 
robStudio(pay) 
end 
task.wait(1) 
UpdateFreeFall(false) 
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
local rootPart = character:FindFirstChild('HumanoidRootPart') 
if rootPart then teleportTo(rootPart.CFrame) end 
FadeOut(0.4) 
end, 
}) 
-- ─────────────────────────────────────────────── 
-- Quick Buy Tab 
-- ─────────────────────────────────────────────── 
-- ─────────────────────────────────────────────── 
-- Quick Buy Tab 
-- ─────────────────────────────────────────────── 
QuickBuyTab:CreateSection("Quick Buy - Regular Shop")

QuickBuyTab:CreateButton({
    Name = "Buy Shiesty",
    Callback = function()
        ReplicatedStorage.ShopRemote:InvokeServer('Shiesty')
        Rayfield:Notify({
            Title = "Quick Buy",
            Content = "Attempted to buy: Shiesty",
            Duration = 2.5
        })
    end,
})

QuickBuyTab:CreateButton({
    Name = "Buy BluGloves",
    Callback = function()
        ReplicatedStorage.ShopRemote:InvokeServer('BluGloves')
    end,
})

QuickBuyTab:CreateButton({
    Name = "Buy WhiteGloves",
    Callback = function()
        ReplicatedStorage.ShopRemote:InvokeServer('WhiteGloves')
    end,
})

QuickBuyTab:CreateButton({
    Name = "Buy BlackGloves",
    Callback = function()
        ReplicatedStorage.ShopRemote:InvokeServer('BlackGloves')
    end,
})

QuickBuyTab:CreateButton({
    Name = "Buy Bandage",
    Callback = function()
        ReplicatedStorage.ShopRemote2:InvokeServer('Bandage')
    end,
})

QuickBuyTab:CreateSection("Quick Buy - Exotic Dealer")

QuickBuyTab:CreateButton({
    Name = "Buy Lemonade",
    Callback = function()
        ReplicatedStorage.ExoticShopRemote:InvokeServer('Lemonade')
    end,
})


-- ─────────────────────────────────────────────── 
-- Main Loops & Events 
-- ─────────────────────────────────────────────── 
RunService.RenderStepped:Connect(function() 
local gui = LocalPlayer:FindFirstChild("PlayerGui") 
local char = LocalPlayer.Character 
if gui then 
local hungerGui = gui:FindFirstChild("Hunger", true) 
if hungerGui then 
local hungerScript = hungerGui:FindFirstChild("HungerBarScript", true) 
if hungerScript then hungerScript.Disabled = ModFlags.InfiniteHunger end 
end 
local runGui = gui:FindFirstChild("Run", true) 
if runGui then 
local staminaScript = runGui:FindFirstChild("StaminaBarScript", true) 
if staminaScript then staminaScript.Disabled = ModFlags.InfiniteStamina end 
end 
local sleepGui = gui:FindFirstChild("SleepGui", true) 
if sleepGui then 
local sleepScript = sleepGui:FindFirstChild("sleepScript", true) 
if sleepScript then sleepScript.Disabled = ModFlags.InfiniteSleep end 
end 
local bloodGui = gui:FindFirstChild("BloodGui") 
if bloodGui then 
bloodGui.Enabled = not ModFlags.DisableBloodEffects 
end 
local jumpDebounce = gui:FindFirstChild("JumpDebounce") 
if jumpDebounce and jumpDebounce:FindFirstChild("LocalScript") then 
jumpDebounce.LocalScript.Disabled = ModFlags.NoJumpCooldown 
end 
local rentGui = gui:FindFirstChild("RentGui") 
if rentGui and rentGui:FindFirstChild("LocalScript") then 
rentGui.LocalScript.Disabled = ModFlags.NoRentPay 
end 
local camTexts = gui:FindFirstChild("CameraTexts") 
if camTexts and camTexts:FindFirstChild("LocalScript") then 
camTexts.Enabled = not ModFlags.DisableCameras 
camTexts.LocalScript.Disabled = ModFlags.DisableCameras 
end 
end 
if char then 
local camBob = char:FindFirstChild("CameraBobbing") 
if camBob then camBob.Disabled = ModFlags.DisableCameraBobbing end 
local fallDamage = char:FindFirstChild("FallDamageRagdoll") 
if fallDamage then fallDamage.Disabled = ModFlags.NoFallDamage end 
end 
end) 
UserInputService.InputBegan:Connect(function(input, gp) 
if gp then return end 
if not ModFlags.InfiniteJump then return end 
if input.KeyCode == Enum.KeyCode.Space then 
local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") 
if hum and hum.Health > 0 then 
hum:ChangeState(Enum.HumanoidStateType.Jumping) 
end 
end 
end) 
local function SetupCharacterEvents(char) 
local hum = char:WaitForChild("Humanoid") 
local root = char:WaitForChild("HumanoidRootPart") 
hum.Died:Connect(function() DeathFrame = root.CFrame end) 
char.DescendantAdded:Connect(function(desc) 
if (desc:IsA("BodyVelocity") or desc:IsA("LinearVelocity") or desc:IsA("VectorForce")) and ModFlags.NoKnockback then 
task.wait() desc:Destroy() 
end 
end) 
if ModFlags.RespawnWhereYouDied and typeof(DeathFrame) == "CFrame" then 
root.CFrame = DeathFrame 
end 
end 
local function onCharacterAdded(char) 
SetupCharacterEvents(char) 
end 
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end 
LocalPlayer.CharacterAdded:Connect(onCharacterAdded) 
LocalPlayer.CharacterAdded:Connect(function() 
if ModFlags.DisableCameras and Lighting:FindFirstChild("Shiesty") then 
local remote = Lighting.Shiesty:FindFirstChildWhichIsA("RemoteEvent", true) 
if remote then remote:FireServer() end 
end 
end) 
