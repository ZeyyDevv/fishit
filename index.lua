-- iSylHub Authentication System with Secure Script Loader

local CONFIG = {
	KEY_CHECK_URL = "http://server.isylhub.workers.dev/api/keys/check",
	SCRIPT_LOAD_URL = "http://server.isylhub.workers.dev/script/load",
	HEARTBEAT_URL = "http://server.isylhub.workers.dev/script/heartbeat",
	GET_KEY_URL = "https://discord.gg/9B3sxTxD2E",
	LOGIN_SCREEN_URL = "https://raw.githubusercontent.com/ZeyyDevv/fishit/refs/heads/main/lib/iSylHubUI.lua",
	HEALTH_CHECK_URL = "http://server.isylhub.workers.dev/health",
	WEBHOOK_URL = "https://discord.com/api/webhooks/1436204787203833957/zCaiIYDbPfB4bOQtTqbafj82UWdPfpRImzWM3EpU7Tn90RUkTHRnioinFLkpe0OTuBtL",
	CACHE_PATH = "iSyl_key_cache.txt",
	AUTO_VERIFY = true,
	USE_CACHE_OFFLINE = true,
	USE_SECURE_LOADER = true,
	TIMEOUT = 10
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")
local MarketplaceService = game:GetService("MarketplaceService")
local Player = Players.LocalPlayer

-- HTTP Helper (unified)
local function httpRequest(options)
	local timeout = options.timeout or CONFIG.TIMEOUT
	local result, completed = nil, false
	
	task.spawn(function()
		local ok, res = pcall(function()
			local jsonData = options.body and HttpService:JSONEncode(options.body) or nil
			local requestOptions = {
				Url = options.url,
				Method = options.method or "GET",
				Headers = options.headers or {["Content-Type"] = "application/json"},
				Body = jsonData,
				Timeout = timeout
			}
			
			if syn and syn.request then
				return syn.request(requestOptions).Body
			elseif request then
				return request(requestOptions).Body
			elseif http and http.request then
				return http.request(requestOptions).Body
			elseif options.method == "GET" and game.HttpGet then
				return game:HttpGet(options.url)
			end
		end)
		if ok and res then result = res end
		completed = true
	end)
	
	local start = tick()
	while not completed and (tick() - start) < timeout do
		task.wait(0.1)
	end
	
	return result
end

-- Simplified HTTP functions
local function httpGet(url, timeout)
	return httpRequest({url = url, method = "GET", timeout = timeout})
end

local function httpPostSync(url, data, timeout)
	return httpRequest({url = url, method = "POST", body = data, timeout = timeout})
end

local function httpPost(url, data)
	task.spawn(function()
		pcall(function()
			httpRequest({url = url, method = "POST", body = data, timeout = 5})
		end)
	end)
end

-- Cache Functions
local function saveCache(key)
	if writefile then pcall(function() writefile(CONFIG.CACHE_PATH, key) end) end
end

local function loadCache()
	if readfile and isfile and isfile(CONFIG.CACHE_PATH) then
		local ok, res = pcall(function() return readfile(CONFIG.CACHE_PATH) end)
		if ok and res and res ~= "" then return res:gsub("%s+", "") end
	end
	return nil
end

local function deleteCache()
	if isfile and delfile then pcall(function() delfile(CONFIG.CACHE_PATH) end) end
end

-- Key Verification
local function verifyKey(key)
	local hwid = Analytics:GetClientId()
	local url = CONFIG.KEY_CHECK_URL .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid) .. "&version=2.0.0"
	local res = httpGet(url)
	if not res then return nil end
	
	local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
	return (ok and type(json) == "table") and json or nil
end

-- Secure Script Loader (Plain Text Response or GitHub Raw URL)
local function loadSecureScript(key, hwid)
	if not CONFIG.USE_SECURE_LOADER then
		return nil, "Secure loader disabled"
	end
	
	local response = httpPostSync(CONFIG.SCRIPT_LOAD_URL, {key = key, hwid = hwid}, CONFIG.TIMEOUT)
	if not response then
		return nil, "Failed to connect to server"
	end
	
	-- Response is plain text, could be script content or GitHub raw URL
	if type(response) ~= "string" or response == "" then
		return nil, "Empty response from server"
	end
	
	-- Check if response is a URL (GitHub raw URL)
	if response:match("^https?://") then
		-- It's a URL, load script from URL
		local scriptContent = httpGet(response, CONFIG.TIMEOUT)
		if scriptContent and scriptContent ~= "" then
			return scriptContent, nil
		else
			return nil, "Failed to load script from GitHub raw URL"
		end
	end
	
	-- Response is script content directly
	return response, nil
