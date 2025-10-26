-- iSylHub Login Screen Library
local LoginScreen = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Helper function to create UI element
local function createElement(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

local function fadeInItems(parent)
    for _, v in pairs(parent:GetDescendants()) do
        if (v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton")) and v.TextTransparency == 1 then
            TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        end
    end
end

-- Create Maintenance Screen
local function createMaintenanceScreen(onClose)
    local Player = Players.LocalPlayer
    local screen = createElement("ScreenGui", {
        Name = "MaintenanceScreen",
        ResetOnSpawn = false,
        Parent = Player:WaitForChild("PlayerGui")
    })
    
    local frame = createElement("Frame", {
        Size = UDim2.fromOffset(380, 280),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screen
    })
    
    createElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})
    createElement("UIStroke", {Thickness = 1, Color = Color3.fromRGB(60, 0, 0), Transparency = 0.5, Parent = frame})
    
    -- Maintenance Icon/Title
    local icon = createElement("TextLabel", {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.fromScale(0.5, 0.15),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "⚠",
        TextColor3 = Color3.fromRGB(200, 140, 60),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 50,
        Parent = frame
    })
    
    local title = createElement("TextLabel", {
        Size = UDim2.new(0, 280, 0, 35),
        Position = UDim2.fromScale(0.5, 0.35),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "Under Maintenance",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        Parent = frame
    })
    
    local message = createElement("TextLabel", {
        Size = UDim2.new(0.85, 0, 0, 80),
        Position = UDim2.fromScale(0.5, 0.55),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "The server is currently undergoing maintenance. Please check back later.",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame
    })
    
    local closeBtn = createElement("TextButton", {
        Size = UDim2.new(0, 120, 0, 40),
        Position = UDim2.fromScale(0.5, 0.82),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "Close",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        Font = Enum.Font.GothamMedium,
        BackgroundColor3 = Color3.fromRGB(120, 30, 30),
        BorderSizePixel = 0,
        Parent = frame
    })
    createElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = closeBtn})
    
    -- Hide initially
    frame.BackgroundTransparency = 1
    icon.TextTransparency = 1
    title.TextTransparency = 1
    message.TextTransparency = 1
    closeBtn.TextTransparency = 1
    
    -- Fade in
    task.wait(0.1)
    TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(icon, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(message, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    
    -- Button hover
    local originalBtn = closeBtn.BackgroundColor3
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(160, 40, 40)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = originalBtn}):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(icon, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(message, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(closeBtn, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.35)
        screen:Destroy()
        if onClose then onClose() end
    end)
end

-- Create Auto-Login Screen
local function createAutoLoginScreen(onComplete)
    local Player = Players.LocalPlayer
    local screen = createElement("ScreenGui", {
        Name = "AutoLoginScreen",
        ResetOnSpawn = false,
        Parent = Player:WaitForChild("PlayerGui")
    })
    
    local frame = createElement("Frame", {
        Size = UDim2.fromOffset(380, 250),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screen
    })
    
    createElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})
    createElement("UIStroke", {Thickness = 1, Color = Color3.fromRGB(60, 0, 0), Transparency = 0.5, Parent = frame})
    
    -- Title (no icon)
    local title = createElement("TextLabel", {
        Size = UDim2.new(0, 280, 0, 40),
        Position = UDim2.fromScale(0.5, 0.25),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "Auto-Login",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        Parent = frame
    })
    
    local subtitle = createElement("TextLabel", {
        Size = UDim2.new(0, 280, 0, 30),
        Position = UDim2.fromScale(0.5, 0.42),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "Welcome back! Verifying your key...",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = frame
    })
    
    -- Loading container
    local loaderContainer = createElement("Frame", {
        Size = UDim2.new(0, 260, 0, 8),
        Position = UDim2.fromScale(0.5, 0.65),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = frame
    })
    createElement("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = loaderContainer})
    
    local loaderFill = createElement("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(180, 20, 20),
        BorderSizePixel = 0,
        Parent = loaderContainer
    })
    createElement("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = loaderFill})
    
    local statusText = createElement("TextLabel", {
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.fromScale(0.5, 0.76),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = "",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Parent = frame
    })
    
    -- Hide initially
    frame.BackgroundTransparency = 1
    title.TextTransparency = 1
    subtitle.TextTransparency = 1
    statusText.TextTransparency = 1
    loaderFill.BackgroundTransparency = 1
    
    -- Fade in
    task.wait(0.1)
    TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(subtitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(statusText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(loaderFill, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    
    -- Loading animation
    task.spawn(function()
        statusText.Text = "Checking cached key..."
        task.wait(0.5)
        
        local steps = 60
        for i = 1, steps do
            loaderFill.Size = UDim2.new(i / steps, 0, 1, 0)
            
            if i == 20 then
                statusText.Text = "Verifying credentials..."
            elseif i == 40 then
                statusText.Text = "Loading session..."
            elseif i == 50 then
                statusText.Text = "Almost done..."
            end
            
            task.wait(0.03)
        end
        
        statusText.Text = "✓ Success!"
        statusText.TextColor3 = Color3.fromRGB(80, 180, 80)
        task.wait(0.3)
        
        -- Fade out
        TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(subtitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(statusText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(loaderFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.5)
        screen:Destroy()
        
        if onComplete then onComplete() end
    end)
    
    return {
        Destroy = function()
            screen:Destroy()
        end
    }
end

-- Create Splash Screen
local function createSplash(onComplete)
    local Player = Players.LocalPlayer
    local splashScreen = createElement("ScreenGui", {
        Name = "LoginSplash",
        ResetOnSpawn = false,
        Parent = Player:WaitForChild("PlayerGui")
    })

    local splashFrame = createElement("Frame", {
        Size = UDim2.fromOffset(380, 210),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        Parent = splashScreen
    })

    createElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = splashFrame})
    createElement("UIStroke", {Thickness = 1, Color = Color3.fromRGB(60, 0, 0), Transparency = 0.5, Parent = splashFrame})

    local titleText = createElement("TextLabel", {
        Size = UDim2.new(0, 220, 0, 40),
        Position = UDim2.fromScale(0.5, 0.22),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = "iSylHub Project",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        TextStrokeTransparency = 0.7,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        Parent = splashFrame
    })

    local subtitleText = createElement("TextLabel", {
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.fromScale(0.5, 0.37),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = "Premium Key System",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = splashFrame
    })

    local loaderContainer = createElement("Frame", {
        Size = UDim2.new(0, 240, 0, 6),
        Position = UDim2.fromScale(0.5, 0.65),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = splashFrame
    })
    createElement("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = loaderContainer})

    local loaderFill = createElement("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(180, 20, 20), BorderSizePixel = 0, Parent = loaderContainer})
    createElement("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = loaderFill})

    local progressText = createElement("TextLabel", {
        Size = UDim2.new(0, 100, 0, 20),
        Position = UDim2.fromScale(0.5, 0.74),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = "0%",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = splashFrame
    })

    -- Splash Animation
    task.spawn(function()
        task.wait(0.5)
        local duration = 2.5
        local steps = 100
        
        for i = 1, steps do
            loaderFill.Size = UDim2.new(i / steps, 0, 1, 0)
            progressText.Text = math.floor(i / steps * 100) .. "%"
            task.wait(duration / steps * (i > 80 and 0.7 or 1))
        end
        
        progressText.Text = "100%"
        task.wait(0.3)
        
        -- Fade out
        TweenService:Create(splashFrame, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(subtitleText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(loaderContainer, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(loaderFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(progressText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        
        task.wait(0.6)
        splashScreen:Destroy()
        if onComplete then onComplete() end
    end)
end

-- Main function to create login screen
function LoginScreen.Create(options)
    options = options or {}
    local onKeyValid = options.onKeyValid or function(key) print("Key:", key) end
    local onClose = options.onClose or function() end
    local checkKeyFunction = options.checkKey or function(key, callback) callback(false, "No validation") end
    local getKeyUrl = options.getKeyUrl or "https://discord.gg/9B3sxTxD2E"
    local healthCheckFunction = options.healthCheck
    
    local Player = Players.LocalPlayer
    
    -- Check server health first
    task.spawn(function()
        local isOnline = false
        if healthCheckFunction then
            healthCheckFunction(function(online)
                isOnline = online
                if isOnline then
                    -- Server is online, show splash then login form
                    createSplash(function()
                        createLoginForm(options)
                    end)
                else
                    -- Server is offline, show maintenance screen
                    createSplash(function()
                        createMaintenanceScreen(onClose)
                    end)
                end
            end)
        else
            -- No health check, assume online
            createSplash(function()
                createLoginForm(options)
            end)
        end
    end)
end

-- Separate login form creation
local function createLoginForm(options)
    local onKeyValid = options.onKeyValid or function(key) print("Key:", key) end
    local onClose = options.onClose or function() end
    local checkKeyFunction = options.checkKey or function(key, callback) callback(false, "No validation") end
    local getKeyUrl = options.getKeyUrl or "https://discord.gg/9B3sxTxD2E"
    local Player = Players.LocalPlayer
    
    -- Login Form
        local screen = createElement("ScreenGui", {Name = "LoginScreen", ResetOnSpawn = false, Parent = Player:WaitForChild("PlayerGui")})
        
        local frame = createElement("Frame", {
            Size = UDim2.fromOffset(380, 210),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = screen
        })
        
        createElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})
        createElement("UIStroke", {Thickness = 1, Color = Color3.fromRGB(60, 0, 0), Transparency = 0.5, Parent = frame})
        
        -- Topbar
        local topbar = createElement("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = frame})
        local title = createElement("TextLabel", {Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 20, 0, 0), Text = "Login", TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = topbar})
        local closeBtn = createElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(1, -30, 0, 7.5), Text = "×", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 20, Font = Enum.Font.Gotham, BackgroundTransparency = 1, AutoButtonColor = false, Parent = topbar})
        
        -- Content
        local content = createElement("Frame", {Size = UDim2.new(1, -40, 0, 180), Position = UDim2.new(0, 20, 0, 50), BackgroundTransparency = 1, Parent = frame})
        
        local keyInput = createElement("TextBox", {
            Size = UDim2.new(1, 0, 0, 45),
            Position = UDim2.new(0, 0, 0, 20),
            PlaceholderText = "Enter key",
            Text = "",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 16,
            Font = Enum.Font.Gotham,
            PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Parent = content
        })
        createElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = keyInput})
        
        local inputUnderline = createElement("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Color3.fromRGB(150, 20, 20), BorderSizePixel = 0, Parent = keyInput})
        
        local status = createElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 70),
            Text = "",
            TextColor3 = Color3.fromRGB(180, 180, 180),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = content
        })
        
        local buttonsContainer = createElement("Frame", {Size = UDim2.new(1, 0, 0, 45), Position = UDim2.new(0, 0, 0, 100), BackgroundTransparency = 1, Parent = content})
        
        local submitBtn = createElement("TextButton", {
            Size = UDim2.new(0.47, 0, 1, 0),
            Text = "Continue",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 15,
            Font = Enum.Font.GothamMedium,
            BackgroundColor3 = Color3.fromRGB(180, 20, 20),
            BorderSizePixel = 0,
            Parent = buttonsContainer
        })
        createElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = submitBtn})
        
        local getKeyBtn = createElement("TextButton", {
            Size = UDim2.new(0.47, 0, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            Text = "Get Key",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 15,
            Font = Enum.Font.Gotham,
            BackgroundColor3 = Color3.fromRGB(120, 30, 30),
            BorderSizePixel = 0,
            Parent = buttonsContainer
        })
        createElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = getKeyBtn})
        createElement("UIGradient", {Rotation = 135, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 15, 15))}), Parent = getKeyBtn})
        
        -- Hide elements initially
        for _, v in pairs(topbar:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then v.TextTransparency = 1 end
        end
        for _, v in pairs(content:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then v.TextTransparency = 1 end
        end
        
        -- Fade in
        task.wait(0.1)
        fadeInItems(topbar)
        fadeInItems(content)
        
        -- Close button
        local function closeScreen()
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            for _, v in pairs(frame:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                end
            end
            task.wait(0.35)
            screen:Destroy()
            onClose()
        end
        
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 20, 20)}):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        end)
        closeBtn.MouseButton1Click:Connect(closeScreen)
        
        -- Input focus
        local originalUnderline = inputUnderline.BackgroundColor3
        keyInput.Focused:Connect(function()
            TweenService:Create(inputUnderline, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(220, 40, 40), Size = UDim2.new(1, 0, 0, 2)}):Play()
        end)
        keyInput.FocusLost:Connect(function()
            TweenService:Create(inputUnderline, TweenInfo.new(0.3), {BackgroundColor3 = originalUnderline, Size = UDim2.new(1, 0, 0, 1)}):Play()
        end)
        
        -- Buttons hover
        local originalBtn = submitBtn.BackgroundColor3
        submitBtn.MouseEnter:Connect(function()
            TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 30, 30)}):Play()
        end)
        submitBtn.MouseLeave:Connect(function()
            TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = originalBtn}):Play()
        end)
        
        local originalGetKey = getKeyBtn.BackgroundColor3
        getKeyBtn.MouseEnter:Connect(function()
            TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(145, 35, 35)}):Play()
        end)
        getKeyBtn.MouseLeave:Connect(function()
            TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = originalGetKey}):Play()
        end)
        
        -- Get key button
        getKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                pcall(setclipboard, getKeyUrl)
                status.Text = "Link copied to clipboard!"
                status.TextColor3 = Color3.fromRGB(100, 180, 100)
            else
                status.Text = "Visit: " .. getKeyUrl
                status.TextColor3 = Color3.fromRGB(180, 140, 60)
            end
        end)
        
        -- Submit handler with custom check function
        submitBtn.MouseButton1Click:Connect(function()
            local key = keyInput.Text:gsub("%s+", "")
            
            if key == "" then
                status.Text = "Please enter a key"
                status.TextColor3 = Color3.fromRGB(180, 60, 60)
                return
            end
            
            submitBtn.Active = false
            submitBtn.Text = "Checking..."
            status.Text = "Verifying..."
            status.TextColor3 = Color3.fromRGB(200, 140, 60)
            
            -- Use custom check function
            checkKeyFunction(key, function(success, message)
                if success then
                    status.Text = message or "✓ Verified"
                    status.TextColor3 = Color3.fromRGB(80, 180, 80)
                    task.wait(0.5)
                    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    for _, v in pairs(frame:GetDescendants()) do
                        if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                            TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                        end
                    end
                    task.wait(0.35)
                    screen:Destroy()
                    onKeyValid(key)
                else
                    status.Text = message or "Invalid key"
                    status.TextColor3 = Color3.fromRGB(180, 60, 60)
                    submitBtn.Text = "Continue"
                    submitBtn.Active = true
                end
            end)
        end)
        
        keyInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then submitBtn:FireButtonClick() end
        end)
end

-- Export CreateAutoLogin function
function LoginScreen.CreateAutoLogin(onComplete)
    return createAutoLoginScreen(onComplete)
end

return LoginScreen
