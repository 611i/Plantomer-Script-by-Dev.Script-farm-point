-- Script Path: game:GetService("StarterGui").MainUI.Tabs.Crates.LocalScript
-- Optimized & Cleaned Version
-- Executor: Delta (1.1.735.1138)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local LocalPlayer = Players.LocalPlayer

local ScriptParent = script.Parent
local CratesFrame = ScriptParent:WaitForChild("CratesFrame")
local CratesHolder = CratesFrame:WaitForChild("CratesHolder"):WaitForChild("CratesContainer")
local NormalCrateBtn = CratesHolder:WaitForChild("Normal")
local PremiumCrateBtn = CratesHolder:WaitForChild("Premium")

local CratesInfoHolder = CratesFrame:WaitForChild("CratesInfoHolder")
local NormalCrateInfo = CratesInfoHolder:WaitForChild("NormalCrateInfo")
local NormalBuyBtn = NormalCrateInfo:WaitForChild("BuyButton")
local PremiumCrateInfo = CratesInfoHolder:WaitForChild("PremiumCrateInfo")
local PremiumBuyBtn = PremiumCrateInfo:WaitForChild("BuyButton")

local SkinsFrame = ScriptParent:WaitForChild("SkinsFrame")
local SkinsContainer = SkinsFrame:WaitForChild("SkinsHolder"):WaitForChild("SkinsContainer")

local SpinFrame = ScriptParent:WaitForChild("SpinFrame")
local ContinueButton = SpinFrame:WaitForChild("ContinueButton")
local ItemsContainer = SpinFrame:WaitForChild("ItemsFrame"):WaitForChild("ItemsContainer")

local CratesButton = ScriptParent:WaitForChild("CratesButton")
local SkinsButton = ScriptParent:WaitForChild("SkinsButton")
local OpeningCrateItemFrame = script:WaitForChild("OpeningCrateItemFrame")

local WeaponsSkins = require(Modules:WaitForChild("WeaponsSkins"))
local RandomGen = Random.new()

local spawnedItems = {}
local skinConnections = {}
local spawnedSkinFrames = {}
local isOpening = false
local isBuying = false
local isEventOpening = false
local previousTab = nil

local function lerp(pA, pB, pAlpha)
    return pA + (pB - pA) * pAlpha
end

local function tweenGraph(pVal, pPower)
    return 1 - (1 - math.clamp(pVal, 0, 1)) ^ pPower
end

local function OpenCrate(skinName, rarity, crateType, duration)
    if isOpening then return end
    isOpening = true

    local totalItems = RandomGen:NextInteger(20, 100)
    local targetIndex = RandomGen:NextInteger(15, totalItems - 5)

    for i = 1, totalItems do
        local currentRarity, currentSkinName
        if i == targetIndex then
            currentRarity = rarity
            currentSkinName = skinName
        else
            currentSkinName, currentRarity = WeaponsSkins.GetRandomSkin(crateType)
        end

        local itemClone = OpeningCrateItemFrame:Clone()
        itemClone.ItemName.Text = currentSkinName
        itemClone.ItemName.TextColor3 = WeaponsSkins.rarityColors[currentRarity]
        itemClone.Rarity.Text = WeaponsSkins.EnglishToArabic[currentRarity] or currentRarity
        itemClone.Rarity.TextColor3 = WeaponsSkins.rarityColors[currentRarity]
        itemClone.Parent = ItemsContainer
        table.insert(spawnedItems, itemClone)
    end

    ItemsContainer.Position = UDim2.new(0, 0, 0.5, 0)
    local itemSizeX = OpeningCrateItemFrame.Size.X.Scale
    local paddingX = ItemsContainer.UIListLayout.Padding.Scale
    local centerOffset = 0.5 - itemSizeX / 2
    local stepSize = -itemSizeX - paddingX
    local targetPos = centerOffset + (targetIndex - 1) * stepSize
    local randomOffset = RandomGen:NextNumber(-itemSizeX / 2, itemSizeX / 2)
    local finalStopPos = targetPos + randomOffset
    local startTime = tick()

    SpinFrame.CrateName.Text = WeaponsSkins.CrateNamesArabic[crateType] or crateType
    SpinFrame.Visible = true
    ContinueButton.Visible = false
    CratesFrame.Visible = false
    SkinsFrame.Visible = false
    CratesButton.Visible = false
    SkinsButton.Visible = false

    local tweenPower = RandomGen:NextNumber(2, 10)
    local lastIndex = 0

    while true do
        local elapsed = (tick() - startTime) / duration
        local alpha = tweenGraph(elapsed, tweenPower)
        local currentPos = lerp(0, finalStopPos, alpha)
        local normalized = (currentPos + randomOffset) / itemSizeX
        local currentIndex = math.abs(math.floor(normalized)) + 1

        if currentIndex ~= lastIndex then
            script.TickSound:Play()
            lastIndex = currentIndex
        end

        ItemsContainer.Position = UDim2.new(currentPos, 0, 0.5, 0)

        if elapsed >= 1 then
            isOpening = false
            ContinueButton.Visible = true
            break
        end

        RunService.Heartbeat:Wait()
    end
end

local function GetRarity(skinName)
    for rarity, list in pairs(WeaponsSkins.NormalWeaponSkins) do
        if table.find(list, skinName) then return rarity end
    end
    for rarity, list in pairs(WeaponsSkins.PremiumWeaponSkins) do
        if table.find(list, skinName) then return rarity end
    end
end

