@tool
extends TileMapLayer

@onready var Game = get_tree().get_first_node_in_group("Game")

@export var inverse = true

func _ready() -> void:
	Game.connect("envSwitched", switch)
	
	if not Engine.is_editor_hint():
		switch() #calls to make sure every value is correct at start

func switch() -> void:
	if Game.envSwitch == inverse:
		modulate = Color (1,1,1,1)
		collision_enabled = true
	else:
		modulate = Color (.3, .3, .3, .6)
		collision_enabled = false

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if inverse:
			modulate = Color(0,1,0,.5)
		else:
			modulate = Color(1,0,0,.5)
		
