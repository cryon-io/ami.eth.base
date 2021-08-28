local _json = am.options.OUTPUT_FORMAT == "json"

local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin", EXIT_PLUGIN_LOAD_ERROR)

local _appId = am.app.get("id", "unknown")

local _info = {
    level = "ok",
	started = _started,
    status = "Node is not running!",
    currentBlock = "unknown",
    currentBlockHash = "unknown",
    synced = false,
    versions = am.app.get_model("VERSIONS"),
    version = am.app.get_version(),
    type = am.app.get_type()
}

local _allRunning = true
for service, _ in pairs(am.app.get_model("SERVICES")) do
	local _ok, _status, _started = _systemctl.safe_get_service_status(_appId .. "-" .. service)
    if _ok then
        _info[service] = _status
        _allRunning = _allRunning and _status == "running"
    else
        _allRunning = false
        _info[service] = "Failed to get service status " .. _appId .. "-" .. service .. " " .. (_status or "")
    end

end

local _defaultIpcPath = path.combine(am.app.get_model("DATA_DIR", "data"), ".ethereum/geth.ipc")

local function _exec_geth(method)
    local _ipcPath = "ipc://." .. am.app.get_model("IPC_PATH", _defaultIpcPath)
    local _arg = {"--exec", method, "attach", _ipcPath}

    local _proc = proc.spawn("bin/geth", _arg, {stdio = {stdout = "pipe", stderr = "pipe"}, wait = true})

    local _exitcode = _proc.exitcode
    local _stdout = _proc.stdoutStream:read("a") or ""
    local _stderr = _proc.stderrStream:read("a") or ""

    if _exitcode ~= 0 then
        local _errorInfo = _stderr:match("error: (.*)")
        local _ok, _output = hjson.safe_parse(_errorInfo)
        if _ok then
            return false, _output
        end
        return false, {message = "unknown (internal error)"}
    end

    local _ok, _output = hjson.safe_parse(_stdout)
    if _ok then
        return true, _output
    end
    return false, {message = "unknown (internal error)"}
end

local _ok, _ethSyncing = _exec_geth("eth.syncing")
if _ok and type(_ethSyncing) == "table" then
    _info.synced = _ethSyncing.currentBlock == _ethSyncing.highestBlock
    _info.currentBlock = _ethSyncing.currentBlock
    _info.status = _info.synced and "Synchronized" or "Syncing..."
    _info.level = _info.synced and "ok" or "warn"
end
if _ethSyncing == false then
    local _ok, _blockNumber = _exec_geth("eth.blockNumber")
    if _ok then
        _info.status = "Synchronized"
        _info.currentBlock = _blockNumber
        _info.synced = true
        _info.level = "ok"
    end
end
local _ok, _blockHash = _exec_geth("eth.getBlock(" .. _info.currentBlock .. ").hash")
_info.currentBlockHash = _ok and _blockHash or "unknown"

if not _allRunning then
    _info.level = "error"
end

if _json then
    print(hjson.stringify_to_json(_info, {indent = false, sortKeys = true}))
else
    print(hjson.stringify(_info))
end
