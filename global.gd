extends Node

#debugging, and data that needs to be in both Player and UI

var arrow_type_num = 0 #type of arrow
var quiver = 10 #number of arrows

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		get_tree().reload_current_scene()
		print("scene reloaded")
	if Input.is_action_just_pressed("debug2"):
		quiver += 1
