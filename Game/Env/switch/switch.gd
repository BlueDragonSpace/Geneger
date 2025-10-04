extends Target

@onready var Game = get_tree().get_first_node_in_group("Game")

func _ready() -> void:
	Game.connect("envSwitched", switched)

func switched() -> void:
	if Game.envSwitch:
		modulate = Color(1,1,1,1)
	else:
		modulate = Color(0,1,0,1)

func get_hit() -> void:
	Game.envSwitch = not Game.envSwitch
	
	is_hit = false