end

-- Inject Heartbeat Code (same as heartbeatInjector.js)
local function injectHeartbeat(script, key, hwid)
	if not script or script == "" then return script end
	if not key or not hwid then return script end
	
	local escapeString = function(str)
		return (str or ""):gsub("\\", "\\\\"):gsub('"', '\\"')
	end
	
	local apiUrl = escapeString(CONFIG.HEARTBEAT_URL:gsub("/script/heartbeat", ""))
	local escapedKey = escapeString(key)
	local escapedHwid = escapeString(hwid)
	
	local heartbeatCode = string.format([[
local _key = "%s"
local _hwid = "%s"
local _heartbeatFailureCount = 0
local _maxFailures = 3
local _httpService = game:GetService("HttpService")

local function _getLocalPlayer()
	local players = game:GetService("Players")
	return players and players.LocalPlayer or nil
end

local function _showNotification(message)
	local text = "[iSylHub] " .. message
	if rconsole and rconsoleprint then
		pcall(function()
			rconsoleprint("@@YELLOW@@")
			rconsoleprint(text .. "\n")
			rconsoleprint("@@WHITE@@")
		end)
	end
	pcall(function()
		local starterGui = game:GetService("StarterGui")
		if starterGui and starterGui.SetCore then
			starterGui:SetCore("SendNotification", {
				Title = "iSylHub",
				Text = message,
				Duration = 5
			})
		end
	end)
	print(text)
	warn(text)
end

local function _kickPlayer(reason)
	local player = _getLocalPlayer()
	if player then
		player:Kick(reason or "Session invalid. Please restart the script.")
	end
end

local function _handleHeartbeatFailure()
	_heartbeatFailureCount = _heartbeatFailureCount + 1
	if _heartbeatFailureCount < _maxFailures then
		_showNotification("Koneksi server gagal (" .. _heartbeatFailureCount .. "/" .. _maxFailures .. ")")
	elseif _heartbeatFailureCount == _maxFailures then
		_showNotification("Koneksi server gagal (" .. _heartbeatFailureCount .. "/" .. _maxFailures .. ")")
		_kickPlayer("iSylHub server sedang maintenance")
	else
		_kickPlayer("iSylHub server sedang maintenance")
	end
end

local function _resetHeartbeatFailureCount()
	if _heartbeatFailureCount > 0 then
		_heartbeatFailureCount = 0
	end
end

local function _heartbeatCheck()
	local player = _getLocalPlayer()
	if not player then return end
	
	local requestBody = _httpService:JSONEncode({key = _key, hwid = _hwid})
	local requestConfig = {
		Url = "%s/script/heartbeat",
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = requestBody
	}
	
	local ok, response = pcall(function()
		if _httpService.RequestAsync then
			return _httpService:RequestAsync(requestConfig)
		elseif _httpService.PostAsync then
			return _httpService:PostAsync(requestConfig.Url, requestBody, Enum.HttpContentType.ApplicationJson)
		elseif syn and syn.request then
			local res = syn.request(requestConfig)
			return {Success = res.Success, Body = res.Body, StatusMessage = res.StatusMessage}
		elseif request then
			local res = request(requestConfig)
			return {Success = res.Success, Body = res.Body, StatusMessage = res.StatusMessage}
		else
			error("No HTTP method available")
		end
	end)
	
	if not ok then
		_handleHeartbeatFailure()
		return
	end
	
	if not response or response.Success == false then
		_handleHeartbeatFailure()
		return
	end
	
	local responseBody = response.Body or response
	if type(responseBody) ~= "string" then
		_handleHeartbeatFailure()
		return
	end
	
	local ok2, result = pcall(function()
		return _httpService:JSONDecode(responseBody)
	end)
	
	if not ok2 or not result then
		_handleHeartbeatFailure()
		return
	end
	
	if not result.valid then
		_kickPlayer(result.msg or "Your session is invalid or expired. Please restart the script.")
		return
	end
	
	_resetHeartbeatFailureCount()
end

do
	local spawnFunc = task.spawn or spawn or coroutine.wrap
	if spawnFunc then
		spawnFunc(function()
			local waitFunc = task.wait or wait
			while true do
				waitFunc(30)
				_heartbeatCheck()
			end
		end)
		
		spawnFunc(function()
			local waitFunc = task.wait or wait
			waitFunc(5)
			_heartbeatCheck()
		end)
	end
end
]], escapedKey, escapedHwid, apiUrl)
	
	return heartbeatCode .. "\n" .. script
