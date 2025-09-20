@tool
extends Area2D

@export var wind_speed := 10.0 #base art speed, and determines how much the wind affects stuff
@export var w = 100 #width
@export var h = 100 #height

@onready var Art: Sprite2D = $Art

func _ready() -> void:
	$CollisionShape2D.shape.size.x = w
	$CollisionShape2D.shape.size.y = h
	Art.region_rect.size.x = w #sets the art width
	Art.region_rect.size.y = h #sets the art height
	
	gravity_direction.x = wind_speed / 10.0
	
	#changes gravity to whatever direction rotated in
	gravity_direction = gravity_direction.rotated(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#techically unnesscessary in process, for the @tool function
	$CollisionShape2D.shape.size.x = w
	$CollisionShape2D.shape.size.y = h
	Art.region_rect.size.x = w #sets the art width
	Art.region_rect.size.y = h #sets the art height
	
	#neccessary for process
	Art.region_rect.position.x += delta * wind_speed
