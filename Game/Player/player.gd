extends RigidBody2D

const SPEED = 10000.0 #basically Acceration, actually
const MAX_SPEED = 200.0

@export_category("Weapon")
@export var kickback := 100.0 #impulse on player
@export var arrow_impulse := 500.0 #impulse on arrow
@export var charge_speed_mult := 1.0 #faster charging

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_animate: AnimationPlayer = $"WeaponPivot/Bow/WeaponAnimate"

var in_control: bool = true

const ARROW = preload("uid://ch6dhgj3k4iki")
var prev_arrow_collision_mask = ARROW.instantiate().collision_mask

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse = get_global_mouse_position()
	weapon_pivot.look_at(mouse)

func _physics_process(delta: float) -> void:
	
	#MOVEMENT
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		if in_control:
			linear_velocity.x += direction * SPEED * delta
		linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED, MAX_SPEED) #basically friction
	elif get_contact_count() > 0: #on ground, not moving
		linear_velocity.x = move_toward(linear_velocity.x, 0, abs(linear_velocity.x) * 0.25) #slow to 0
		linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED, MAX_SPEED) #in extreme cases of speed, but still friction
	
	if Input.is_action_just_pressed("charge_shot"):
		weapon_animate.play("charge",-1, charge_speed_mult)
		
	elif Input.is_action_just_released("charge_shot"):
		var weapon_direction = Vector2(cos(weapon_pivot.rotation), sin(weapon_pivot.rotation))
		var base_impulse = weapon_direction * weapon_animate.current_animation_position
		
		#adds arrow as child, then adds general qualities
		var arrow = ARROW.instantiate()
		arrow.position = global_position
		arrow.rotation = weapon_pivot.rotation
		
		#specific qualities (based on arrow type)
		match(Global.arrow_type_num):
			
			1: #straight shooting
				arrow.gravity_scale = 0
				base_impulse /= 3
				arrow.modulate = Color(0.0, 1.0, 0.0, 1.0)
			2: #ghost
				base_impulse /= 3
				arrow.modulate = Color(0.0, 0.0, 0.0, 0.5)
				arrow.collision_mask = 0 #doesn't collide with anything (note that this must be changed back)
			3: #impulse
				var Art = arrow.get_node("Art")
				Art.visible = false
				arrow.collision_layer = 0 #doesn't collide with anything
				base_impulse *= 8 #high knockback
			_: #default
				arrow.collision_mask = prev_arrow_collision_mask
				
		#adds arrow impulse
		arrow.apply_impulse(arrow_impulse * base_impulse)
		
		$Projectiles.add_child(arrow)
		if $Projectiles.get_child_count() > 5:
			$Projectiles.remove_child($Projectiles.get_child(0))
		
		
		
		apply_impulse(-1 * kickback * base_impulse)
		
		weapon_animate.play("release", -1, charge_speed_mult)
