extends Control

# Settings Menu controller script
# Handles audio, video, and gameplay settings

@onready var master_volume_slider: HSlider = $VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var sound_effects_slider: HSlider = $VBoxContainer/SoundEffectsContainer/SoundEffectsSlider
@onready var music_volume_slider: HSlider = $VBoxContainer/MusicVolumeContainer/MusicVolumeSlider

@onready var master_volume_label: Label = $VBoxContainer/MasterVolumeContainer/MasterVolumeLabel
@onready var sound_effects_label: Label = $VBoxContainer/SoundEffectsContainer/SoundEffectsLabel
@onready var music_volume_label: Label = $VBoxContainer/MusicVolumeContainer/MusicVolumeLabel

@onready var sound_effects_toggle: CheckBox = $VBoxContainer/SoundEffectsToggle
@onready var music_toggle: CheckBox = $VBoxContainer/MusicToggle
@onready var debug_info_toggle: CheckBox = $VBoxContainer/DebugInfoToggle

@onready var back_button: Button = $VBoxContainer/BackButton
@onready var reset_button: Button = $VBoxContainer/ResetButton

func _ready():
	"""Initialize the settings menu with current values."""
	# Set up sliders
	master_volume_slider.min_value = 0.0
	master_volume_slider.max_value = 1.0
	master_volume_slider.step = 0.05
	
	sound_effects_slider.min_value = 0.0
	sound_effects_slider.max_value = 1.0
	sound_effects_slider.step = 0.05
	
	music_volume_slider.min_value = 0.0
	music_volume_slider.max_value = 1.0
	music_volume_slider.step = 0.05
	
	# Load current settings
	_load_current_settings()
	
	# Connect signals
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	sound_effects_slider.value_changed.connect(_on_sound_effects_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	
	sound_effects_toggle.toggled.connect(_on_sound_effects_toggled)
	music_toggle.toggled.connect(_on_music_toggled)
	debug_info_toggle.toggled.connect(_on_debug_info_toggled)
	
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Focus the back button by default
	back_button.grab_focus()

func _load_current_settings():
	"""Load current settings from GameManager."""
	master_volume_slider.value = GameManager.master_volume
	sound_effects_slider.value = GameManager.sound_effects_volume
	music_volume_slider.value = GameManager.music_volume
	
	sound_effects_toggle.button_pressed = GameManager.sound_effects_enabled
	music_toggle.button_pressed = GameManager.music_enabled
	debug_info_toggle.button_pressed = GameManager.show_debug_info
	
	_update_volume_labels()

func _update_volume_labels():
	"""Update volume percentage labels."""
	master_volume_label.text = "Master Volume: " + str(int(master_volume_slider.value * 100)) + "%"
	sound_effects_label.text = "Sound Effects: " + str(int(sound_effects_slider.value * 100)) + "%"
	music_volume_label.text = "Music Volume: " + str(int(music_volume_slider.value * 100)) + "%"

func _on_master_volume_changed(value: float):
	"""Handle master volume slider change."""
	GameManager.set_master_volume(value)
	_update_volume_labels()

func _on_sound_effects_volume_changed(value: float):
	"""Handle sound effects volume slider change."""
	GameManager.set_sound_effects_volume(value)
	_update_volume_labels()

func _on_music_volume_changed(value: float):
	"""Handle music volume slider change."""
	GameManager.set_music_volume(value)
	_update_volume_labels()

func _on_sound_effects_toggled(button_pressed: bool):
	"""Handle sound effects toggle."""
	GameManager.sound_effects_enabled = button_pressed
	GameManager.save_settings()

func _on_music_toggled(button_pressed: bool):
	"""Handle music toggle."""
	GameManager.music_enabled = button_pressed
	GameManager.save_settings()

func _on_debug_info_toggled(button_pressed: bool):
	"""Handle debug info toggle."""
	GameManager.show_debug_info = button_pressed
	GameManager.save_settings()

func _on_back_pressed():
	"""Handle back button press - return to main menu."""
	GameManager.return_to_main_menu()

func _on_reset_pressed():
	"""Handle reset button press - reset all settings to default."""
	GameManager.master_volume = 1.0
	GameManager.sound_effects_volume = 1.0
	GameManager.music_volume = 1.0
	GameManager.sound_effects_enabled = true
	GameManager.music_enabled = true
	GameManager.show_debug_info = false
	GameManager.save_settings()
	
	# Reload the UI
	_load_current_settings()

func _input(event):
	"""Handle input events."""
	if event.is_action_pressed("ui_cancel"):
		# ESC key returns to main menu
		_on_back_pressed() 
