local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/xb4nger/Trxp.cc/refs/heads/main/Theme'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles



local Window = Library:CreateWindow({
    Title = '🎃 | Trxp.cc',
    Footer = "Trxp.cc",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    QuickShop = Window:AddTab('QuickShop'),
    ['Settings'] = Window:AddTab('UI'),
}


local TweenService = game:GetService("TweenService")
local player = game:GetService("Players").LocalPlayer or game:GetService("Players").PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("TrxpFrame") then
    playerGui.TrxpFrame:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrxpFrame"
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.4, 0, 0.15, 0)
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.new(0.5, 0, 0.5, 0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.RichText = true
label.Text = "<font color='rgb(255,0,0)'>Trxp</font><font color='rgb(0,102,255)'>.</font><font color='rgb(255,255,255)'>cc</font>"
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.TextTransparency = 1
label.Parent = frame

function FadeIn(speed)
	TweenService:Create(frame, TweenInfo.new(speed), {BackgroundTransparency = 0}):Play()
	TweenService:Create(label, TweenInfo.new(speed), {TextTransparency = 0}):Play()
end

function FadeOut(speed)
	TweenService:Create(frame, TweenInfo.new(speed), {BackgroundTransparency = 1}):Play()
	TweenService:Create(label, TweenInfo.new(speed), {TextTransparency = 1}):Play()
end




local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function teleportTo(cf)
	local char = player.Character or player.CharacterAdded:Wait()
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







local DupeGunBox = Tabs.Main:AddLeftGroupbox('Guns')
local MDupe = Tabs.Main:AddRightGroupbox('Money')
local TargetBox = Tabs.Main:AddRightGroupbox('Target')
local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Hitbox Expander')
local KillAuraBox = Tabs.Main:AddLeftGroupbox('Kill Aura')
local ESPGroupbox = Tabs.Visuals:AddLeftGroupbox('ESP')
local TabBox = Tabs.Visuals:AddLeftTabbox()
local WalkGroupbox = Tabs.Misc:AddLeftGroupbox('Movement')
local ExtraBox = Tabs.Misc:AddLeftGroupbox('Bypasses')
local DropBox = Tabs.Misc:AddLeftGroupbox('Auto Drop')
local ExtraBox1 = Tabs.Misc:AddRightGroupbox('Teleports')
local FarmsBox = Tabs.Misc:AddRightGroupbox('Farms')
local GUIsBox = Tabs.Visuals:AddRightGroupbox('GUIs')
local BankBox = Tabs.Misc:AddRightGroupbox('Bank Withdraw/Deposit')
local QuickShopLeftGroup = Tabs.QuickShop:AddLeftGroupbox('QuickShop')
local QuickShopRightGroup = Tabs.QuickShop:AddRightGroupbox('ExoticDealer')


local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))

local Player = Players.LocalPlayer
local Character, Backpack

local function updateCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Backpack = Player:WaitForChild("Backpack")
end


updateCharacter()


Player.CharacterAdded:Connect(function()
    updateCharacter()
end)

local running = false

local function getPing()
    if typeof(Player.GetNetworkPing) == "function" then
        local success, result = pcall(function()
            return tonumber(string.match(Player:GetNetworkPing(), "%d+"))
        end)
        if success and result then return result end
    end
    local t0 = tick()
    local temp = Instance.new("BoolValue")
    temp.Parent = ReplicatedStorage
    temp.Name = "PingTest_" .. tostring(math.random(10000, 99999))
    task.wait(0.1)
    local t1 = tick()
    temp:Destroy()
    return math.clamp((t1 - t0)*1000, 50, 300)
end

local function dupeOne()
    local Tool = Character:FindFirstChildOfClass("Tool") or Backpack:FindFirstChildOfClass("Tool")
    if not Tool then return end
    Tool.Parent = Backpack
    task.wait(0.5)

    local ToolName = Tool.Name
    local ToolId
    local delay = 0.25 + ((math.clamp(getPing(),0,300) /300)*0.03)

    local conn; conn = ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item)
        if item.Name == ToolName then
            local owner = item:WaitForChild("owner",2)
            if owner and owner.Value == Player.Name then
                ToolId = item:GetAttribute("SpecialId")
            end
        end
    end)

    task.spawn(function() ReplicatedStorage.ListWeaponRemote:FireServer(ToolName,99999) end)
    task.wait(delay)
    task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Store",ToolName) end)
    task.wait(3)
    if ToolId then
        task.spawn(function() ReplicatedStorage.BuyItemRemote:FireServer(ToolName,"Remove",ToolId) end)
    end
    task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Grab",ToolName) end)
    conn:Disconnect()
end


task.spawn(function()
    while true do
        if running then
            dupeOne()
            task.wait(1.5)
        else
            task.wait(0.1)
        end
    end
end)




DupeGunBox:AddButton('Dupe Gun', function()
    dupeOne()
end)

DupeGunBox:AddToggle('AutoDupeGunToggle', {
    Text = 'Auto Dupe Gun',
    Default = false,
    Tooltip = 'Automatically duplicate gun repeatedly',
    Callback = function(value)
        running = value

    end,
})

if Toggles and Toggles.AutoDupeGunToggle then
    Toggles.AutoDupeGunToggle:OnChanged(function()

    end)
end



local InfiniteAmmo = false
local AlwaysAutomatic = false
local NoRecoil = false
local NoSpread = false
local FireRateBoost = false

local WeaponTables = {}

DupeGunBox:AddToggle('AlwaysAutomaticToggle', {
        Text = 'Always Automatic',
        Default = false,
        Callback = function(state)
            AlwaysAutomatic = state
            Library:Notify('Always Automatic: ' .. (state and 'ON' or 'OFF'), 3)
        end,
    })

DupeGunBox:AddToggle('NoRecoilToggle', {
        Text = 'No Recoil',
        Default = false,
        Callback = function(state)
            NoRecoil = state
            Library:Notify('No Recoil: ' .. (state and 'ON' or 'OFF'), 3)
        end,
    })

DupeGunBox:AddToggle('NoSpreadToggle', {
        Text = 'No Spread',
        Default = false,
        Callback = function(state)
            NoSpread = state
            Library:Notify('No Spread: ' .. (state and 'ON' or 'OFF'), 3)
        end,
    })

DupeGunBox:AddToggle('FireRateBoostToggle', {
        Text = 'Fire Rate Boost',
        Default = false,
        Callback = function(state)
            FireRateBoost = state
            Library:Notify('Fire Rate Boost: ' .. (state and 'ON' or 'OFF'), 3)
        end,
    })

DupeGunBox:AddToggle('InfiniteAmmoToggle', {
        Text = 'Infinite Ammo',
        Default = false,
        Callback = function(state)
            local tool, setting = getToolSetting()
            if not tool or not setting then
                Library:Notify('Tool not equipped or invalid.', 3)
                return
            end

            storeOriginal(
                tool,
                'LimitedAmmoEnabled',
                setting.LimitedAmmoEnabled == true,
                true
            )
            storeOriginal(tool, 'MaxAmmo', setting.MaxAmmo)
            storeOriginal(tool, 'AmmoPerMag', setting.AmmoPerMag)
            storeOriginal(tool, 'Ammo', setting.Ammo)

            if state then
                setting.LimitedAmmoEnabled = false
                setting.MaxAmmo = 9e9
                setting.AmmoPerMag = 9e9
                setting.Ammo = 9e9
                Library:Notify('Infinite Ammo ON', 3)
            else
                restoreOriginal(tool, setting, 'LimitedAmmoEnabled')
                restoreOriginal(tool, setting, 'MaxAmmo')
                restoreOriginal(tool, setting, 'AmmoPerMag')
                restoreOriginal(tool, setting, 'Ammo')
                Library:Notify('Infinite Ammo OFF', 3)
            end
        end,
    })

DupeGunBox:AddToggle('InfDamageToggle', {
        Text = 'Infinite Damage',
        Default = false,
        Callback = function(state)
            local tool, setting = getToolSetting()
            if not tool or not setting then
                Library:Notify('Tool not equipped or invalid.', 3)
                return
            end

            storeOriginal(tool, 'BaseDamage', setting.BaseDamage)

            if state then
                setting.BaseDamage = 9e9
                Library:Notify('Infinite Damage ON', 3)
            else
                restoreOriginal(tool, setting, 'BaseDamage')
                Library:Notify('Infinite Damage OFF', 3)
            end
        end,
    })



task.spawn(function()
    while true do
        local found = {}
        for _, obj in ipairs(getgc(true)) do
            if typeof(obj) == 'table' and rawget(obj, 'FireRate') then
                table.insert(found, obj)
            end
        end
        WeaponTables = found
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        for _, weapon in ipairs(WeaponTables) do
            pcall(function()
                rawset(weapon, 'FireAnimationSpeed', 100)
                rawset(weapon, 'FlamingBullet', true)
                rawset(weapon, 'Auto', AlwaysAutomatic)
                rawset(
                    weapon,
                    'FireMode',
                    AlwaysAutomatic and 'Auto' or weapon.FireMode
                )
                rawset(
                    weapon,
                    'BurstAmount',
                    AlwaysAutomatic and 1 or weapon.BurstAmount
                )
                rawset(
                    weapon,
                    'ShotsPerBurst',
                    AlwaysAutomatic and 1 or weapon.ShotsPerBurst
                )

                rawset(weapon, 'CameraRecoilingEnabled', not NoRecoil)
                rawset(weapon, 'Recoil', NoRecoil and 0 or 1)
                rawset(weapon, 'Accuracy', NoSpread and 0 or 1)
                rawset(weapon, 'FireRate', FireRateBoost and 0.01 or 0.1)
            end)
        end
        task.wait(0.3)
    end
end)






MDupe:AddLabel("STEPS")
MDupe:AddLabel("Click Buy Ingredients")
MDupe:AddLabel("Tp To Penthouse")
MDupe:AddLabel("Cook Koolaid")
MDupe:AddLabel("Tp To Koolaid Seller")
MDupe:AddLabel("Make Sure You Can See Press E To Sell")
MDupe:AddLabel("Press Dupe")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer


