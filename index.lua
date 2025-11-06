-- iSylHub Authentication System
-- Refactored & Simplified

-- =========================
-- CONFIG
-- =========================
local CONFIG = {
	KEY_CHECK_URL = "https://server.isylhub.workers.dev/api/keys/check",
	GET_KEY_URL = "https://discord.gg/9B3sxTxD2E",
	MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/iSylvesterr/fishit/refs/heads/main/fishit.lua",
	LOGIN_SCREEN_URL = "https://raw.githubusercontent.com/ZeyyDevv/fishit/refs/heads/main/lib/iSylHubUI.lua",
	HEALTH_CHECK_URL = "https://server.isylhub.workers.dev/health",
	CACHE_PATH = "iSyl_key_cache.txt",
	AUTO_VERIFY = true,
	USE_CACHE_OFFLINE = true,
	HEALTH_CHECK_TIMEOUT = 10 -- Timeout dalam detik
}

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")
local Player = Players.LocalPlayer

-- =========================
-- HELPERS
-- =========================
local function safe_get(url, timeout)
	timeout = timeout or CONFIG.HEALTH_CHECK_TIMEOUT
	local result = nil
	local completed = false
	local requestError = nil
	
	-- Start request in separate thread
	task.spawn(function()
		local ok, res = pcall(function()
			if syn and syn.request then
				return syn.request({Url = url, Method = "GET", Timeout = timeout}).Body
			elseif request then
				return request({Url = url, Method = "GET", Timeout = timeout}).Body
			elseif http and http.request then
				return http.request({Url = url, Method = "GET", Timeout = timeout}).Body
			elseif game.HttpGet then
				return game:HttpGet(url)
			end
		end)
		if ok and res then
			result = res
		else
			requestError = res
		end
		completed = true
	end)
	
	-- Wait for completion or timeout
	local startTime = tick()
	while not completed and (tick() - startTime) < timeout do
		task.wait(0.1)
	end
	
	-- Jika timeout, return nil
	if not completed then
		return nil
	end
	
	return result
end

local function save_cache(key)
	if writefile then
		pcall(function() writefile(CONFIG.CACHE_PATH, key) end)
	end
end

local function load_cache()
	if readfile and isfile and isfile(CONFIG.CACHE_PATH) then
		local ok, res = pcall(function() return readfile(CONFIG.CACHE_PATH) end)
		if ok and res and res ~= "" then
			return res:gsub("%s+", "")
		end
	end
	return nil
end

local function delete_cache()
	if isfile and delfile then
		pcall(function() delfile(CONFIG.CACHE_PATH) end)
	end
end

local function is_hwid_reset(json)
	if type(json) ~= "table" then return false end
	if json.reset_hwid == true or json.hwid_reset == true then return true end
	if json.reset and tostring(json.reset):lower():find("hwid") then return true end
	if json.msg then
		local msg = tostring(json.msg):upper()
		return msg:find("HWID") and msg:find("RESET")
	end
	return false
end

local function check_key(key)
	local hwid = Analytics:GetClientId()
	local url = CONFIG.KEY_CHECK_URL .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)
	local res = safe_get(url)
	
	if not res then return nil end
	
	local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
	if not ok or type(json) ~= "table" then return nil end
	
	if is_hwid_reset(json) then
		Player:Kick("HWID HAS BEEN RESET")
		return nil
	end
	
	return json
end

local function load_main_script()
	task.wait(0.2)
	local body = safe_get(CONFIG.MAIN_SCRIPT_URL)
	if not body then
		warn("Failed to get main script")
		return
	end
	
	local fn, err = loadstring(body)
	if not fn then
		warn("Failed to compile main script:", err)
		return
	end
	
	local ok, err2 = pcall(fn)
	if not ok then
		warn("Error running main script:", err2)
	end
end

-- =========================
-- LOGIN SCREEN LOADER
-- =========================
local function load_login_screen()
	-- Try local file first
	if script and script.Parent then
		local module = script.Parent:FindFirstChild("loginscreen")
		if module then
			local ok, result = pcall(function() return require(module) end)
			if ok and result then
				print("✓ Loaded Login Screen from local file")
				return result
			end
		end
	end
	
	-- Load from GitHub
	local body = safe_get(CONFIG.LOGIN_SCREEN_URL)
	if not body then
		warn("Failed to load Login Screen from GitHub")
		return nil
	end
	
	local fn, err = loadstring(body)
	if not fn then
		warn("Failed to compile Login Screen:", err)
		return nil
	end
	
	local ok, result = pcall(fn)
	if ok and result then
		print("✓ Loaded Login Screen from GitHub")
		return result
	end
	
	warn("❌ Login Screen library failed to load")
	return nil
end

-- =========================
-- MAIN LOGIC
-- =========================
local LoginScreen = load_login_screen()
if not LoginScreen then return end

