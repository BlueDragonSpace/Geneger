extends Node

@onready var Player = null #defines itself to global, to avoid reload scene problems

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		get_tree().reload_current_scene()
		print("scene reloaded")
	if Input.is_action_just_pressed("debug2"):
		Player.global_position = Vector2(100,100)
