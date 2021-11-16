local _user = am.app.get("user")
ami_assert(type(_user) == "string", "User not specified...")

local _ok, _userPlugin = am.plugin.safe_get("user")
ami_assert(_ok, "Failed to load user plugin - " .. tostring(_userPlugin), EXIT_PLUGIN_LOAD_ERROR)

log_info("Checking user '" .. _user .. "' availability...")
local _ok = _userPlugin.add(_user)
ami_assert(_ok, "Failed to create user - " .. _user)

local DATA_PATH = am.app.get_model("DATA_DIR")
local _ok, _error = fs.safe_mkdirp(DATA_PATH)

local _ok, _uid = fs.safe_getuid(_user)
ami_assert(_ok, "Failed to get " .. _user .. "uid - " .. (_uid or ""))

local _ok, _error = fs.safe_chown(DATA_PATH, _uid, _uid, { recurse = true })
if not _ok then 
    ami_error("Failed to chown " .. DATA_PATH .. " - " .. (_error or ""))
end

log_info("Configuring " .. am.app.get("id") .. " services...")

local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin - " .. tostring(_systemctl))

for service, file in pairs(am.app.get_model("SERVICES")) do
    local _ok, _error = _systemctl.safe_install_service(file, am.app.get("id") .. "-" .. service)
    ami_assert(_ok, "Failed to install " .. am.app.get("id") .. "-" .. service .. ".service " .. (_error or ""))
end

log_success(am.app.get("id") .. " services configured")