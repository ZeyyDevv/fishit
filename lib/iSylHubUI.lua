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

-- Create Login Form (placeholder - implement as needed)
createLoginForm = function(options)
    -- TODO: Implement login form
    warn("createLoginForm not yet implemented")
    return {}
end

-- Export module
LoginScreen.CreateMaintenance = createMaintenanceScreen
LoginScreen.CreateAutoLogin = createAutoLoginScreen
LoginScreen.CreateSplash = createSplash
LoginScreen.Create = createLoginForm

return LoginScreen