ScriptParent:GetPropertyChangedSignal("Visible"):Connect(function()
    if ScriptParent.Visible then
        if not isEventOpening then
            SpinFrame.Visible = false
            SkinsFrame.Visible = false
            CratesFrame.Visible = true
            CratesButton.Visible = true
            SkinsButton.Visible = true
        end
        for _, item in ipairs(spawnedItems) do
            item:Destroy()
        end
        spawnedItems = {}
    else
        for _, conn in ipairs(skinConnections) do
            conn:Disconnect()
        end
        skinConnections = {}
        for _, frame in ipairs(spawnedSkinFrames) do
            frame:Destroy()
        end
        spawnedSkinFrames = {}
    end
end)

SkinsFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not SkinsFrame.Visible then
        for _, conn in ipairs(skinConnections) do
            conn:Disconnect()
        end
        skinConnections = {}
        for _, frame in ipairs(spawnedSkinFrames) do
            frame:Destroy()
        end
        spawnedSkinFrames = {}
    end
end)

SkinsButton.Activated:Connect(function()
    script.Click:Play()
    if not SkinsFrame.Visible then
        CratesFrame.Visible = false
        SkinsFrame.Visible = true

        local success, ownedSkins = pcall(function()
            return Remotes.GetOwnedSkins:InvokeServer()
        end)

        if success and ownedSkins then
            for _, skinName in ipairs(ownedSkins) do
                if not string.find(skinName, "افتراضي") then
                    local skinTemplate = script.SkinTemplate:Clone()
                    skinTemplate.SkinName.Text = skinName
                    skinTemplate.Name = skinName

                    local rarity = GetRarity(skinName)
                    if rarity then
                        skinTemplate.SkinRarity.Text = rarity
                        skinTemplate.SkinRarity.TextColor3 = WeaponsSkins.rarityColors[rarity]
                        skinTemplate.LayoutOrder = WeaponsSkins.RarityLayoutOrder[rarity] or 0
                        skinTemplate.Parent = SkinsContainer
                    end

                    table.insert(spawnedSkinFrames, skinTemplate)

                    local equipConn = skinTemplate.Equip.Activated:Connect(function()
                        skinTemplate.Pop:Play()
                        CratesFrame.Visible = true
                        SkinsFrame.Visible = false
                        Remotes.ApplyWeaponSkin:FireServer(skinName)
                    end)
                    table.insert(skinConnections, equipConn)
                end
            end
        end
    end
end)

CratesButton.Activated:Connect(function()
    script.Click:Play()
    CratesFrame.Visible = true
    SkinsFrame.Visible = false
    for _, conn in ipairs(skinConnections) do
        conn:Disconnect()
    end
    skinConnections = {}
    for _, frame in ipairs(spawnedSkinFrames) do
        frame:Destroy()
    end
    spawnedSkinFrames = {}
end)

PremiumCrateBtn.Activated:Connect(function()
    script.Click:Play()
    NormalCrateInfo.Visible = false
    PremiumCrateInfo.Visible = true
end)

NormalCrateBtn.Activated:Connect(function()
    script.Click:Play()
    NormalCrateInfo.Visible = true
    PremiumCrateInfo.Visible = false
end)

local function BuyCrate(crateType)
    script.Click:Play()
    if isBuying then return end

    local success, rarity, skinName = pcall(function()
        return Remotes.BuyWeaponSkin:InvokeServer(crateType)
    end)

    if success and type(rarity) ~= "boolean" and skinName then
        isBuying = true
        local duration = RandomGen:NextNumber(3, 7)
        task.delay(duration, function()
            isBuying = false
        end)
        OpenCrate(skinName, rarity, crateType, duration)
    end
end

NormalBuyBtn.Activated:Connect(function()
    isEventOpening = false
    BuyCrate("Normal")
end)

PremiumBuyBtn.Activated:Connect(function()
    isEventOpening = false
    BuyCrate("Premium")
end)

Remotes.WeaponCrateSkin.OnClientEvent:Connect(function(rarity, skinName, crateType)
    local cratesMain = ScriptParent.Parent:FindFirstChild("Crates")
    if cratesMain and cratesMain:FindFirstChild("Crates") then
        cratesMain.Crates.Interactable = false
    end

    isEventOpening = true
    isBuying = true
    local duration = RandomGen:NextNumber(3, 7)
    
    task.delay(duration, function()
        isBuying = false
    end)

    for _, child in ipairs(ScriptParent.Parent:GetChildren()) do
        if child.Visible then
            previousTab = child
            break
        end
    end

    if previousTab then
        previousTab.Visible = false
    end

    CratesFrame.Visible = false
    CratesButton.Visible = false
    SkinsFrame.Visible = false
    SkinsButton.Visible = false
    ScriptParent.Visible = true

    task.wait(0.1)
    OpenCrate(skinName, rarity, crateType, duration)
end)

ContinueButton.Activated:Connect(function()
    for _, item in ipairs(spawnedItems) do
        item:Destroy()
    end
    spawnedItems = {}

    SpinFrame.Visible = false
    SkinsFrame.Visible = false
    CratesFrame.Visible = true
    CratesButton.Visible = true
    SkinsButton.Visible = true

    if isEventOpening then
        if previousTab then
            previousTab.Visible = true
            previousTab = nil
        end
        local cratesMain = ScriptParent.Parent:FindFirstChild("Crates")
        if cratesMain and cratesMain:FindFirstChild("Crates") then
            cratesMain.Crates.Interactable = true
        end
        ScriptParent.Visible = false
        isEventOpening = false
    else
        script.Click:Play()
    end
end)