end

-- Load and Execute Script
local function executeScript(script)
	if not script or script == "" then return false end
	
	local fn, err = loadstring(script)
	if not fn then
		warn("Failed to load script:", err)
		return false
	end
	
	local ok = pcall(fn)
	if not ok then
		warn("Error running script:", err)
		return false
	end
	
	return true
end

-- Load Main Script
local function loadMainScript(scriptUrl, secureScript, key, hwid)
	task.wait(0.2)
	
	-- Get key and hwid for heartbeat injection
	local currentKey = key
	local currentHwid = hwid or Analytics:GetClientId()
	
	if secureScript then
		-- Inject heartbeat before executing
		local scriptWithHeartbeat = injectHeartbeat(secureScript, currentKey, currentHwid)
		if executeScript(scriptWithHeartbeat) then return end
	end
	
	if scriptUrl then
		local body = httpGet(scriptUrl)
		if body then 
			-- Inject heartbeat before executing
			local scriptWithHeartbeat = injectHeartbeat(body, currentKey, currentHwid)
			executeScript(scriptWithHeartbeat)
			return
		end
	end
	
	-- Offline/Maintenance mode - no script available
	local player = Players.LocalPlayer
	if player then
		player:Kick("iSylHub server sedang maintenance. Silakan coba lagi nanti atau hubungi support di Discord.")
	end
end

-- Login Screen Loader
local function loadLoginScreen()
	if script and script.Parent then
		local module = script.Parent:FindFirstChild("loginscreen")
		if module then
			local ok, result = pcall(function() return require(module) end)
			if ok and result then return result end
		end
	end
	
	local body = httpGet(CONFIG.LOGIN_SCREEN_URL)
	if not body then return nil end
	
	local fn, err = loadstring(body)
	if not fn then return nil end
	
	local ok, result = pcall(fn)
	return (ok and result) and result or nil
end

local LoginScreen = loadLoginScreen()
if not LoginScreen then return end

-- Login Logs
local function sendLoginLog(key, scriptUrl, loginMethod, secureScript)
	if not CONFIG.WEBHOOK_URL or CONFIG.WEBHOOK_URL == "" then return end
	
	local hwid = Analytics:GetClientId()
	local username = Player.Name
	local userId = tostring(Player.UserId)
	local placeId = tostring(game.PlaceId)
	local gameName = "Unknown"
	
	local ok, productInfo = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if ok and productInfo then
		gameName = productInfo.Name or "Unknown"
	end
	
	local time = os.date("%Y-%m-%d %H:%M:%S")
	local keyMasked = #key > 12 and (string.sub(key, 1, 8) .. "..." .. string.sub(key, -4)) or key
	local scriptUrlDisplay = scriptUrl or (secureScript and "Script from KEY_CHECK_URL") or "Offline/Maintenance"
	
	local content = string.format(
		"**🔐 Login Success**\n\n" ..
		"**User:** %s (`%s`)\n" ..
		"**HWID:** `%s`\n" ..
		"**Key:** `%s`\n" ..
		"**Script Source:** `%s`\n" ..
		"**Game:** %s (`%s`)\n" ..
		"**Login Method:** %s\n" ..
		"**Time:** `%s`",
		username, userId, hwid, keyMasked, scriptUrlDisplay, gameName, placeId, loginMethod, time
	)
	
	local webhookUrl = CONFIG.WEBHOOK_URL
	if not webhookUrl:find("?") then
		webhookUrl = webhookUrl .. "?with_components=true"
	else
		webhookUrl = webhookUrl .. "&with_components=true"
	end
	
	httpPost(webhookUrl, {
		flags = 32768,
		components = {{
			type = 17,
			accent_color = nil,
			spoiler = false,
			components = {{
				type = 10,
				content = content
			}, {
				type = 14,
				divider = true,
				spacing = 1
			}, {
				type = 10,
				content = "-# iSylHub Login System"
			}}
		}}
	})
end

-- Main Logic
local function onKeyValid(key, scriptUrl, loginMethod, secureScript)
	local hwid = Analytics:GetClientId()
	saveCache(key)
	sendLoginLog(key, scriptUrl, loginMethod or "Unknown", secureScript)
	loadMainScript(scriptUrl, secureScript, key, hwid)
end