local function on_key_valid(key)
	save_cache(key)
	load_main_script()
end

local function check_key_function(key, callback)
	local json = check_key(key)
	if not json then
		callback(false, "Failed to connect to server or invalid response")
		return
	end
	
	if json.ok then
		callback(true, json.msg or "Key valid")
	else
		callback(false, json.msg or "Invalid key")
	end
end

-- =========================
-- HEALTH CHECK WITH LOADING
-- =========================
local function health_check_function(callback, loadingControl)
	-- Lakukan health check dengan timeout
	-- Loading screen akan muncul dari LoginScreen.Create (splash screen)
	task.spawn(function()
		print("⏳ Menunggu response dari server...")
		
		local startTime = tick()
		local timeout = CONFIG.HEALTH_CHECK_TIMEOUT
		local checkInterval = 0.1 -- Update progress setiap 0.1 detik
		local lastProgress = 10
		local shouldStop = false
		
		-- Update progress secara real-time sambil menunggu response
		task.spawn(function()
			while not shouldStop and tick() - startTime < timeout do
				local elapsed = tick() - startTime
				local progress = math.min(10 + (elapsed / timeout) * 40, 50) -- Progress dari 10% sampai 50%
				
				if loadingControl and progress > lastProgress and not shouldStop then
					loadingControl.UpdateProgress(progress, true)
					lastProgress = progress
					
					-- Update status text berdasarkan waktu
					if elapsed < 2 then
						loadingControl.UpdateStatus("Menunggu response dari server...", Color3.fromRGB(200, 140, 60))
					elseif elapsed < 5 then
						loadingControl.UpdateStatus("Server mungkin lambat, menunggu...", Color3.fromRGB(200, 140, 60))
					else
						loadingControl.UpdateStatus("Server tidak merespon, menunggu timeout...", Color3.fromRGB(200, 100, 60))
					end
				end
				
				task.wait(checkInterval)
			end
		end)
		
		-- Lakukan request
		local res = safe_get(CONFIG.HEALTH_CHECK_URL, timeout)
		local elapsedTime = tick() - startTime
		
		-- Stop progress updater
		shouldStop = true
		
		-- Cek apakah timeout
		if not res and elapsedTime >= timeout then
			warn("⏱️ Health check timeout setelah " .. timeout .. " detik")
			if loadingControl then
				loadingControl.UpdateProgress(100, true)
				loadingControl.UpdateStatus("⏱️ Timeout - Server tidak merespon", Color3.fromRGB(180, 60, 60))
			end
			callback(false) -- Server mati atau timeout, akan tampilkan maintenance
			return
		end
		
		if not res then
			warn("❌ Gagal terhubung ke server")
			if loadingControl then
				loadingControl.UpdateProgress(100, true)
				loadingControl.UpdateStatus("❌ Gagal terhubung ke server", Color3.fromRGB(180, 60, 60))
			end
			callback(false) -- Akan tampilkan maintenance
			return
		end
		
		-- Parse response
		local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
		if ok and type(json) == "table" then
			local isOnline = json.status and (json.status == "OK" or json.status == "ok") and json.uptime ~= nil
			if isOnline then
				print("✓ Server online (response dalam " .. string.format("%.2f", elapsedTime) .. " detik)")
				if loadingControl then
					loadingControl.UpdateProgress(50, true)
					loadingControl.UpdateStatus("✓ Server online!", Color3.fromRGB(100, 180, 100))
				end
			else
				warn("⚠️ Server status tidak valid")
				if loadingControl then
					loadingControl.UpdateProgress(100, true)
					loadingControl.UpdateStatus("⚠️ Server status tidak valid", Color3.fromRGB(180, 60, 60))
				end
			end
			callback(isOnline) -- Akan tampilkan login form atau maintenance
		else
			warn("❌ Invalid server response")
			if loadingControl then
				loadingControl.UpdateProgress(100, true)
				loadingControl.UpdateStatus("❌ Invalid server response", Color3.fromRGB(180, 60, 60))
			end
			callback(false) -- Akan tampilkan maintenance
		end
	end)
end