MDupe:AddButton("Teleport to Penthouse", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid and root then
        FadeIn(0.3)
        
        humanoid:ChangeState(0)
        repeat task.wait() until not player:GetAttribute("LastACPos")
        root.CFrame = CFrame.new(-181.86 + 2, 397.14, -587.99)
		task.wait(2)
        FadeOut(0.4)
    end
end)

MDupe:AddButton("Teleport to Sell Juice", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid and root then
        FadeIn(0.3)
        
        humanoid:ChangeState(0)
        repeat task.wait() until not player:GetAttribute("LastACPos")
        root.CFrame = CFrame.new(-71.63, 287.06, -319.95)
		task.wait(2)
        FadeOut(0.3)
    end
end)




MDupe:AddButton('Buy Ingredients', function()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("ExoticShopRemote")
    remote:InvokeServer("Ice-Fruit Bag")
    remote:InvokeServer("Ice-Fruit Cupz")
    remote:InvokeServer("FijiWater")
    remote:InvokeServer("FreshWater")
    Library:Notify("Bought all ingredients.", 3)
end)




MDupe:AddButton('Dupe', function()
    local Workspace = game:GetService("Workspace")
    local IceFruitSellPart = Workspace:FindFirstChild("IceFruit Sell")
    if not IceFruitSellPart then
        Library:Notify("IceFruit Sell part not found.", 3)
        return
    end
    local prompt = IceFruitSellPart:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        Library:Notify("ProximityPrompt not found inside IceFruit Sell.", 3)
        return
    end
    Library:Notify("Starting Cupz Money Method...", 3)
    for i = 1, 5000 do
        task.spawn(function()
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end)
    end
    Library:Notify("Cupz Money Method completed successfully!", 3)
end)




MDupe:AddToggle('InstantInteraction', {
    Text = 'Instant Interaction',
    Default = false,
    Callback = function(value)
        if value then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end
            workspace.DescendantAdded:Connect(function(v)
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end)
        end
    end
})










getgenv().Players = cloneref(game:GetService("Players"))
getgenv().LocalPlayer = getgenv().Players.LocalPlayer
getgenv().ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
getgenv().Camera = workspace.CurrentCamera


local function kill_gun(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return end
    local tool = getgenv().LocalPlayer.Character and getgenv().LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local hitpart = targetPlayer.Character:FindFirstChild("Head")
    local hitpos = hitpart.Position
    local damage = math.huge
    local setting = tool:FindFirstChild("Setting")
    if setting then
        pcall(function()
            require(setting).Range = 10000
        end)
    end
    getgenv().ReplicatedStorage.VisualizeMuzzle:FireServer(tool.Handle, true, {false, 7, Color3.new(1, 1.1098, 0), 15, true, 0.02}, tool.GunScript_Local.MuzzleEffect)
    getgenv().ReplicatedStorage.VisualizeBullet:FireServer(tool, tool.Handle, Vector3.new(-0.177, 0.088, 0.980), tool.Handle.GunFirePoint,
        {true, {112139677907600, 92977228204408, 112139677907600, 92977228204408}, 1, 1, 10, tool.GunScript_Local.HitEffect, true},
        {true, {0,0,0,0,0,0}, 1,1,1, tool.GunScript_Local.BloodEffect},
        {true,0.2,{3696144972},true,7,1},
        {false,8,true,{163064102},1,1.5,1,false,tool.GunScript_Local.ExplosionEffect},
        {false,Vector3.new(0.1,0,0),Vector3.new(-0.1,0,0),tool.GunScript_Local.TracerEffect,nil,tool.GunScript_Local.ParticleEffect,300,526,0,Vector3.zero,Vector3.new(0.4,0.4,0.4),Color3.new(0.639,0.635,0.611),1,Enum.Material.Neon,Enum.PartType.Cylinder,false,6696543809,0,Vector3.new(0.007,0.007,0.007)},
        {true,{269514869,269514887,269514807,269514817},0.5,1,1.5,100},
        {false,3,Color3.new(1,0.647,0.6),6,true}
    )
    getgenv().ReplicatedStorage.InflictTarget:FireServer(tool, getgenv().LocalPlayer, targetPlayer.Character:FindFirstChildOfClass("Humanoid"), hitpart, damage,
        {0,0,false,false, tool.GunScript_Server.IgniteScript, tool.GunScript_Server.IcifyScript,100,100},
        {false,5,3},
        hitpart,
        {false,{1930359546},1,1.5,1},
        hitpos,
        Vector3.new(0.074,-0.099,-0.992),
        true
    )
end





local function updatePlayerList()
    local list = {}
    for _, plr in ipairs(getgenv().Players:GetPlayers()) do
        if plr ~= getgenv().LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

getgenv().killBringEnabled = false
getgenv().SelectedPlayer = nil
getgenv().originalPositions = {}

local playerDropdown = TargetBox:AddDropdown('PlayerDropdown', {
    Values = updatePlayerList(),
    Default = '',
    Multi = false,
    Text = 'Select Player',
    Callback = function(name)
        getgenv().SelectedPlayer = getgenv().Players:FindFirstChild(name)
        if not getgenv().SelectedPlayer then
            Library:Notify('Player not found!', 3)
        end
    end,
})

TargetBox:AddButton('RefreshPlayerList', function()
    playerDropdown:SetValues(updatePlayerList())
    Library:Notify('Player list refreshed', 2)
end)

TargetBox:AddButton('Kill Selected Player', function()
    if getgenv().SelectedPlayer and getgenv().SelectedPlayer.Character then
        local tool = getgenv().LocalPlayer.Character and getgenv().LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            kill_gun(getgenv().SelectedPlayer)
            Library:Notify('Attempted to kill ' .. getgenv().SelectedPlayer.Name, 3)
        else
            Library:Notify('No tool equipped!', 3)
        end
    else
        Library:Notify('No valid target selected!', 3)
    end
end)


TargetBox:AddButton('View Inventory', function()
    if getgenv().SelectedPlayer and getgenv().SelectedPlayer:FindFirstChild('Backpack') then
        local items = getgenv().SelectedPlayer.Backpack:GetChildren()
        local itemNames = {}
        for _, item in ipairs(items) do
            table.insert(itemNames, item.Name)
        end
        if #itemNames > 0 then
            Library:Notify('Backpack items: ' .. table.concat(itemNames, ', '), 10)
        else
            Library:Notify("Target's backpack is empty.", 10)
        end
    else
        Library:Notify('No player selected or backpack missing.', 3)
    end
end)

TargetBox:AddButton('Goto Player', function()
    local target = getgenv().SelectedPlayer
    if not target then
        Library:Notify('No player selected', 3)
        return
    end

    local targetChar = target.Character
    local targetHRP = targetChar and targetChar:FindFirstChild('HumanoidRootPart')
    local localChar = getgenv().LocalPlayer.Character
    local hum = localChar and localChar:FindFirstChildOfClass('Humanoid')
    local hrp = localChar and localChar:FindFirstChild('HumanoidRootPart')

    if targetHRP and hum and hrp then
        hum:ChangeState(0)
        repeat task.wait() until not getgenv().LocalPlayer:GetAttribute('LastACPos')
        hrp.CFrame = CFrame.new(targetHRP.Position + Vector3.new(2, 0, 0))
        Library:Notify('Teleported to ' .. target.Name, 3)
    else
        Library:Notify('Teleport failed: Missing parts', 3)
    end
end)

TargetBox:AddToggle('KillBring', {
    Text = 'KillBring',
    Default = false,
    Callback = function(value)
        getgenv().killBringEnabled = value
        if not value then
            if getgenv().SelectedPlayer and getgenv().originalPositions[getgenv().SelectedPlayer.UserId] then
                local targetChar = getgenv().SelectedPlayer.Character
                if targetChar then
                    local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
                    if targetRoot then
                        targetRoot.Anchored = false
                        targetRoot.CFrame = getgenv().originalPositions[getgenv().SelectedPlayer.UserId]
                        getgenv().originalPositions[getgenv().SelectedPlayer.UserId] = nil
                    end
                end
            end
        end
    end,
})

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().killBringEnabled and getgenv().SelectedPlayer then
            local targetChar = getgenv().SelectedPlayer.Character
            local speakerChar = getgenv().LocalPlayer.Character
            if targetChar and speakerChar then
                local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
                local speakerRoot = speakerChar:FindFirstChild('HumanoidRootPart')
                local targetHumanoid = targetChar:FindFirstChildOfClass('Humanoid')
                if targetRoot and speakerRoot and targetHumanoid then
                    if not getgenv().originalPositions[getgenv().SelectedPlayer.UserId] then
                        getgenv().originalPositions[getgenv().SelectedPlayer.UserId] = targetRoot.CFrame
                    end
                    local offset = speakerRoot.CFrame.LookVector * 2 + Vector3.new(0, 0.25, 0)
                    targetRoot.CFrame = speakerRoot.CFrame + offset
                    targetHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    task.wait(0.1)
                    targetHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    task.wait(0.1)
                    targetHumanoid:ChangeState(Enum.HumanoidStateType.Seated)
                    task.wait(0.1)
                    targetHumanoid:ChangeState(Enum.HumanoidStateType.Running)
                    targetRoot.Anchored = true
                end
            end
        end
    end
end)

