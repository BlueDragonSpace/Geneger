extends Node2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@export var current_lvl = 0

@onready var levels: Node2D = $Levels
#### [spawn point, num targets, quiver] ****** HIGHLY IMPORTANTTTTTTT
var lvl_index := []

signal envSwitched
var envSwitch = false: #is the environmental switch on or off
	set(new):
		envSwitch = new
		envSwitched.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in levels.get_children():
		if child.get_class() == "Node2D":
			
			@warning_ignore("unused_variable")
			var targets = 0
			
			for sub_child in child.get_children():
				if sub_child.name.begins_with("Target"):
					targets += 1
				
			lvl_index.push_back([child.position, targets, child.quiver])
	
	#%Player.teleport(lvl_index[current_lvl][0]) # doesn't work here?
	UI.connect("transitioning_out", next_level)
	UI.connect("has_started", start_rise)
	
	$Player/Camera2D.reset_smoothing()

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("debug4") and Global.dev_mode:
		UI.transition_in()

func next_level() -> void:
		current_lvl += 1
		
		if lvl_index.size() <= current_lvl:
			current_lvl = 0
		
		%Player.teleport(lvl_index[current_lvl][0])
		$Player/Camera2D.position = Vector2(0,0) #teleports camera to player, to stop camera jerk to position
		%Player.quiver = lvl_index[current_lvl][2]
		
		UI.target_max = lvl_index[current_lvl][1] #accesses amount of targets on this level

#start game functions
func start_rise() -> void:
	$"Levels/0/StartRise/AnimationPlayer".play("rise")
	$Player/Camera2D.position_smoothing_enabled = true

func _on_fall_area_body_entered(_body: Node2D) -> void:
	$"Levels/0/StartRise/AnimationPlayer".play_backwards("fall") #plays fall backwards
