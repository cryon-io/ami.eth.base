if type(am.app.get_config()) ~= "table" then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION)
end

am.app.set_model(
    {
        SERVICE_CONFIGURATION = util.merge_tables(
            {
                TimeoutStopSec = 300,
            },
            type(am.app.get_config("SERVICE_CONFIGURATION")) == "table" and am.app.get_config("SERVICE_CONFIGURATION") or {},
            true
        ),
        DAEMON_NAME = "geth",
        SERVICE_NAME = "eth-geth",
        DATA_DIR = path.combine(os.cwd(), "data")
    },
    { merge = true, overwrite = true }
)