getgenv().SpectateConnection = nil
local function spectatePlayer(enable)
    if enable then
        if getgenv().SelectedPlayer and getgenv().SelectedPlayer.Character and getgenv().SelectedPlayer.Character:FindFirstChild('Humanoid') then
            getgenv().Camera.CameraSubject = getgenv().SelectedPlayer.Character.Humanoid
            Library:Notify('Spectating: ' .. getgenv().SelectedPlayer.Name, 3)
            getgenv().SpectateConnection = getgenv().SelectedPlayer.CharacterAdded:Connect(function(newChar)
                getgenv().Camera.CameraSubject = newChar:FindFirstChild('Humanoid')
            end)
        else
            Library:Notify('Error: No player selected!', 3)
        end
    else
        getgenv().Camera.CameraSubject = getgenv().LocalPlayer.Character and getgenv().LocalPlayer.Character:FindFirstChild('Humanoid')
        if getgenv().SpectateConnection then
            getgenv().SpectateConnection:Disconnect()
            getgenv().SpectateConnection = nil
        end
        Library:Notify('Stopped Spectating', 3)
    end
end

TargetBox:AddToggle('SpectateToggle', {
    Text = 'Spectate Player',
    Default = false,
    Callback = function(value)
        if getgenv().SelectedPlayer then
            spectatePlayer(value)
        else
            Library:Notify('Error: No player selected to spectate!', 3)
        end
    end,
})










local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Transparency = 0.5

local hitboxEnabled = false
local hitboxSize = 15

local function ApplyHitbox(player)
	if player == LocalPlayer then return end
	local function expand()
		if not hitboxEnabled then return end
		local head = player.Character and player.Character:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			local size = hitboxSize * 2
			head.Size = Vector3.new(size, size, size)
			head.CanCollide = false
			head.Massless = true
			head.Transparency = Transparency
			head.CFrame *= CFrame.new(0, (size - 2) / 2, 0)
		end
	end

	player.CharacterAppearanceLoaded:Connect(function()
		task.wait(0.1)
		expand()
	end)

	if player.Character and player.Character:FindFirstChild("Head") then
		expand()
	end
end

local function ResetHitbox(player)
	local head = player.Character and player.Character:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		head.Size = Vector3.new(2, 1, 1)
		head.Transparency = 0
		head.CanCollide = true
		head.Massless = false
	end
end

local function UpdateHitboxes()
	for _, player in pairs(Players:GetPlayers()) do
		if hitboxEnabled then
			ApplyHitbox(player)
		else
			ResetHitbox(player)
		end
	end
end



LeftGroupBox:AddToggle('HitboxExpanderEnabled', {
    Text = 'Enable Hitbox Expander',
    Default = false,
    Tooltip = 'Expands the hitbox size of enemy players',
})

LeftGroupBox:AddSlider('HitboxExpanderSize', {
    Text = 'Hitbox Size',
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Tooltip = 'Size of the expanded hitbox',
})

Toggles.HitboxExpanderEnabled:OnChanged(function()
	hitboxEnabled = Toggles.HitboxExpanderEnabled.Value
	UpdateHitboxes()
end)

Options.HitboxExpanderSize:OnChanged(function()
	hitboxSize = Options.HitboxExpanderSize.Value
	if hitboxEnabled then
		UpdateHitboxes()
	end
end)

Players.PlayerAdded:Connect(function(player)
	if hitboxEnabled then
		ApplyHitbox(player)
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	if hitboxEnabled then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				ApplyHitbox(player)
			end
		end
	end
end)

hitboxEnabled = Toggles.HitboxExpanderEnabled.Value
hitboxSize = Options.HitboxExpanderSize.Value
UpdateHitboxes()

-- Kill Aura (fixed rotation + Kill Rate)
getgenv().KillAuraEnabled      = false
getgenv().KillAuraKeybind      = ""
getgenv().KillAuraRange        = 25
getgenv().KillAuraKillRate     = 0.2      -- renamed to Kill Rate (seconds between tries for the current rotation step)
getgenv().KillAuraPart         = "Head"
getgenv().KillAuraBeam         = true
getgenv().KillAuraRainbow      = false
getgenv().KillAuraBeamColor    = Color3.fromRGB(255,255,255)
getgenv().KillAuraHighlight    = true
getgenv().KillAuraHighlightFill    = Color3.fromRGB(255,0,0)
getgenv().KillAuraHighlightOutline = Color3.fromRGB(255,255,255)
getgenv().KillAuraDeadCheck    = true

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- rotation state
local rotationList = {}      -- array of player objects for current rotation
local rotationIndex = 1      -- current index into rotationList

-- GUI (assumes KillAuraBox exists like in your snippet)
KillAuraBox:AddToggle("KillAuraToggle", {
    Text = "Kill Aura",
    Default = false,
    Callback = function(v) getgenv().KillAuraEnabled = v end
}):AddKeyPicker("KillAuraKey", {Default="", SyncToggleState=true, Mode="Toggle", Text="Kill Aura Key"})

KillAuraBox:AddDropdown("KillAuraPart", {
    Values = {"Head","Torso","HumanoidRootPart"},
    Default = getgenv().KillAuraPart,
    Multi = false,
    Text = "Hit Part",
    Callback = function(v) getgenv().KillAuraPart = v end
})

KillAuraBox:AddToggle("KillAuraHighlight", {
    Text = "Highlight Target",
    Default = getgenv().KillAuraHighlight,
    Callback = function(v)
        getgenv().KillAuraHighlight = v
        if not v then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    local h = plr.Character:FindFirstChild("KillAuraHighlight")
                    if h then pcall(function() h:Destroy() end) end
                end
            end
        end
    end
})

KillAuraBox:AddToggle("KillAuraBeam", {
    Text = "Beam Visual",
    Default = getgenv().KillAuraBeam,
    Callback = function(v) getgenv().KillAuraBeam = v end
})

KillAuraBox:AddToggle("KillAuraRainbow", {
    Text = "Rainbow Beam ",
    Default = getgenv().KillAuraRainbow,
    Callback = function(v) getgenv().KillAuraRainbow = v end
})

KillAuraBox:AddToggle("KillAuraDeadCheck", {
    Text = "Skip Dead Players",
    Default = getgenv().KillAuraDeadCheck,
    Callback = function(v) getgenv().KillAuraDeadCheck = v end
})

KillAuraBox:AddSlider("KillAuraRange", {
    Text = "Range",
    Min = 5, Max = 500, Default = getgenv().KillAuraRange, Rounding = 0,
    Callback = function(v) getgenv().KillAuraRange = v end
})

-- Kill Rate slider (renamed)
KillAuraBox:AddSlider("KillAuraKillRate", {
    Text = "Kill Rate",
    Min = 0.03, Max = 10, Default = getgenv().KillAuraKillRate, Rounding = 2,
    Callback = function(v) getgenv().KillAuraKillRate = v end
})

KillAuraBox:AddLabel("Beam Color"):AddColorPicker("KillAuraBeamColor", {
    Default = getgenv().KillAuraBeamColor,
    Title = "Beam Color",
    Transparency = 0,
    Callback = function(v) getgenv().KillAuraBeamColor = v end
})
if Options and Options.KillAuraBeamColor and Options.KillAuraBeamColor.OnChanged then
    Options.KillAuraBeamColor:OnChanged(function() getgenv().KillAuraBeamColor = Options.KillAuraBeamColor.Value end)
end

KillAuraBox:AddLabel("Highlight Fill"):AddColorPicker("KillAuraHighlightFill", {
    Default = getgenv().KillAuraHighlightFill,
    Title = "Highlight Fill",
    Callback = function(v) getgenv().KillAuraHighlightFill = v end
})
if Options and Options.KillAuraHighlightFill and Options.KillAuraHighlightFill.OnChanged then
    Options.KillAuraHighlightFill:OnChanged(function() getgenv().KillAuraHighlightFill = Options.KillAuraHighlightFill.Value end)
end

KillAuraBox:AddLabel("Highlight Outline"):AddColorPicker("KillAuraHighlightOutline", {
    Default = getgenv().KillAuraHighlightOutline,
    Title = "Highlight Outline",
    Callback = function(v) getgenv().KillAuraHighlightOutline = v end
})
if Options and Options.KillAuraHighlightOutline and Options.KillAuraHighlightOutline.OnChanged then
    Options.KillAuraHighlightOutline:OnChanged(function() getgenv().KillAuraHighlightOutline = Options.KillAuraHighlightOutline.Value end)
end

local function cleanupVisuals()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("KillAuraHighlight")
            if h then pcall(function() h:Destroy() end) end
        end
    end
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "KillAuraBeamPart" then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function getValidTargets()
    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return {} end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local targets = {}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if getgenv().KillAuraDeadCheck and (not hum or hum.Health <= 0) then
                -- skip dead
            else
                local d = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d <= (getgenv().KillAuraRange or 25) then
                    table.insert(targets, plr)
                end
            end
        end
    end
    return targets
end

local function ensureHighlight(plr)
    if not plr.Character then return end
    local h = plr.Character:FindFirstChild("KillAuraHighlight")
    if not h then
        pcall(function()
            local obj = Instance.new("Highlight")
            obj.Name = "KillAuraHighlight"
            obj.FillTransparency = 0.5
            obj.OutlineTransparency = 0
            obj.Parent = plr.Character
        end)
        h = plr.Character:FindFirstChild("KillAuraHighlight")
    end
    if h then
        pcall(function()
            h.FillColor = getgenv().KillAuraHighlightFill or Color3.fromRGB(255,0,0)
            h.OutlineColor = getgenv().KillAuraHighlightOutline or Color3.fromRGB(255,255,255)
        end)
    end
end

local function createBeamPart(startPos, endPos)
    local dist = (startPos - endPos).Magnitude
    local part = Instance.new("Part")
    part.Name = "KillAuraBeamPart"
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.Material = Enum.Material.Neon
    part.Size = Vector3.new(0.18, 0.18, math.max(dist, 0.01))
    part.CFrame = CFrame.new((startPos + endPos) / 2, endPos)
    part.Color = getgenv().KillAuraRainbow and Color3.fromHSV((tick() % 5) / 5, 1, 1) or (getgenv().KillAuraBeamColor or Color3.new(1,1,1))
    part.Parent = workspace
    Debris:AddItem(part, math.max(getgenv().KillAuraKillRate or 0.12, 0.08))
end

