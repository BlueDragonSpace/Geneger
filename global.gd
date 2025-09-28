extends Node

# Things that need to be carried over, and the occasional debug function
var arrow_type_num = 0 #type of arrow

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		get_tree().reload_current_scene()
		print("scene reloaded")
