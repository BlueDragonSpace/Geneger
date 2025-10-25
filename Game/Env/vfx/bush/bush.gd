extends Area2D

const LEAF_IN_WIND = preload("uid://i46l7cqgab01")

func _on_body_entered(_body: Node2D) -> void:
	$AnimationPlayer.play("shake")

func release_leaves() -> void:
	for leaf in randi_range(1,2):
		var child = LEAF_IN_WIND.instantiate()
		add_child(child)