-- keep your original remote-firing logic exactly as it was
local function fireRemotes(tool, hitPart, hum)
    local VM = ReplicatedStorage:FindFirstChild("VisualizeMuzzle")
    local VB = ReplicatedStorage:FindFirstChild("VisualizeBullet")
    local IT = ReplicatedStorage:FindFirstChild("InflictTarget")
    if VM and VB and IT then
        pcall(function()
            VM:FireServer(tool.Handle, true, { false, 7, Color3.new(1, 1.1, 0), 15, true, 0.02 }, tool:FindFirstChild("GunScript_Local") and tool.GunScript_Local:FindFirstChild("MuzzleEffect"))
        end)
        pcall(function()
            VB:FireServer(
                tool,
                tool.Handle,
                Vector3.new(-0.177, 0.088, 0.980),
                tool.Handle:FindFirstChild("GunFirePoint"),
                { true, {112139677907600, 92977228204408, 112139677907600, 92977228204408}, 1, 1, 10, tool.GunScript_Local and tool.GunScript_Local.HitEffect, true },
                { true, {0, 0, 0, 0, 0, 0}, 1, 1, 1, tool.GunScript_Local and tool.GunScript_Local.BloodEffect },
                { true, 0.2, {3696144972}, true, 7, 1 },
                { false, 8, true, {163064102}, 1, 1.5, 1, false, tool.GunScript_Local and tool.GunScript_Local.ExplosionEffect },
                { false, Vector3.new(0.1, 0, 0), Vector3.new(-0.1, 0, 0), tool.GunScript_Local and tool.GunScript_Local.TracerEffect },
                { true, {269514869, 269514887, 269514807, 269514817}, 0.5, 1, 1.5, 100 },
                { false, 3, Color3.new(1, 0.647, 0.6), 6, true }
            )
        end)
        pcall(function()
            IT:FireServer(
                tool,
                LocalPlayer,
                hum,
                hitPart,
                100,
                { 0, 0, false, false, tool.GunScript_Server and tool.GunScript_Server.IgniteScript, tool.GunScript_Server and tool.GunScript_Server.IcifyScript, 100, 100 },
                { false, 5, 3 },
                hitPart,
                { false, {1930359546}, 1, 1.5, 1 },
                hitPart.Position,
                Vector3.new(0.074, -0.099, -0.992),
                true
            )
        end)
    else
        local fallback = ReplicatedStorage:FindFirstChild("Attack") or ReplicatedStorage:FindFirstChild("Inflict") or ReplicatedStorage:FindFirstChild("Damage")
        if fallback then pcall(function() fallback:FireServer(hitPart.Position) end) end
    end
end

local function attemptKill(plr)
    if not (plr and plr.Character and LocalPlayer and LocalPlayer.Character) then return end
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not (tool and tool:FindFirstChild("Handle")) then return end
    local hitPartName = getgenv().KillAuraPart or "Head"
    local hitPart = plr.Character:FindFirstChild(hitPartName) or plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
    if not hitPart then return end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if getgenv().KillAuraDeadCheck and (not hum or hum.Health <= 0) then return end

    local preHealth = hum and hum.Health or nil

    if getgenv().KillAuraHighlight then ensureHighlight(plr) else
        local ex = plr.Character:FindFirstChild("KillAuraHighlight")
        if ex then pcall(function() ex:Destroy() end) end
    end

    if getgenv().KillAuraBeam then
        local ok, startHRP = pcall(function() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end)
        if ok and startHRP then createBeamPart(startHRP.Position, hitPart.Position) end
    end

    -- keep the original remote calls (no logic changes here)
    fireRemotes(tool, hitPart, hum)

    -- optionally you can still check health after a short delay for visual/debugging, but we do NOT use that to skip targets now
    -- (left intentionally minimal to preserve original behavior)
    --[[
    task.spawn(function()
        task.wait(0.45)
        -- no fail counting or skipping by default in this rotation version
    end)
    --]]
end

-- Build a stable rotation list (unique players), preserving order between rebuilds when possible
local function rebuildRotation(validTargets)
    -- try to keep previous rotation ordering where possible
    local map = {}
    for i,plr in ipairs(rotationList) do
        if plr and plr.UserId then map[plr.UserId] = true end
    end
    local newList = {}
    -- keep old players first (if still valid)
    for _,plr in ipairs(rotationList) do
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            for _,v in ipairs(validTargets) do
                if v.UserId == plr.UserId then
                    table.insert(newList, v)
                    break
                end
            end
        end
    end
    -- then add any new players not already in list
    for _,v in ipairs(validTargets) do
        local found = false
        for _,x in ipairs(newList) do if x.UserId == v.UserId then found = true break end end
        if not found then table.insert(newList, v) end
    end
    rotationList = newList
    if rotationIndex > #rotationList then rotationIndex = 1 end
end

task.spawn(function()
    while true do
        local rate = tonumber(getgenv().KillAuraKillRate) or 0.2
        task.wait(math.max(0.01, rate))
        if getgenv().KillAuraEnabled then
            if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                -- no local character
            else
                local valids = getValidTargets()
                if #valids == 0 then
                    -- nothing to attack; reset rotation
                    rotationList = {}
                    rotationIndex = 1
                elseif #valids == 1 then
                    -- only one target: keep trying them every tick
                    local the = valids[1]
                    attemptKill(the)
                else
                    -- multiple targets: maintain rotation
                    -- rebuild rotation to reflect current valid targets
                    rebuildRotation(valids)
                    if #rotationList > 0 then
                        -- clamp rotationIndex
                        if rotationIndex < 1 then rotationIndex = 1 end
                        if rotationIndex > #rotationList then rotationIndex = 1 end
                        local target = rotationList[rotationIndex]
                        if target then
                            attemptKill(target)
                        end
                        rotationIndex = rotationIndex + 1
                        if rotationIndex > #rotationList then
                            rotationIndex = 1 -- start new rotation next loop
                        end
                    end
                end
            end
        else
            cleanupVisuals()
        end
    end
end)



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local MaxDistance = 10000

local RootGui = CoreGui
local MasterGui = RootGui:FindFirstChild("UnifiedESP") or Instance.new("ScreenGui")
MasterGui.Name = "UnifiedESP"
MasterGui.ResetOnSpawn = false
MasterGui.Parent = RootGui

local Drawn, Connections = {}, {}

local function clearEntries(tbl)
	for _, v in ipairs(tbl) do
		if typeof(v) == "Instance" then pcall(function() v:Destroy() end)
		elseif typeof(v) == "RBXScriptConnection" then pcall(function() v:Disconnect() end) end
	end
end

local function DupeCheck(name)
	if Drawn[name] then clearEntries(Drawn[name]) end
	Drawn[name] = {}
end

local function Create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do inst[k] = v end
	inst.Parent = MasterGui
	return inst
end

local function CreateTextLabel()
	return Create("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 14,
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 1,
		Size = UDim2.new(0, 200, 0, 20),
		AnchorPoint = Vector2.new(0.5, 0),
		ZIndex = 3,
		Visible = false
	})
end

local function makeCorner()
	local h = Create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 6, 0, 1),
		ZIndex = 3,
		Visible = false
	})
	local v = Create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 0, 6),
		ZIndex = 3,
		Visible = false
	})
	return h, v
end

local function createHealthParts()
	local outline = Create("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 1,
		Visible = false
	})
	local back = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderSizePixel = 0,
		ZIndex = 2,
		Visible = false
	})
	local bar = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 255, 0),
		BorderSizePixel = 0,
		ZIndex = 3,
		Visible = false
	})
	return outline, back, bar
end

getgenv().ESPColors = getgenv().ESPColors or {
	Name = Color3.fromRGB(255, 255, 255),
	Item = Color3.fromRGB(255, 255, 255),
	Distance = Color3.fromRGB(255, 255, 255),
	Box = Color3.fromRGB(255, 255, 255),
	Health = Color3.fromRGB(0, 255, 0),
	Chams = Color3.fromRGB(255, 255, 255)
}

local showName, showItem, showDist, showHealth, showBox, showChams = false, false, false, false, false, false

local function applyChamsToCharacter(p, char)
	if p == LocalPlayer then return end
	if not char then return end
	local existing = char:FindFirstChild("ThermalHighlight")
	if existing then pcall(function() existing:Destroy() end) end
	if showChams then
		local h = Instance.new("Highlight")
		h.Name = "ThermalHighlight"
		h.Adornee = char
		h.OutlineTransparency = 1
		h.FillColor = getgenv().ESPColors.Chams
		h.FillTransparency = 0.6
		h.Parent = char
	end
end

local function clearAllChams()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local c = p.Character:FindFirstChild("ThermalHighlight")
			if c then pcall(function() c:Destroy() end) end
		end
	end
end

local function LerpColor(health, userColor)
	local hc = math.clamp(health, 0, 1)
	if hc < 0.5 then
		local g = math.floor(math.clamp(hc * 510, 0, 255))
		return Color3.fromRGB(255, g, 0)
	else
		local t = (hc - 0.5) * 2
		local r_start, g_start, b_start = 255, 255, 0
		local r_end = math.floor(userColor.R * 255)
		local g_end = math.floor(userColor.G * 255)
		local b_end = math.floor(userColor.B * 255)
		local r = math.floor(r_start + (r_end - r_start) * t)
		local g = math.floor(g_start + (g_end - g_start) * t)
		local b = math.floor(b_start + (b_end - b_start) * t)
		return Color3.fromRGB(r, g, b)
	end
end

