local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)

if not success or not Rayfield then
    warn("Failed to load Rayfield UI: " .. tostring(Rayfield))
    return -- Stop script safely
end

local Window = Rayfield:CreateWindow({
   Name = "Trident Hub",
   LoadingTitle = "Loading Trident Hub...",
   LoadingSubtitle = "by Trident",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RayfieldConfig",
      FileName = "TridentConfig"
   },
   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/cn4NDA5nJS",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"
-- ... (everything else stays the same from here)

local MainTab = Window:CreateTab("Main", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local FarmsTab = Window:CreateTab("Farms", 4483362458)
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

local function getPing()
    local success, ping = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return success and math.clamp(ping, 30, 400) or 150
end

local function dupeOne()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then 
            Rayfield:Notify({Title="Dupe Failed",Content="No character loaded",Duration=3})
            return 
        end
        
        -- Find any tool (gun)
        local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if not tool then 
            Rayfield:Notify({Title="Dupe Error",Content="Equip a gun first!",Duration=4})
            return 
        end
        
        -- Equip if needed
        if tool.Parent == LocalPlayer.Backpack then
            tool.Parent = char
            task.wait(0.4)
        end
        
        local toolName = tool.Name
        local specialId = nil
        
        -- Catch the SpecialId when market item spawns
        local conn = game.ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item)
            if item.Name == toolName then
                local owner = item:FindFirstChild("owner")
                if owner and owner.Value == LocalPlayer.Name then
                    specialId = item:GetAttribute("SpecialId")
                end
            end
        end)
        
        -- Adaptive timing (works better on laggy servers)
        local pingAdjust = getPing() / 1000 * 1.2
        local delay = 0.28 + pingAdjust
        
        -- Step 1: Fake list weapon
        game.ReplicatedStorage.ListWeaponRemote:FireServer(toolName, 999999)
        task.wait(delay)
        
        -- Step 2: Store to backpack
        game.ReplicatedStorage.BackpackRemote:InvokeServer("Store", toolName)
        task.wait(delay + 0.15)
        
        -- Step 3: Remove from market if we captured ID
        if specialId then
            game.ReplicatedStorage.BuyItemRemote:FireServer(toolName, "Remove", specialId)
            task.wait(0.35)
        end
        
        -- Step 4: Grab duplicate back
        game.ReplicatedStorage.BackpackRemote:InvokeServer("Grab", toolName)
        
        conn:Disconnect()
        
        Rayfield:Notify({
            Title = "Dupe Success",
            Content = "Gun duplicated — check your backpack",
            Duration = 4,
            Image = 4483362458
        })
    end)
end

-- Auto dupe loop with slight randomization to avoid detection
task.spawn(function()
    while true do
        if running then
            dupeOne()
            task.wait(1.7 + math.random(2,8)/10)  -- 1.7–2.5s random delay
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
    hrp.Anchored = true
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    task.defer(function()
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
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
-- Main Tab - Buy Ingredients (removed label, kept button)
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
            Title = "Trident Hub",
            Content = "Bought all ingredients.",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})
