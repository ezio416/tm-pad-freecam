// c 2024-01-22
// m 2024-05-28

// everything here courtesy of "Auto-hide Opponents" plugin - https://github.com/XertroV/tm-autohide-opponents

bool   checkingApi        = false;
string version;
bool   versionSafe        = false;
uint   versionSafeRetries = 0;

bool GameVersionSafe() {
    string[] knownGood = {
        "2023-11-15_11_56",  // released 2023-11-21
        "2024-01-10_12_53",  // released 2024-01-10
        "2024-04-30_16_52"   // released 2024-05-22
    };

    version = GetApp().SystemPlatform.ExeVersion;

    if (knownGood.Find(version) > -1)
        return true;

    return GetStatusFromOpenplanet();
}

bool GetStatusFromOpenplanet() {
    checkingApi = true;

    trace("GetStatusFromOpenplanet starting");

    // request config for other plugin that does exactly the same thing, just me being lazy :P
    Net::HttpRequest@ req = Net::HttpGet("https://openplanet.dev/plugin/freecamspeedlimiter/config/version-compat");
    while (!req.Finished())
        yield();

    const int code = req.ResponseCode();
    if (code != 200) {
        warn("GetStatusFromOpenplanet error: code: " + code + "; error: " + req.Error() + "; body: " + req.String());
        checkingApi = false;
        return RetryGetStatus();
    }

    try {
        const string pluginVersion = Meta::ExecutingPlugin().Version;
        const Json::Value@ response = Json::Parse(req.String());

        if (response.GetType() == Json::Type::Object) {
            if (response.HasKey(pluginVersion)) {
                if (response[pluginVersion].HasKey(version) && bool(response[pluginVersion][version])) {
                    checkingApi = false;
                    trace("GetStatusFromOpenplanet good");
                    return true;
                }  else
                    warn("GetStatusFromOpenplanet warning: game version " + version + " not marked good with plugin version " + pluginVersion);
            } else
                warn("GetStatusFromOpenplanet warning: plugin version " + pluginVersion + " not specified");
        } else
            warn("GetStatusFromOpenplanet error: wrong JSON type received");

        checkingApi = false;
        return false;
    } catch {
        warn("GetStatusFromOpenplanet exception: " + getExceptionInfo());
        checkingApi = false;
        return RetryGetStatus();
    }
}

bool RetryGetStatus() {
    checkingApi = true;

    trace("retrying GetStatusFromOpenplanet in 1000 ms");

    sleep(1000);

    if (versionSafeRetries++ > 5) {
        warn("not retrying GetStatusFromOpenplanet anymore, too many failures");
        checkingApi = false;
        return false;
    }

    trace("retrying GetStatusFromOpenplanet...");

    checkingApi = false;
    return GetStatusFromOpenplanet();
}