-- =========================
-- VERIFY WITH LOADING SCREEN
-- =========================
local function verify_with_loading(key)
	if not key or key == "" then
		warn("❌ Key tidak valid")
		return
	end
	
	-- Tampilkan loading screen dengan kontrol manual
	local loadingControl = LoginScreen.CreateAutoLogin(nil, {
		manualControl = true,
		initialStatus = "Memverifikasi key...",
		subtitle = "Verifying your key..."
	})
	
	-- Update progress awal
	loadingControl.UpdateProgress(10, true)
	loadingControl.UpdateStatus("Memverifikasi key...", Color3.fromRGB(200, 140, 60))
	
	task.spawn(function()
		-- Verifikasi key
		if not CONFIG.AUTO_VERIFY then
			-- Skip verification, langsung valid
			loadingControl.UpdateProgress(50, true)
			loadingControl.UpdateStatus("Verification disabled, loading...", Color3.fromRGB(100, 180, 100))
			task.wait(0.3)
			
			save_cache(key)
			loadingControl.UpdateProgress(100, true)
			loadingControl.UpdateStatus("✓ Key berhasil diverifikasi", Color3.fromRGB(80, 180, 80))
			task.wait(0.3)
			
			loadingControl.Complete()
			load_main_script()
			return
		end
		
		-- Verify key dengan progress update
		loadingControl.UpdateProgress(30, true)
		loadingControl.UpdateStatus("Menghubungi server...", Color3.fromRGB(200, 140, 60))
		
		local json = check_key(key)
		
		if json and json.ok then
			-- Key valid
			loadingControl.UpdateProgress(70, true)
			loadingControl.UpdateStatus("Key valid, menyimpan...", Color3.fromRGB(100, 180, 100))
			task.wait(0.2)
			
			save_cache(key)
			loadingControl.UpdateProgress(100, true)
			loadingControl.UpdateStatus("✓ " .. (json.msg or "Key berhasil diverifikasi"), Color3.fromRGB(80, 180, 80))
			task.wait(0.3)
			
			loadingControl.Complete()
			print("✓ " .. (json.msg or "Key berhasil diverifikasi"))
			load_main_script()
		elseif json and not json.ok then
			-- Key tidak valid
			loadingControl.UpdateProgress(100, true)
			local errorMsg = json.msg or "Key tidak valid"
			loadingControl.UpdateStatus("❌ " .. errorMsg, Color3.fromRGB(180, 60, 60))
			task.wait(1)
			
			warn("❌ " .. errorMsg)
			loadingControl.Destroy()
			Player:Kick("Key verification failed: " .. errorMsg)
		else
			-- Offline atau error koneksi
			if CONFIG.USE_CACHE_OFFLINE then
				loadingControl.UpdateProgress(70, true)
				loadingControl.UpdateStatus("Offline mode, menyimpan key...", Color3.fromRGB(200, 140, 60))
				task.wait(0.2)
				
				save_cache(key)
				loadingControl.UpdateProgress(100, true)
				loadingControl.UpdateStatus("✓ Key disimpan (offline mode)", Color3.fromRGB(80, 180, 80))
				task.wait(0.3)
				
				loadingControl.Complete()
				print("✓ Key disimpan (offline mode)")
				load_main_script()
			else
				loadingControl.UpdateProgress(100, true)
				loadingControl.UpdateStatus("❌ Gagal terhubung ke server", Color3.fromRGB(180, 60, 60))
				task.wait(1)
				
				warn("❌ Gagal terhubung ke server")
				loadingControl.Destroy()
				Player:Kick("Failed to connect to server. Please check your internet connection.")
			end
		end
	end)
end

local function execute_auto_login()
	-- Check for global key variable first (like execute.lua)
	if _G._iSylhub and type(_G._iSylhub) == "string" then
		local globalKey = _G._iSylhub:gsub("%s+", "")
		if globalKey ~= "" then
			-- Langsung verifikasi dengan loading screen, tidak tampilkan login input
			verify_with_loading(globalKey)
			return false -- Don't show login screen
		end
	end
	
	-- Check cache
	local cachedKey = load_cache()
	if not cachedKey then return true end
	
	-- Skip verification if disabled
	if not CONFIG.AUTO_VERIFY then
		LoginScreen.CreateAutoLogin(function() on_key_valid(cachedKey) end)
		return false
	end
	
	-- Verify key
	local json = check_key(cachedKey)
	if json and json.ok then
		LoginScreen.CreateAutoLogin(function() on_key_valid(cachedKey) end)
		return false
	elseif json and not json.ok then
		delete_cache()
	elseif CONFIG.USE_CACHE_OFFLINE then
		-- Use cache if offline
		LoginScreen.CreateAutoLogin(function() on_key_valid(cachedKey) end)
		return false
	end
	
	return true
end

-- =========================
-- INITIALIZE
-- =========================
task.spawn(function()
	local should_show_login = execute_auto_login()
	
	if should_show_login then
		-- LoginScreen.Create akan menampilkan splash screen (loading) sambil menunggu health check
		-- Health check akan dilakukan dengan timeout, dan loading akan stuck sampai selesai
		LoginScreen.Create({
			onKeyValid = on_key_valid,
			checkKey = check_key_function,
			getKeyUrl = CONFIG.GET_KEY_URL,
			healthCheck = health_check_function,
			onClose = function()
				print("Login screen closed")
			end
		})
	end
end)

