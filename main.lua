
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

-- Load WindUi
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Window
local Window = WindUI:CreateWindow({
    Title = gradient("RexxyyAuto", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
    Icon = "rbxassetid://90566677928169",
    Author = "Fish It",
    Size = UDim2.fromOffset(500, 320),
    Folder = "RexxyyHub",
    Transparent = false,
    Theme = "Arcvour",
    ToggleKey = Enum.KeyCode.K,
    SideBarWidth = 160,
    KeySystem = false
    }
})

-- Tabs
local Tabs = {
    Farming = Window:Tab({ Title = "Farming", Icon = "fish", ShowTabTitle = true }),
    Spawn_Boat = Window:Tab({ Title = "Spawn Boat", Icon = "ship", ShowTabTitle = true }),
    Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true }),
    Edit_Stats = Window:Tab({ Title = "Edit Stats", Icon = "file-pen", ShowTabTitle = true }),
    Buy_Rod = Window:Tab({ Title = "Buy Rod", Icon = "anchor", ShowTabTitle = true }),
    Buy_Weather = Window:Tab({ Title = "Buy Weather", Icon = "cloud", ShowTabTitle = true }),
    Buy_Baits = Window:Tab({ Title = "Buy Baits", Icon = "bug", ShowTabTitle = true }),
    TP_Islands = Window:Tab({ Title = "TP Islands", Icon = "map-pin", ShowTabTitle = true }),
    TP_Shop = Window:Tab({ Title = "TP Shop", Icon = "shopping-cart", ShowTabTitle = true }),
    TP_NPC = Window:Tab({ Title = "Teleport to NPC", Icon = "users", ShowTabTitle = true }),
    TP_Player = Window:Tab({ Title = "TP Player", Icon = "user-round-search", ShowTabTitle = true })
}

if not Tabs.Farming or not Tabs.Spawn_Boat or not Tabs.Movement or not Tabs.Edit_Stats or not Tabs.Buy_Rod or not Tabs.Buy_Weather or not Tabs.Buy_Baits or not Tabs.TP_Islands or not Tabs.TP_Shop or not Tabs.TP_NPC or not Tabs.TP_Player then
    warn("Gagal membuat satu atau lebih tab.")
    return
end

local featureState = {
    AutoFish = false,
    AutoSellAll = false,
    AutoSellOnEquip = false,
    WalkSpeed = false,
    InfiniteJump = false,
    NoClip = false
}

local statValues = {
    FishingLuck = nil,
    ShinyChance = nil,
    MutationChance = nil
}

