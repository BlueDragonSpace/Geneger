extends Area2D

const NOTIF = preload("uid://c31o46op57e4y")

func _on_body_entered(_body: Node2D) -> void:
	print('hit')
	var child = NOTIF.instantiate()
	add_child(child)
