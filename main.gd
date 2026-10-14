extends Node


const BUTTON_TWEEN_DURATION: float = 0.2
const CONFIG_PATH: String = "user://config.cfg"
const LEADERBOARD_ENTRY_SCENE: PackedScene = preload("uid://btjwpkidd8h44")

## Array[Array[String, String]].
## Essentially an array of tuples of entries
var leaderboard: Array[Array] = [
	["Dana", "534"],
	["Nyes", "1256"],
	["Apollo", "123"],
]

var _menu_transition_tween: Tween

@onready var gameplay_node: Gameplay = %Gameplay
@onready var main_menu: Control = %MainMenu
@onready var leaderboard_menu: Control = %Leaderboard
@onready var leaderboard_entry_container: VBoxContainer = %LeaderboardEntryContainer
@onready var music_player: AudioStreamPlayer = %Music


func _ready() -> void:
	leaderboard_menu.offset_transform_position_ratio.y = 1

	_rotate_main_menu_tween()
	# _save_config()
	_load_config()
	leaderboard.sort_custom(_sort_leaderboard)
	_update_leaderboard_entries()


func _rotate_main_menu_tween():
	const ROTATE_AMOUNT: float = 1
	main_menu.offset_transform_rotation = -deg_to_rad(ROTATE_AMOUNT)
	var tween: Tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	tween.tween_property(main_menu, "offset_transform_rotation", deg_to_rad(ROTATE_AMOUNT), 1)
	tween.tween_property(main_menu, "offset_transform_rotation", deg_to_rad(-ROTATE_AMOUNT), 1)


func _on_play_pressed() -> void:
	_create_menu_transition_tween()
	
	_menu_transition_tween.tween_property(main_menu, "offset_transform_position_ratio", Vector2(0, 1), 1)
	_menu_transition_tween.tween_callback(gameplay_node.show_arm)


func _on_leaderboard_pressed() -> void:
	_create_menu_transition_tween()
	
	_menu_transition_tween.tween_property(main_menu, "offset_transform_position_ratio", Vector2(0, 1), 1)
	_menu_transition_tween.tween_property(leaderboard_menu, "offset_transform_position_ratio", Vector2.ZERO, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_back_pressed() -> void:
	_create_menu_transition_tween()
	
	_menu_transition_tween.tween_property(leaderboard_menu, "offset_transform_position_ratio", Vector2(0, 1), 1)
	_menu_transition_tween.tween_property(main_menu, "offset_transform_position_ratio", Vector2.ZERO, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _create_menu_transition_tween() -> void:
	if _menu_transition_tween and _menu_transition_tween.is_valid():
		_menu_transition_tween.kill()

	_menu_transition_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


func _on_button_mouse_entered(button: Button) -> void:
	const ROTATE_AMOUNT: float = 10.0
	const SCALE_AMOUNT: float = 1.2

	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	tween.tween_property(button, "offset_transform_rotation", deg_to_rad(ROTATE_AMOUNT * [-1, 1].pick_random()), BUTTON_TWEEN_DURATION)
	tween.tween_property(button, "offset_transform_scale", Vector2(SCALE_AMOUNT, SCALE_AMOUNT), BUTTON_TWEEN_DURATION)


func _on_button_mouse_exited(button: Button) -> void:
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(button, "offset_transform_rotation", 0.0, BUTTON_TWEEN_DURATION)
	tween.tween_property(button, "offset_transform_scale", Vector2.ONE, BUTTON_TWEEN_DURATION)


func _on_gameplay_game_finished() -> void:
	music_player.stream_paused = true


func _save_config() -> void:
	var config := ConfigFile.new()

	for entry: Array[String] in leaderboard:
		config.set_value("leaderboard", entry[0], entry[1])
		
	config.save(CONFIG_PATH)


func _load_config() -> void:
	var config := ConfigFile.new()

	config.load(CONFIG_PATH)

	var section_keys: PackedStringArray = config.get_section_keys("leaderboard")
	leaderboard.resize(section_keys.size())
	leaderboard.clear()
	for entry_key: String in section_keys:
		var entry: Array[String] = [entry_key, config.get_value("leaderboard", entry_key)]
		leaderboard.append(entry)


func _sort_leaderboard(entry_1: Array, entry_2: Array):
	if int(entry_1[1]) < int(entry_2[1]):
		return true
	return false


func _update_leaderboard_entries() -> void:
	for child: LeaderboardEntry in leaderboard_entry_container.get_children():
		child.queue_free()
	
	for entry: Array[String] in leaderboard:
		var leaderboard_entry: LeaderboardEntry = LEADERBOARD_ENTRY_SCENE.instantiate()
		leaderboard_entry_container.add_child(leaderboard_entry)
		leaderboard_entry.entry_name = entry[0]
		leaderboard_entry.entry_time = entry[1]


func _on_gameplay_game_restarted() -> void:
	music_player.stream_paused = false
