// c 2024-05-26
// m 2024-05-26

const string title = "\\$FFF" + Icons::Gamepad + "\\$G Pad FreeCam";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

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

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (!S_Enabled)
        return;

    CGameControlCameraFree@ Cam = GetFreeCamControls();
    if (Cam is null)
        return;

    CInputScriptPad@ Pad = GetPad();
    if (Pad is null)
        return;

    const float halfPi = Math::PI * 0.5f;
    const float twoPi  = Math::PI * 2.0f;

    if (UI::Begin(title + " (cam)", UI::WindowFlags::None)) {
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

    if (UI::Begin(title + " (pad)", UI::WindowFlags::None)) {
        UI::Text("LX: " + Pad.LeftStickX);
        UI::Text("LY: " + Pad.LeftStickY);
        UI::Text("RX: " + Pad.RightStickX);
        UI::Text("RY: " + Pad.RightStickY);
    }

    UI::End();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CDx11Viewport@ Viewport = cast<CDx11Viewport@>(App.Viewport);
    if (Viewport is null)
        return;

    const float fps = Viewport.AverageFps;
    const float deadzone = 0.1f;

    if (Math::Abs(Pad.RightStickX) > deadzone)
        Cam.m_Yaw -= Pad.RightStickX * 0.01f;

    if (Math::Abs(Pad.RightStickY) > deadzone)
        Cam.m_Pitch += Pad.RightStickY * 0.01f;

    const float cos_y = Math::Cos(Cam.m_Yaw);
    const float sin_y = Math::Sin(Cam.m_Yaw);
    const float cos_p = Math::Cos(Cam.m_Pitch);
    const float sin_p = Math::Sin(Cam.m_Pitch);

    if (UI::Begin(title + " (trig)", UI::WindowFlags::None)) {
        UI::Text("cos yaw: " + cos_y);
        UI::Text("sin yaw: " + sin_y);
        UI::Text("cos pitch: " + cos_p);
        UI::Text("sin pitch: " + sin_p);
    }

    UI::End();

    const float speedNormForFps = 20.0f / fps;

    const float move_x = Pad.LeftStickY * speedNormForFps * sin_y * cos_p;
    const float move_y = Pad.LeftStickY * speedNormForFps * -sin_p;
    const float move_z = Pad.LeftStickY * speedNormForFps * cos_y * cos_p;

    if (Math::Abs(Pad.LeftStickX) > deadzone) {
        Cam.m_FreeVal_Loc_Translation.x += Pad.LeftStickX * speedNormForFps * sin_y;
        Cam.m_FreeVal_Loc_Translation.z += Pad.LeftStickX * speedNormForFps * cos_y;
    }

    // if (Math::Abs(Pad.LeftStickY) > deadzone) {
    //     Cam.m_FreeVal_Loc_Translation.x -= move_x;
    //     Cam.m_FreeVal_Loc_Translation.y -= move_y;
    //     Cam.m_FreeVal_Loc_Translation.z -= move_z;
    // }
}
