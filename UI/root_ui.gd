extends CanvasLayer

@onready var Player = get_tree().get_first_node_in_group("Player")

@onready var arrow_type: HBoxContainer = $Theme/ArrowType
@onready var quiver: VBoxContainer = $Theme/Quiver

const UI_ARROW = preload("uid://ds8ha74oyja1o")

var time := 0.0

func _ready() -> void:
	#makes first arrow selected
	var count = 0
	for child in arrow_type.get_children():
		if count ==  0:
			child.modulate.a = 1.0
			Global.arrow_type_num = 0
		else:
			child.modulate.a = 0.5
		count += 1
	
	for num in Global.quiver:
		quiver.add_child(UI_ARROW.instantiate())
		
	#connect("Player.arrow_released", $Theme/Quiver.get_child(0).queue_free)
	Player.arrow_released.connect(delete_quiver_arrow)

func delete_quiver_arrow() -> void:
	quiver.get_child(0).queue_free()
	Global.quiver -= 1

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("switch_arrow"):
		for num in range (0,arrow_type.get_child_count()):
			var child = arrow_type.get_child(num)
			
			if child.modulate.a == 1.0:
				child.modulate.a = 0.5
				Global.arrow_type_num += 1
			elif num == Global.arrow_type_num:
				child.modulate.a = 1.0
		
		#on case of last index, loop back around
		if Global.arrow_type_num > arrow_type.get_child_count() - 1:
			Global.arrow_type_num = 0
			arrow_type.get_child(Global.arrow_type_num).modulate.a = 1.0
	
	if quiver.get_child_count() < Global.quiver:
		quiver.add_child(UI_ARROW.instantiate())
	
	# Speedrun Timer
	time += delta
	
	var msec = fmod(time, 1) * 100
	var sec = fmod(time,60)
	var minute = fmod(time,3600) / 60
	$Theme/SpeedrunTimer.text = "%02d" % minute + ":" + "%02d" % sec + "." + "%02d" % msec
