# Changelog

### [11-19-2020] (v0.2.0) General improvements
- [ADDED] New import feature, to "append" `boxes_data`
- [CHANGED] Open dialog now overwrite the current boxes data, instead of appending (use new import instead)
- [FIX] Fix dozen of console errors and warnings
- [FIX] Fix issue where the added box was saved in other animations of the same frame after changing the selected animation
- [FIX] Minor usability improvements

### [08-22-2020] (v0.1.1) Fix incompatibility issues with Godot 3.2.1
- [ADDED] `.json` sufix to saved files;
- [ADDED] an example containing the current necessary node structure;
- [ADDED] [usage](USAGE.md) instructions;
- [FIX] #08 where the tool crashed when adding a new `Animated`;
- [FIX] animation selections from menu;
- [FIX] wront node pathes when changing parameters;
- [FIX] shortcuts which uses `CTRL+KEY`;

### [12-01-2019] (v0.1.0) WIP Stable Version
- [ADDED] Now you can add your own `.TSCN` files to make your collision mapping. See the README Usage's section;
- [FIX] NinePatch can't be resized to 1x rectangle extents (make an offset with wrong displaying position and align);
- [FIX] Collider offset when setting the extents to 0 (it must be impossible to set an 0 extents).

### [11-25-2019] (v0.0.1) Development version
- [FIX] Playing animation by `AnimationPlayer.start()` gives some floating animation steps;
- [FIX] Saving random boxes while playing animation;
- [FIX] If you play animation right after scale a rectangle it's change will be lost;
- [FIX] Collision shapes being duplicated and stored at the wrong time;
- [FIX] A lot of little duplicating/storing little issues;
- [FIX] Some data changed on inspector not being saved.

