local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")

local _allOk = true
for service, _ in pairs(am.app.get_model("SERVICES")) do
	local _ok, _error = _systemctl.safe_start_service(am.app.get("id") .. "-" .. service)
	if not _ok then
		_allOk = false
		log_warn("Failed to start " .. am.app.get("id") .. "-" .. service .. ".service " .. (_error or ""))
	end
end

if not _allOk then
	log_error("Failed to start some or all of the services!")
else
	log_success("Node services succesfully started.")
end
