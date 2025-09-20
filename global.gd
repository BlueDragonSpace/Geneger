extends Node

#debugging, and data that needs to be in both Player and UI

signal new_arrow_type_num
var arrow_type_num = 0:
	set(new):
		arrow_type_num = new
		new_arrow_type_num.emit()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		get_tree().reload_current_scene()
		print("scene reloaded")
