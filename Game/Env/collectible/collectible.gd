extends Area2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@export var image = Texture2D
@export_enum("Bow", "Arrow") var item: String

func _ready() -> void:
	$Sprite2D.texture = image

func _on_body_entered(body: Node2D) -> void:
	
	#only player will ever connect with this
	#if something else collides with this, we have a major problem
	if body.name == 'Player':
		body.Animate.play("collecting")
		body.in_control = false
		
		var collectible_art = body.get_node("CollectibleArt")
		collectible_art.texture = image
		
		match item:
			"Bow":
				body.has_bow = true
				UI.add_arrow_type(image)
			"Arrow":
				UI.add_arrow_type(image)
			_:
				print('no item defined')
		queue_free()
	else: print(body.name + ' collected something... we have a problem')
