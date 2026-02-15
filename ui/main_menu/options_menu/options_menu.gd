# res://ui/main_menu/options_menu/options_menu.gd
extends Control

signal closed

@onready var master_slider: HSlider = $PanelContainer/VBoxContainer/MasterContainer/MasterSlider
@onready var music_slider: HSlider = $PanelContainer/VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $PanelContainer/VBoxContainer/SfxContainer/SfxSlider
@onready var back_button: Button = $PanelContainer/VBoxContainer/BackButton

const CFG_PATH := "user://settings.cfg"
const CFG_SECTION := "audio"

func _ready() -> void:
	# Load saved settings (or current bus values) and apply immediately.
	_load_audio_settings_to_sliders()

	# Controller focus: start on the first slider.
	# (Make sure Focus Mode = All on sliders/buttons in the Inspector.)
	master_slider.grab_focus()

	# Wire slider changes to audio buses.
	master_slider.value_changed.connect(func(v: float) -> void:
		_set_bus_linear("Master", v)
	)
	music_slider.value_changed.connect(func(v: float) -> void:
		_set_bus_linear("Music", v)
	)
	sfx_slider.value_changed.connect(func(v: float) -> void:
		_set_bus_linear("SFX", v)
	)

	# Back button: save + close.
	back_button.pressed.connect(func() -> void:
		_save_audio_settings_from_sliders()
		emit_signal("closed")
		queue_free()
	)

func _unhandled_input(event: InputEvent) -> void:
	# Allow controller "back" to close the menu.
	if event.is_action_pressed("ui_cancel"):
		_save_audio_settings_from_sliders()
		emit_signal("closed")
		queue_free()
		get_viewport().set_input_as_handled()

func _set_bus_linear(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	linear = clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))

func _get_bus_linear(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return 1.0
	var db := AudioServer.get_bus_volume_db(idx)
	return db_to_linear(db)

func _load_audio_settings_to_sliders() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CFG_PATH)

	# If no file yet, pull current bus values.
	if err != OK:
		master_slider.value = _get_bus_linear("Master")
		music_slider.value = _get_bus_linear("Music")
		sfx_slider.value = _get_bus_linear("SFX")
		return

	master_slider.value = float(cfg.get_value(CFG_SECTION, "master", _get_bus_linear("Master")))
	music_slider.value = float(cfg.get_value(CFG_SECTION, "music", _get_bus_linear("Music")))
	sfx_slider.value = float(cfg.get_value(CFG_SECTION, "sfx", _get_bus_linear("SFX")))

	# Apply immediately
	_set_bus_linear("Master", master_slider.value)
	_set_bus_linear("Music", music_slider.value)
	_set_bus_linear("SFX", sfx_slider.value)

func _save_audio_settings_from_sliders() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(CFG_SECTION, "master", master_slider.value)
	cfg.set_value(CFG_SECTION, "music", music_slider.value)
	cfg.set_value(CFG_SECTION, "sfx", sfx_slider.value)
	cfg.save(CFG_PATH)
