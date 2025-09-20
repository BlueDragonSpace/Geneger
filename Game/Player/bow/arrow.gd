extends RigidBody2D

var has_hit = false

func _physics_process(_delta: float) -> void:
	
	if get_contact_count() > 0:
		has_hit = true
	
	if not has_hit:
		rotation = atan2(linear_velocity.y, linear_velocity.x)
		
