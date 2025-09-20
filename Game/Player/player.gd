extends RigidBody2D

const SPEED = 20000.0 #basically Acceration, actually
const MAX_SPEED = 300.0

@export_category("Weapon")
@export var kickback := 200.0 #impulse on player
@export var arrow_impulse := 500.0 #impulse on arrow
@export var charge_speed_mult := 1.0 #faster charging

var in_control: bool = true

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_animate: AnimationPlayer = $"WeaponPivot/Bow/WeaponAnimate"

const ARROW = preload("uid://ch6dhgj3k4iki")

func _ready() -> void:
	Global.Player = self

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
		linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED, MAX_SPEED)
	elif get_contact_count() > 0:
		linear_velocity.x = move_toward(linear_velocity.x, 0, abs(linear_velocity.x) * 0.25)
	
	if Input.is_action_just_pressed("charge_shot"):
		weapon_animate.play("charge",-1, charge_speed_mult)
		
	elif Input.is_action_just_released("charge_shot"):
		var weapon_direction = Vector2(cos(weapon_pivot.rotation), sin(weapon_pivot.rotation))
		var base_impulse = weapon_direction * weapon_animate.current_animation_position
		
		var arrow = ARROW.instantiate()
		arrow.position = global_position
		arrow.rotation = weapon_pivot.rotation
		arrow.apply_impulse(arrow_impulse * base_impulse)
		$Projectiles.add_child(arrow)
		if $Projectiles.get_child_count() > 5:
			$Projectiles.remove_child($Projectiles.get_child(0))
		
		apply_impulse(-1 * kickback * base_impulse)
		
		weapon_animate.play("release", -1, charge_speed_mult)
