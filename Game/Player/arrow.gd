extends RigidBody2D

func _physics_process(_delta: float) -> void:
	
	#var get_to = linear_velocity.normalized()
	#
	#get_to = get_to.angle_to(get_to)
	#get_to = get_to - rotation
	#apply_torque(get_to * 5000)
	var velo = Vector2(linear_velocity.x,linear_velocity.y)
	
	look_at(velo)
