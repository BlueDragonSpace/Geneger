extends CanvasLayer

@onready var Player = get_tree().get_first_node_in_group("Player")

@onready var arrow_type: HBoxContainer = $Theme/HUD/ArrowType
@onready var quiver: VBoxContainer = $Theme/HUD/Quiver
@onready var animate: AnimationPlayer = $Animate

signal transitioning_out

const UI_ARROW = preload("uid://ds8ha74oyja1o")
const TYPE = preload("uid://fp8qbuv3sgpo") #arrow type

var time := 0.0
var target_max : int = 99 #gets set by root_game
var current_targets = 0:
	set(new):
		current_targets = new
		$Theme/HUD/TargetTracker/Current.text = str(current_targets)

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
	
	for num in Player.quiver:
		quiver.add_child(UI_ARROW.instantiate())
		
	#connect("Player.arrow_released", $Theme/Quiver.get_child(0).queue_free)
	Player.arrow_released.connect(delete_quiver_arrow)
	
	$Theme/HUD/TargetTracker.visible = false
	$Theme/Death.visible = true
	$Theme/Pause.visible = false

func delete_quiver_arrow() -> void:
	quiver.get_child(0).queue_free()
	#Global.quiver -= 1

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
		
		$Sound/ChangeArrow.play()
	
	if quiver.get_child_count() < Player.quiver:
		quiver.add_child(UI_ARROW.instantiate())
	
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
			$Theme/Pause.visible = false
			$Sound/MenuDissipate.play()
		else:
			get_tree().paused = true
			$Theme/Pause.visible = true
	
	# Speedrun Timer
	time += delta
	
	var msec = fmod(time, 1) * 100
	var sec = fmod(time,60)
	var minute = fmod(time,3600) / 60
	$Theme/HUD/SpeedrunTimer.text = "%02d" % minute + ":" + "%02d" % sec + "." + "%02d" % msec
	
	if current_targets >= target_max: #transition to next level
		transition_in()
		
		#makes current_targets the variable equal to 0 as it transitions, but visibly, it shows the max until transition
		var temp = current_targets
		current_targets = 0
		$Theme/HUD/TargetTracker/Current.text = str(temp)
	

func add_arrow_type() -> void:
	var child = TYPE.instantiate()
	#child.modulate = Color(randi_range(0,255),randi_range(0,255),randi_range(0,255))
	arrow_type.add_child(child)
	
func transition_in() -> void:
	animate.play("transition_in")

func transtion_out() -> void:
	transitioning_out.emit()
	animate.play("transition_out")
	
	$Theme/HUD/TargetTracker.visible = true
	$Theme/HUD/TargetTracker/Current.text = "0"
	$Theme/HUD/TargetTracker/Max.text = str(target_max)
	