local function PlayerESP(player)
	if player == LocalPlayer then return end
	DupeCheck(player.Name)

	local nameT = CreateTextLabel()
	local itemT = CreateTextLabel()
	local distT = CreateTextLabel()
	table.insert(Drawn[player.Name], nameT)
	table.insert(Drawn[player.Name], itemT)
	table.insert(Drawn[player.Name], distT)

	local TL_H, TL_V = makeCorner()
	local TR_H, TR_V = makeCorner()
	local BL_H, BL_V = makeCorner()
	local BR_H, BR_V = makeCorner()
	for _, v in ipairs({ TL_H, TL_V, TR_H, TR_V, BL_H, BL_V, BR_H, BR_V }) do
		table.insert(Drawn[player.Name], v)
	end

	local healthOutline, healthBack, healthBar = createHealthParts()
	table.insert(Drawn[player.Name], healthOutline)
	table.insert(Drawn[player.Name], healthBack)
	table.insert(Drawn[player.Name], healthBar)

	local con = RunService.RenderStepped:Connect(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not char or not hrp or not hum or hum.Health <= 0 then
			for _, v in ipairs(Drawn[player.Name]) do if typeof(v) == "Instance" then v.Visible = false end end
			return
		end

		local screenPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
		local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
		if not onScreen or dist > MaxDistance then
			for _, v in ipairs(Drawn[player.Name]) do if typeof(v) == "Instance" then v.Visible = false end end
			return
		end

		local scale = math.clamp(11.5 / (screenPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5))) * 100, 8, 500)
		local w, h = 2 * scale, 3 * scale

		if showName then
			nameT.Text = player.Name
			nameT.TextColor3 = getgenv().ESPColors.Name
			nameT.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - h / 2 - 16)
			nameT.Visible = true
		else
			nameT.Visible = false
		end

		local baseY = screenPos.Y + h / 2 + 8
		local nextY = baseY

		if showItem then
			local tool = char:FindFirstChildOfClass("Tool")
			local itemName = tool and tool.Name or "[None]"
			itemT.Text = itemName
			itemT.TextColor3 = getgenv().ESPColors.Item
			itemT.Position = UDim2.new(0, screenPos.X, 0, nextY)
			itemT.Visible = true
			nextY = nextY + 18
		else
			itemT.Visible = false
		end

		if showDist then
			local distText = string.format("%.0f ", dist)
			distT.Text = distText
			distT.TextColor3 = getgenv().ESPColors.Distance
			distT.Position = UDim2.new(0, screenPos.X, 0, nextY)
			distT.Visible = true
			nextY = nextY + 18
		else
			distT.Visible = false
		end

		if showBox then
			local cornerWidth, cornerHeight, cornerThickness = 6, 1, 1
			TL_H.Size, TR_H.Size, BL_H.Size, BR_H.Size = UDim2.new(0, cornerWidth, 0, cornerHeight), UDim2.new(0, cornerWidth, 0, cornerHeight), UDim2.new(0, cornerWidth, 0, cornerHeight), UDim2.new(0, cornerWidth, 0, cornerHeight)
			TL_V.Size, TR_V.Size, BL_V.Size, BR_V.Size = UDim2.new(0, cornerThickness, 0, cornerWidth), UDim2.new(0, cornerThickness, 0, cornerWidth), UDim2.new(0, cornerThickness, 0, cornerWidth), UDim2.new(0, cornerThickness, 0, cornerWidth)

			TL_H.Position = UDim2.new(0, screenPos.X - w / 2, 0, screenPos.Y - h / 2)
			TL_V.Position = UDim2.new(0, screenPos.X - w / 2, 0, screenPos.Y - h / 2)
			TR_H.Position = UDim2.new(0, screenPos.X + w / 2 - cornerWidth, 0, screenPos.Y - h / 2)
			TR_V.Position = UDim2.new(0, screenPos.X + w / 2 - cornerThickness, 0, screenPos.Y - h / 2)
			BL_H.Position = UDim2.new(0, screenPos.X - w / 2, 0, screenPos.Y + h / 2 - cornerHeight)
			BL_V.Position = UDim2.new(0, screenPos.X - w / 2, 0, screenPos.Y + h / 2 - cornerWidth)
			BR_H.Position = UDim2.new(0, screenPos.X + w / 2 - cornerWidth, 0, screenPos.Y + h / 2 - cornerHeight)
			BR_V.Position = UDim2.new(0, screenPos.X + w / 2 - cornerThickness, 0, screenPos.Y + h / 2 - cornerWidth)

			for _, f in ipairs({ TL_H, TL_V, TR_H, TR_V, BL_H, BL_V, BR_H, BR_V }) do
				f.BackgroundColor3 = getgenv().ESPColors.Box
				f.Visible = true
			end
		else
			for _, v in ipairs({ TL_H, TL_V, TR_H, TR_V, BL_H, BL_V, BR_H, BR_V }) do v.Visible = false end
		end

		if showHealth then
			local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			local barHeight = h
			local filled = barHeight * healthPercent
			local barX = screenPos.X - w / 2 - 4
			local barY = screenPos.Y - h / 2
			local barWidth = 2

			healthOutline.Position = UDim2.new(0, barX - 1, 0, barY - 1)
			healthOutline.Size = UDim2.new(0, barWidth + 2, 0, barHeight + 2)
			healthBack.Position = UDim2.new(0, barX, 0, barY)
			healthBack.Size = UDim2.new(0, barWidth, 0, barHeight)
			healthBar.Position = UDim2.new(0, barX, 0, barY + (barHeight - filled))
			healthBar.Size = UDim2.new(0, barWidth, 0, filled)
			healthBar.BackgroundColor3 = LerpColor(healthPercent, getgenv().ESPColors.Health)
			healthOutline.Visible, healthBack.Visible, healthBar.Visible = true, true, true
		else
			healthOutline.Visible, healthBack.Visible, healthBar.Visible = false, false, false
		end
	end)

	table.insert(Drawn[player.Name], con)
	table.insert(Connections, con)
end

local function SetupPlayer(p)
	PlayerESP(p)
	p.CharacterAdded:Connect(function() task.wait(1) PlayerESP(p) end)
end

for _, p in ipairs(Players:GetPlayers()) do task.spawn(function() SetupPlayer(p) end) end
Players.PlayerAdded:Connect(function(p) task.spawn(function() SetupPlayer(p) end) end)

if typeof(ESPGroupbox) == "table" or typeof(ESPGroupbox) == "Instance" then
    if not getgenv().ESPInitialized then
        getgenv().ESPInitialized = true

        ESPGroupbox:AddToggle('NameESP', {
            Text = 'Name',
            Default = false,
            Callback = function(v)
                showName = v
            end
        }):AddColorPicker('NameColor', {
            Text = 'Name',
            Default = getgenv().ESPColors.Name,
            Callback = function(v)
                getgenv().ESPColors.Name = v
            end
        })

        ESPGroupbox:AddToggle('ItemESP', {
            Text = 'Item',
            Default = false,
            Callback = function(v)
                showItem = v
            end
        }):AddColorPicker('ItemColor', {
            Text = 'Item',
            Default = getgenv().ESPColors.Item,
            Callback = function(v)
                getgenv().ESPColors.Item = v
            end
        })

        ESPGroupbox:AddToggle('DistanceESP', {
            Text = 'Distance',
            Default = false,
            Callback = function(v)
                showDist = v
            end
        }):AddColorPicker('DistanceColor', {
            Text = 'Distance ',
            Default = getgenv().ESPColors.Distance,
            Callback = function(v)
                getgenv().ESPColors.Distance = v
            end
        })

        ESPGroupbox:AddToggle('HealthESP', {
            Text = 'Health Bar',
            Default = false,
            Callback = function(v)
                showHealth = v
            end
        }):AddColorPicker('HealthColor', {
            Text = 'Health ',
            Default = getgenv().ESPColors.Health,
            Callback = function(v)
                getgenv().ESPColors.Health = v
            end
        })

        ESPGroupbox:AddToggle('BoxESP', {
            Text = 'Corner Box',
            Default = false,
            Callback = function(v)
                showBox = v
            end
        }):AddColorPicker('BoxColor', {
            Text = 'Box',
            Default = getgenv().ESPColors.Box,
            Callback = function(v)
                getgenv().ESPColors.Box = v
            end
        })

        ESPGroupbox:AddToggle('ChamsESP', {
            Text = 'Chams',
            Default = false,
            Callback = function(v)
                showChams = v
                if showChams then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            applyChamsToCharacter(p, p.Character)
                        end
                        p.CharacterAdded:Connect(function(c)
                            applyChamsToCharacter(p, c)
                        end)
                    end
                else
                    clearAllChams()
                end
            end
        }):AddColorPicker('ChamsColor', {
            Text = 'Chams',
            Default = getgenv().ESPColors.Chams,
            Callback = function(v)
                getgenv().ESPColors.Chams = v
                if showChams then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local h = p.Character:FindFirstChild("ThermalHighlight")
                            if h then
                                h.FillColor = v
                            end
                        end
                    end
                end
            end
        })
    end
end




local Tab1 = TabBox:AddTab('Local Player')
local Tab2 = TabBox:AddTab('Local Weapon')

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GunChamsEnabled = false
local GunChamsRainbow = false
local GunChamsColor = Color3.fromRGB(255, 0, 0)
local GunChamsTransparency = 0.3
local OriginalGunStates = {}
local CurrentTool = nil
local GunHighlight = nil

local function ApplyChams(tool)
    if not GunChamsEnabled or not tool then return end
    local color = GunChamsRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or GunChamsColor
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            if not OriginalGunStates[part] then
                OriginalGunStates[part] = {Color = part.Color, Transparency = part.Transparency}
            end
            pcall(function()
                part.Color = color
                part.Transparency = math.clamp(GunChamsTransparency, 0, 0.9)
            end)
        end
    end
    if not GunHighlight or GunHighlight.Adornee ~= tool then
        if GunHighlight then pcall(function() GunHighlight:Destroy() end) end
        GunHighlight = Instance.new("Highlight")
        GunHighlight.Adornee = tool
        GunHighlight.Parent = tool
    end
    GunHighlight.FillTransparency = 1
    GunHighlight.OutlineTransparency = 0
    GunHighlight.OutlineColor = color
end

