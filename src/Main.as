// c 2024-05-26
// m 2025-07-21

const float   halfPi      = Math::PI * 0.5f;
const float   twoPi       = Math::PI * 2.0f;
const string  pluginColor = "\\$F5F";
const string  pluginIcon  = Icons::Gamepad;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

void Main() {
    versionSafe = GameVersionSafe();
    if (true
        and S_Enabled
        and versionSafe
    ) {
        ToggleVanillaControls(false);
    }
    S_OverrideCheck = false;

    CGameControlCameraFree@ Cam;
    CInputScriptPad@ Pad;

    auto App = cast<CTrackMania>(GetApp());

    while (true) {
        yield();

        if (false
            or !S_Enabled
            or App.Viewport is null
        ) {
            continue;
        }

        auto Playground = cast<CSmArenaClient>(App.CurrentPlayground);
        if (false
            or Playground is null
            or Playground.GameTerminals.Length == 0
            or Playground.GameTerminals[0] is null
            or Dev::GetOffsetUint16(Playground.GameTerminals[0], 0x30) == 0  // alt cam
        ) {
            @Cam = null;
            @Pad = null;
            continue;
        }

        @Cam = GetFreeCamControls();
        if (Cam is null) {
            @Pad = null;
            continue;
        }

        @Pad = GetPad();
        if (Pad is null) {
            @Cam = null;
            continue;
        }

        if (S_ClampPitch) {
            Cam.m_Pitch = Math::Clamp(Cam.m_Pitch, -halfPi, halfPi);
        }

        const float panSpeed = S_PanMultiplier / App.Viewport.AverageFps;
        const float panUp    = GetControlValue(Pad, S_PanUp);
        const float panDown  = GetControlValue(Pad, S_PanDown);
        const float panLeft  = GetControlValue(Pad, S_PanLeft);
        const float panRight = GetControlValue(Pad, S_PanRight);

        if (panUp > S_Deadzone) {
            Cam.m_Pitch -= panUp * panSpeed;
        }

        if (panDown > S_Deadzone) {
            Cam.m_Pitch += panDown * panSpeed;
        }

        if (panLeft > S_Deadzone) {
            Cam.m_Yaw += panLeft * panSpeed;
        }

        if (panRight > S_Deadzone) {
            Cam.m_Yaw -= panRight * panSpeed;
        }

        const float moveSpeed    = S_MoveMultiplier / App.Viewport.AverageFps;
        const float moveUp       = GetControlValue(Pad, S_MoveUp);
        const float moveDown     = GetControlValue(Pad, S_MoveDown);
        const float moveLeft     = GetControlValue(Pad, S_MoveLeft);
        const float moveRight    = GetControlValue(Pad, S_MoveRight);
        const float moveForward  = GetControlValue(Pad, S_MoveForward);
        const float moveBackward = GetControlValue(Pad, S_MoveBackward);

        if (moveUp > S_Deadzone) {
            Cam.m_FreeVal_Loc_Translation.y += moveUp * moveSpeed;
        }

        if (moveDown > S_Deadzone) {
            Cam.m_FreeVal_Loc_Translation.y -= moveDown * moveSpeed;
        }

        if (moveLeft > S_Deadzone) {
            Cam.m_FreeVal_Loc_Translation.x -= moveLeft * moveSpeed * Math::Sin(Cam.m_Yaw - halfPi);
            Cam.m_FreeVal_Loc_Translation.z -= moveLeft * moveSpeed * Math::Cos(Cam.m_Yaw - halfPi);
        }

        if (moveRight > S_Deadzone) {
            Cam.m_FreeVal_Loc_Translation.x += moveRight * moveSpeed * Math::Sin(Cam.m_Yaw - halfPi);
            Cam.m_FreeVal_Loc_Translation.z += moveRight * moveSpeed * Math::Cos(Cam.m_Yaw - halfPi);
        }

        const float cosPitch = Math::Cos(Cam.m_Pitch);

        if (Math::Abs(moveForward) > S_Deadzone) {
            Cam.m_FreeVal_Loc_Translation.x += moveForward * moveSpeed * Math::Sin(Cam.m_Yaw) * cosPitch;
            Cam.m_FreeVal_Loc_Translation.y += moveForward * moveSpeed * -Math::Sin(Cam.m_Pitch);
            Cam.m_FreeVal_Loc_Translation.z += moveForward * moveSpeed * Math::Cos(Cam.m_Yaw) * cosPitch;

            if (Cam.m_TargetIsEnabled) {
                Cam.m_Radius -= moveForward * moveSpeed;
            }
        }

        if (Math::Abs(moveBackward) > S_Deadzone) {
            Cam.m_FreeVal_Loc_Translation.x -= moveBackward * moveSpeed * Math::Sin(Cam.m_Yaw) * cosPitch;
            Cam.m_FreeVal_Loc_Translation.y -= moveBackward * moveSpeed * -Math::Sin(Cam.m_Pitch);
            Cam.m_FreeVal_Loc_Translation.z -= moveBackward * moveSpeed * Math::Cos(Cam.m_Yaw) * cosPitch;

            if (Cam.m_TargetIsEnabled) {
                Cam.m_Radius += moveBackward * moveSpeed;
            }
        }
    }
}

void OnDestroyed() {
    ToggleVanillaControls(true);
}

void OnDisabled() {
    ToggleVanillaControls(true);
}

void OnEnabled() {
    if (true
        and S_Enabled
        and versionSafe
    ) {
        ToggleVanillaControls(false);
    }
}

void OnSettingsChanged() {
    if (S_OverrideCheck) {
        versionSafe = true;
    }

    ToggleVanillaControls(!S_Enabled);
}

void Render() {
    RenderDebug();
}

void RenderMenu() {
    if (UI::MenuItem(
        pluginTitle + (versionSafe ? "" : "\\$AAA (disabled" + (checkingApi ? ", checking..." : "") + ")"), "",
        S_Enabled,
        versionSafe
    )) {
        S_Enabled = !S_Enabled;
        ToggleVanillaControls(!S_Enabled);
    }
}
