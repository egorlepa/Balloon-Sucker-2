# Menu System Setup Guide

This guide explains how to create the menu scenes in the Godot editor. All scripts are already created and ready to use.

## 1. Main Menu Scene (main_menu.tscn)

Create a new scene with the following structure:

```
Main Menu (Control) - Attach main_menu.gd
├── TitleLabel (Label)
├── VersionLabel (Label)
└── VBoxContainer (VBoxContainer)
    ├── PlayButton (Button) - Text: "Play"
    ├── SettingsButton (Button) - Text: "Settings"
    ├── HighScoresButton (Button) - Text: "High Scores"
    ├── InstructionsButton (Button) - Text: "Instructions"
    └── QuitButton (Button) - Text: "Quit"
```

**Layout Settings:**
- Main Control: Anchor preset "Full Rect"
- TitleLabel: Center horizontally, position near top
- VersionLabel: Bottom right corner
- VBoxContainer: Center screen, proper spacing between buttons

## 2. Settings Menu Scene (settings_menu.tscn)

Create a new scene with the following structure:

```
Settings Menu (Control) - Attach settings_menu.gd
└── VBoxContainer (VBoxContainer)
    ├── MasterVolumeContainer (HBoxContainer)
    │   ├── MasterVolumeLabel (Label) - Text: "Master Volume:"
    │   └── MasterVolumeSlider (HSlider)
    ├── SoundEffectsContainer (HBoxContainer)
    │   ├── SoundEffectsLabel (Label) - Text: "Sound Effects:"
    │   └── SoundEffectsSlider (HSlider)
    ├── MusicVolumeContainer (HBoxContainer)
    │   ├── MusicVolumeLabel (Label) - Text: "Music Volume:"
    │   └── MusicVolumeSlider (HSlider)
    ├── SoundEffectsToggle (CheckBox) - Text: "Sound Effects Enabled"
    ├── MusicToggle (CheckBox) - Text: "Music Enabled"
    ├── DebugInfoToggle (CheckBox) - Text: "Show Debug Info"
    ├── ResetButton (Button) - Text: "Reset to Defaults"
    └── BackButton (Button) - Text: "Back"
```

## 3. Game Over Screen (game_over.tscn)

Create a new scene with the following structure:

```
Game Over (Control) - Attach game_over.gd
└── VBoxContainer (VBoxContainer)
    ├── GameOverLabel (Label) - Text: "Game Over!"
    ├── FinalScoreLabel (Label)
    ├── HighScoreLabel (Label)
    ├── NewHighScoreLabel (Label)
    ├── RestartButton (Button) - Text: "Play Again"
    └── MainMenuButton (Button) - Text: "Main Menu"
```

## 4. Pause Menu Scene (pause_menu.tscn)

Create a new scene with the following structure:

```
Pause Menu (Control) - Attach pause_menu.gd
└── VBoxContainer (VBoxContainer)
    ├── PauseLabel (Label) - Text: "Paused"
    ├── ResumeButton (Button) - Text: "Resume"
    ├── RestartButton (Button) - Text: "Restart"
    └── MainMenuButton (Button) - Text: "Main Menu"
```

## 5. High Scores Screen (high_scores.tscn)

Create a new scene with the following structure:

```
High Scores (Control) - Attach high_scores.gd
└── VBoxContainer (VBoxContainer)
    ├── TitleLabel (Label) - Text: "High Scores"
    ├── ScoresContainer (VBoxContainer)
    ├── ClearScoresButton (Button) - Text: "Clear Scores"
    └── BackButton (Button) - Text: "Back"
```

## 6. Instructions Screen (instructions.tscn)

Create a new scene with the following structure:

```
Instructions (Control) - Attach instructions.gd
└── VBoxContainer (VBoxContainer)
    ├── TitleLabel (Label) - Text: "Instructions"
    ├── InstructionsText (RichTextLabel)
    └── BackButton (Button) - Text: "Back"
```

## 7. Update Game Scene (game.tscn)

Add these nodes to your existing game scene:

```
Game (Node2D) - Update game.gd
├── ... (existing nodes)
├── PauseMenu (Control) - Instance of pause_menu.tscn
└── PauseButton (Button) - Text: "Pause" (position in top-right corner)
```

## Styling Tips

1. **Color Scheme:** Use dark backgrounds with bright accent colors
2. **Fonts:** Consider using larger, bold fonts for titles
3. **Button Styling:** Add hover effects and consistent sizing
4. **Layout:** Center elements and use proper margins
5. **Mobile Friendly:** Ensure buttons are large enough for touch

## Process Control Settings

Make sure to set the correct Process Mode for pause-related nodes:

- **PauseMenu:** Set Process Mode to "When Paused"
- **PauseButton:** Set Process Mode to "When Paused"

This ensures the pause menu works correctly when the game is paused.

## Next Steps

1. Create each scene file (.tscn) in the Godot editor
2. Set up the node structure as described
3. Attach the corresponding script files
4. Test the menu system
5. Adjust styling and layout as needed

All the scripts are already created and will work once the scene structures are set up correctly! 
