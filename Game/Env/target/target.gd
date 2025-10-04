extends Area2D
class_name Target

@onready var UI = get_tree().get_first_node_in_group("UI")

var is_hit = false
const NOTIF = preload("uid://c31o46op57e4y")

func _on_body_entered(body: Node2D) -> void:
	body.set_deferred("freeze", true)
	
	if not is_hit:
		is_hit = true
		var child = NOTIF.instantiate()
		add_child(child)
		$Sound.play()
		
		UI.current_targets += 1
	
	#When Target hit, disable self, change art,  add one to targets hit
