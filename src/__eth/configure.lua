local _user = am.app.get("user")
ami_assert(type(_user) == "string", "User not specified...")
local _ok, _uid = fs.safe_getuid(_user)
if not _ok or not _uid then
    log_info("Creating user - " .. _user .. "...")
    local _ok = os.execute('adduser --disabled-login --disabled-password --gecos "" ' .. _user)
    ami_assert(_ok, "Failed to create user - " .. _user)
    log_info("User " .. _user .. " created.")
else
    log_info("User " .. _user .. " found.")
end

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