// c 2024-05-28
// m 2024-05-28

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Clamp camera pitch" description="Prevents you from turning the camera upside-down"]
bool S_ClampPitch = true;

[Setting category="General" name="Deadzone" min=0.0f max=1.0f description="Applies to sticks and triggers"]
float S_Deadzone = 0.1f;

[Setting category="General" name="Movement speed multiplier" min=0.0f max=1000.0f]
float S_MoveMultiplier = 300.0f;

[Setting category="General" name="Pan speed multiplier" min=0.0f max=10.0f]
float S_PanMultiplier = 2.0f;

[Setting category="General" name="Swap sticks" description="Makes it so left stick pans and right stick moves"]
bool S_SwapSticks = false;

[Setting category="General" name="Swap triggers" description="Makes it so left trigger (L2) moves up and right trigger (R2) moves down"]
bool S_SwapTriggers = false;

[Setting category="General" name="Invert pan up/down" description="For you flight sim enjoyers"]
bool S_InvertY = false;

[Setting category="General" name="Show debug windows"]
bool S_Debug = false;
