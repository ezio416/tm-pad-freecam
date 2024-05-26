// c 2024-01-22
// m 2024-02-25

// everything here courtesy of "FreeCam: Show CP" plugin - https://github.com/XertroV/tm-freecam-show-cp

// pre 2023-11-21: 0x68
// 2023-11-21: 0x80
const uint ActiveCamControlOffset = 0x80;

uint16 GetMemberOffset(const string &in className, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::GetType(className);

    if (type is null)
        throw("Unable to find reflection info for " + className);

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    return member.Offset;
}

CGameControlCameraFree@ GetFreeCamControls() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App is null || App.GameScene is null || App.CurrentPlayground is null)
        return null;

    // get the game camera struct
    // orig 0x2b8; GameScene at 0x2a8
    CMwNod@ gameCamCtrl = Dev::GetOffsetNod(App, GetMemberOffset("CGameManiaPlanet", "GameScene") + 0x10);
    if (gameCamCtrl is null)
        return null;

    if (Dev::GetOffsetUint64(gameCamCtrl, ActiveCamControlOffset) & 0xF != 0)
        return null;

    return cast<CGameControlCameraFree@>(Dev::GetOffsetNod(gameCamCtrl, ActiveCamControlOffset));
}
