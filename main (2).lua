
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

--- HyRexxyy add new feature and variable
local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
if not player or not replicatedStorage then return end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Fish It Script",
    LoadingTitle = "Fish It",
    LoadingSubtitle = "by @HyRexxyy",
    Theme = "Amethyst",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Rexxyy",
        FileName = "FishIt"
    },
    KeySystem = false
})

-- Tabs

local DevTab = Window:CreateTab("Developer", "airplay")
local MainTab = Window:CreateTab("Auto Fish", "fish")
local PlayerTab = Window:CreateTab("Player", "users-round")
local IslandsTab = Window:CreateTab("Islands", "map")
local SettingsTab = Window:CreateTab("Settings", "cog")
local NPCTab = Window:CreateTab("NPC", "user")
local EventTab = Window:CreateTab("Event", "cog")
local Spawn_Boat = Window:CreateTab("Spawn Boat", "cog")
local Buy_Rod = Window:CreateTab("Buy Rod", "cog")
local Buy_Weather = Window:CreateTab("Buy Weather", "cog")
local Buy_Baits = Window:CreateTab("Buy Bait", "cog")


-- Remotes
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")

-- State
local AutoSell = false
local autofish = false
local perfectCast = false
local ijump = false
local autoRecastDelay = 0.5
local enchantPos = Vector3.new(3231, -1303, 1402)

local featureState = {
    AutoSell = false,
}

local function NotifySuccess(title, message)
	Rayfield:Notify({ Title = title, Content = message, Duration = 3, Image = "circle-check" })
end

local function NotifyError(title, message)
	Rayfield:Notify({ Title = title, Content = message, Duration = 3, Image = "ban" })
end

-- Developer Info
DevTab:CreateParagraph({
    Title = "HyRexxyy Script",
    Content = "Thanks for using this script!\n\nDont forget to follow me on my social platform\nDeveloper:\n- Tiktok: tiktok.com/hyrexxyy\n- Instagram: @hyrexxyy\n- GitHub: github.com/hyrexxyy\n\nKeep supporting!"
})

DevTab:CreateButton({ Name = "Tutor Tiktok", Callback = function() setclipboard("https://tiktok.com/hyrexxyy") NotifySuccess("Link Tiktok", "Copied to clipboard!") end })
DevTab:CreateButton({ Name = "Instagram", Callback = function() setclipboard("https://instagram.com/hyrexxyy") NotifySuccess("Link Instagram", "Copied to clipboard!") end })
DevTab:CreateButton({ Name = "GitHub", Callback = function() setclipboard("https://github.com/hyrexxyy") NotifySuccess("Link GitHub", "Copied to clipboard!") end })

-- MainTab (Auto Fish)
MainTab:CreateParagraph({
    Title = "🎣 Auto Fish Settings",
    Content = "Gunakan toggle & slider di bawah untuk mengatur auto fishing."
})

-- Section: Standard Boats
Spawn_Boat:CreateParagraph({
    Title = "🚤 Standard Boats",
    Content = "Spawn a boat"
})

local standard_boats = {
    { Name = "Small Boat", ID = 1, Desc = "Acceleration: 160% | Passengers: 3 | Top Speed: 120%" },
    { Name = "Kayak", ID = 2, Desc = "Acceleration: 180% | Passengers: 1 | Top Speed: 155%" },
    { Name = "Jetski", ID = 3, Desc = "Acceleration: 240% | Passengers: 2 | Top Speed: 280%" },
    { Name = "Highfield Boat", ID = 4, Desc = "Acceleration: 180% | Passengers: 3 | Top Speed: 180%" },
    { Name = "Speed Boat", ID = 5, Desc = "Acceleration: 200% | Passengers: 4 | Top Speed: 220%" },
    { Name = "Fishing Boat", ID = 6, Desc = "Acceleration: 180% | Passengers: 8 | Top Speed: 230%" },
    { Name = "Mini Yacht", ID = 14, Desc = "Acceleration: 140% | Passengers: 10 | Top Speed: 290%" },
    { Name = "Hyper Boat", ID = 7, Desc = "Acceleration: 240% | Passengers: 7 | Top Speed: 400%" },
    { Name = "Frozen Boat", ID = 11, Desc = "Acceleration: 193% | Passengers: 3 | Top Speed: 230%" },
    { Name = "Cruiser Boat", ID = 13, Desc = "Acceleration: 180% | Passengers: 4 | Top Speed: 185%" }
}

