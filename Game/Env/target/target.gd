extends Area2D
class_name Target

@onready var UI = get_tree().get_first_node_in_group("UI")

var is_hit = false
const NOTIF = preload("uid://c31o46op57e4y")

func _on_body_entered(body: Node2D) -> void:
	body.set_deferred("freeze", true)
	
	if not is_hit:
		is_hit = true
		body.hit() #this function is terrible code.....
		var child = NOTIF.instantiate()
		add_child(child)
		
		get_hit()
	
	#When Target hit, disable self, change art,  add one to targets hit

#this function is changed in the Switch
func get_hit() -> void: #gets set by extentions of Target, like the Hit-switch
	UI.current_targets += 1
	$Sound.play()
