// c 2024-05-26
// m 2024-05-28

const float  halfPi = Math::PI * 0.5f;
const string title  = "\\$F5F" + Icons::Gamepad + "\\$G Pad FreeCam";
const float  twoPi  = Math::PI * 2.0f;

void Main() {
    versionSafe = GameVersionSafe();
    S_OverrideCheck = false;
}

void OnSettingsChanged() {
    if (S_OverrideCheck)
        versionSafe = true;
}

void Render() {
    if (!S_Enabled)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CDx11Viewport@ Viewport = cast<CDx11Viewport@>(App.Viewport);
    if (Viewport is null)
        return;

    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (
        Playground is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
        || Dev::GetOffsetUint16(Playground.GameTerminals[0], 0x30) == 0  // alt cam
    )
        return;

    CGameControlCameraFree@ Cam = GetFreeCamControls();
    if (Cam is null)
        return;

    CInputScriptPad@ Pad = GetPad();
    if (Pad is null)
        return;

    if (S_ClampPitch) {
        Cam.m_ClampPitch = true;
        Cam.m_ClampPitchMin = -halfPi;
        Cam.m_ClampPitchMax = halfPi;
    } else
        Cam.m_ClampPitch = false;

    if (S_Debug) {
        Window_DebugCam(Cam);
        Window_DebugTrig(Cam);
        Window_DebugPad(Pad);
    }

    const float panSpeed = S_PanMultiplier / Viewport.AverageFps;
    const float panX     = S_SwapSticks ? Pad.LeftStickX : Pad.RightStickX;
    const float panY     = S_SwapSticks ? Pad.LeftStickY : Pad.RightStickY;

    if (Math::Abs(panX) > S_Deadzone)
        Cam.m_Yaw -= panX * panSpeed;

    if (Math::Abs(panY) > S_Deadzone)
        Cam.m_Pitch += (S_InvertY ? -1.0f : 1.0f) * panY * panSpeed;

    const float moveSpeed = S_MoveMultiplier / Viewport.AverageFps;
    const float moveX     = S_SwapSticks ? Pad.RightStickX : Pad.LeftStickX;
    const float moveY     = S_SwapSticks ? Pad.RightStickY : Pad.LeftStickY;

    if (Math::Abs(moveX) > S_Deadzone) {
        Cam.m_FreeVal_Loc_Translation.x += moveX * moveSpeed * Math::Sin(Cam.m_Yaw - halfPi);
        Cam.m_FreeVal_Loc_Translation.z += moveX * moveSpeed * Math::Cos(Cam.m_Yaw - halfPi);
    }

    const float cosPitch = Math::Cos(Cam.m_Pitch);

    if (Math::Abs(moveY) > S_Deadzone) {
        Cam.m_FreeVal_Loc_Translation.x -= moveY * moveSpeed * Math::Sin(Cam.m_Yaw) * cosPitch;
        Cam.m_FreeVal_Loc_Translation.y -= moveY * moveSpeed * -Math::Sin(Cam.m_Pitch);
        Cam.m_FreeVal_Loc_Translation.z -= moveY * moveSpeed * Math::Cos(Cam.m_Yaw) * cosPitch;
    }

    const float moveUp   = S_SwapTriggers ? Pad.L2 : Pad.R2;
    const float moveDown = S_SwapTriggers ? Pad.R2 : Pad.L2;

    if (Math::Abs(moveUp) > S_Deadzone)
        Cam.m_FreeVal_Loc_Translation.y += moveUp * moveSpeed;

    if (Math::Abs(moveDown) > S_Deadzone)
        Cam.m_FreeVal_Loc_Translation.y -= moveDown * moveSpeed;
}

void RenderMenu() {
    if (UI::MenuItem(title + (versionSafe ? "" : "\\$AAA (disabled" + (checkingApi ? ", checking..." : "") + ")"), "", S_Enabled, versionSafe))
        S_Enabled = !S_Enabled;
}

CInputScriptPad@ GetPad() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CInputPortDx8@ Port = cast<CInputPortDx8@>(App.InputPort);
    if (Port is null || Port.Script_Pads.Length == 0)
        return null;

    for (uint i = 0; i < Port.Script_Pads.Length; i++) {
        CInputScriptPad@ Pad = Port.Script_Pads[i];
        if (
            Pad is null
            || Pad.Type == CInputScriptPad::EPadType::Keyboard
            || Pad.Type == CInputScriptPad::EPadType::Mouse
        )
            continue;

        return Pad;
    }

    return null;
}