-- Dupe Guns Section
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
})
MainTab:CreateToggle({
    Name = 'Auto Dupe Gun',
    CurrentValue = false,
    Flag = "AutoDupeGunToggle",
    Callback = function(Value)
        running = Value
    end,
})
-- Teleports Tab
TeleportsTab:CreateDropdown({
    Name = "Select Teleport",
    Options = {"🏦Bank", "🏠Penthouse", "🎙️Studio"},
    CurrentOption = {"🏦Bank"},
    MultipleOptions = false,
    Flag = "TeleportSelect",
    Callback = function(Option)
        if Option == "🏦Bank" then
            FadeIn(0.3)
            LocalPlayer.Character.Humanoid:ChangeState(0)
            repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-202.7586, 283.6267, -1222.1841)
            task.wait(2)
            FadeOut(0.4)
        elseif Option == "🏠Penthouse" then
            FadeIn(0.3)
            LocalPlayer.Character.Humanoid:ChangeState(0)
            repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-163, 397, -594)
            task.wait(2)
            FadeOut(0.4)
        elseif Option == "🎙️Studio" then
            FadeIn(0.3)
            LocalPlayer.Character.Humanoid:ChangeState(0)
            repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(93426.23 + 2, 14484.71, 561.80)
            task.wait(2)
            FadeOut(0.4)
        end
    end,
})
-- Misc Tab
local MiscBox = MiscTab:CreateSection("Misc")
MiscTab:CreateToggle({ Name = "Infinite Stamina", CurrentValue = false, Flag = "InfiniteStamina", Callback = function(v) ModFlags.InfiniteStamina = v end })
MiscTab:CreateToggle({ Name = "Infinite Hunger", CurrentValue = false, Flag = "InfiniteHunger", Callback = function(v) ModFlags.InfiniteHunger = v end })
MiscTab:CreateToggle({ Name = "Infinite Sleep", CurrentValue = false, Flag = "InfiniteSleep", Callback = function(v) ModFlags.InfiniteSleep = v end })
MiscTab:CreateToggle({ Name = "Instant Interaction", CurrentValue = false, Flag = "InstantInteraction", Callback = function(Value)
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
MiscTab:CreateToggle({ Name = "Disable Camera Bobbing", CurrentValue = false, Flag = "DisableCameraBobbing", Callback = function(v) ModFlags.DisableCameraBobbing = v end })
MiscTab:CreateToggle({ Name = "Disable Blood Effects", CurrentValue = false, Flag = "DisableBloodEffects", Callback = function(v) ModFlags.DisableBloodEffects = v end })
MiscTab:CreateToggle({ Name = "No Fall Damage", CurrentValue = false, Flag = "NoFallDamage", Callback = function(v) ModFlags.NoFallDamage = v end })
MiscTab:CreateToggle({ Name = "No Jump Cooldown", CurrentValue = false, Flag = "NoJumpCooldown", Callback = function(v) ModFlags.NoJumpCooldown = v end })
MiscTab:CreateToggle({ Name = "No Rent Pay", CurrentValue = false, Flag = "NoRentPay", Callback = function(v) ModFlags.NoRentPay = v end })
MiscTab:CreateToggle({ Name = "Disable Cameras", CurrentValue = false, Flag = "DisableCameras", Callback = function(v) ModFlags.DisableCameras = v end })
MiscTab:CreateToggle({ Name = "No Knockback", CurrentValue = false, Flag = "NoKnockback", Callback = function(v) ModFlags.NoKnockback = v end })
MiscTab:CreateToggle({ Name = "Respawn Where You Died", CurrentValue = false, Flag = "RespawnWhereYouDied", Callback = function(v) ModFlags.RespawnWhereYouDied = v end })
MiscTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "InfiniteJump", Callback = function(v) ModFlags.InfiniteJump = v end })
MiscTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value) currentWalkSpeed = Value end,
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
            if moveConnection then
                moveConnection:Disconnect()
                moveConnection = nil
            end
        end
    end,
})
-- Farms Tab
local FarmsBox = FarmsTab:CreateSection("Auto Farms")
FarmsTab:CreateButton({
    Name = 'Construction Job',
    Callback = function()
        FadeIn(0.3)
        local speaker = LocalPlayer
     
        local function inlineTeleport(cframe)
            local char = speaker.Character
            if char and char:FindFirstChild('Humanoid') and char:FindFirstChild('HumanoidRootPart') then
                char.Humanoid:ChangeState(0)
                repeat task.wait() until not speaker:GetAttribute('LastACPos')
                char.HumanoidRootPart.CFrame = cframe
            end
        end
        local function hasPlyWood()
            return speaker.Backpack:FindFirstChild('Plywood') ~= nil or
                   (speaker.Character and speaker.Character:FindFirstChildOfClass('Tool') and
                    speaker.Character:FindFirstChildOfClass('Tool').Name == 'Plywood')
        end
        local function fireProximityPrompt(prompt)
            if prompt then fireproximityprompt(prompt) end
        end
        local function equipPlyWood()
            local plywood = speaker.Backpack:FindFirstChild('Plywood')
            if plywood then plywood.Parent = speaker.Character end
        end
        local function grabWood()
            inlineTeleport(CFrame.new(-1727, 371, -1178))
            task.wait(0.1)
            while not hasPlyWood() do
                fireProximityPrompt(workspace.ConstructionStuff['Grab Wood']:FindFirstChildOfClass('ProximityPrompt'))
                task.wait(0.1)
                equipPlyWood()
            end
        end
        local function buildWall(wallPromptName, wallPosition)
            local prompt = workspace.ConstructionStuff[wallPromptName]:FindFirstChildOfClass('ProximityPrompt')
            while prompt and prompt.Enabled do
                inlineTeleport(wallPosition)
                task.wait(0.01)
                fireProximityPrompt(prompt)
                task.wait()
                if not hasPlyWood() then grabWood() end
            end
        end
        task.spawn(function()
            inlineTeleport(CFrame.new(-1728, 371, -1172))
            task.wait(0.2)
            fireProximityPrompt(workspace.ConstructionStuff['Start Job']:FindFirstChildOfClass('ProximityPrompt'))
            task.wait(0.5)
            if not hasPlyWood() then grabWood() end
            buildWall('Wall2 Prompt', CFrame.new(-1705, 368, -1151))
            buildWall('Wall3 Prompt', CFrame.new(-1732, 368, -1152))
            buildWall('Wall4 Prompt2', CFrame.new(-1772, 368, -1152))
            buildWall('Wall1 Prompt3', CFrame.new(-1674, 368, -1166))
            inlineTeleport(CFrame.new(-1728, 371, -1172))
            task.wait(0.2)
            fireProximityPrompt(workspace.ConstructionStuff['Quit Job']:FindFirstChildOfClass('ProximityPrompt'))
            FadeOut(0.4)
        end)
    end,
})
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
-- Main Loops
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
        if bloodGui then bloodGui.Enabled = not ModFlags.DisableBloodEffects end
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
        if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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
    if ModFlags.RespawnWhereYouDied and typeof(DeathFrame) == "CFrame" then root.CFrame = DeathFrame end
end
local function onCharacterAdded(char) SetupCharacterEvents(char) end
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterAdded:Connect(function()
    if ModFlags.DisableCameras and Lighting:FindFirstChild("Shiesty") then
        local remote = Lighting.Shiesty:FindFirstChildWhichIsA("RemoteEvent", true)
        if remote then remote:FireServer() end
    end
end)