-- Check Key Function
local function checkKeyFunction(key, callback)
	local hwid = Analytics:GetClientId()
	
	-- First verify key
	local json = verifyKey(key)
	if not json then
		callback(false, "Failed to connect to server or invalid response")
		return
	end
	
	if not json.ok then
		callback(false, json.msg or "Invalid key")
		return
	end
	
	-- If key is valid, load script from SCRIPT_LOAD_URL
	if CONFIG.USE_SECURE_LOADER then
		local secureScript, errorMsg = loadSecureScript(key, hwid)
		if secureScript then
			_G._secureScript = secureScript
			_G._scriptUrl = nil
			callback(true, "Key valid - Script loaded")
			return
		elseif errorMsg and errorMsg ~= "Secure loader disabled" then
			warn("Secure loader failed:", errorMsg)
		end
	end
	
	-- Fallback to script_url if available
	if json.script_url then
		_G._scriptUrl = json.script_url
		_G._secureScript = nil
		callback(true, "Key valid")
	else
		_G._scriptUrl = nil
		_G._secureScript = nil
		callback(true, "Key valid")
	end
end

-- Health Check
local function healthCheck(callback, ctrl)
	task.spawn(function()
		local start = tick()
		local timeout = CONFIG.TIMEOUT
		local lastProgress, stopped = 10, false
		
		task.spawn(function()
			while not stopped and (tick() - start) < timeout do
				local elapsed = tick() - start
				local progress = math.min(10 + (elapsed / timeout) * 40, 50)
				
				if ctrl and progress > lastProgress and not stopped then
					ctrl.UpdateProgress(progress, true)
					lastProgress = progress
					
					if elapsed < 2 then
						ctrl.UpdateStatus("Menunggu response dari server...", Color3.fromRGB(200, 140, 60))
					elseif elapsed < 5 then
						ctrl.UpdateStatus("Server mungkin lambat, menunggu...", Color3.fromRGB(200, 140, 60))
					else
						ctrl.UpdateStatus("Server tidak merespon, menunggu timeout...", Color3.fromRGB(200, 100, 60))
					end
				end
				task.wait(0.1)
			end
		end)
		
		local res = httpGet(CONFIG.HEALTH_CHECK_URL, timeout)
		local elapsed = tick() - start
		stopped = true
		
		if not res then
			if ctrl then
				ctrl.UpdateProgress(100, true)
				ctrl.UpdateStatus(elapsed >= timeout and "⏱️ Timeout - Server tidak merespon" or "❌ Gagal terhubung ke server", Color3.fromRGB(180, 60, 60))
			end
			callback(false)
			return
		end
		
		local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
		local isOnline = ok and type(json) == "table" and json.status and (json.status == "OK" or json.status == "ok") and json.uptime ~= nil
		
		if ctrl then
			if isOnline then
				ctrl.UpdateProgress(50, true)
				ctrl.UpdateStatus("✓ Server online!", Color3.fromRGB(100, 180, 100))
			else
				ctrl.UpdateProgress(100, true)
				ctrl.UpdateStatus("⚠️ Server status tidak valid", Color3.fromRGB(180, 60, 60))
			end
		end
		
		callback(isOnline)
	end)
end