void Window_DebugCam(CGameControlCameraFree@ Cam) {
    if (UI::Begin(title + " (cam)", UI::WindowFlags::AlwaysAutoResize)) {
        UI::Text("I recommend you do not change these values. You can break the camera!");

        UI::Separator();

        Cam.m_Fov                      = UI::SliderFloat ("m_Fov",                      Cam.m_Fov,                       10.0f,     100.0f,   "%.6f");  // 75.0
        Cam.m_FreeVal_Loc_Translation  = UI::SliderFloat3("m_FreeVal_Loc_Translation",  Cam.m_FreeVal_Loc_Translation,   0.1f,      2000.0f,  "%.6f");
        Cam.m_Pitch                    = UI::SliderFloat ("m_Pitch",                    Cam.m_Pitch,                     -halfPi,   halfPi,   "%.6f");
        Cam.m_Yaw                      = UI::SliderFloat ("m_Yaw",                      Cam.m_Yaw,                       -Math::PI, Math::PI, "%.6f");
        Cam.m_Roll                     = UI::SliderFloat ("m_Roll",                     Cam.m_Roll,                      -Math::PI, Math::PI, "%.6f");  // 0.0
        Cam.m_Radius                   = UI::SliderFloat ("m_Radius",                   Cam.m_Radius,                    0.0f,      10.0f,    "%.6f");  // 0.0
        Cam.m_RelativeFollowedPos      = UI::SliderFloat3("m_RelativeFollowedPos",      Cam.m_RelativeFollowedPos,       -10.0f,    10.0f,    "%.6f");
        Cam.m_TargetPos                = UI::SliderFloat3("m_TargetPos",                Cam.m_TargetPos,                 0.1f,      2000.0f,  "%.6f");  // 0.0, 0.0, 0.0
        Cam.m_TargetIsEnabled          = UI::Checkbox    ("m_TargetIsEnabled",          Cam.m_TargetIsEnabled);                                         // false
        Cam.m_NearZ                    = UI::SliderFloat ("m_NearZ",                    Cam.m_NearZ,                     0.05f,     1000.0f,  "%.6f");  // 0.05
        Cam.m_FarZ                     = UI::SliderFloat ("m_FarZ",                     Cam.m_FarZ,                      0.0f,      50000.0f, "%.6f");  // 50000.0
        Cam.m_FreeVal_Lens_DofFocusZ   = UI::SliderFloat ("m_FreeVal_Lens_DofFocusZ",   Cam.m_FreeVal_Lens_DofFocusZ,    -100.0f,   100.0f,   "%.6f");  // 30.0
        Cam.m_FreeVal_Lens_DofLensSize = UI::SliderFloat ("m_FreeVal_Lens_DofLensSize", Cam.m_FreeVal_Lens_DofLensSize,  -100.0f,   100.0f,   "%.6f");  // 0.0
        Cam.m_ClampPitch               = UI::Checkbox    ("m_ClampPitch",               Cam.m_ClampPitch);                                              // false
        Cam.m_ClampPitchMin            = UI::SliderFloat ("m_ClampPitchMin",            Cam.m_ClampPitchMin,             -halfPi,   0.0f,    "%.6f");   // 0.0
        Cam.m_ClampPitchMax            = UI::SliderFloat ("m_ClampPitchMax",            Cam.m_ClampPitchMax,             0.0f,      halfPi,  "%.6f");   // 0.0
        Cam.m_Acceleration             = UI::SliderFloat ("m_Acceleration",             Cam.m_Acceleration,              0.0f,      100.0f,  "%.6f");   // 50.0
        Cam.m_StartMoveSpeed           = UI::SliderFloat ("m_StartMoveSpeed",           Cam.m_StartMoveSpeed,            0.0f,      100.0f,  "%.6f");   // 1.0
        Cam.m_MoveSpeedCoef            = UI::SliderInt   ("m_MoveSpeedCoef",            Cam.m_MoveSpeedCoef,             0,         10);                // 5
        Cam.m_MoveSpeed                = UI::SliderFloat ("m_MoveSpeed",                Cam.m_MoveSpeed,                 0.0f,      100.0f,  "%.6f");   // 0.0
        Cam.m_MoveInertia              = UI::SliderFloat ("m_MoveInertia",              Cam.m_MoveInertia,               0.0f,      1.0f,    "%.6f");   // 0.5
        Cam.m_RotateSpeed              = UI::SliderFloat ("m_RotateSpeed",              Cam.m_RotateSpeed,               0.0f,      twoPi,   "%.6f");   // pi/2
        Cam.m_RotateInertia            = UI::SliderFloat ("m_RotateInertia",            Cam.m_RotateInertia,             0.0f,      1.0f,    "%.6f");   // 0.0
        Cam.m_UseForcedRoll            = UI::Checkbox    ("m_UseForcedRoll",            Cam.m_UseForcedRoll);                                           // false
        Cam.m_ForcedRoll               = UI::SliderFloat ("m_ForcedRoll",               Cam.m_ForcedRoll,                0.0f,      twoPi,   "%.6f");   // 0.0
        Cam.m_DisableMouseZ            = UI::Checkbox    ("m_DisableMouseZ",            Cam.m_DisableMouseZ);                                           // false
        Cam.m_DebugUseOculus           = UI::Checkbox    ("m_DebugUseOculus",           Cam.m_DebugUseOculus);                                          // false
        Cam.Pos                        = UI::SliderFloat3("Pos",                        Cam.Pos,                         0.1f,      2000.0f, "%.6f");   // 0.0, 0.0, 0.0
        // UI::Text(Cam.IdName);
    }

    UI::End();
}

void Window_DebugPad(CInputScriptPad@ Pad) {
    if (UI::Begin(title + " (pad)", UI::WindowFlags::None)) {
        UI::Text("LX: " + Pad.LeftStickX);
        UI::Text("LY: " + Pad.LeftStickY);
        UI::Separator();
        UI::Text("RX: " + Pad.RightStickX);
        UI::Text("RY: " + Pad.RightStickY);
        UI::Separator();
        UI::Text("L2: " + Pad.L2);
        UI::Text("R2: " + Pad.R2);
    }

    UI::End();
}

void Window_DebugTrig(CGameControlCameraFree@ Cam) {
    if (UI::Begin(title + " (trig)", UI::WindowFlags::None)) {
        UI::Text("cos yaw: "   + Math::Cos(Cam.m_Yaw));
        UI::Text("sin yaw: "   + Math::Sin(Cam.m_Yaw));
        UI::Text("cos pitch: " + Math::Cos(Cam.m_Pitch));
        UI::Text("sin pitch: " + Math::Sin(Cam.m_Pitch));
    }

    UI::End();
}
