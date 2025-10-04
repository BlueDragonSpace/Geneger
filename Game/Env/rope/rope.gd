#@tool
extends StaticBody2D

@export var segments : int = 5

const ROPE_SEGMENT = preload("uid://dnaj04dm1jb5q")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var last_child = null 
	
	for segment in segments:
		var rope_segment = ROPE_SEGMENT.instantiate()
		rope_segment.position.y += 16 + segment * 15 #is 15 rather than 16 to try to stop arrows from clipping through
		if segment == 0:
			rope_segment.get_child(0).node_a = self.get_path()
		else:
			rope_segment.get_child(0).node_a = last_child.get_path()
		last_child = rope_segment
		add_child(rope_segment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		pass
