local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")

local _allOk = true

for service, _ in pairs(am.app.get_model("SERVICES")) do
	local _ok, _error = _systemctl.safe_remove_service(am.app.get("id") .. "-" .. service)
	if not _ok then
        log_warn("Failed to start " .. am.app.get("id") .. "-" .. service .. ".service " .. (_error or ""))
        _allOk = false
    end 
end

if _allOk then
    log_success("Node services succesfully removed.")
end