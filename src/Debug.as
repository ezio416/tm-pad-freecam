void RenderDebug() {
    if (!S_Debug) {
        return;
    }

    CGameControlCameraFree@ Cam = GetFreeCamControls();

    if (UI::Begin(pluginTitle + "\\$888 (debug)", S_Debug, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoFocusOnAppearing)) {
        auto App = cast<CTrackMania>(GetApp());

        const bool ss = (true
            and cast<CSmArenaClient>(App.CurrentPlayground) !is null
            and App.CurrentPlayground.GameTerminals.Length != 1
        );
        if (ss) {
            UI::Text("\\$C80Plugin is disabled for splitscreen!");
        }

        UI::BeginDisabled(ss);
        App.SystemConfig.InputsDisableFreeCamPadControl = !UI::Checkbox("Vanilla controls enabled", !App.SystemConfig.InputsDisableFreeCamPadControl);
        UI::EndDisabled();
        UI::SameLine();
        UI::Text("\\$888(Does not disable plugin's controls)");

        UI::BeginDisabled(Cam is null);
        if (UI::TreeNode(Icons::Camera + " Camera" + (Cam is null ? "\\$888 (null)" : ""))) {
            UI::Text("\\$F80Changing these values is not recommended. You can break something!");

            UI::Separator();
            Cam.m_Pitch                    = UI::SliderFloat ("m_Pitch",                    Cam.m_Pitch,                    -halfPi,   halfPi,   "%.6f");
            Cam.m_Yaw                      = UI::SliderFloat ("m_Yaw",                      Cam.m_Yaw,                      -Math::PI, Math::PI, "%.6f");
            UI::Separator();
            Cam.m_DisableMouseZ            = UI::Checkbox    ("m_DisableMouseZ",            Cam.m_DisableMouseZ);                                          // false
            Cam.m_Fov                      = UI::SliderFloat ("m_Fov",                      Cam.m_Fov,                      10.0f,     100.0f,   "%.6f");  // 75.0
            UI::Separator();
            Cam.m_UseForcedRoll            = UI::Checkbox    ("m_UseForcedRoll",            Cam.m_UseForcedRoll);                                          // false
            Cam.m_ForcedRoll               = UI::SliderFloat ("m_ForcedRoll",               Cam.m_ForcedRoll,               0.0f,      twoPi,    "%.6f");  // 0.0
            Cam.m_Roll                     = UI::SliderFloat ("m_Roll",                     Cam.m_Roll,                     -Math::PI, Math::PI, "%.6f");  // 0.0
            UI::Separator();
            Cam.m_FarZ                     = UI::SliderFloat ("m_FarZ",                     Cam.m_FarZ,                     0.0f,      50000.0f, "%.6f");  // 50000.0
            Cam.m_NearZ                    = UI::SliderFloat ("m_NearZ",                    Cam.m_NearZ,                    0.05f,     1000.0f,  "%.6f");  // 0.05
            UI::Separator();
            Cam.m_Acceleration             = UI::SliderFloat ("m_Acceleration",             Cam.m_Acceleration,             0.0f,      100.0f,  "%.6f");   // 50.0
            Cam.m_MoveInertia              = UI::SliderFloat ("m_MoveInertia",              Cam.m_MoveInertia,              0.0f,      1.0f,     "%.6f");  // 0.5
            Cam.m_MoveSpeed                = UI::SliderFloat ("m_MoveSpeed",                Cam.m_MoveSpeed,                0.0f,      100.0f,   "%.6f");  // 0.0
            Cam.m_MoveSpeedCoef            = UI::SliderInt   ("m_MoveSpeedCoef",            Cam.m_MoveSpeedCoef,            0,         10);                // 5
            Cam.m_StartMoveSpeed           = UI::SliderFloat ("m_StartMoveSpeed",           Cam.m_StartMoveSpeed,           0.0f,      100.0f,   "%.6f");  // 1.0
            UI::Separator();
            Cam.m_RotateInertia            = UI::SliderFloat ("m_RotateInertia",            Cam.m_RotateInertia,            0.0f,      1.0f,     "%.6f");  // 0.0
            Cam.m_RotateSpeed              = UI::SliderFloat ("m_RotateSpeed",              Cam.m_RotateSpeed,              0.0f,      twoPi,    "%.6f");  // pi/2
            UI::Separator();
            Cam.m_TargetIsEnabled          = UI::Checkbox    ("m_TargetIsEnabled",          Cam.m_TargetIsEnabled);                                        // false
            Cam.m_TargetPos                = UI::SliderFloat3("m_TargetPos",                Cam.m_TargetPos,                0.1f,      2000.0f,  "%.6f");  // 0.0, 0.0, 0.0
            Cam.m_Radius                   = UI::SliderFloat ("m_Radius",                   Cam.m_Radius,                   0.0f,      10.0f,    "%.6f");  // 0.0
            UI::Separator();
            Cam.m_FreeVal_Loc_Translation  = UI::SliderFloat3("m_FreeVal_Loc_Translation",  Cam.m_FreeVal_Loc_Translation,  0.1f,      2000.0f,  "%.6f");
            Cam.Pos                        = UI::SliderFloat3("Pos",                        Cam.Pos,                        0.1f,      2000.0f,  "%.6f");  // 0.0, 0.0, 0.0
            UI::Separator();
            Cam.m_FreeVal_Lens_DofFocusZ   = UI::SliderFloat ("m_FreeVal_Lens_DofFocusZ",   Cam.m_FreeVal_Lens_DofFocusZ,   -100.0f,   100.0f,   "%.6f");  // 30.0
            Cam.m_FreeVal_Lens_DofLensSize = UI::SliderFloat ("m_FreeVal_Lens_DofLensSize", Cam.m_FreeVal_Lens_DofLensSize, -100.0f,   100.0f,   "%.6f");  // 0.0
            Cam.m_RelativeFollowedPos      = UI::SliderFloat3("m_RelativeFollowedPos",      Cam.m_RelativeFollowedPos,      -10.0f,    10.0f,    "%.6f");

            UI::Separator();

            UI::BeginDisabled();
            UI::SliderFloat("cos(yaw)",   Math::Cos(Cam.m_Yaw),   -1.0f, 1.0f, "%.6f");
            UI::SliderFloat("sin(yaw)",   Math::Sin(Cam.m_Yaw),   -1.0f, 1.0f, "%.6f");
            UI::SliderFloat("cos(pitch)", Math::Cos(Cam.m_Pitch), -1.0f, 1.0f, "%.6f");
            UI::SliderFloat("sin(pitch)", Math::Sin(Cam.m_Pitch), -1.0f, 1.0f, "%.6f");
            UI::EndDisabled();

            UI::TreePop();
        }
        UI::EndDisabled();

        UI::BeginDisabled(Pad is null);
        if (UI::TreeNode(Icons::Gamepad + " Gamepad" + (Pad is null ? "\\$888 (null)" : ""))) {
            UI::BeginDisabled();
            UI::SliderFloat("Left stick X",  Pad.LeftStickX,  -1.0f, 1.0f, "%.6f");
            UI::SliderFloat("Left stick Y",  Pad.LeftStickY,  -1.0f, 1.0f, "%.6f");
            UI::Separator();
            UI::SliderFloat("Right stick X", Pad.RightStickX, -1.0f, 1.0f, "%.6f");
            UI::SliderFloat("Right stick Y", Pad.RightStickY, -1.0f, 1.0f, "%.6f");
            UI::Separator();
            UI::SliderFloat("Left trigger",  Pad.L2,          0.0f, 1.0f, "%.6f");
            UI::SliderFloat("Right trigger", Pad.R2,          0.0f, 1.0f, "%.6f");
            UI::EndDisabled();

            UI::TreePop();
        }
        UI::EndDisabled();
    }
    UI::End();
}