do
    Tabs.Farming:Section({ Title = "Auto Features" })
    
    local AutoSellAllToggle
    AutoSellAllToggle = Tabs.Farming:Toggle({
        Title = "Auto Sell All Fish",
        Desc = "Warning: This feature will sell all fish",
        Value = false,
        Callback = function(value)
            featureState.AutoSellAll = value
            if value then
                task.spawn(function()
                    while featureState.AutoSellAll and player do
                        pcall(function()
                            if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end
                            
                            local npcContainer = replicatedStorage:FindFirstChild("NPC")
                            local alexNpc = npcContainer and npcContainer:FindFirstChild("Alex")
                            
                            if not alexNpc then
                                WindUI:Notify({ Title = "Error", Content = "Sell NPC 'Alex' not found.", Duration = 4, Icon = "alert-triangle" })
                                featureState.AutoSellAll = false
                                if AutoSellAllToggle then AutoSellAllToggle:Set(false) end
                                return
                            end

                            local originalCFrame = player.Character.HumanoidRootPart.CFrame
                            local npcPosition = alexNpc.WorldPivot.Position
                            
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(npcPosition)
                            task.wait(1)
                            
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
                            task.wait(1)
                            
                            player.Character.HumanoidRootPart.CFrame = originalCFrame
                        end)
                        task.wait(20)
                    end
                end)
            end
        end
    })

    local netFolder = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
    local equipItemEvent = netFolder:WaitForChild("RE/EquipItem")
    local sellItemFunc = netFolder:WaitForChild("RF/SellItem")
    local oldNamecall
    
    Tabs.Farming:Toggle({
        Title = "Auto Sell Equipped Fish",
        Desc = "Warning: Make sure to click the fish you want to sell",
        Value = false,
        Callback = function(value)
            featureState.AutoSellOnEquip = value
            if value then
                if not oldNamecall then
                    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                        if featureState.AutoSellOnEquip and self == equipItemEvent and getnamecallmethod() == "FireServer" then
                            local args = {...}
                            local itemId = args[1]
                            if type(itemId) == "string" then
                                task.spawn(function()
                                    task.wait()
                                    if featureState.AutoSellOnEquip then
                                        pcall(function()
                                            sellItemFunc:InvokeServer(itemId)
                                        end)
                                    end
                                end)
                            end
                        end
                        return oldNamecall(self, ...)
                    end)
                end
                WindUI:Notify({ Title = "Success", Content = "Auto Sell on Equip is now active.", Duration = 4, Icon = "check" })
            else
                if oldNamecall and unhookmetamethod then
                    unhookmetamethod(game, "__namecall")
                    oldNamecall = nil
                end
                WindUI:Notify({ Title = "Info", Content = "Auto Sell on Equip has been disabled.", Duration = 4, Icon = "info" })
            end
        end
    })

    local AutoFishToggle
    AutoFishToggle = Tabs.Farming:Toggle({
        Title = "Enable Auto Fish",
        Desc = "Automatically catches fish.",
        Value = false,
        Callback = function(value)
            featureState.AutoFish = value
            
            if value then
                pcall(function()
                    local args = { 1 }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/EquipToolFromHotbar"):FireServer(unpack(args))
                end)
                
                task.wait(1)
                
                WindUI:Notify({ Title = "Success", Content = "Auto Fishing has started.", Duration = 5, Icon = "check" })
                
                task.spawn(function()
                    while featureState.AutoFish and player do
                        pcall(function()
                            local chargeArgs = { 1752984487.133336 }
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/ChargeFishingRod"):InvokeServer(unpack(chargeArgs))
                            
                            task.wait(0.2)
                            
                            local minigameArgs = { -0.7499996423721313, 1 }
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(unpack(minigameArgs))
                            
                            task.wait(0.2)
                            
                            local completedArgs = {}
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FishingCompleted"):FireServer(unpack(completedArgs))
                        end)
                        task.wait(0.5)
                    end
                end)
            else
                WindUI:Notify({ Title = "Info", Content = "Auto Fishing has stopped.", Duration = 5, Icon = "info" })
            end
        end
    })
end

do
    Tabs.Spawn_Boat:Section({ Title = "Standard Boats" })
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
    for _, boatData in ipairs(standard_boats) do
        Tabs.Spawn_Boat:Button({
            Title = boatData.Name,
            Desc = boatData.Desc,
            Callback = function()
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/DespawnBoat"):InvokeServer()
                    task.wait(3)
                    local args = { boatData.ID }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SpawnBoat"):InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Spawning Boat", Content = "Replacing existing boat with " .. boatData.Name, Duration = 3, Icon = "ship" })
                end)
            end
        })
    end

    Tabs.Spawn_Boat:Section({ Title = "Other Boats" })
    local other_boats = {
        { Name = "Alpha Floaty", ID = 8 },
        { Name = "DEV Evil Duck 9000", ID = 9 },
        { Name = "Festive Duck", ID = 10 },
        { Name = "Santa Sleigh", ID = 12 }
    }
    for _, boatData in ipairs(other_boats) do
        Tabs.Spawn_Boat:Button({
            Title = boatData.Name,
            Callback = function()
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/DespawnBoat"):InvokeServer()
                    task.wait(3)
                    local args = { boatData.ID }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SpawnBoat"):InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Spawning Boat", Content = "Replacing existing boat with " .. boatData.Name, Duration = 3, Icon = "ship" })
                end)
            end
        })
    end
