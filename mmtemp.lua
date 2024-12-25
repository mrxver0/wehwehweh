local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local coinCount = 0
local coinLimit = 40
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = game:GetService("Workspace").CurrentCamera
local Noclip, Clip

-- Function to ensure we locate the CoinContainer specific to Murder Mystery 2 maps
local function ensureCoinContainer()
    for _, map in pairs(workspace:GetChildren()) do
        if map:IsA("Model") and map:FindFirstChild("CoinContainer") then
            local CoinContainer = map:FindFirstChild("CoinContainer")
            return CoinContainer, map.Name
        end
    end
    
    warn("CoinContainer not found in any MM2 map!")
    return nil, nil
end

-- Function to clear ESP boxes
local function clearESP(CoinContainer)
    if CoinContainer then
        for _, item in pairs(CoinContainer:GetChildren()) do
            if item:IsA("BasePart") then
                for _, child in pairs(item:GetChildren()) do
                    if child:IsA("BoxHandleAdornment") then
                        child:Destroy()
                    end
                end
            end
        end
    end
end

-- Function to handle coin collection (moves player to coin)
local function collectCoin(coin)
    -- Create a tween to move the player towards the coin
    local coinPosition = coin.Position
    local playerPosition = character.HumanoidRootPart.Position
    local direction = (coinPosition - playerPosition).unit
    local targetPosition = coinPosition + direction * 5 -- Move slightly above the coin
    
    -- Calculate distance and time to move at 16 studs per second
    local distance = (coinPosition - playerPosition).magnitude
    local timeToMove = distance / 16  -- Time to move 16 studs per second
    
    -- Disable collision temporarily (no-clip)
    noclip()

    -- Tween the player to the coin
    local tweenInfo = TweenInfo.new(
        timeToMove, -- Duration calculated based on distance and speed
        Enum.EasingStyle.Quint, -- Easing style
        Enum.EasingDirection.Out -- Easing direction
    )
    
    local goal = {Position = targetPosition}
    local tween = TweenService:Create(character.HumanoidRootPart, tweenInfo, goal)
    tween:Play()

    -- Wait until the character reaches the coin
    tween.Completed:Connect(function()
        -- Now that the character is close enough to the coin, we simulate collection
        if (coin.Position - character.HumanoidRootPart.Position).magnitude <= 5 then
            coin:Destroy()  -- Remove the coin (simulating collection)
            coinCount = coinCount + 1
            print("Coin collected! Total coins: " .. coinCount)
        end
        
        -- Re-enable collision for the player's parts
        clip()

        -- Add a 0.5-second pause before moving to the next coin
        wait(0.5)
    end)
end

-- Main ESP loop for coins
while true do
    local CoinContainer, mapName = ensureCoinContainer()
    
    if coinCount >= coinLimit then
        warn("Reached coin limit! ESP disabled.")
        clearESP(CoinContainer)
        wait(1)
        continue
    end
    
    if CoinContainer then
        for _, item in pairs(CoinContainer:GetChildren()) do
            if item:IsA("BasePart") and not item:FindFirstChildOfClass("BoxHandleAdornment") then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Adornee = item
                espBox.Size = item.Size
                espBox.AlwaysOnTop = true
                espBox.ZIndex = 10
                espBox.Color3 = Color3.fromRGB(173, 216, 230) -- Light Blue
                espBox.Transparency = 0.5
                espBox.Parent = item

                -- Automatically move towards the detected coin
                collectCoin(item)
            end
        end
    end
    
    -- Increment coin count if a coin is picked up (placeholder event)
    -- Replace this with the actual coin pickup event listener
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("CoinAmount") then
        coinCount = player.Data.CoinAmount.Value
    end
    
    wait(0.5)
end

-- No-Clip Functions
function noclip()
    Clip = false
    local function Nocl()
        if Clip == false and game.Players.LocalPlayer.Character ~= nil then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide and v.Name ~= "HumanoidRootPart" then
                    v.CanCollide = false
                end
            end
        end
        wait(0.21) -- basic optimization
    end
    Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
end

function clip()
    if Noclip then Noclip:Disconnect() end
    Clip = true
end