local function ResetGunChams()
    for part, data in pairs(OriginalGunStates) do
        if part and part.Parent then
            pcall(function()
                part.Color = data.Color
                part.Transparency = data.Transparency
            end)
        end
    end
    OriginalGunStates = {}
    if GunHighlight then
        pcall(function() GunHighlight:Destroy() end)
        GunHighlight = nil
    end
end

local function HookTool(tool)
    if not tool:IsA("Tool") then return end
    tool.Equipped:Connect(function()
        CurrentTool = tool
        if GunChamsEnabled then ApplyChams(tool) end
    end)
    tool.Unequipped:Connect(function()
        if CurrentTool == tool then
            ResetGunChams()
            CurrentTool = nil
        end
    end)
end

local function HookCharacter(char)
    char.ChildAdded:Connect(HookTool)
    for _, child in ipairs(char:GetChildren()) do
        HookTool(child)
    end
end

if LocalPlayer.Character then HookCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookCharacter)

Tab2:AddToggle("GunChamsToggle", {
    Text = "Enable Gun Chams",
    Default = GunChamsEnabled,
    Callback = function(state)
        GunChamsEnabled = state
        if state and CurrentTool then ApplyChams(CurrentTool) else ResetGunChams() end
    end
}):AddColorPicker("GunChamsColor", {
    Default = GunChamsColor,
    Title = "Gun Chams Color",
    Callback = function(v)
        GunChamsColor = v
        if GunChamsEnabled and CurrentTool then ApplyChams(CurrentTool) end
    end
})

Tab2:AddToggle("GunChamsRainbow", {
    Text = "Rainbow Gun Chams",
    Default = GunChamsRainbow,
    Callback = function(state)
        GunChamsRainbow = state
    end
})

Tab2:AddSlider("GunChamsTransparency", {
    Text = "Gun Transparency",
    Default = GunChamsTransparency,
    Min = 0,
    Max = 0.9,
    Rounding = 2,
    Callback = function(value)
        GunChamsTransparency = value
        if GunChamsEnabled and CurrentTool then ApplyChams(CurrentTool) end
    end
})

local PlayerChamsEnabled = false
local PlayerChamsRainbow = false
local PlayerChamsColor = Color3.fromRGB(0, 255, 255)
local PlayerOutlineEnabled = true
local PlayerOutlineColor = Color3.fromRGB(0, 0, 0)
local PlayerChamsTransparency = 0.3
local PlayerChamsMaterial = Enum.Material.ForceField
local OriginalStates = {}
local CharacterOutline = nil

local function updateOutline(char)
    if not char then return end
    if PlayerOutlineEnabled and PlayerChamsEnabled then
        if not CharacterOutline or CharacterOutline.Adornee ~= char then
            if CharacterOutline then pcall(function() CharacterOutline:Destroy() end) end
            CharacterOutline = Instance.new("Highlight")
            CharacterOutline.Adornee = char
            CharacterOutline.Parent = char
        end
        CharacterOutline.FillTransparency = 1
        CharacterOutline.OutlineTransparency = 0
        CharacterOutline.OutlineColor = PlayerOutlineColor
    elseif CharacterOutline then
        pcall(function() CharacterOutline:Destroy() end)
        CharacterOutline = nil
    end
end

local function ApplyPlayerChams(char)
    if not PlayerChamsEnabled or not char then return end
    local color = PlayerChamsRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or PlayerChamsColor
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not OriginalStates[part] then
                OriginalStates[part] = {Material = part.Material, Transparency = part.Transparency, Color = part.Color}
            end
            pcall(function()
                part.Material = PlayerChamsMaterial
                part.Color = color
                part.Transparency = (PlayerChamsMaterial == Enum.Material.Glass)
                    and PlayerChamsTransparency
                    or math.clamp(PlayerChamsTransparency, 0, 0.9)
            end)
        end
    end
    updateOutline(char)
end

local function ResetPlayerChams()
    for part, data in pairs(OriginalStates) do
        if part and part.Parent then
            pcall(function()
                part.Material = data.Material
                part.Transparency = data.Transparency
                part.Color = data.Color
            end)
        end
    end
    OriginalStates = {}
    if CharacterOutline then
        pcall(function() CharacterOutline:Destroy() end)
        CharacterOutline = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if PlayerChamsEnabled then
        task.wait(0.5)
        ApplyPlayerChams(char)
    end
    if humanoid then
        humanoid.Died:Connect(function()
            OriginalStates = {}
            if CharacterOutline then
                pcall(function() CharacterOutline:Destroy() end)
                CharacterOutline = nil
            end
        end)
    end
end)

Tab1:AddToggle("PlayerChamsToggle", {
    Text = "Enable Player Chams",
    Default = PlayerChamsEnabled,
    Callback = function(state)
        PlayerChamsEnabled = state
        if state and LocalPlayer.Character then ApplyPlayerChams(LocalPlayer.Character) else ResetPlayerChams() end
    end
}):AddColorPicker("PlayerChamsColor", {
    Default = PlayerChamsColor,
    Title = "Player Chams Color",
    Callback = function(v)
        PlayerChamsColor = v
        if PlayerChamsEnabled and LocalPlayer.Character then ApplyPlayerChams(LocalPlayer.Character) end
    end
})

Tab1:AddToggle("PlayerChamsRainbow", {
    Text = "Rainbow Player Chams",
    Default = PlayerChamsRainbow,
    Callback = function(state)
        PlayerChamsRainbow = state
    end
})

Tab1:AddToggle("PlayerOutlineToggle", {
    Text = "Outline",
    Default = PlayerOutlineEnabled,
    Callback = function(state)
        PlayerOutlineEnabled = state
        if PlayerChamsEnabled and LocalPlayer.Character then updateOutline(LocalPlayer.Character) end
    end
}):AddColorPicker("PlayerChamsOutlineColor", {
    Default = PlayerOutlineColor,
    Title = "Outline Color",
    Callback = function(v)
        PlayerOutlineColor = v
        if PlayerChamsEnabled and LocalPlayer.Character then updateOutline(LocalPlayer.Character) end
    end
})

Tab1:AddSlider("PlayerChamsTransparency", {
    Text = "Chams Transparency",
    Default = PlayerChamsTransparency,
    Min = 0,
    Max = 0.9,
    Rounding = 2,
    Callback = function(value)
        PlayerChamsTransparency = value
        if PlayerChamsEnabled and LocalPlayer.Character then ApplyPlayerChams(LocalPlayer.Character) end
    end
})

Tab1:AddDropdown("PlayerChamsMaterial", {
    Values = {"ForceField", "Neon", "Foil", "Glass"},
    Default = "ForceField",
    Multi = false,
    Text = "Chams Material",
    Callback = function(value)
        PlayerChamsMaterial = Enum.Material[value] or Enum.Material.ForceField
        if PlayerChamsEnabled and LocalPlayer.Character then ApplyPlayerChams(LocalPlayer.Character) end
    end
})

RunService.RenderStepped:Connect(function()
    if GunChamsEnabled and GunChamsRainbow and CurrentTool then ApplyChams(CurrentTool) end
    if PlayerChamsEnabled and PlayerChamsRainbow and LocalPlayer.Character then ApplyPlayerChams(LocalPlayer.Character) end
end)







local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Lighting = cloneref(game:GetService("Lighting"))
local Workspace = cloneref(game:GetService("Workspace"))
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

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
}

ExtraBox:AddToggle('InfiniteHunger', {
    Text = 'Infinite Hunger',
    Default = false,
    Callback = function(v) ModFlags.InfiniteHunger = v end,
})

ExtraBox:AddToggle('InfiniteStamina', {
    Text = 'Infinite Stamina',
    Default = false,
    Callback = function(v) ModFlags.InfiniteStamina = v end,
})

ExtraBox:AddToggle('InfiniteSleep', {
    Text = 'Infinite Sleep',
    Default = false,
    Callback = function(v) ModFlags.InfiniteSleep = v end,
})

ExtraBox:AddToggle('DisableCameraBobbing', {
    Text = 'Disable Camera Bobbing',
    Default = false,
    Callback = function(v) ModFlags.DisableCameraBobbing = v end,
})

ExtraBox:AddToggle('DisableBloodEffects', {
    Text = 'Disable Blood Effects',
    Default = false,
    Callback = function(v) ModFlags.DisableBloodEffects = v end,
})

ExtraBox:AddToggle('NoFallDamage', {
    Text = 'No Fall Damage',
    Default = false,
    Callback = function(v) ModFlags.NoFallDamage = v end,
})

ExtraBox:AddToggle('NoJumpCooldown', {
    Text = 'No Jump Cooldown',
    Default = false,
    Callback = function(v) ModFlags.NoJumpCooldown = v end,
})

ExtraBox:AddToggle('NoRentPay', {
    Text = 'No Rent Pay',
    Default = false,
    Callback = function(v) ModFlags.NoRentPay = v end,
})

ExtraBox:AddToggle('DisableCameras', {
    Text = 'Disable Cameras',
    Default = false,
    Callback = function(v) ModFlags.DisableCameras = v end,
})

ExtraBox:AddToggle('NoKnockback', {
    Text = 'No Knockback',
    Default = false,
    Callback = function(v) ModFlags.NoKnockback = v end,
})

ExtraBox:AddToggle('RespawnWhereYouDied', {
    Text = 'Respawn Where You Died',
    Default = false,
    Callback = function(v) ModFlags.RespawnWhereYouDied = v end,
})

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