end

do
    local WalkSpeedSlider
    
    Tabs.Movement:Section({ Title = "Movement Exploits" })

    local WalkSpeedToggle
    WalkSpeedToggle = Tabs.Movement:Toggle({
        Title = "Enable WalkSpeed",
        Value = false,
        Callback = function(state)
            featureState.WalkSpeed = state
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = state and (tonumber(WalkSpeedSlider.Value.Default) or 16) or 16
            end
        end
    })
    WalkSpeedSlider = Tabs.Movement:Slider({
        Title = "WalkSpeed Value",
        Value = { Min = 16, Max = 200, Default = 100 },
        Step = 1,
        Callback = function(value)
            if featureState.WalkSpeed and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = tonumber(value) or 16
            end
        end
    })

    Tabs.Movement:Toggle({
        Title = "Enable Infinite Jump",
        Value = false,
        Callback = function(v) featureState.InfiniteJump = v end
    })
    local UserInputService = game:GetService("UserInputService")
    if UserInputService then
        UserInputService.JumpRequest:Connect(function()
            if featureState.InfiniteJump and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    local NoClipToggle
    NoClipToggle = Tabs.Movement:Toggle({
        Title = "Enable No Clip",
        Value = false,
        Callback = function(state)
            featureState.NoClip = state
            if not state and player and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    })
    task.spawn(function()
        while task.wait(0.1) do
            if Window and Window.Destroyed then break end
            if featureState.NoClip and player and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
    end)

    if player then
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if featureState.WalkSpeed and humanoid then
                humanoid.WalkSpeed = tonumber(WalkSpeedSlider.Value.Default) or 16
            end
        end)
    end
end