for _, boat in ipairs(standard_boats) do
    Spawn_Boat:CreateButton({
        Name = "🛥️ " .. boat.Name,
        Callback = function()
            pcall(function()
                replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/DespawnBoat"]:InvokeServer()
                task.wait(3)
                replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SpawnBoat"]:InvokeServer(boat.ID)
                Rayfield:Notify({
                    Title = "🚤 Spawning Boat",
                    Content = "Replacing with " .. boat.Name .. "\n" .. boat.Desc,
                    Duration = 5,
                    Image = 4483362458
                })
            end)
        end
    })
end

-- Section: Other Boats
Spawn_Boat:CreateParagraph({
    Title = "🦆 Other Boats",
    Content = "Special / event-only boats"
})

local other_boats = {
    { Name = "Alpha Floaty", ID = 8 },
    { Name = "DEV Evil Duck 9000", ID = 9 },
    { Name = "Festive Duck", ID = 10 },
    { Name = "Santa Sleigh", ID = 12 }
}

for _, boat in ipairs(other_boats) do
    Spawn_Boat:CreateButton({
        Name = "🛶 " .. boat.Name,
        Callback = function()
            pcall(function()
                replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/DespawnBoat"]:InvokeServer()
                task.wait(3)
                replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SpawnBoat"]:InvokeServer(boat.ID)
                Rayfield:Notify({
                    Title = "⛵ Spawning Boat",
                    Content = "Replacing with " .. boat.Name,
                    Duration = 5,
                    Image = 4483362458
                })
            end)
        end
    })
end


MainTab:CreateToggle({
    Name = "🎣 Enable Auto Fishing",
    CurrentValue = false,
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

                        local x = perfectCast and -1.238 or (math.random(-1000, 1000) / 1000)
                        local y = perfectCast and 0.969 or (math.random(0, 1000) / 1000)

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
    Name = "✨ Use Perfect Cast",
    CurrentValue = false,
    Callback = function(val)
        perfectCast = val
    end
})

MainTab:CreateSlider({
    Name = "⏱️ Auto Recast Delay (seconds)",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = autoRecastDelay,
    Callback = function(val)
        autoRecastDelay = val
    end
})
-- Buy Rods
Buy_Rod:CreateParagraph({
    Title = "🎣 Purchase Rods",
    Content = "Select a rod to buy using coins."
})

local rods = {
    { Name = "Luck Rod", Price = "350 Coins", ID = 79, Desc = "Luck: 50% | Speed: 2% | Weight: 15 kg" },
    { Name = "Carbon Rod", Price = "900 Coins", ID = 76, Desc = "Luck: 30% | Speed: 4% | Weight: 20 kg" },
    { Name = "Grass Rod", Price = "1.50k Coins", ID = 85, Desc = "Luck: 55% | Speed: 5% | Weight: 250 kg" },
    { Name = "Demascus Rod", Price = "3k Coins", ID = 77, Desc = "Luck: 80% | Speed: 4% | Weight: 400 kg" },
    { Name = "Ice Rod", Price = "5k Coins", ID = 78, Desc = "Luck: 60% | Speed: 7% | Weight: 750 kg" },
    { Name = "Lucky Rod", Price = "15k Coins", ID = 4, Desc = "Luck: 130% | Speed: 7% | Weight: 5k kg" },
    { Name = "Midnight Rod", Price = "50k Coins", ID = 80, Desc = "Luck: 100% | Speed: 10% | Weight: 10k kg" },
    { Name = "Steampunk Rod", Price = "215k Coins", ID = 6, Desc = "Luck: 175% | Speed: 19% | Weight: 25k kg" },
    { Name = "Chrome Rod", Price = "437k Coins", ID = 7, Desc = "Luck: 229% | Speed: 23% | Weight: 250k kg" },
    { Name = "Astral Rod", Price = "1M Coins", ID = 5, Desc = "Luck: 350% | Speed: 43% | Weight: 550k kg" }
}

