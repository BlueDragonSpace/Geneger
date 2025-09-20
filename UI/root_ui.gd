extends CanvasLayer

@onready var arrow_type: HBoxContainer = $Theme/ArrowType
var arrow_type_num = 0

func _ready() -> void:
	#makes first arrow selected
	var count = 0
	for child in arrow_type.get_children():
		if count ==  0:
			child.modulate.a = 1.0
			arrow_type_num = 0
		else:
			child.modulate.a = 0.5
		count += 1

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("switch_arrow"):
		for child in arrow_type.get_children():
			#make next in line true as selected, then link to player
			pass