do
    Tabs.Edit_Stats:Section({ Title = "Edit Visual Stats" })
    
    Tabs.Edit_Stats:Input({
        Title = "Fishing Luck",
        Placeholder = "Enter a number (e.g., 99999)",
        Type = "Input",
        Callback = function(value)
            statValues.FishingLuck = tonumber(value)
        end
    })
    Tabs.Edit_Stats:Button({
        Title = "Set Fishing Luck",
        Callback = function()
            if statValues.FishingLuck then
                WindUI:Notify({ Title = "Success", Content = "Fishing Luck persistence enabled.", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Please enter a valid number first.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })

    Tabs.Edit_Stats:Input({
        Title = "Shiny Chance",
        Placeholder = "Enter a number (e.g., 99999)",
        Type = "Input",
        Callback = function(value)
            statValues.ShinyChance = tonumber(value)
        end
    })
    Tabs.Edit_Stats:Button({
        Title = "Set Shiny Chance",
        Callback = function()
            if statValues.ShinyChance then
                WindUI:Notify({ Title = "Success", Content = "Shiny Chance persistence enabled.", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Please enter a valid number first.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })

    Tabs.Edit_Stats:Input({
        Title = "Mutation Chance",
        Placeholder = "Enter a number (e.g., 99999)",
        Type = "Input",
        Callback = function(value)
            statValues.MutationChance = tonumber(value)
        end
    })
    Tabs.Edit_Stats:Button({
        Title = "Set Mutation Chance",
        Callback = function()
            if statValues.MutationChance then
                WindUI:Notify({ Title = "Success", Content = "Mutation Chance persistence enabled.", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Please enter a valid number first.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })

    Tabs.Edit_Stats:Section({ Title = "Rod Modifier" })

    Tabs.Edit_Stats:Button({
        Title = "Apply Max Stats to Skinned Rod",
        Desc = "Modifies the stats of your currently equipped skinned rod.",
        Callback = function()
            local backpack = player.PlayerGui:FindFirstChild("Backpack", true)
            local backpackDisplay = backpack and backpack:FindFirstChild("Display", true)
            
            if not backpackDisplay then
                WindUI:Notify({ Title = "Error", Content = "Please open your backpack first.", Duration = 4, Icon = "alert-triangle" })
                return
            end

            local itemsFolder = replicatedStorage:FindFirstChild("Items")
            if not itemsFolder then
                WindUI:Notify({ Title = "Error", Content = "Items data folder not found.", Duration = 4, Icon = "alert-triangle" })
                return
            end

            local modified = false
            for _, tile in ipairs(backpackDisplay:GetChildren()) do
                if tile.Name == "Tile" then
                    local skinActiveLabel = tile:FindFirstChild("Inner", true) and tile.Inner:FindFirstChild("Tags", true) and tile.Inner.Tags:FindFirstChild("SkinActive", true)
                    local itemNameLabel = tile:FindFirstChild("Inner", true) and tile.Inner:FindFirstChild("Tags", true) and tile.Inner.Tags:FindFirstChild("ItemName", true)
                    
                    if skinActiveLabel and itemNameLabel and skinActiveLabel.Text == "★ SKIN ★" then
                        local itemName = itemNameLabel.Text
                        local moduleName = "!!! " .. itemName
                        
                        local rodModule = itemsFolder:FindFirstChild(moduleName)
                        
                        if rodModule then
                            local success, rodData = pcall(require, rodModule)
                            
                            if success and type(rodData) == "table" then
                                rodData.VisualClickPowerPercent = 99999999
                                rodData.MaxWeight = 99999999
                                if rodData.RollData then
                                    rodData.RollData.BaseLuck = 99999999
                                end
                                modified = true
                                WindUI:Notify({ Title = "Modified!", Content = itemName .. " stats have been maxed.", Duration = 4, Icon = "check" })
                            end
                        end
                    end
                end
            end

            if not modified then
                WindUI:Notify({ Title = "Info", Content = "No skinned rod found in your backpack.", Duration = 4, Icon = "info" })
            end
        end
    })
end

do
    Tabs.Buy_Rod:Section({ Title = "Purchase Rods" })
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
    for _, rodData in ipairs(rods) do
        Tabs.Buy_Rod:Button({
            Title = rodData.Name .. " (" .. rodData.Price .. ")",
            Desc = rodData.Desc,
            Callback = function()
                pcall(function()
                    local args = { rodData.ID }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseFishingRod"):InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Purchase Attempt", Content = "Buying " .. rodData.Name, Duration = 3, Icon = "info" })
                end)
            end
        })
    end
end

do
    Tabs.Buy_Weather:Section({ Title = "Purchase Weather Events" })
    local weathers = {
        { Name = "Wind", Price = "10k Coins", Desc = "Increases Rod Speed" },
        { Name = "Snow", Price = "15k Coins", Desc = "Adds Frozen Mutations" },
        { Name = "Cloudy", Price = "20k Coins", Desc = "Increases Luck" },
        { Name = "Storm", Price = "35k Coins", Desc = "Increase Rod Speed And Luck" },
        { Name = "Shark Hunt", Price = "300k Coins", Desc = "Shark Hunt" }
    }
    for _, weatherData in ipairs(weathers) do
        Tabs.Buy_Weather:Button({
            Title = weatherData.Name .. " (" .. weatherData.Price .. ")",
            Desc = weatherData.Desc,
            Callback = function()
                pcall(function()
                    local args = { weatherData.Name }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseWeatherEvent"):InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Purchase Attempt", Content = "Buying " .. weatherData.Name .. " event", Duration = 3, Icon = "info" })
                end)
            end
        })
    end
end

do
    Tabs.Buy_Baits:Section({ Title = "Purchase Baits" })
    local baits = {
        { Name = "Topwater Bait", Price = "100 Coins", ID = 10, Desc = "Luck: 8%" },
        { Name = "Luck Bait", Price = "1k Coins", ID = 2, Desc = "Luck: 10%" },
        { Name = "Midnight Bait", Price = "3k Coins", ID = 3, Desc = "Luck: 20%" },
        { Name = "Chroma Bait", Price = "290k Coins", ID = 6, Desc = "Luck: 100%" },
        { Name = "Dark Mater Bait", Price = "630k Coins", ID = 8, Desc = "Luck: 175%" },
        { Name = "Corrupt Bait", Price = "1.15M Coins", ID = 15, Desc = "Luck: 200% | Mutation Chance: 10% | Shiny Chance: 10%" }
    }
    for _, baitData in ipairs(baits) do
        Tabs.Buy_Baits:Button({
            Title = baitData.Name .. " (" .. baitData.Price .. ")",
            Desc = baitData.Desc,
            Callback = function()
                pcall(function()
                    local args = { baitData.ID }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseBait"):InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Purchase Attempt", Content = "Buying " .. baitData.Name, Duration = 3, Icon = "info" })
                end)
            end
        })
    end