for _, rod in ipairs(rods) do
    Buy_Rod:CreateButton({
        Name = rod.Name .. " (" .. rod.Price .. ")",
        Callback = function()
            pcall(function()
                replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]:InvokeServer(rod.ID)
                Rayfield:Notify({
                    Title = "🎣 Purchase Rod",
                    Content = "Buying " .. rod.Name,
                    Duration = 3
                })
            end)
        end
    })
end

-- Buy Weather
Buy_Weather:CreateParagraph({
    Title = "🌤️ Purchase Weather Events",
    Content = "Select a weather event to trigger."
})
local autoBuyWeather = false

Buy_Weather:CreateToggle({
    Name = "🌀 Auto Buy All Weather",
    CurrentValue = false,
    Flag = "AutoBuyWeatherToggle",
    Callback = function(Value)
        autoBuyWeather = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Weather",
                Content = "Started Auto Buying Weather",
                Duration = 3
            })

            task.spawn(function()
                while autoBuyWeather do
                    for _, w in ipairs(weathers) do
                        pcall(function()
                            replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]:InvokeServer(w.Name)
                            
                        end)
                        task.wait(1.5) -- jeda antar pembelian
                    end
                    task.wait(10) -- tunggu sebelum mengulang pembelian
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Weather",
                Content = "Stopped Auto Buying",
                Duration = 2
            })
        end
    end
})
local weathers = {
    { Name = "Wind", Price = "10k Coins", Desc = "Increases Rod Speed" },
    { Name = "Snow", Price = "15k Coins", Desc = "Adds Frozen Mutations" },
    { Name = "Cloudy", Price = "20k Coins", Desc = "Increases Luck" },
    { Name = "Storm", Price = "35k Coins", Desc = "Increase Rod Speed And Luck" },
    { Name = "Shark Hunt", Price = "300k Coins", Desc = "Shark Hunt" }
}

for _, w in ipairs(weathers) do
    Buy_Weather:CreateButton({
        Name = w.Name .. " (" .. w.Price .. ")",
        Callback = function()
            pcall(function()
                replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]:InvokeServer(w.Name)
                Rayfield:Notify({
                    Title = "⛅ Weather Event",
                    Content = "Triggering " .. w.Name,
                    Duration = 3
                })
            end)
        end
    })
end




-- Buy Bait
Buy_Baits:CreateParagraph({
    Title = "🪱 Purchase Baits",
    Content = "Buy bait to enhance fishing luck or effects."
})

local baits = {
    { Name = "Topwater Bait", Price = "100 Coins", ID = 10, Desc = "Luck: 8%" },
    { Name = "Luck Bait", Price = "1k Coins", ID = 2, Desc = "Luck: 10%" },
    { Name = "Midnight Bait", Price = "3k Coins", ID = 3, Desc = "Luck: 20%" },
    { Name = "Chroma Bait", Price = "290k Coins", ID = 6, Desc = "Luck: 100%" },
    { Name = "Dark Mater Bait", Price = "630k Coins", ID = 8, Desc = "Luck: 175%" },
    { Name = "Corrupt Bait", Price = "1.15M Coins", ID = 15, Desc = "Luck: 200% | Mutation Chance: 10% | Shiny Chance: 10%" }
}

for _, bait in ipairs(baits) do
    Buy_Baits:CreateButton({
        Name = bait.Name .. " (" .. bait.Price .. ")",
        Callback = function()
            pcall(function()
                replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]:InvokeServer(bait.ID)
                Rayfield:Notify({
                    Title = "🪱 Bait Purchase",
                    Content = "Buying " .. bait.Name,
                    Duration = 3
                })
            end)
        end
    })
end

local AutoSellToggle = MainTab:CreateToggle({
    Name = "🛒 Auto Sell (Teleport ke Alex)",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(value)
        featureState.AutoSell = value
        if value then
            task.spawn(function()
                while featureState.AutoSell and player do
                    pcall(function()
                        if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end

                        local npcContainer = replicatedStorage:FindFirstChild("NPC")
                        local alexNpc = npcContainer and npcContainer:FindFirstChild("Alex")

                        if not alexNpc then
                            Rayfield:Notify({
                                Title = "❌ Error",
                                Content = "NPC 'Alex' tidak ditemukan!",
                                Duration = 5,
                                Image = 4483362458
                            })
                            featureState.AutoSell = false
                            AutoSellToggle:Set(false)
                            return
                        end

                        local originalCFrame = player.Character.HumanoidRootPart.CFrame
                        local npcPosition = alexNpc.WorldPivot.Position

                        player.Character.HumanoidRootPart.CFrame = CFrame.new(npcPosition)
                        task.wait(1)

                        replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]:InvokeServer()
                        task.wait(1)

                        player.Character.HumanoidRootPart.CFrame = originalCFrame
                    end)
                    task.wait(20)
                end
            end)
        end
    end
})

