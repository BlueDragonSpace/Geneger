extends Area2D
class_name Target

const NOTIF = preload("uid://c31o46op57e4y")

func _on_body_entered(body: Node2D) -> void:
	body.set_deferred("freeze", true)
	
	var child = NOTIF.instantiate()
	add_child(child)
	
	#When Target hit, disable self, change art,  add one to targets hit
