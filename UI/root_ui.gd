extends CanvasLayer

@onready var arrow_type: HBoxContainer = $Theme/ArrowType

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

func _process(_delta: float) -> void:
	
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