LocalPlayer.CharacterAdded:Connect(function()
    if ModFlags.DisableCameras and Lighting:FindFirstChild("Shiesty") then
        local remote = Lighting.Shiesty:FindFirstChildWhichIsA("RemoteEvent", true)
        if remote then remote:FireServer() end
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

local DeathFrame = nil

local function SetupCharacterEvents(char)
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    hum.Died:Connect(function() DeathFrame = root.CFrame end)
    char.DescendantAdded:Connect(function(desc)
        if (desc:IsA("BodyVelocity") or desc:IsA("LinearVelocity") or desc:IsA("VectorForce")) and ModFlags.NoKnockback then
            task.wait()
            desc:Destroy()
        end
    end)
    if ModFlags.RespawnWhereYouDied and typeof(DeathFrame) == "CFrame" then
        root.CFrame = DeathFrame
    end
end

if Character then SetupCharacterEvents(Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacterEvents)

local FullbrightEnabled = false
local OriginalSettings = {}

local function enableFullbright()
    if not next(OriginalSettings) then
        OriginalSettings.Brightness = Lighting.Brightness
        OriginalSettings.ClockTime = Lighting.ClockTime
        OriginalSettings.FogEnd = Lighting.FogEnd
        OriginalSettings.GlobalShadows = Lighting.GlobalShadows
        OriginalSettings.OutdoorAmbient = Lighting.OutdoorAmbient
    end
    Lighting.Brightness = 2
    Lighting.ClockTime = 12
    Lighting.FogEnd = 1e5
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

local function disableFullbright()
    for prop, val in pairs(OriginalSettings) do
        Lighting[prop] = val
    end
end

ExtraBox:AddToggle('FullbrightToggle', {
    Text = 'Fullbright',
    Default = false,
}):OnChanged(function(v)
    FullbrightEnabled = v
    if v then
        enableFullbright()
    else
        disableFullbright()
    end
end)

ExtraBox:AddToggle('Noclip', {
    Text = 'Noclip',
    Default = false,
}):OnChanged(function(state)
    local player = Players.LocalPlayer
    local character = player.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = not state
            end
        end
    end
end)






local ReplicatedStorage = game:GetService("ReplicatedStorage")
local autoDrop = false
local dropAmount = 10000

local function autoDropLoop()
    while autoDrop do
        ReplicatedStorage.BankProcessRemote:InvokeServer("Drop", tostring(dropAmount))
        task.wait(0.25)
    end
end

DropBox:AddInput('DropAmount', {
    Default = '10000',
    Numeric = true,
    Text = 'Drop Amount',
    Tooltip = 'How much money to auto drop',
    Callback = function(value)
        local num = tonumber(value)
        if num then
            dropAmount = num
        end
    end,
})

DropBox:AddToggle('AutoDrop', {
    Text = 'Auto Drop',
    Default = false,
    Callback = function(state)
        autoDrop = state
        if state then
            task.spawn(autoDropLoop)
        end
    end,
})



local autoDepo = false
local depoAmount = 30000
local autoWithd = false
local withdAmount = 90000
local BankAction = ReplicatedStorage.BankAction

local function autoDepositLoop()
    while autoDepo do
        BankAction:FireServer('depo', depoAmount)
        task.wait(3)
    end
end

local function autoWithdrawLoop()
    while autoWithd do
        BankAction:FireServer('with', withdAmount)
        task.wait(3)
    end
end

BankBox:AddInput('DepositAmount', {
    Default = '30000',
    Numeric = true,
    Text = 'Deposit Amount',
    Tooltip = 'How much money to auto deposit',
    Callback = function(value)
        local num = tonumber(value)
        if num then
            depoAmount = num
        end
    end,
})

BankBox:AddToggle('AutoDeposit', {
    Text = 'Auto Deposit',
    Default = false,
    Callback = function(state)
        autoDepo = state
        if state then
            task.spawn(autoDepositLoop)
        end
    end,
})

BankBox:AddInput('WithdrawAmount', {
    Default = '90000',
    Numeric = true,
    Text = 'Withdraw Amount',
    Tooltip = 'How much money to auto withdraw',
    Callback = function(value)
        local num = tonumber(value)
        if num then
            withdAmount = num
        end
    end,
})

BankBox:AddToggle('AutoWithdraw', {
    Text = 'Auto Withdraw',
    Default = false,
    Callback = function(state)
        autoWithd = state
        if state then
            task.spawn(autoWithdrawLoop)
        end
    end,
})

BankBox:AddButton('ATM GUI', function()
    local playerGui = getgenv().Players.LocalPlayer
        and getgenv().Players.LocalPlayer:FindFirstChild('PlayerGui')
    if playerGui then
        local atmGui = playerGui:FindFirstChild('ATMGui')
        if atmGui then
            atmGui:Destroy() 
        end
        if getgenv().Lighting.Assets and getgenv().Lighting.Assets.GUI and getgenv().Lighting.Assets.GUI:FindFirstChild('ATMGui') then
            local clone = getgenv().Lighting.Assets.GUI.ATMGui:Clone()
            clone.Parent = playerGui
            if clone.Frame and clone.Frame.closeBtn then
                clone.Frame.closeBtn.MouseButton1Click:Connect(function()
                    clone:Destroy()
                end)
            end
        end
    end
end)





local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local moveConnection
local stayUpEnabled = false

local function keepUpright()
	local char = player.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z))
		end
	end
end

local function startStayUp()
	if moveConnection then moveConnection:Disconnect() end
	moveConnection = RunService.Heartbeat:Connect(function()
		if stayUpEnabled then
			keepUpright()
		end
	end)
end

local function stopStayUp()
	if moveConnection then
		moveConnection:Disconnect()
		moveConnection = nil
	end
end


ExtraBox1:AddToggle('StayUpToggle', {
	Text = 'Disable Falling Over',
	Default = false,
	Tooltip = 'Keeps you upright',
})

Toggles.StayUpToggle:OnChanged(function(value)
	stayUpEnabled = value
	if stayUpEnabled then
		startStayUp()
	else
		stopStayUp()
	end
end)



ExtraBox1:AddButton("Teleport to Bank", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-202.7586, 283.6267, -1222.1841)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Cash Wash", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-987.11, 253.72, -685.13)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Penthouse", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-163, 397, -594)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Apartment", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-613.7843017578125, 356.49395751953125, -689.0292358398438)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Gunshop 1", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(92976.28125, 122097.953125, 17022.783203125)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Gunshop 2", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(66192.453, 123615.711, 5744.736)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Gunshop 3", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(72426.188, 128855.641, -1081.063)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Dealership", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-385.97552490234375, 253.4141082763672, -1236.3612060546875)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Backpack", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-670.86, 253.60, -682.25)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Market", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-388.34, 340.34, -562.64)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Abandonded($$$)", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-733.03, 286.94, -779.16)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Studio($$$)", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(93426.23 + 2, 14484.71, 561.80)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to House 1", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-670, 256, -484)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to House 2", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-647, 256, -485)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Hospital", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1590.833251953125, 254.272216796875, 18.926502227783203)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to MarGreens", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-336.8796691894531, 254.45382690429688, -394.1875)
    task.wait(2)
    FadeOut(0.4)
end)

ExtraBox1:AddButton("Teleport to Dollar Central", function()
    FadeIn(0.3)
    LocalPlayer.Character.Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-393.72430419921875, 253.82049560546875, -1108.29052734375)
    task.wait(2)
    FadeOut(0.4)
end)













getgenv().Players = game:GetService("Players")
getgenv().RunService = game:GetService("RunService")
getgenv().UserInputService = game:GetService("UserInputService")
getgenv().ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
getgenv().Workspace = game:GetService("Workspace")
getgenv().LocalPlayer = getgenv().Players.LocalPlayer
getgenv().Camera = workspace.CurrentCamera

getgenv().Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(c) getgenv().Character = c end)

getgenv().CarFlyEnabled = false
getgenv().CarFlySpeed = 100
getgenv().FLYING = false
getgenv().CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
getgenv().OriginalCollisions = {}
getgenv().InfiniteJumpEnabled = false
getgenv().Running = false

local Platform, PlatformWeld, FlyBV, FlyBG, VehicleModel, VehiclePart, CarFlyConnection

local function getVehicle()
    local h = Character and Character:FindFirstChildOfClass("Humanoid")
    if h and h.SeatPart and h.SeatPart:IsA("VehicleSeat") then
        local m = h.SeatPart:FindFirstAncestorOfClass("Model")
        return m, m and (m.PrimaryPart or h.SeatPart)
    end
end

local function setCollisions(m, e)
    if not m then return end
    for _,p in ipairs(m:GetDescendants()) do
        if p:IsA("BasePart") then
            if e then
                if OriginalCollisions[p]~=nil then
                    p.CanCollide = OriginalCollisions[p]
                    OriginalCollisions[p] = nil
                end
            else
                if OriginalCollisions[p]==nil then
                    OriginalCollisions[p] = p.CanCollide
                    p.CanCollide = false
                end
            end
        end
    end
end

local function startCarFly()
    if FLYING then return end
    VehicleModel, VehiclePart = getVehicle()
    if not VehiclePart then return end
    FLYING = true
    setCollisions(VehicleModel,false)
    Platform = Instance.new("Part")
    Platform.Size = Vector3.new(8,1,12)
    Platform.CFrame = VehiclePart.CFrame * CFrame.new(0,-VehiclePart.Size.Y/2-Platform.Size.Y/2-0.5,0)
    Platform.Anchored = false
    Platform.CanCollide = false
    Platform.Transparency = 1
    Platform.Massless = true
    Platform.Parent = Workspace
    PlatformWeld = Instance.new("WeldConstraint")
    PlatformWeld.Part0 = Platform
    PlatformWeld.Part1 = VehicleModel.PrimaryPart or VehiclePart
    PlatformWeld.Parent = Platform
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
    FlyBV.P = 12500
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = Platform
    FlyBG = Instance.new("BodyGyro")
    FlyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
    FlyBG.P = 90000
    FlyBG.D = 3000
    FlyBG.CFrame = Platform.CFrame
    FlyBG.Parent = Platform
    Camera.CameraSubject = Character:FindFirstChild("Humanoid")
    Camera.CameraType = Enum.CameraType.Custom
    CarFlyConnection = RunService.RenderStepped:Connect(function()
        if not FLYING or not Platform or not VehiclePart then return end
        local mv = Vector3.zero
        if CONTROL.F~=0 then mv+=Camera.CFrame.LookVector*CONTROL.F end
        if CONTROL.B~=0 then mv-=Camera.CFrame.LookVector*CONTROL.B end
        if CONTROL.L~=0 then mv-=Camera.CFrame.RightVector*CONTROL.L end
        if CONTROL.R~=0 then mv+=Camera.CFrame.RightVector*CONTROL.R end
        if CONTROL.E~=0 then mv+=Camera.CFrame.UpVector*CONTROL.E end
        if CONTROL.Q~=0 then mv-=Camera.CFrame.UpVector*CONTROL.Q end
        FlyBV.Velocity = mv.Magnitude>0 and mv.Unit*CarFlySpeed or Vector3.zero
        local look=Camera.CFrame.LookVector
        FlyBG.CFrame=CFrame.new(Platform.Position,Platform.Position+look)
    end)
