-- Unified script with auto fishing logic, teleport, inventory, and enhancements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Fish It Script",
    LoadingTitle = "Fish It ",
    LoadingSubtitle = "by AldyToi",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AldyToi",
        FileName = "FishIt"
    },
    KeySystem = false
})

-- Tabs
local MainTab = Window:CreateTab("Auto Fish", "fish")
local PlayerTab = Window:CreateTab("Player", "users-round")
local IslandsTab = Window:CreateTab("Islands", "map")
local SettingsTab = Window:CreateTab("Settings", "cog")
local DevTab = Window:CreateTab("Developer", "airplay")

-- Remotes
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SellRemote = Remotes.Server:FindFirstChild("SellAll") or Remotes:FindFirstChild("SellAllItems")
local EnchantRemote = Remotes.Server:FindFirstChild("ActivateEnchantingAltar") or Remotes:FindFirstChild("ActivateEnchant")

-- State
local autofish = false
local perfectCast = true
local ijump = false
local autoRecastDelay = 1.4
local enchantPos = Vector3.new(3231, -1303, 1402)

local function NotifySuccess(title, message)
	Rayfield:Notify({ Title = title, Content = message, Duration = 3, Image = "circle-check" })
end

local function NotifyError(title, message)
	Rayfield:Notify({ Title = title, Content = message, Duration = 3, Image = "ban" })
end

-- Developer Info
DevTab:CreateParagraph({
    Title = "QuietXDev by Prince",
    Content = "Thanks For Using This Script!\n\nDeveloper:\n- Discord: discord.gg/2aMDrb92kf\n- Instagram: @quietxdev\n- GitHub: github.com/ohmygod-king\n\nKeep supporting us!"
})

DevTab:CreateButton({ Name = "Discord Server", Callback = function() setclipboard("https://discord.gg/2aMDrb92kf") NotifySuccess("Link Discord", "Copied to clipboard!") end })
DevTab:CreateButton({ Name = "Instagram", Callback = function() setclipboard("https://instagram.com/quietxdev") NotifySuccess("Link Instagram", "Copied to clipboard!") end })
DevTab:CreateButton({ Name = "GitHub", Callback = function() setclipboard("https://github.com/ohmygod-king") NotifySuccess("Link GitHub", "Copied to clipboard!") end })

-- Auto Fishing
MainTab:CreateToggle({
    Name = "Enable Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(val)
        autofish = val
        if val then
            task.spawn(function()
                while autofish do
                    pcall(function()
                        equipRemote:FireServer(1)
                        task.wait(0.1)

                        local timestamp = perfectCast and 9999999999 or (tick() + math.random())
                        rodRemote:InvokeServer(timestamp)
                        task.wait(0.1)

                        local x, y = -1.238, 0.969
                        if not perfectCast then
                            x = math.random(-1000, 1000) / 1000
                            y = math.random(0, 1000) / 1000
                        end
                        miniGameRemote:InvokeServer(x, y)
                        task.wait(1.3)

                        finishRemote:FireServer()
                    end)
                    task.wait(autoRecastDelay)
                end
            end)
        end
    end
})

MainTab:CreateToggle({
    Name = "Use Perfect Cast",
    CurrentValue = true,
    Flag = "PerfectCast",
    Callback = function(val)
        perfectCast = val
    end
})

MainTab:CreateSlider({
    Name = "Auto Recast Delay (seconds)",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = autoRecastDelay,
    Callback = function(val)
        autoRecastDelay = val
    end
})

MainTab:CreateButton({
    Name = "Sell All Fishes",
    Callback = function()
        if SellRemote then
            SellRemote:FireServer()
            NotifySuccess("Auto Sell", "All fish have been sold.")
        else
            NotifyError("Auto Sell", "Sell remote not found!")
        end
    end
})

MainTab:CreateButton({
    Name = "Auto Enchant Rod",
    Callback = function()
        local char = Workspace.Characters:FindFirstChild(LocalPlayer.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(enchantPos + Vector3.new(0, 5, 0))
            task.wait(1.2)
            if EnchantRemote then
                EnchantRemote:FireServer()
                NotifySuccess("Enchant", "Enchantment Activated!")
            else
                NotifyError("Enchant", "Enchant remote not found!")
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Print Inventory to Console",
    Callback = function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            print("-- INVENTORY CONTENTS --")
            for _, item in pairs(backpack:GetChildren()) do
                print(item.Name)
            end
        else
            print("Backpack not found!")
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Flag = "InfinityJump",
    Callback = function(val)
        ijump = val
    end
})

UserInputService.JumpRequest:Connect(function()
    if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 35,
    Flag = "JumpPower",
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end
})

local islandCoords = {
    ["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
    ["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
    ["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
    ["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
    ["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
    ["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
    ["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
    ["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
    ["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
    ["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) }
}

for _, data in pairs(islandCoords) do
    IslandsTab:CreateButton({
        Name = data.name,
        Callback = function()
            local char = Workspace.Characters:FindFirstChild(LocalPlayer.Name)
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
                NotifySuccess("Teleported!", "You are now at " .. data.name)
            else
                NotifyError("Teleport Failed", "Character or HRP not found!")
            end
        end
    })
end

SettingsTab:CreateButton({ Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
SettingsTab:CreateButton({ Name = "Server Hop (New Server)", Callback = function()
    local placeId = game.PlaceId
    local servers, cursor = {}, ""
    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end
    until not cursor or #servers > 0

    if #servers > 0 then
        local targetServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
    else
        NotifyError("Server Hop Failed", "No available servers found!")
    end
end })
