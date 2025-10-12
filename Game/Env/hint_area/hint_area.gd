extends Area2D

@export var hint: String = ''

@onready var UI = get_tree().get_first_node_in_group("UI")

func _on_body_entered(_body: Node2D) -> void:
	UI.hint(hint)
