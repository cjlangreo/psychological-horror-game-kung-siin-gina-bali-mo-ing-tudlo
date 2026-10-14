class_name Gameplay
extends Node


signal game_finished
signal _arm_hidden

enum Finger{
	THUMB,
	INDEX,
	MIDDLE,
	RING,
	PINKY
}

const WIN_MUSIC: AudioStream = preload("uid://b2mfk5qqyqsmn")
const YOU_WIN_AUDIO: AudioStream = preload("uid://c1sfci8xghhdc")

@export var thumb_textures: Array[Texture2D]
@export var thumb_bitmap_textures: Array[BitMap]

@export var index_textures: Array[Texture2D]
@export var index_bitmap_textures: Array[BitMap]

@export var middle_textures: Array[Texture2D]
@export var middle_bitmap_textures: Array[BitMap]

@export var ring_textures: Array[Texture2D]
@export var ring_bitmap_textures: Array[BitMap]

@export var pinky_textures: Array[Texture2D]
@export var pinky_bitmap_textures: Array[BitMap]

var _thumb_counter: int = 0:
	set(value):
		_thumb_counter = clampi(value, 0, 2)
var _index_counter: int = 0:
	set(value):
		_index_counter = clampi(value, 0, 2)
var _middle_counter: int = 0:
	set(value):
		_middle_counter = clampi(value, 0, 2)
var _ring_counter: int = 0:
	set(value):
		_ring_counter = clampi(value, 0, 2)
var _pinky_counter: int = 0:
	set(value):
		_pinky_counter = clampi(value, 0, 2)

@onready var alima_texture_rect: TextureRect = %Alima
@onready var thumb_texture_button: TextureButton = %Thumb
@onready var index_texture_button: TextureButton = %Index
@onready var middle_texture_button: TextureButton = %Middle
@onready var ring_texture_button: TextureButton = %Ring
@onready var pinky_texture_button: TextureButton = %Pinky
@onready var gore_sfx_player: AudioStreamPlayer = %GoreSFXPlayer
@onready var game_end: Control = %GameEnd
@onready var win_sfx_player: AudioStreamPlayer = %WinSFX
@onready var play_again_button: Button = %PlayAgain


func _ready() -> void:
	alima_texture_rect.offset_transform_position_ratio = Vector2(0, 1)
	game_end.hide()


func show_arm() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.tween_property(alima_texture_rect, "offset_transform_position_ratio", Vector2.ZERO, 1)

	
func _hide_arm() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.tween_property(alima_texture_rect, "offset_transform_position_ratio", Vector2(0, 1), 1)
	tween.tween_callback(_arm_hidden.emit)


func _on_thumb_pressed() -> void:
	_update_finger(Finger.THUMB)


func _on_pinky_pressed() -> void:
	_update_finger(Finger.PINKY)
	

func _on_ring_pressed() -> void:
	_update_finger(Finger.RING)
	

func _on_middle_pressed() -> void:
	_update_finger(Finger.MIDDLE)
	

func _on_index_pressed() -> void:
	_update_finger(Finger.INDEX)


func _update_finger(finger: Finger) -> void:
	gore_sfx_player.play()
	match finger:
		Finger.THUMB:
			_thumb_counter += 1
			thumb_texture_button.texture_normal = thumb_textures[_thumb_counter]
			thumb_texture_button.texture_click_mask = thumb_bitmap_textures[_thumb_counter]
			if _thumb_counter == 2:
				thumb_texture_button.disabled = true
				thumb_texture_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
				
		Finger.INDEX:
			_index_counter += 1
			index_texture_button.texture_normal = index_textures[_index_counter]
			index_texture_button.texture_click_mask = index_bitmap_textures[_index_counter]
			if _index_counter == 2:
				index_texture_button.disabled = true
				index_texture_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
				
		Finger.MIDDLE:
			_middle_counter += 1
			middle_texture_button.texture_normal = middle_textures[_middle_counter]
			middle_texture_button.texture_click_mask = middle_bitmap_textures[_middle_counter]
			if _middle_counter == 2:
				middle_texture_button.disabled = true
				middle_texture_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
				
		Finger.RING:
			_ring_counter += 1
			ring_texture_button.texture_normal = ring_textures[_ring_counter]
			ring_texture_button.texture_click_mask = ring_bitmap_textures[_ring_counter]
			if _ring_counter == 2:
				ring_texture_button.disabled = true
				ring_texture_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
				
		Finger.PINKY:
			_pinky_counter += 1
			pinky_texture_button.texture_normal = pinky_textures[_pinky_counter]
			pinky_texture_button.texture_click_mask = pinky_bitmap_textures[_pinky_counter]
			if _pinky_counter == 2:
				pinky_texture_button.disabled = true
				pinky_texture_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
				


	if _thumb_counter == 2 and \
		_index_counter == 2 and \
		_middle_counter == 2 and \
		_ring_counter == 2 and \
		_pinky_counter == 2:
			_end_game()


func _end_game():
	game_finished.emit()
	
	thumb_texture_button.disabled = true
	index_texture_button.disabled = true
	middle_texture_button.disabled = true
	ring_texture_button.disabled = true
	pinky_texture_button.disabled = true

	await get_tree().create_timer(3).timeout
	_hide_arm()
	await _arm_hidden
	win_sfx_player.play()
	game_end.show()
	await win_sfx_player.finished
	win_sfx_player.stream = WIN_MUSIC
	win_sfx_player.play()
	await win_sfx_player.finished
	play_again_button.show()


func _on_play_again_pressed() -> void:
	_reset_arm()
	show_arm()
	game_end.hide()
	play_again_button.hide()
	win_sfx_player.stream = YOU_WIN_AUDIO



func _reset_arm() -> void:
	_thumb_counter = 0
	_index_counter = 0
	_middle_counter = 0
	_ring_counter = 0
	_pinky_counter = 0

	thumb_texture_button.texture_normal = thumb_textures[_thumb_counter]
	thumb_texture_button.texture_click_mask = thumb_bitmap_textures[_thumb_counter]
	thumb_texture_button.disabled = false
	thumb_texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	index_texture_button.texture_normal = index_textures[_index_counter]
	index_texture_button.texture_click_mask = index_bitmap_textures[_index_counter]
	index_texture_button.disabled = false
	index_texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	middle_texture_button.texture_normal = middle_textures[_middle_counter]
	middle_texture_button.texture_click_mask = middle_bitmap_textures[_middle_counter]
	middle_texture_button.disabled = false
	middle_texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	ring_texture_button.texture_normal = ring_textures[_ring_counter]
	ring_texture_button.texture_click_mask = ring_bitmap_textures[_ring_counter]
	ring_texture_button.disabled = false
	ring_texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	pinky_texture_button.texture_normal = pinky_textures[_pinky_counter]
	pinky_texture_button.texture_click_mask = pinky_bitmap_textures[_pinky_counter]
	pinky_texture_button.disabled = false
	pinky_texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
