extends AnimatableBody2D

##shared between all arrows
var type = '' #gets type decided by player
var has_hit = false
##shared between all arrows

var platform_width: int = 64 #size of platform, for code purposes

var strange_velocity: Vector2 = Vector2.ZERO #gets modified when shot out of bow
#kinda strange... never worked with AnimatableBody2D before, hoping for a moving platform

func _ready() -> void:
	$CollisionShape2D.shape.size.x = platform_width

func _on_right_end_body_entered(_body: Node2D) -> void:
	strange_velocity = Vector2.ZERO #time to stop moving, hit something on the right

func _physics_process(delta: float) -> void:
	position += strange_velocity * delta
