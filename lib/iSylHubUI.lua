-- iSylHub Login Screen Library 
local LoginScreen = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ProtectGui function (similar to FluentPlus)
local ProtectGui = protectgui or (syn and syn.protect_gui) or function(gui)
    if gui and typeof(gui) == "Instance" then
        pcall(function()
            gui.ResetOnSpawn = false
            gui.DisplayOrder = 1000
        end)
    end
end

-- Platform detection (improved for all platforms)
local function getPlatform()
    if RunService:IsStudio() then
        return false -- Desktop in studio
    end
    local platform = UserInputService:GetPlatform()
    return table.find({Enum.Platform.IOS, Enum.Platform.Android}, platform) ~= nil
end

local isMobile = getPlatform()

-- Responsive Size Definitions
-- Ukuran untuk [Desktop] or [Mobile]. Mobile dibuat lebih sempit agar pas.
-- Menggunakan UDim2 dengan kombinasi scale dan offset untuk responsif sempurna
local function getResponsiveSize(mobileWidth, mobileHeight, desktopWidth, desktopHeight)
    if isMobile then
        -- Mobile: gunakan scale untuk adaptasi berbagai ukuran layar
        return UDim2.new(0.85, 0, 0, mobileHeight) -- 85% lebar layar, tinggi tetap
    else
        return UDim2.fromOffset(desktopWidth, desktopHeight)
    end
end

local SIZES = {
    Maintenance = getResponsiveSize(320, 290, 380, 280),
    AutoLogin   = getResponsiveSize(320, 260, 380, 250),
    Splash      = getResponsiveSize(320, 250, 380, 240),
    Login       = getResponsiveSize(320, 220, 380, 210)
}


-- Helper function to create UI element (improved with error handling)
local function createElement(className, props)
    local success, inst = pcall(function()
        return Instance.new(className)
    end)
    
    if not success or not inst then
        warn("Failed to create instance:", className)
        return nil
    end
    
    for k, v in pairs(props) do
        pcall(function()
            inst[k] = v
        end)
    end
    return inst
end

-- Safe function to get PlayerGui (critical for mobile)
local function getPlayerGui()
    local player = Players.LocalPlayer
    if not player then
        player = Players:GetPlayers()[1]
    end
    if player then
        return player:WaitForChild("PlayerGui", 10)
    end
    return nil
end