-- Toggle logic
local blockUpdateOxygen = false

PlayerTab:CreateToggle({
    Name = "Unlimited Oxygen",
    CurrentValue = false,
    Flag = "BlockUpdateOxygen",
    Callback = function(value)
        blockUpdateOxygen = value
        Rayfield:Notify({
            Title = "Update Oxygen Block",
            Content = value and "Remote blocked!" or "Remote allowed!",
            Duration = 3,
        })
    end,
})

-- Hook FireServer
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and tostring(self) == "URE/UpdateOxygen" and blockUpdateOxygen then
        warn("Tahan Napas Bang")
        return nil -- prevent call
    end

    return oldNamecall(self, unpack(args))
end))

-- Player Tab
PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Callback = function(val)
        ijump = val
    end
})



UserInputService.JumpRequest:Connect(function()
    if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

do
    PlayerTab:CreateParagraph({
        Title = "🛒 Teleport to Shops",
        Content = "Click a button to teleport to the respective shop NPC."
    })
    local shop_npcs = {
        { Name = "Boats Shop", Path = "Boat Expert" },
        { Name = "Rod Shop", Path = "Joe" },
        { Name = "Bobber Shop", Path = "Seth" }
    }

    for _, npc_data in ipairs(shop_npcs) do
        PlayerTab:CreateButton({
            Name = npc_data.Name,
            Callback = function()
                local npc = game:GetService("ReplicatedStorage"):FindFirstChild("NPC"):FindFirstChild(npc_data.Path)
                local char = game:GetService("Players").LocalPlayer.Character
                if npc and char and char:FindFirstChild("HumanoidRootPart") then
                    char:PivotTo(npc:GetPivot())
                    Rayfield:Notify({
                        Title = "Teleported",
                        Content = "To " .. npc_data.Name,
                        Duration = 3,
                        Image = 4483362458
                    })
                else
                    Rayfield:Notify({
                        Title = "Error",
                        Content = "NPC or Character not found.",
                        Duration = 3,
                        Image = 4483362458
                    })
                end
            end,
        })
    end

    PlayerTab:CreateButton({
        Name = "Weather Machine",
        Callback = function()
            local weather = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!"):FindFirstChild("Weather Machine")
            local char = game:GetService("Players").LocalPlayer.Character
            if weather and char and char:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(CFrame.new(weather.Position))
                Rayfield:Notify({
                    Title = "Teleported",
                    Content = "To Weather Machine",
                    Duration = 3,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Weather Machine or Character not found.",
                    Duration = 3,
                    Image = 4483362458
                })
            end
        end,
    })
end



PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 16,
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
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end
})

