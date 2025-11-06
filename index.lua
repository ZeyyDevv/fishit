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
	USE_CACHE_OFFLINE = true
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
local function safe_get(url)
	local ok, res = pcall(function()
		if syn and syn.request then
			return syn.request({Url = url, Method = "GET"}).Body
		elseif request then
			return request({Url = url, Method = "GET"}).Body
		elseif http and http.request then
			return http.request({Url = url, Method = "GET"}).Body
		elseif game.HttpGet then
			return game:HttpGet(url)
		end
	end)
	return ok and res or nil
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

local function health_check_function(callback)
	task.spawn(function()
		local res = safe_get(CONFIG.HEALTH_CHECK_URL)
		if not res then
			callback(false)
			return
		end
		
		local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
		if ok and type(json) == "table" then
			local isOnline = json.status and (json.status == "OK" or json.status == "ok") and json.uptime ~= nil
			callback(isOnline)
		else
			callback(false)
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
	
	-- Tampilkan loading screen
	LoginScreen.CreateAutoLogin(function()
		-- Verifikasi key
		if not CONFIG.AUTO_VERIFY then
			-- Skip verification, langsung valid
			save_cache(key)
			print("✓ Key berhasil diverifikasi (verification disabled)")
			load_main_script()
			return
		end
		
		-- Verify key
		local json = check_key(key)
		
		if json and json.ok then
			-- Key valid
			save_cache(key)
			print("✓ " .. (json.msg or "Key berhasil diverifikasi"))
			load_main_script()
		elseif json and not json.ok then
			-- Key tidak valid
			local errorMsg = json.msg or "Key tidak valid"
			warn("❌ " .. errorMsg)
			Player:Kick("Key verification failed: " .. errorMsg)
		else
			-- Offline atau error koneksi
			if CONFIG.USE_CACHE_OFFLINE then
				save_cache(key)
				print("✓ Key disimpan (offline mode)")
				load_main_script()
			else
				warn("❌ Gagal terhubung ke server")
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

