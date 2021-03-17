local _user = am.app.get("user")
ami_assert(type(_user) == "string", "User not specified...")

fs.remove(am.app.get_model("CHAINDATA_DIR", "data/.ethereum/geth/chaindata/"), { recurse = true })
log_success("Succesfully removed database.")