-- Islands Tab
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
    ["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
["11"] = { name = "Lost Isle", position = Vector3.new(-3670.30078125, -113.00000762939453, -1128.0589599609375)},
["12"] = { name = "Lost Isle [Lost Shore]", position = Vector3.new(-3697, 97, -932)},
["13"] = { name = "Lost Isle [Sisyphus]", position = Vector3.new(-3719.850830078125, -113.00000762939453, -958.6303100585938)},

["14"] = { name = "Lost Isle [Treasure Hall]", position = Vector3.new(-3652, -298.25, -1469)},
["15"] = { name = "Lost Isle [Treasure Room]", position = Vector3.new(-3652, -283.5, -1651.5)}
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
-- NPC Tab
local npcFolder = ReplicatedStorage:WaitForChild("NPC")
for _, npc in ipairs(npcFolder:GetChildren()) do
	NPCTab:CreateButton({
		Name = "Teleport to NPC: " .. npc.Name,
		Callback = function()
			local npcCandidates = Workspace:GetDescendants()
			for _, descendant in ipairs(npcCandidates) do
				if descendant.Name == npc.Name and descendant:FindFirstChild("HumanoidRootPart") then
					local myChar = LocalPlayer.Character
					local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
					if myHRP then
						myHRP.CFrame = descendant.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
						NotifySuccess("Teleport Success", "You teleported to NPC: " .. npc.Name)
						return
					end
				end
			end
			NotifyError("Teleport Failed", "NPC not found in Workspace!")
		end
	})
end

-- Settings Tab
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
SettingsTab:CreateButton({ Name = "Unload Script", Callback = function()
    Rayfield:Notify({ Title = "Script Unloaded", Content = "The script will now unload.", Duration = 3, Image = "circle-check" })
    wait(3)
    game:GetService("CoreGui").Rayfield:Destroy()
end })

-- 🔄 Ambil semua anak dari workspace.Props dan filter hanya yang berupa Model atau BasePart

local function createEventButtons()
    EventTab.Flags = {} -- Bersihkan flags lama agar tidak dobel
    local props = Workspace:FindFirstChild("Props")
    if props then
        for _, child in pairs(props:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                local eventName = child.Name

                EventTab:CreateButton({
                    Name = "Teleport to: " .. eventName,
                    Callback = function()
                        local character = Workspace.Characters:FindFirstChild(LocalPlayer.Name)
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        local pos = nil

                        if child:IsA("Model") then
                            if child.PrimaryPart then
                                pos = child.PrimaryPart.Position
                            else
                                local part = child:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    pos = part.Position
                                end
                            end
                        elseif child:IsA("BasePart") then
                            pos = child.Position
                        end

                        if pos and hrp then
                            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) -- Naik dikit biar gak stuck
                            Rayfield:Notify({
                                Title = "✅ Teleported",
                                Content = "You have been teleported to: " .. eventName,
                                Duration = 4
                            })
                        else
                            Rayfield:Notify({
                                Title = "❌ Teleport Failed",
                                Content = "Failed to locate valid part for: " .. eventName,
                                Duration = 4
                            })
                        end
                    end
                })
            end
        end
    end
end

-- Tombol untuk refresh list event
EventTab:CreateButton({
    Name = "🔄 Refresh Event List",
    Callback = function()
        createEventButtons()
        Rayfield:Notify({
            Title = "✅ Refreshed",
            Content = "Event list has been refreshed.",
            Duration = 3
        })
    end
})

-- Panggil pertama kali saat tab dibuka
createEventButtons()

local props = Workspace:FindFirstChild("Props")
if props then
    for _, child in pairs(props:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            local eventName = child.Name

            EventTab:CreateButton({
                Name = "Teleport to: " .. eventName,
                Callback = function()
                    local character = Workspace.Characters:FindFirstChild(LocalPlayer.Name)
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    local pos = nil

                    if child:IsA("Model") then
                        if child.PrimaryPart then
                            pos = child.PrimaryPart.Position
                        else
                            local part = child:FindFirstChildWhichIsA("BasePart")
                            if part then
                                pos = part.Position
                            end
                        end
                    elseif child:IsA("BasePart") then
                        pos = child.Position
                    end

                    if pos and hrp then
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) -- Naik dikit biar gak stuck
                        Rayfield:Notify({
                            Title = "✅ Teleported",
                            Content = "You have been teleported to: " .. eventName,
                            Duration = 4
                        })
                    else
                        Rayfield:Notify({
                            Title = "❌ Teleport Failed",
                            Content = "Failed to locate valid part for: " .. eventName,
                            Duration = 4
                        })
                    end
                end
            })
        end
    end
else
    Rayfield:Notify({
        Title = "Reloading Props Event",
        Content = "workspace.Props tidak ditemukan!",
        Duration = 1
    })
end

-- Mengubah semua modifier fishing rod menjadi 99999
local Modifiers = require(game:GetService("ReplicatedStorage").Shared.FishingRodModifiers)
for key in pairs(Modifiers) do
    Modifiers[key] = 999999999
end

-- Memaksa efek "Luck Bait"
local bait = require(game:GetService("ReplicatedStorage").Baits["Luck Bait"])
bait.Luck = 999999999