end

local function stopCarFly()
    FLYING=false
    if CarFlyConnection then CarFlyConnection:Disconnect() CarFlyConnection=nil end
    if FlyBV then FlyBV:Destroy() FlyBV=nil end
    if FlyBG then FlyBG:Destroy() FlyBG=nil end
    if PlatformWeld then PlatformWeld:Destroy() PlatformWeld=nil end
    if Platform then Platform:Destroy() Platform=nil end
    if VehicleModel then setCollisions(VehicleModel,true) end
end

UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.W then CONTROL.F=1
    elseif i.KeyCode==Enum.KeyCode.S then CONTROL.B=1
    elseif i.KeyCode==Enum.KeyCode.A then CONTROL.L=1
    elseif i.KeyCode==Enum.KeyCode.D then CONTROL.R=1
    elseif i.KeyCode==Enum.KeyCode.E then CONTROL.E=1
    elseif i.KeyCode==Enum.KeyCode.Q then CONTROL.Q=1 end
end)

UserInputService.InputEnded:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.W then CONTROL.F=0
    elseif i.KeyCode==Enum.KeyCode.S then CONTROL.B=0
    elseif i.KeyCode==Enum.KeyCode.A then CONTROL.L=0
    elseif i.KeyCode==Enum.KeyCode.D then CONTROL.R=0
    elseif i.KeyCode==Enum.KeyCode.E then CONTROL.E=0
    elseif i.KeyCode==Enum.KeyCode.Q then CONTROL.Q=0 end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local moveConnection
local movementEnabled = false
local currentWalkSpeed = 16
local fastFallSpeed = -200 

local function getHumanoid()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
end

local function keepUpright()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.RotVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z))
        end
    end
end

local function isGrounded(hrp)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), rayParams)
    return ray ~= nil
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

local function stopWalkLoop()
    if moveConnection then
        moveConnection:Disconnect()
        moveConnection = nil
    end
    keepUpright()
end

WalkGroupbox:AddToggle('WalkSpeedToggle', {
    Text = 'Enable WalkSpeed',
    Default = false,
})

Toggles.WalkSpeedToggle:OnChanged(function(value)
    movementEnabled = value
    if movementEnabled then
        startWalkLoop()
    else
        stopWalkLoop()
    end
end)

WalkGroupbox:AddSlider('WalkSpeedSlider', {
    Text = 'WalkSpeed',
    Default = 16,
    Min = 10,
    Max = 100,
    Rounding = 0,
})

Options.WalkSpeedSlider:OnChanged(function(value)
    currentWalkSpeed = value
end)

WalkGroupbox:AddToggle('CarFlyToggle', {
    Text = 'Car Fly',
    Default = false,
}):AddKeyPicker('CarFlyKeybind', {
    Default = 'F',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Car Fly Keybind',
    NoUI = false,
})

Toggles.CarFlyToggle:OnChanged(function(state)
    CarFlyEnabled = state
    if state then
        startCarFly()
    else
        stopCarFly()
    end
end)



Options.CarFlyKeybind:OnClick(function()
    CarFlyEnabled = not CarFlyEnabled
    if CarFlyEnabled then
        startCarFly()
    else
        stopCarFly()
    end
end)

WalkGroupbox:AddSlider('CarFlySpeed', {
    Text = 'Car Fly Speed',
    Default = 100,
    Min = 20,
    Max = 300,
    Rounding = 1,
})

Options.CarFlySpeed:OnChanged(function(value)
    CarFlySpeed = value
end)




FarmsBox:AddButton('Construction Farm', function()
    FadeIn(0.3)
    local speaker = LocalPlayer
    if not speaker then return end

    local function getCharacter()
        return speaker.Character or speaker.CharacterAdded:Wait()
    end

    local function getBackpack()
        return speaker:FindFirstChild('Backpack')
    end

    local function hasPlyWood()
        local backpack = getBackpack()
        local character = getCharacter()
        return (backpack and backpack:FindFirstChild('PlyWood'))
            or (character and character:FindFirstChild('PlyWood'))
    end

    local function equipPlyWood()
        local backpack = getBackpack()
        if backpack then
            local plyWood = backpack:FindFirstChild('PlyWood')
            if plyWood then
                plyWood.Parent = getCharacter()
            end
        end
    end

    local function fireProximityPrompt(prompt)
        if prompt and prompt:IsA('ProximityPrompt') then
            fireproximityprompt(prompt)
        end
    end

    local function inlineTeleport(cframe)
        local char = speaker.Character
        if char and char:FindFirstChild('Humanoid') and char:FindFirstChild('HumanoidRootPart') then
            char.Humanoid:ChangeState(0)
            repeat task.wait() until not speaker:GetAttribute('LastACPos')
            char.HumanoidRootPart.CFrame = cframe
        end
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
            if not hasPlyWood() then
                grabWood()
            end
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
        if yourButton then yourButton:Click() end
        FadeOut(0.4)
    end)
end)

FarmsBox:AddButton('Studio Farm', function()
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

    local SwimMethod = false
    local FreeFallLoop

    local function UpdateFreeFall(state)
        if state then
            SwimMethod = true
            if not FreeFallLoop then
                FreeFallLoop = RunService.Heartbeat:Connect(function()
                    if playerHumanoid then
                        playerHumanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                    end
                end)
            end
        else
            SwimMethod = false
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
end)






GUIsBox:AddButton('Open Trunk', function()
    local playerGui = game:GetService('Players').LocalPlayer.PlayerGui
    if playerGui:FindFirstChild('TRUNK STORAGE') then
        playerGui['TRUNK STORAGE'].Enabled = true
    else
        Library:Notify('Trunk Storage GUI not found', 3)
    end
end)

GUIsBox:AddButton('Tattoo Shop', function()
    local playerGui = game:GetService('Players').LocalPlayer.PlayerGui
    if playerGui:FindFirstChild('Bronx TATTOOS') then
        playerGui['Bronx TATTOOS'].Enabled = true
    else
        Library:Notify('Bronx Tattoo GUI not found', 3)
    end
end)

GUIsBox:AddButton('Bronx Market', function()
    local Players = game:GetService('Players')
    local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild('PlayerGui')
    if playerGui and playerGui:FindFirstChild('Bronx Market 2') then
        playerGui['Bronx Market 2'].Enabled = true
    else
        Library:Notify('Bronx Market GUI not found', 3)
    end
end)









QuickShopLeftGroup:AddButton('Buy Shiesty', function()
    getgenv().ReplicatedStorage.ShopRemote:InvokeServer('Shiesty')
end)

QuickShopLeftGroup:AddButton('Buy BluGloves', function()
    getgenv().ReplicatedStorage.ShopRemote:InvokeServer('BluGloves')
end)

QuickShopLeftGroup:AddButton('Buy WhiteGloves', function()
    getgenv().ReplicatedStorage.ShopRemote:InvokeServer('WhiteGloves')
end)

QuickShopLeftGroup:AddButton('Buy BlackGloves', function()
    getgenv().ReplicatedStorage.ShopRemote:InvokeServer('BlackGloves')
end)

QuickShopLeftGroup:AddButton('Buy Bandage', function()
    getgenv().ReplicatedStorage.ShopRemote2:InvokeServer('Bandage')
end)



QuickShopRightGroup:AddButton('Buy IceFruit Bag', function()
    getgenv().ReplicatedStorage.ExoticShopRemote:InvokeServer('Ice-Fruit Bag')
end)

QuickShopRightGroup:AddButton('Buy Water', function()
    getgenv().ReplicatedStorage.ShopRemote:InvokeServer('Water')
end)

QuickShopRightGroup:AddButton('Buy Fiji Water', function()
    getgenv().ReplicatedStorage.ExoticShopRemote:InvokeServer('FijiWater')
end)

QuickShopRightGroup:AddButton('Buy IceFruit Cupz', function()
    getgenv().ReplicatedStorage.ExoticShopRemote:InvokeServer('Ice-Fruit Cupz')
end)

QuickShopRightGroup:AddButton('Buy Fresh Water', function()
    getgenv().ReplicatedStorage.ExoticShopRemote:InvokeServer('FreshWater')
end)

QuickShopRightGroup:AddButton('Buy Lemonade', function()
    getgenv().ReplicatedStorage.ExoticShopRemote:InvokeServer('Lemonade')
end)

QuickShopRightGroup:AddButton('Buy Fake Card', function()
    getgenv().ReplicatedStorage.ExoticShopRemote:InvokeServer('FakeCard')
end)


QuickShopRightGroup:AddButton('Buy G26', function()
    getgenv().ReplicatedStorage.ExoticShopRemote:InvokeServer('G26')
end)













local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')





MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

task.spawn(function()
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode.Name == Options.MenuKeybind.Value then
            Library:Toggle()
        end
    end)
end)




MenuGroup:AddDivider()
MenuGroup:AddButton("Unload", function() Library:Unload() end)



ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)


SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")

SaveManager:BuildConfigSection(Tabs["Settings"])
ThemeManager:ApplyToTab(Tabs["Settings"])
LoadAutoloadConfig()

Library:OnUnload(function()

end)







