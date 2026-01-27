float GetControlValue(CInputScriptPad@ Pad, const ControlAxis axis) {
    if (Pad is null) {
        return 0.0f;
    }

    switch (axis) {
        case ControlAxis::Left_Stick_X_Left:
            return Pad.LeftStickX < 0.0f ? Math::Abs(Pad.LeftStickX) : 0.0f;

        case ControlAxis::Left_Stick_X_Right:
            return Pad.LeftStickX > 0.0f ? Pad.LeftStickX : 0.0f;

        case ControlAxis::Left_Stick_Y_Up:
            return Pad.LeftStickY < 0.0f ? Math::Abs(Pad.LeftStickY) : 0.0f;

        case ControlAxis::Left_Stick_Y_Down:
            return Pad.LeftStickY > 0.0f ? Pad.LeftStickY : 0.0f;

        case ControlAxis::Right_Stick_X_Left:
            return Pad.RightStickX < 0.0f ? Math::Abs(Pad.RightStickX) : 0.0f;

        case ControlAxis::Right_Stick_X_Right:
            return Pad.RightStickX > 0.0f ? Pad.RightStickX : 0.0f;

        case ControlAxis::Right_Stick_Y_Up:
            return Pad.RightStickY < 0.0f ? Math::Abs(Pad.RightStickY) : 0.0f;

        case ControlAxis::Right_Stick_Y_Down:
            return Pad.RightStickY > 0.0f ? Pad.RightStickY : 0.0f;

        case ControlAxis::Left_Trigger:
            return Pad.L2;

        case ControlAxis::Right_Trigger:
            return Pad.R2;

        default:
            return 0.0f;
    }
}

// pre 2023-11-21: 0x68
// 2023-11-21: 0x80
const uint ActiveCamControlOffset = 0x80;

// courtesy of "FreeCam: Show CP" plugin - https://github.com/XertroV/tm-freecam-show-cp
CGameControlCameraFree@ GetFreeCamControls() {
    auto App = cast<CTrackMania>(GetApp());

    if (false
        or App.GameScene is null
        or cast<CSmArenaClient>(App.CurrentPlayground) is null
    ) {
        return null;
    }

    // get the game camera struct
    // orig 0x2b8; GameScene at 0x2a8
    CMwNod@ gameCamCtrl = Dev::GetOffsetNod(App, GetMemberOffset("CGameManiaPlanet", "GameScene") + 0x10);
    if (gameCamCtrl is null) {
        return null;
    }

    if (Dev::GetOffsetUint64(gameCamCtrl, ActiveCamControlOffset) & 0xF != 0) {
        return null;
    }

    return cast<CGameControlCameraFree>(Dev::GetOffsetNod(gameCamCtrl, ActiveCamControlOffset));
}

uint16 GetMemberOffset(const string&in className, const string&in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::GetType(className);

    if (type is null) {
        throw("Unable to find reflection info for " + className);
    }

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    return member.Offset;
}

CInputScriptPad@ GetPad() {
    auto App = cast<CTrackMania>(GetApp());

    if (false
        or App.InputPort is null
        or App.InputPort.Script_Pads.Length == 0
    ) {
        return null;
    }

    for (uint i = 0; i < App.InputPort.Script_Pads.Length; i++) {
        CInputScriptPad@ Pad = App.InputPort.Script_Pads[i];
        if (false
            or Pad is null
            or Pad.Type == CInputScriptPad::EPadType::Keyboard
            or Pad.Type == CInputScriptPad::EPadType::Mouse
        ) {
            continue;
        }

        return Pad;
    }

    return null;
}

void ToggleVanillaControls(const bool b) {
    GetApp().SystemConfig.InputsDisableFreeCamPadControl = !b;
}
