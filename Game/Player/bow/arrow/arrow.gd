extends RigidBody2D

@onready var Player = get_tree().get_first_node_in_group('Player')

#multiple inheritance, which messes up inheritance strings, but eh if it works it works (until it doesn't...)
##shared between all arrows
var type = '' #gets type decided by player
var has_hit = false
##shared between all arrows

func _ready() -> void:
	match type:
		'antiGrav':
			$Sound/AntiGrav.play()
		'ghost':
			$Sound/Ghost.play()
		'impulse':
			pass
		'teleport':
			$TeleportCamera.enabled = true
		_:
			pass #there's already a sound for it on release in player
	
	$Sound/ArrowGoing.play()

func _physics_process(_delta: float) -> void:
	
	if get_contact_count() > 0 and not has_hit:
		has_hit = true
		$CPUParticles2D.emitting = true
		$Sound/ArrowGoing.stop()
		$Sound/ArrowHit.play()
		
		hit()
	
	if not has_hit:
		rotation = atan2(linear_velocity.y, linear_velocity.x)

func hit() -> void:
		if type == 'teleport':
			Player.teleport(global_position)
			$TeleportCamera.enabled = false
