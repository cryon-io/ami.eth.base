if type(am.app.get_configuration()) ~= "table" then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION)
end

am.app.set_model(
    {
        SERVICE_CONFIGURATION = util.merge_tables(
            {
                TimeoutStopSec = 300,
            },
            type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and am.app.get_configuration("SERVICE_CONFIGURATION") or {},
            true
        ),
        DAEMON_NAME = "geth",
        DATA_DIR = path.combine(os.cwd(), "data"),
		STARTUP_ARGS = am.app.get_configuration("STARTUP_ARGS", {}),
        SERVICES = {
            ["eth-geth"] = "__eth/assets/daemon.service"
        }
    },
    { merge = true, overwrite = true }
)