end

do
    Tabs.TP_Islands:Section({ Title = "Island Locations" })
    
    local locations = {
        "Coral Reefs", "Crater Island", "Esoteric Depths", "Kohana",
        "Kohana Volcano", "Stingray Shores", "Tropical Grove", "Lost Isle", "Lost Shore"
    }
    table.sort(locations)
    
    for _, name in ipairs(locations) do
        Tabs.TP_Islands:Button({
            Title = name,
            Callback = function()
                if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                    return
                end
                
                local islandContainer = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
                local islandPart = islandContainer and islandContainer:FindFirstChild(name)
                
                if islandPart then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(islandPart.Position)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. name, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "Location '" .. name .. "' not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end
end

do
    Tabs.TP_Shop:Section({ Title = "Shop Locations" })

    local shop_npcs = {
        { Name = "Boats Shop", Path = "Boat Expert" },
        { Name = "Rod Shop", Path = "Joe" },
        { Name = "Bobber Shop", Path = "Seth" }
    }

    for _, npc_data in ipairs(shop_npcs) do
        Tabs.TP_Shop:Button({
            Title = npc_data.Name,
            Callback = function()
                if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                    return
                end

                local npcContainer = replicatedStorage:FindFirstChild("NPC")
                local npc_model = npcContainer and npcContainer:FindFirstChild(npc_data.Path)

                if npc_model and npc_model:IsA("Model") and npc_model.WorldPivot then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(npc_model.WorldPivot.Position)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. npc_data.Name, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "NPC for '" .. npc_data.Name .. "' not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end

    Tabs.TP_Shop:Button({
        Title = "Weather Machine",
        Callback = function()
            if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                return
            end
            
            local islandContainer = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
            local islandPart = islandContainer and islandContainer:FindFirstChild("Weather Machine")
            
            if islandPart then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(islandPart.Position)
                WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to Weather Machine", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Location 'Weather Machine' not found.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })
end

do
    Tabs.TP_NPC:Section({ Title = "NPC Locations" })
    local npc_names = {
        "Alex", "Billy Bob", "Boat Expert", "Burt", "Esoteric Gatekeeper", "Jed", 
        "Jeffery", "Jess", "Joe", "Jones", "Lava Fisherman", "Lonely Fisherman", 
        "McBoatson", "Ram", "Sam", "Santa", "Scientist", "Scott", "Seth", 
        "Silly Fisherman", "Spokesperson", "Tim"
    }
    table.sort(npc_names)

    for _, npc_name in ipairs(npc_names) do
        Tabs.TP_NPC:Button({
            Title = npc_name,
            Callback = function()
                if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                    return
                end

                local npcContainer = replicatedStorage:FindFirstChild("NPC")
                local npc_model = npcContainer and npcContainer:FindFirstChild(npc_name)

                if npc_model and npc_model:IsA("Model") and npc_model.WorldPivot then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(npc_model.WorldPivot.Position)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. npc_name, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "NPC '" .. npc_name .. "' not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end
end

do
    Tabs.TP_Player:Section({ Title = "Teleport to Player" })

    local selectedPlayerName = nil
    local playerDropdown
    
    local function getPlayerList()
        local playerList = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(playerList, p.Name)
            end
        end
        table.sort(playerList)
        return playerList
    end

    playerDropdown = Tabs.TP_Player:Dropdown({
        Title = "Select Player",
        Values = getPlayerList(),
        AllowNone = true,
        Callback = function(value)
            selectedPlayerName = value
        end
    })

    Tabs.TP_Player:Button({
        Title = "Teleport to Selected Player",
        Callback = function()
            pcall(function()
                if not selectedPlayerName then
                    WindUI:Notify({ Title = "Error", Content = "No player selected.", Duration = 4, Icon = "alert-triangle" })
                    return
                end
                
                if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    WindUI:Notify({ Title = "Error", Content = "Your character was not found.", Duration = 4, Icon = "alert-triangle" })
                    return
                end

                local charactersFolder = workspace:FindFirstChild("Characters")
                if not charactersFolder then
                    WindUI:Notify({ Title = "Error", Content = "'Characters' folder not found in workspace.", Duration = 4, Icon = "alert-triangle" })
                    return
                end

                local targetCharacter = charactersFolder:FindFirstChild(selectedPlayerName)
                
                if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = targetCharacter.HumanoidRootPart.CFrame
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. selectedPlayerName, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "Could not find character for " .. selectedPlayerName, Duration = 4, Icon = "alert-triangle" })
                end
            end)
        end
    })

    local function refreshPlayerList()
        if playerDropdown and not playerDropdown.Opened then
            local newList = getPlayerList()
            local currentValue = playerDropdown.Value
            playerDropdown:Refresh(newList)

            if table.find(newList, currentValue) then
                playerDropdown:Select(currentValue)
            else
                selectedPlayerName = nil
                playerDropdown:Select(nil)
            end
        end
    end

    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)
end

task.spawn(function()
    while task.wait(0.5) do
        if Window and Window.Destroyed then break end

        pcall(function()
            if not player or not player.PlayerGui then return end
            
            local function findAndSetStat(statName, statValue, formatString, prefix)
                if statValue then
                    local settingsGui = player.PlayerGui:FindFirstChild("Settings")
                    if not settingsGui then return end
                    local statTile = settingsGui:FindFirstChild("StatTile", true)
                    if not statTile then return end

                    local labelToUpdate
                    if statName == "Fishing Luck" then
                         local statFrame = statTile:FindFirstChild("Stat")
                         if statFrame and statFrame:FindFirstChild("Label") then
                            labelToUpdate = statFrame.Label
                         end
                    else
                        for _, child in ipairs(statTile:GetChildren()) do
                            if child:IsA("Frame") and child:FindFirstChild("Label") and child.Label.Text:find(statName) then
                                labelToUpdate = child.Label
                                break
                            end
                        end
                    end
                    
                    if labelToUpdate then
                        local newText = string.format(formatString, prefix or "", statValue)
                        if labelToUpdate.Text ~= newText then
                            labelToUpdate.Text = newText
                        end
                    end
                end
            end

            findAndSetStat("Fishing Luck", statValues.FishingLuck, "%sFishing Luck: +%s%%", "")
            findAndSetStat("Shiny Chance", statValues.ShinyChance, "%sShiny Chance: %s%%", "")
            findAndSetStat("Mutation Chance", statValues.MutationChance, "%sMutation Chance: +%s%%", "")
        end)
    end
end)

local VirtualUser = game:GetService("VirtualUser")
if player and VirtualUser then
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

if Window then
    Window:SelectTab(1)
    WindUI:Notify({
        Title = "RexxyyHub Script Ready",
        Content = "All features have been loaded for Fish It.",
        Duration = 8,
        Icon = "check-circle"
    })
end
