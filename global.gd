extends Node

# Things that need to be carried over, and the occasional debug function
var arrow_type_num = 0 #type of arrow

var time: float = 0.0 #time in seconds (obvs)

var joypad = false #is using an external computer
var joypad_deadzone = 0.1
var joypad_right_stick = Vector2.ZERO #deadzoned coordinates

func _ready() -> void:
	
	###Joypads!!!
	if Input.get_connected_joypads().size() > 0:
		joypad = true
	else:
		joypad = false

func _process(delta: float) -> void:
	
	time += delta
	
	if Input.is_action_just_pressed("debug1"):
		get_tree().reload_current_scene()
		print("scene reloaded")
	
	if joypad:
		var x : float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		if x > 0.5 + joypad_deadzone or x < 0.5 - joypad_deadzone:
			joypad_right_stick.x = x
		
		var y : float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		if y > 0.5 + joypad_deadzone or y < 0.5 - joypad_deadzone:
			joypad_right_stick.y = y
