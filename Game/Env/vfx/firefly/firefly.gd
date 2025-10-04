extends Sprite2D

var speed = randf_range(1, 2) #pixels per second
var direction = randi_range(-1,1)
var time_alive: float = 0.0
var random_offset = randf_range(0, 2 * PI)

var seen = false #tracks when player sees firefly to get it to start moving

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if direction == 0:
		direction = 1
	
	if direction == -1:
		flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if seen:
		
		time_alive += delta
		position.y += sin(time_alive + random_offset)
		
		position.x += direction * speed + randf_range(-0.25, 0.25)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	print('dead_firefly')


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	seen = true
