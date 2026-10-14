class_name LeaderboardEntry
extends HBoxContainer

var entry_name: String:
	set(value):
		entry_name = value
		name_label.text = entry_name

var entry_time: String:
	set(value):
		entry_time = value
		time_label.text = entry_time

@onready var name_label: Label = %EntryName
@onready var time_label: Label = %EntryTime
