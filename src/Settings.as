// c 2024-05-28
// m 2025-07-21

[Setting category="General" name="Enabled" description="When disabled, the vanilla controls will be active"]
bool S_Enabled = true;

[Setting category="General" name="Clamp camera pitch" description="Prevents you from turning the camera upside-down"]
bool S_ClampPitch = true;

[Setting category="General" name="Deadzone" min=0.0f max=1.0f description="Applies to sticks and triggers"]
float S_Deadzone = 0.1f;

[Setting category="General" name="Movement speed multiplier" min=0.0f max=1000.0f]
float S_MoveMultiplier = 300.0f;

[Setting category="General" name="Pan speed multiplier" min=0.0f max=10.0f]
float S_PanMultiplier = 2.0f;

[Setting category="General" name="Show debug window"]
bool S_Debug = false;

[Setting category="General" name="Override game version check (unsafe)"
description="If you don't want to wait for the plugin author to test the current game version, try this setting. \\$FA0It may crash your game."]
bool S_OverrideCheck = false;


enum ControlAxis {
    Left_Stick_X_Neg,
    Left_Stick_X_Pos,
    Left_Stick_Y_Neg,
    Left_Stick_Y_Pos,
    Right_Stick_X_Neg,
    Right_Stick_X_Pos,
    Right_Stick_Y_Neg,
    Right_Stick_Y_Pos,
    Left_Trigger,
    Right_Trigger,
    None,
    _Count
}

[Setting category="Binds" hidden]
ControlAxis S_MoveUp = ControlAxis::Right_Trigger;

[Setting category="Binds" hidden]
ControlAxis S_MoveDown = ControlAxis::Left_Trigger;

[Setting category="Binds" hidden]
ControlAxis S_MoveLeft = ControlAxis::Left_Stick_X_Neg;

[Setting category="Binds" hidden]
ControlAxis S_MoveRight = ControlAxis::Left_Stick_X_Pos;

[Setting category="Binds" hidden]
ControlAxis S_MoveForward = ControlAxis::Left_Stick_Y_Neg;

[Setting category="Binds" hidden]
ControlAxis S_MoveBackward = ControlAxis::Left_Stick_Y_Pos;

[Setting category="Binds" hidden]
ControlAxis S_PanUp = ControlAxis::Right_Stick_Y_Neg;

[Setting category="Binds" hidden]
ControlAxis S_PanDown = ControlAxis::Right_Stick_Y_Pos;

[Setting category="Binds" hidden]
ControlAxis S_PanLeft = ControlAxis::Right_Stick_X_Neg;

[Setting category="Binds" hidden]
ControlAxis S_PanRight = ControlAxis::Right_Stick_X_Pos;

[SettingsTab icon="Gamepad" name="Binds"]
void SettingsTab_Controls() {
    if (UI::Button("Reset to default (plugin)")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Binds") {
                settings[i].Reset();
            }
        }
    }

    UI::SameLine();
    if (UI::Button("Reset to default (vanilla)")) {
        S_MoveUp       = ControlAxis::Left_Stick_Y_Neg;
        S_MoveDown     = ControlAxis::Left_Stick_Y_Pos;
        S_MoveLeft     = ControlAxis::Left_Stick_X_Neg;
        S_MoveRight    = ControlAxis::Left_Stick_X_Pos;
        S_MoveForward  = ControlAxis::Right_Trigger;
        S_MoveBackward = ControlAxis::Left_Trigger;
        S_PanUp        = ControlAxis::Right_Stick_Y_Neg;
        S_PanDown      = ControlAxis::Right_Stick_Y_Pos;
        S_PanLeft      = ControlAxis::Right_Stick_X_Neg;
        S_PanRight     = ControlAxis::Right_Stick_X_Pos;
    }

    UI::SeparatorText("Movement");
    S_MoveUp       = ShowCombo(S_MoveUp,       Icons::ArrowCircleUp    + " Up##move");
    S_MoveDown     = ShowCombo(S_MoveDown,     Icons::ArrowCircleDown  + " Down##move");
    S_MoveLeft     = ShowCombo(S_MoveLeft,     Icons::ArrowCircleLeft  + " Left##move");
    S_MoveRight    = ShowCombo(S_MoveRight,    Icons::ArrowCircleRight + " Right##move");
    S_MoveForward  = ShowCombo(S_MoveForward,  Icons::ArrowCircleOUp   + " Forward##move");
    S_MoveBackward = ShowCombo(S_MoveBackward, Icons::ArrowCircleODown + " Backward##move");

    UI::SeparatorText("Panning");
    S_PanUp    = ShowCombo(S_PanUp,    Icons::ArrowCircleUp    + " Up##pan");
    S_PanDown  = ShowCombo(S_PanDown,  Icons::ArrowCircleDown  + " Down##pan");
    S_PanLeft  = ShowCombo(S_PanLeft,  Icons::ArrowCircleLeft  + " Left##pan");
    S_PanRight = ShowCombo(S_PanRight, Icons::ArrowCircleRight + " Right##pan");
}

void ClearControlsWithAxis(const ControlAxis axis) {
    if (S_MoveUp == axis) {
        S_MoveUp = ControlAxis::None;
    }

    if (S_MoveDown == axis) {
        S_MoveDown = ControlAxis::None;
    }

    if (S_MoveLeft == axis) {
        S_MoveLeft = ControlAxis::None;
    }

    if (S_MoveRight == axis) {
        S_MoveRight = ControlAxis::None;
    }

    if (S_MoveForward == axis) {
        S_MoveForward = ControlAxis::None;
    }

    if (S_MoveBackward == axis) {
        S_MoveBackward = ControlAxis::None;
    }

    if (S_PanUp == axis) {
        S_PanUp = ControlAxis::None;
    }

    if (S_PanDown == axis) {
        S_PanDown = ControlAxis::None;
    }

    if (S_PanLeft == axis) {
        S_PanLeft = ControlAxis::None;
    }

    if (S_PanRight == axis) {
        S_PanRight = ControlAxis::None;
    }
}

ControlAxis ShowCombo(ControlAxis setting, const string&in label) {
    if (UI::BeginCombo(label, (setting == ControlAxis::None ? "\\$F00" : "") + tostring(setting))) {
        for (int i = 0; i < ControlAxis::_Count; i++) {
            ControlAxis axis = ControlAxis(i);
            if (UI::Selectable(tostring(axis), setting == axis)) {
                ClearControlsWithAxis(axis);
                setting = axis;
            }
        }

        UI::EndCombo();
    }

    return setting;
}
