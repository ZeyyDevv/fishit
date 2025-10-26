local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local webhookURL = "https://discord.com/api/webhooks/1403155137614188617/ss9lg3iPu8R_u0H5cLLp-PLuM13E-7kZxk7jaMvpH40S2UOrlyvdXvEI1RDNhl4FgL6E"
local REObtainedNewFish = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
local REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
local REFishingStopped = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingStopped"]

local caughtFishName, caughtFishWeight, fishIdData, notifData, isNewData = nil, nil, nil, nil, nil

REFishCaught.OnClientEvent:Connect(function(fishName, weightData)
    caughtFishName = fishName
    caughtFishWeight = weightData.Weight
end)

REObtainedNewFish.OnClientEvent:Connect(function(fishId, weightData, notifDataReceived, isNew)
    fishIdData = fishId
    notifData = notifDataReceived
    isNewData = isNew
end)

REFishingStopped.OnClientEvent:Connect(function()
    for i = 1, 10 do
        if caughtFishName then break end
        task.wait(0.1)
    end
    
    if not caughtFishName then return end
    
    task.wait(0.2)
    
    local player = Players.LocalPlayer
    local container = {
        {
            ["type"] = 17,
            ["accent_color"] = nil,
            ["spoiler"] = false,
            ["components"] = {
                {["type"] = 10, ["content"] = "### 🎣 **New Fish Caught!** (<t:" .. math.floor(os.time()) .. ":F>)"},
                {["type"] = 14, ["divider"] = true, ["spacing"] = 1},
                {["type"] = 10, ["content"] = "👤 **Username:** " .. player.Name},
                {["type"] = 10, ["content"] = string.format("🐟 **Fish:** %s (Weight: %.2f kg)", caughtFishName, caughtFishWeight)},
                {["type"] = 10, ["content"] = string.format("%s **Is New Fish:** %s", isNewData and "✅" or "❌", isNewData and "Yes" or "No")},
                {["type"] = 10, ["content"] = "🕐 **Time:** <t:" .. math.floor(os.time()) .. ":R>"},
                {["type"] = 10, ["content"] = "\n\n-# Webhook Fish It by <@1186284402565722197> from iSylHub Project"}
            }
        }
    }
    
    request({
        Url = webhookURL .. "?with_components=true",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json", ["accept"] = "*/*", ["cache-control"] = "no-cache"},
        Body = HttpService:JSONEncode({["components"] = container, ["flags"] = 32768})
    })
    
    caughtFishName, caughtFishWeight, fishIdData, notifData, isNewData = nil, nil, nil, nil, nil
end)