-- Verify With Loading
local function verifyWithLoading(key)
	if not key or key == "" then return end
	
	local ctrl = LoginScreen.CreateAutoLogin(nil, {
		manualControl = true,
		initialStatus = "Memverifikasi key...",
		subtitle = "Verifying your key..."
	})
	
	ctrl.UpdateProgress(10, true)
	ctrl.UpdateStatus("Memverifikasi key...", Color3.fromRGB(200, 140, 60))
	
	task.spawn(function()
		if not CONFIG.AUTO_VERIFY then
			ctrl.UpdateProgress(50, true)
			ctrl.UpdateStatus("Verification disabled, loading...", Color3.fromRGB(100, 180, 100))
			task.wait(0.3)
			saveCache(key)
			ctrl.UpdateProgress(100, true)
			ctrl.UpdateStatus("✓ Key berhasil diverifikasi", Color3.fromRGB(80, 180, 80))
			task.wait(0.3)
			ctrl.Complete()
			onKeyValid(key, nil, "Global Key (AUTO_VERIFY disabled)", nil)
			return
		end
		
		ctrl.UpdateProgress(30, true)
		ctrl.UpdateStatus("Menghubungi server...", Color3.fromRGB(200, 140, 60))
		
		local json = verifyKey(key)
		
		if json and json.ok then
			local secureScript = nil
			local scriptUrl = nil
			
			-- Load script from SCRIPT_LOAD_URL
			if CONFIG.USE_SECURE_LOADER then
				ctrl.UpdateProgress(50, true)
				ctrl.UpdateStatus("Loading script...", Color3.fromRGB(200, 140, 60))
				
				local hwid = Analytics:GetClientId()
				secureScript, errorMsg = loadSecureScript(key, hwid)
				if secureScript then
					ctrl.UpdateProgress(70, true)
					ctrl.UpdateStatus("Script loaded, menyimpan...", Color3.fromRGB(100, 180, 100))
				elseif errorMsg and errorMsg ~= "Secure loader disabled" then
					warn("Secure loader failed:", errorMsg)
					if json.script_url then
						scriptUrl = json.script_url
					end
				elseif json.script_url then
					scriptUrl = json.script_url
				end
			elseif json.script_url then
				scriptUrl = json.script_url
			end
			
			task.wait(0.2)
			saveCache(key)
			ctrl.UpdateProgress(100, true)
			ctrl.UpdateStatus("✓ " .. (json.msg or "Key berhasil diverifikasi"), Color3.fromRGB(80, 180, 80))
			task.wait(0.3)
			ctrl.Complete()
			onKeyValid(key, scriptUrl, "Global Key (_iSylhub)", secureScript)
		elseif json and not json.ok then
			local msg = json.msg or "Key tidak valid"
			ctrl.UpdateProgress(100, true)
			ctrl.UpdateStatus("❌ " .. msg, Color3.fromRGB(180, 60, 60))
			task.wait(1)
			ctrl.Destroy()
			Player:Kick("Key verification failed: " .. msg)
		else
			if CONFIG.USE_CACHE_OFFLINE then
				ctrl.UpdateProgress(70, true)
				ctrl.UpdateStatus("Offline mode, menyimpan key...", Color3.fromRGB(200, 140, 60))
				task.wait(0.2)
				saveCache(key)
				ctrl.UpdateProgress(100, true)
				ctrl.UpdateStatus("✓ Key disimpan (offline mode)", Color3.fromRGB(80, 180, 80))
				task.wait(0.3)
				ctrl.Complete()
				onKeyValid(key, nil, "Global Key (Offline Mode)", nil)
			else
				ctrl.UpdateProgress(100, true)
				ctrl.UpdateStatus("❌ Gagal terhubung ke server", Color3.fromRGB(180, 60, 60))
				task.wait(1)
				ctrl.Destroy()
				Player:Kick("Failed to connect to server. Please check your internet connection.")
			end
		end
	end)
end

-- Execute Auto Login
local function executeAutoLogin()
	if _G._iSylhub and type(_G._iSylhub) == "string" then
		local key = _G._iSylhub:gsub("%s+", "")
		if key ~= "" then
			verifyWithLoading(key)
			return false
		end
	end
	
	local cachedKey = loadCache()
	if not cachedKey then return true end
	
	if not CONFIG.AUTO_VERIFY then
		LoginScreen.CreateAutoLogin(function() onKeyValid(cachedKey, nil, "Cache (AUTO_VERIFY disabled)", nil) end)
		return false
	end
	
	local json = verifyKey(cachedKey)
	if json and json.ok then
		local secureScript = nil
		local scriptUrl = nil
		
		-- Load script from SCRIPT_LOAD_URL
		if CONFIG.USE_SECURE_LOADER then
			local hwid = Analytics:GetClientId()
			secureScript, errorMsg = loadSecureScript(cachedKey, hwid)
			if not secureScript and json.script_url then
				scriptUrl = json.script_url
			end
		elseif json.script_url then
			scriptUrl = json.script_url
		end
		
		LoginScreen.CreateAutoLogin(function() onKeyValid(cachedKey, scriptUrl, "Cache (Auto-Login)", secureScript) end)
		return false
	elseif json and not json.ok then
		deleteCache()
	elseif CONFIG.USE_CACHE_OFFLINE then
		LoginScreen.CreateAutoLogin(function() onKeyValid(cachedKey, nil, "Cache (Offline Mode)", nil) end)
		return false
	end
	
	return true
end

-- Initialize
task.spawn(function()
	local shouldShow = executeAutoLogin()
	
	if shouldShow then
		LoginScreen.Create({
			onKeyValid = function(key)
				local scriptUrl = _G._scriptUrl
				local secureScript = _G._secureScript
				_G._scriptUrl = nil
				_G._secureScript = nil
				onKeyValid(key, scriptUrl, "Manual Login", secureScript)
			end,
			checkKey = checkKeyFunction,
			getKeyUrl = CONFIG.GET_KEY_URL,
			healthCheck = healthCheck,
			onClose = function() end
		})
	end
end)