local function fadeInItems(parent)
    for _, v in pairs(parent:GetDescendants()) do
        if (v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton")) and v.TextTransparency == 1 then
            TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        end
    end
end

-- Forward declarations (to prevent "attempt to call nil value" errors)
local createMaintenanceScreen
local createAutoLoginScreen
local createSplash
local createLoginForm

-- Create Maintenance Screen
createMaintenanceScreen = function(onClose)
    local playerGui = getPlayerGui()
    if not playerGui then
        warn("Failed to get PlayerGui for MaintenanceScreen")
        if onClose then onClose() end
        return
    end
    
    local screen = createElement("ScreenGui", {
        Name = "MaintenanceScreen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
        Parent = playerGui
    })
    
    if not screen then
        warn("Failed to create MaintenanceScreen")
        if onClose then onClose() end
        return
    end
    
    -- Protect the GUI (important for mobile)
    ProtectGui(screen)
    
    local frame = createElement("Frame", {
        Size = SIZES.Maintenance, -- MODIFIED: Menggunakan ukuran responsif
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true, -- Important for mobile touch
        Parent = screen
    })
    
    if not frame then
        warn("Failed to create frame for MaintenanceScreen")
        screen:Destroy()
        if onClose then onClose() end
        return
    end
    
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
        Size = UDim2.new(0.9, 0, 0, isMobile and 40 or 35), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.35),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "Under Maintenance",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = isMobile and 24 or 22, -- Text lebih besar di mobile
        TextScaled = false, -- Explicitly set to false for better control
        Parent = frame
    })
    
    local message = createElement("TextLabel", {
        Size = UDim2.new(0.85, 0, 0, isMobile and 100 or 90), -- MODIFIED: Lebih tinggi untuk mobile
        Position = UDim2.fromScale(0.5, 0.55),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "The server is currently undergoing maintenance. Please check back later.",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 15 or 14, -- Text lebih besar di mobile
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame
    })
    
    local closeBtn = createElement("TextButton", {
        Size = UDim2.new(isMobile and 0.85 or 0.5, 0, 0, isMobile and 45 or 40), -- MODIFIED: Tombol lebih besar di mobile
        Position = UDim2.fromScale(0.5, 0.82),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "Close",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 16 or 15, -- Text lebih besar di mobile untuk readability
        Font = Enum.Font.GothamMedium,
        BackgroundColor3 = Color3.fromRGB(120, 30, 30),
        BorderSizePixel = 0,
        Active = true, -- Important for mobile touch
        AutoButtonColor = false, -- Prevent default button color change
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
    
    -- Button interactions (mobile-safe)
    local originalBtn = closeBtn.BackgroundColor3
    
    -- Only add mouse hover events on non-mobile platforms
    if not isMobile then
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(160, 40, 40)}):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = originalBtn}):Play()
        end)
    end
    
    -- Touch/Click event (works on all platforms)
    closeBtn.Activated:Connect(function()
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

-- Create Auto-Login Screen (Interactive with controllable progress)
createAutoLoginScreen = function(onComplete, options)
    options = options or {}
    local playerGui = getPlayerGui()
    if not playerGui then
        warn("Failed to get PlayerGui for AutoLoginScreen")
        if onComplete then onComplete() end
        return {}
    end
    
    local screen = createElement("ScreenGui", {
        Name = "AutoLoginScreen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
        Parent = playerGui
    })
    
    if not screen then
        warn("Failed to create AutoLoginScreen")
        if onComplete then onComplete() end
        return {}
    end
    
    -- Protect the GUI (important for mobile)
    ProtectGui(screen)
    
    local frame = createElement("Frame", {
        Size = SIZES.AutoLogin, -- MODIFIED: Menggunakan ukuran responsif
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true, -- Important for mobile touch
        Parent = screen
    })
    
    if not frame then
        warn("Failed to create frame for AutoLoginScreen")
        screen:Destroy()
        if onComplete then onComplete() end
        return {}
    end
    
    createElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})
    createElement("UIStroke", {Thickness = 1, Color = Color3.fromRGB(60, 0, 0), Transparency = 0.5, Parent = frame})
    
    -- Title (no icon)
    local title = createElement("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, isMobile and 45 or 40), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.25),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "Auto-Login",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = isMobile and 30 or 28, -- Text lebih besar di mobile
        TextScaled = false,
        Parent = frame
    })
    
    local subtitle = createElement("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, isMobile and 35 or 30), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.42),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = options.subtitle or "Welcome back! Verifying your key...",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 14 or 13, -- Text lebih besar di mobile
        TextWrapped = true,
        Parent = frame
    })
    
    -- Loading container
    local loaderContainer = createElement("Frame", {
        Size = UDim2.new(0.8, 0, 0, 8), -- MODIFIED: Menggunakan skala
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
        Size = UDim2.new(0.9, 0, 0, isMobile and 25 or 20), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.76),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = options.initialStatus or "Checking cached key...",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 12 or 11, -- Text lebih besar di mobile
        TextWrapped = true,
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
    
    -- Control functions
    local currentProgress = 0
    local isDestroyed = false
    
    local function updateProgress(progress, smooth)
        if isDestroyed then return end
        progress = math.clamp(progress, 0, 100)
        currentProgress = progress
        
        if smooth then
            TweenService:Create(loaderFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(progress / 100, 0, 1, 0)
            }):Play()
        else
            loaderFill.Size = UDim2.new(progress / 100, 0, 1, 0)
        end
    end
    
    local function updateStatus(text, color)
        if isDestroyed then return end
        statusText.Text = text or statusText.Text
        if color then
            statusText.TextColor3 = color
        end
    end
    
    local function complete()
        if isDestroyed then return end
        updateProgress(100, true)
        updateStatus("✓ Success!", Color3.fromRGB(80, 180, 80))
        task.wait(0.3)
        
        -- Fade out
        TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(subtitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(statusText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(loaderFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.5)
        isDestroyed = true
        screen:Destroy()
        
        if onComplete then onComplete() end
    end
    
    local function destroy()
        if isDestroyed then return end
        isDestroyed = true
        screen:Destroy()
    end

    -- Return control object
    local control = {
        UpdateProgress = updateProgress,
        UpdateStatus = updateStatus,
        Complete = complete,
        Destroy = destroy,
        GetProgress = function() return currentProgress end
    }
    
    -- Auto-complete jika tidak ada kontrol manual (backward compatibility)
    if not options.manualControl then
        task.spawn(function()
            statusText.Text = "Checking cached key..."
            task.wait(0.5)
            
            local steps = 60
            for i = 1, steps do
                if isDestroyed then break end
                updateProgress((i / steps) * 100, true)
                
                if i == 20 then
                    updateStatus("Verifying credentials...")
                elseif i == 40 then
                    updateStatus("Loading session...")
                elseif i == 50 then
                    updateStatus("Almost done...")
                end
                
                task.wait(0.03)
            end
            
            if not isDestroyed then
                complete()
            end
        end)
    end
    
    return control
end

-- Create Splash Screen (Interactive with controllable progress)
createSplash = function(onComplete, options)
    options = options or {}
    local playerGui = getPlayerGui()
    if not playerGui then
        warn("Failed to get PlayerGui for SplashScreen")
        if onComplete then onComplete() end
        return {}
    end
    
    local splashScreen = createElement("ScreenGui", {
        Name = "LoginSplash",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
        Parent = playerGui
    })
    
    if not splashScreen then
        warn("Failed to create SplashScreen")
        if onComplete then onComplete() end
        return {}
    end
    
    -- Protect the GUI (important for mobile)
    ProtectGui(splashScreen)

    local splashFrame = createElement("Frame", {
        Size = SIZES.Splash, -- MODIFIED: Menggunakan ukuran responsif
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        Active = true, -- Important for mobile touch
        Parent = splashScreen
    })
    
    if not splashFrame then
        warn("Failed to create frame for SplashScreen")
        splashScreen:Destroy()
        if onComplete then onComplete() end
        return {}
    end

    createElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = splashFrame})
    createElement("UIStroke", {Thickness = 1, Color = Color3.fromRGB(60, 0, 0), Transparency = 0.5, Parent = splashFrame})

    local titleText = createElement("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, isMobile and 45 or 40), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.20),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = "iSylHub Project",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = isMobile and 28 or 26, -- Text lebih besar di mobile
        TextStrokeTransparency = 0.7,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextScaled = false,
        Parent = splashFrame
    })

    local subtitleText = createElement("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, isMobile and 25 or 20), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.33),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = "Premium Key System",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 14 or 13, -- Text lebih besar di mobile
        TextWrapped = true,
        Parent = splashFrame
    })

    local statusText = createElement("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, isMobile and 25 or 20), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.50),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = options.initialStatus or "Initializing...",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 12 or 11, -- Text lebih besar di mobile
        TextWrapped = true,
        Parent = splashFrame
    })

    local loaderContainer = createElement("Frame", {
        Size = UDim2.new(0.8, 0, 0, 6), -- MODIFIED: Menggunakan skala
        Position = UDim2.fromScale(0.5, 0.65),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = splashFrame
    })
    createElement("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = loaderContainer})

    local loaderFill = createElement("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(180, 20, 20),
        BorderSizePixel = 0,
        Parent = loaderContainer
    })
    createElement("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = loaderFill})

    local progressText = createElement("TextLabel", {
        Size = UDim2.new(0.8, 0, 0, isMobile and 25 or 20), -- MODIFIED: Lebih tinggi di mobile
        Position = UDim2.fromScale(0.5, 0.75),
        AnchorPoint = Vector2.new(0.5, 0),
        Text = "0%",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 13 or 12, -- Text lebih besar di mobile
        Parent = splashFrame
    })

    -- Hide initially
    splashFrame.BackgroundTransparency = 1
    titleText.TextTransparency = 1
    subtitleText.TextTransparency = 1
    statusText.TextTransparency = 1
    progressText.TextTransparency = 1
    loaderFill.BackgroundTransparency = 1

    -- Fade in
    task.wait(0.1)
    TweenService:Create(splashFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    TweenService:Create(titleText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(subtitleText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(statusText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(progressText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(loaderFill, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()

    -- Control functions
    local currentProgress = 0
    local isDestroyed = false
    
    local function updateProgress(progress, smooth)
        if isDestroyed then return end
        progress = math.clamp(progress, 0, 100)
        currentProgress = progress
        
        if smooth then
            TweenService:Create(loaderFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(progress / 100, 0, 1, 0)
            }):Play()
        else
            loaderFill.Size = UDim2.new(progress / 100, 0, 1, 0)
        end
        progressText.Text = math.floor(progress) .. "%"
    end
    
    local function updateStatus(text, color)
        if isDestroyed then return end
        statusText.Text = text or statusText.Text
        if color then
            statusText.TextColor3 = color
        end
    end
    
    local function complete()
        if isDestroyed then return end
        updateProgress(100, true)
        updateStatus("✓ Ready!", Color3.fromRGB(80, 180, 80))
        task.wait(0.3)
        
        -- Fade out
        TweenService:Create(splashFrame, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(subtitleText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(statusText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(loaderContainer, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(loaderFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(progressText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        
        task.wait(0.6)
        isDestroyed = true
        splashScreen:Destroy()
        if onComplete then onComplete() end
    end
    
    local function destroy()
        if isDestroyed then return end
        isDestroyed = true
        splashScreen:Destroy()
    end

    -- Return control object
    local control = {
        UpdateProgress = updateProgress,
        UpdateStatus = updateStatus,
        Complete = complete,
        Destroy = destroy,
        GetProgress = function() return currentProgress end
    }

    -- Auto-complete jika tidak ada kontrol manual (backward compatibility)
    if not options.manualControl then
        task.spawn(function()
            task.wait(0.5)
            local duration = options.duration or 2.5
            local steps = 100
            
            for i = 1, steps do
                if isDestroyed then break end
                updateProgress(i, true)
                task.wait(duration / steps * (i > 80 and 0.7 or 1))
            end
            
            if not isDestroyed then
                complete()
            end
        end)
    end

    return control
end

-- Create Login Form (Full implementation with mobile support)
createLoginForm = function(options)
    options = options or {}
    local onKeyValid = options.onKeyValid or function(key) print("Key:", key) end
    local onClose = options.onClose or function() end
    local checkKeyFunction = options.checkKey or function(key, callback) callback(false, "No validation") end
    local getKeyUrl = options.getKeyUrl or "https://discord.gg/9B3sxTxD2E"
    
    local playerGui = getPlayerGui()
    if not playerGui then
        warn("Failed to get PlayerGui for LoginForm")
        if onClose then onClose() end
        return
    end
    
    -- Login Form ScreenGui
    local screen = createElement("ScreenGui", {
        Name = "LoginScreen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
        Parent = playerGui
    })
    
    if not screen then
        warn("Failed to create LoginScreen")
        if onClose then onClose() end
        return
    end
    
    -- Protect the GUI (important for mobile)
    ProtectGui(screen)
    
    local frame = createElement("Frame", {
        Size = SIZES.Login, -- Using responsive size
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true, -- Important for mobile touch
        Parent = screen
    })
    
    if not frame then
        warn("Failed to create frame for LoginScreen")
        screen:Destroy()
        if onClose then onClose() end
        return
    end
    
    createElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})
    createElement("UIStroke", {Thickness = 1, Color = Color3.fromRGB(60, 0, 0), Transparency = 0.5, Parent = frame})
    
    -- Topbar
    local topbar = createElement("Frame", {
        Size = UDim2.new(1, 0, 0, isMobile and 45 or 40),
        BackgroundTransparency = 1,
        Parent = frame
    })
    
    local title = createElement("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        Text = "Login",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 20 or 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar
    })
    
    local closeBtn = createElement("TextButton", {
        Size = UDim2.new(0, isMobile and 30 or 25, 0, isMobile and 30 or 25),
        Position = UDim2.new(1, -30, 0, isMobile and 7.5 or 7.5),
        Text = "×",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = isMobile and 24 or 20,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Active = true, -- Important for mobile touch
        Parent = topbar
    })
    
    -- Content
    local content = createElement("Frame", {
        Size = UDim2.new(1, -40, 0, isMobile and 200 or 180),
        Position = UDim2.new(0, 20, 0, isMobile and 55 or 50),
        BackgroundTransparency = 1,
        Parent = frame
    })
    
    local keyInput = createElement("TextBox", {
        Size = UDim2.new(1, 0, 0, isMobile and 50 or 45),
        Position = UDim2.new(0, 0, 0, 20),
        PlaceholderText = "Enter key",
        Text = "",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = isMobile and 17 or 16,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Active = true, -- Important for mobile touch
        Parent = content
    })
    createElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = keyInput})
    
    local inputUnderline = createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(150, 20, 20),
        BorderSizePixel = 0,
        Parent = keyInput
    })
    
    local status = createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, isMobile and 25 or 20),
        Position = UDim2.new(0, 0, 0, 70),
        Text = "",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = isMobile and 13 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = content
    })
    
    local buttonsContainer = createElement("Frame", {
        Size = UDim2.new(1, 0, 0, isMobile and 50 or 45),
        Position = UDim2.new(0, 0, 0, isMobile and 110 or 100),
        BackgroundTransparency = 1,
        Parent = content
    })
    
    local submitBtn = createElement("TextButton", {
        Size = UDim2.new(0.47, 0, 1, 0),
        Text = "Continue",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 16 or 15,
        Font = Enum.Font.GothamMedium,
        BackgroundColor3 = Color3.fromRGB(180, 20, 20),
        BorderSizePixel = 0,
        Active = true, -- Important for mobile touch
        AutoButtonColor = false,
        Parent = buttonsContainer
    })
    createElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = submitBtn})
    
    local getKeyBtn = createElement("TextButton", {
        Size = UDim2.new(0.47, 0, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        Text = "Get Key",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 16 or 15,
        Font = Enum.Font.Gotham,
        BackgroundColor3 = Color3.fromRGB(120, 30, 30),
        BorderSizePixel = 0,
        Active = true, -- Important for mobile touch
        AutoButtonColor = false,
        Parent = buttonsContainer
    })
    createElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = getKeyBtn})
    createElement("UIGradient", {
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 15, 15))
        }),
        Parent = getKeyBtn
    })
    
    -- Hide elements initially
    for _, v in pairs(topbar:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            v.TextTransparency = 1
        end
    end
    for _, v in pairs(content:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
            v.TextTransparency = 1
        end
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
        if onClose then onClose() end
    end
    
    -- Close button interactions (mobile-safe)
    if not isMobile then
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 20, 20)}):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        end)
    end
    
    -- Touch/Click event (works on all platforms)
    closeBtn.Activated:Connect(closeScreen)
    
    -- Input focus
    local originalUnderline = inputUnderline.BackgroundColor3
    keyInput.Focused:Connect(function()
        TweenService:Create(inputUnderline, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(220, 40, 40),
            Size = UDim2.new(1, 0, 0, 2)
        }):Play()
    end)
    keyInput.FocusLost:Connect(function()
        TweenService:Create(inputUnderline, TweenInfo.new(0.3), {
            BackgroundColor3 = originalUnderline,
            Size = UDim2.new(1, 0, 0, 1)
        }):Play()
    end)
    
    -- Buttons hover (only for non-mobile)
    if not isMobile then
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
    end
    
    -- Get key button (works on all platforms)
    getKeyBtn.Activated:Connect(function()
        if setclipboard then
            pcall(function()
                setclipboard(getKeyUrl)
                status.Text = "Link copied to clipboard!"
                status.TextColor3 = Color3.fromRGB(100, 180, 100)
            end)
        else
            status.Text = "Visit: " .. getKeyUrl
            status.TextColor3 = Color3.fromRGB(180, 140, 60)
        end
    end)
    
    -- Submit handler with custom check function
    submitBtn.Activated:Connect(function()
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
                if onKeyValid then onKeyValid(key) end
            else
                status.Text = message or "Invalid key"
                status.TextColor3 = Color3.fromRGB(180, 60, 60)
                submitBtn.Text = "Continue"
                submitBtn.Active = true
            end
        end)
    end)
    
    -- Enter key to submit
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            submitBtn:FireButtonClick()
        end
    end)
