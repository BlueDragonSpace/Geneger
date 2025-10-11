extends CanvasLayer

@onready var Player = get_tree().get_first_node_in_group("Player")

@onready var ArrowType: HBoxContainer = $Theme/HUD/ArrowType
@onready var Quiver: VBoxContainer = $Theme/HUD/Quiver
@onready var Animate: AnimationPlayer = $Animate

signal transitioning_out

const UI_ARROW = preload("uid://ds8ha74oyja1o")
const TYPE = preload("uid://fp8qbuv3sgpo") #arrow type

var target_max : int = 99 #gets set by root_game
var current_targets = 0:
	set(new):
		current_targets = new
		$Theme/HUD/TargetTracker/Current.text = str(current_targets)

@export var started = false: #changed by animation
	set(new):
		started = new
		
		if started:
			has_started.emit()
		
		if Player: #makes sure the player exists, and therefore the game has started
			Player.in_control = started
			$Theme/Start.visible = not started
			
signal has_started 

#usually animated...
@export var can_pause : bool = false #cannot pause during start scene... death, and during transitions

func _ready() -> void:
	#makes first arrow selected
	var count = 0
	for child in ArrowType.get_children():
		if count ==  0:
			child.modulate.a = 1.0
			Global.arrow_type_num = 0
		else:
			child.modulate.a = 0.5
		count += 1
	
	for num in Player.quiver:
		Quiver.add_child(UI_ARROW.instantiate())
		
	#connect("Player.arrow_released", $Theme/Quiver.get_child(0).queue_free)
	Player.arrow_released.connect(delete_quiver_arrow)
	
	$Theme/HUD/TargetTracker.visible = false
	$Theme/HUD/SpeedrunTimer.visible = false
	$Theme/Death.visible = true
	$Theme/Pause.visible = false
	
	$Theme/Start.visible = not started
	Player.in_control = started #isn't this bad code or something idk lol
	can_pause = started

func delete_quiver_arrow() -> void:
	Quiver.get_child(0).queue_free()
	#Global.quiver -= 1

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("switch_arrow"):
		for num in range (0,ArrowType.get_child_count()):
			var child = ArrowType.get_child(num)
			
			if child.modulate.a == 1.0:
				child.modulate.a = 0.5
				Global.arrow_type_num += 1
			elif num == Global.arrow_type_num:
				child.modulate.a = 1.0
		
		#on case of last index, loop back around
		if Global.arrow_type_num > ArrowType.get_child_count() - 1:
			Global.arrow_type_num = 0
			ArrowType.get_child(Global.arrow_type_num).modulate.a = 1.0
		
		$Sound/ChangeArrow.play()
	
	if Quiver.get_child_count() < Player.quiver:
		Quiver.add_child(UI_ARROW.instantiate())
	
	if Input.is_action_just_pressed("pause") and can_pause:
		if get_tree().paused:
			get_tree().paused = false
			$Theme/Pause.visible = false
			$Sound/MenuDissipate.play()
		else:
			get_tree().paused = true
			$Theme/Pause.visible = true
	
	# Speedrun Timer
	if not started:
		#now this... is what we call "cheating"
		Global.time = 0
		
	
	var msec = fmod(Global.time, 1) * 100
	var sec = fmod(Global.time,60)
	var minute = fmod(Global.time,3600) / 60
	$Theme/HUD/SpeedrunTimer.text = "%02d" % minute + ":" + "%02d" % sec + "." + "%02d" % msec
	
	if current_targets >= target_max: #transition to next level
		transition_in()
		
		#makes current_targets the variable equal to 0 as it transitions, but visibly, it shows the max until transition
		var temp = current_targets
		current_targets = 0
		$Theme/HUD/TargetTracker/Current.text = str(temp)
	
	#start game
	if not started and Input.is_action_just_pressed("advance"):
		Animate.play("start_in")

	

func add_arrow_type() -> void: #this function is not used??
	var child = TYPE.instantiate()
	#child.modulate = Color(randi_range(0,255),randi_range(0,255),randi_range(0,255))
	ArrowType.add_child(child)
	
func transition_in() -> void:
	Animate.play("transition_in")

func transtion_out() -> void:
	transitioning_out.emit()
	Animate.play("transition_out")
	
	$Theme/HUD/TargetTracker.visible = true
	$Theme/HUD/TargetTracker/Current.text = "0"
	$Theme/HUD/TargetTracker/Max.text = str(target_max)

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_speedrun_button_pressed() -> void:
	$Theme/HUD/SpeedrunTimer.visible = $Theme/Pause/SpeedrunButton.button_pressed
