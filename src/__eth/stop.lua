local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")

for service, _ in pairs(am.app.get_model("SERVICES")) do
	local _ok, _error = _systemctl.safe_stop_service(am.app.get("id").. "-" .. service)
	ami_assert(_ok, "Failed to stop " .. am.app.get("id") .. "-" .. service .. ".service " .. (_error or ""))
end

log_success("Node services succesfully stopped.")