end

-- Main function to create login screen (with health check and splash)
function LoginScreen.Create(options)
    options = options or {}
    local onKeyValid = options.onKeyValid or function(key) print("Key:", key) end
    local onClose = options.onClose or function() end
    local checkKeyFunction = options.checkKey or function(key, callback) callback(false, "No validation") end
    local getKeyUrl = options.getKeyUrl or "https://discord.gg/9B3sxTxD2E"
    local healthCheckFunction = options.healthCheck
    
    -- Check server health first
    task.spawn(function()
        local isOnline = false
        if healthCheckFunction then
            -- Tampilkan loading screen dengan progress yang dapat dikontrol
            local loadingControl = createSplash(nil, {
                manualControl = true,
                initialStatus = "Menunggu response dari server..."
            })
            
            if not loadingControl then
                -- Fallback: proceed without health check
                createSplash(function()
                    createLoginForm(options)
                end)
                return
            end
            
            -- Update progress sambil menunggu health check
            loadingControl.UpdateProgress(10, true)
            loadingControl.UpdateStatus("Menunggu response dari server...", Color3.fromRGB(200, 140, 60))
            
            -- Pass loading control to health check function if it accepts it
            local success, result = pcall(function()
                return healthCheckFunction(function(online)
                    isOnline = online
                    
                    if isOnline then
                        -- Server online
                        loadingControl.UpdateProgress(50, true)
                        loadingControl.UpdateStatus("Server online, memuat...", Color3.fromRGB(100, 180, 100))
                        task.wait(0.3)
                        
                        loadingControl.Complete()
                        
                        -- Show splash then login form
                        task.wait(0.5)
                        createSplash(function()
                            createLoginForm(options)
                        end)
                    else
                        -- Server offline
                        loadingControl.UpdateProgress(100, true)
                        loadingControl.UpdateStatus("Server sedang maintenance", Color3.fromRGB(180, 60, 60))
                        task.wait(0.5)
                        
                        loadingControl.Complete()
                        
                        -- Show maintenance screen
                        task.wait(0.5)
                        createMaintenanceScreen(onClose)
                    end
                end, loadingControl)
            end)
            
            -- If health check doesn't accept loading control, use default callback
            if not success then
                healthCheckFunction(function(online)
                    isOnline = online
                    
                    if isOnline then
                        loadingControl.UpdateProgress(50, true)
                        loadingControl.UpdateStatus("Server online, memuat...", Color3.fromRGB(100, 180, 100))
                        task.wait(0.3)
                        loadingControl.Complete()
                        task.wait(0.5)
                        createSplash(function()
                            createLoginForm(options)
                        end)
                    else
                        loadingControl.UpdateProgress(100, true)
                        loadingControl.UpdateStatus("Server sedang maintenance", Color3.fromRGB(180, 60, 60))
                        task.wait(0.5)
                        loadingControl.Complete()
                        task.wait(0.5)
                        createMaintenanceScreen(onClose)
                    end
                end)
            end
        else
            -- No health check, assume online
            createSplash(function()
                createLoginForm(options)
            end)
        end
    end)
end

-- Export module
LoginScreen.CreateMaintenance = createMaintenanceScreen
LoginScreen.CreateAutoLogin = createAutoLoginScreen
LoginScreen.CreateSplash = createSplash

return LoginScreen
