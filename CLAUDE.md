# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "Balloon Warfare" - a Godot 4.4 mobile game where players pop balloons that float up from the bottom of the screen. The game features a complete menu system, high score tracking, audio settings, and progressive difficulty.

## Development Commands

Since this is a Godot project, development is primarily done through the Godot editor. However, for automation and testing:

- **Open in Godot**: Launch the Godot editor and open the project.godot file
- **Run Game**: F5 in Godot editor or use the play button
- **Export Build**: Use Godot's export presets for target platforms
- **Scene Testing**: F6 to run current scene in Godot editor

## IMPORTANT: Missing Scene Files

**The game will not run until the menu scene files are created.** Currently only `balloon.tscn` and `game.tscn` exist, but the menu system requires these additional scene files:

- `main_menu.tscn` (required - set as main scene in project.godot)
- `settings_menu.tscn`
- `game_over.tscn`
- `pause_menu.tscn`
- `high_scores.tscn`
- `instructions.tscn`

**To create these scenes:** Follow the step-by-step instructions in `MENU_SETUP_GUIDE.md`. All the scripts (.gd files) are ready and will work once the scene structures are created in the Godot editor.

## Architecture Overview

### Core System Architecture

The game uses a **Singleton Pattern** with `GameManager` as the central coordinator:

- **GameManager** (`game_manager.gd`): Autoloaded singleton managing scene transitions, game state, high scores, settings persistence, and audio
- **Scene-Based Menu System**: Complete menu flow with proper scene management
- **Signal-Driven Communication**: GameManager emits signals for game state changes

### Key Components

1. **Game Manager Singleton** (`game_manager.gd:29`)
   - Scene transitions and game state management
   - High score system with persistent storage
   - Audio settings with real-time volume control
   - Pause system with ESC key handling

2. **Main Game Loop** (`game.gd`)
   - Balloon spawning with progressive difficulty
   - Wind physics system affecting balloon movement
   - Health/score tracking with GameManager integration
   - Real-time debug information display

3. **Balloon System** (`balloon.gd`)
   - Physics-based balloon movement with wind effects
   - Color randomization using sprite resource preloads
   - Click-to-pop interaction with audio feedback
   - Pooled balloon management

4. **Complete Menu System**
   - Main menu with game navigation
   - Settings menu with audio controls and preferences
   - Pause menu with in-game options
   - Game over screen with high score detection
   - High scores display with persistent storage
   - Instructions screen with game help

### Data Persistence

- **High Scores**: Saved to `user://high_scores.save` using Godot's FileAccess
- **Settings**: Saved to `user://settings.save` including audio preferences and debug options
- **Auto-Save**: All changes saved immediately to prevent data loss

## Key Technical Details

### Scene Structure
- Main scene: `main_menu.tscn` (configured in project.godot:14)
- GameManager is autoloaded (project.godot:29)
- All menu scenes follow consistent naming patterns matching their script files

### Audio System
- Centralized audio management through GameManager
- Volume scaling with master/SFX/music separation
- Sound effect playing via `GameManager.play_sound_effect()` (game_manager.gd:170)

### Physics & Game Mechanics
- Balloon movement uses RigidBody2D with custom physics
- Wind system affects all balloons simultaneously
- Difficulty scaling based on time elapsed with curve-based progression
- Health system with game over at 0 health

### Performance Considerations
- Balloon pooling and proper cleanup to prevent memory leaks
- Efficient scene transitions using direct scene changes
- Debug information toggle for performance monitoring

## Common Development Patterns

### Adding New Menu Screens
1. Create new scene file (.tscn)
2. Create corresponding script file (.gd)
3. Use GameManager.change_scene() for transitions
4. Follow existing menu script patterns for consistency

### Audio Integration
```gdscript
# Play sound effects through GameManager
GameManager.play_sound_effect(audio_player, volume_scale)
```

### Scene Transitions
```gdscript
# Use GameManager for all scene changes
GameManager.change_scene("res://scene_name.tscn")
GameManager.start_new_game()
GameManager.return_to_main_menu()
```

### Settings Management
```gdscript
# Settings are automatically saved when changed
GameManager.set_master_volume(volume)
GameManager.toggle_sound_effects()
```

## Mobile Platform Considerations

- Project configured for mobile rendering (project.godot:38)
- Touch-friendly button sizes in menu layouts
- Viewport scaling for different screen sizes
- Input handling for both mouse and touch events

## Important File Locations

- **Project Configuration**: `project.godot`
- **Main Game Logic**: `game.gd`
- **Core System**: `game_manager.gd`
- **Menu Setup Guide**: `MENU_SETUP_GUIDE.md`
- **System Overview**: `MENU_SYSTEM_OVERVIEW.md`
- **Asset Resources**: `assets/` and `sprites/` directories

## Development Notes

- All menu scenes need to be created manually in Godot editor following the setup guide
- Node names in scenes must match @onready variable names in scripts
- Pause-related nodes require "When Paused" process mode
- AdMob integration is available but not currently implemented (addons/admob/)

## Testing Approach

Test the game through the Godot editor:
1. Run main scene to test full game flow
2. Test individual scenes using F6 in Godot editor
3. Verify menu transitions and state persistence
4. Test on target mobile platforms using Godot's remote debugging