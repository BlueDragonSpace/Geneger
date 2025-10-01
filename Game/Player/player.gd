extends RigidBody2D

#region Variables, Signals, a whole bunch of stuff

@onready var UI = get_tree().get_first_node_in_group("UI")
@onready var Art: AnimatedSprite2D = $Art
@onready var Animate: AnimationPlayer = $Animate

const SPEED = 5000.0 #basically Acceration, actually
const MAX_SPEED = 200.0

@export var in_control: bool = true #can the player control stuff with the player
var is_dead: bool = false #is the player dead 

@export var charge_move_speed_mult = 0.3
@export var air_control = .05 #ranges from 0 to 1, less control for smaller (goes way too fast at 1)
@export var jump_height = 250

@export_category("Weapon")
@export var kickback := 100.0 #impulse on player
@export var arrow_impulse := 500.0 #impulse on arrow

@export var charge_speed_mult := 1.0: #faster charging
	set(new):
		charge_speed_mult = new
		$WeaponPivot/Bow/CritStar.speed_scale = new
@export var crit_bonus := 1.25 #increased impulse for crit arrows

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_animate: AnimationPlayer = $"WeaponPivot/Bow/WeaponAnimate"
@export var has_bow = false: #got the bow!
	set(new):
		has_bow = new
		if has_bow:
			$WeaponPivot.visible = true

const ARROW = preload("uid://ch6dhgj3k4iki")
var prev_arrow_collision_mask = ARROW.instantiate().collision_mask
var quiver = 10 #number of arrows you have
@export var critable = false #if released this frame, does it crit? (exported for convenince of animation)

signal arrow_released
#endregion

func _ready() -> void:
	weapon_pivot.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse = get_global_mouse_position()
	
	if in_control:
		weapon_pivot.look_at(mouse)
	elif Input.is_action_just_pressed("advance") and is_dead:
		get_tree().reload_current_scene()
		
	## DEBUG
	if Input.is_action_just_pressed("debug2"):
		quiver += 1

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#var direction := Input.get_axis("move_left", "move_right") 

func _physics_process(delta: float) -> void:
	
	#MOVEMENT on X-axis
	var direction := Input.get_axis("move_left", "move_right")
	
	#this is exactly why I need a state machine... this is absolutely horrible
	if direction:
		if in_control:
			linear_velocity.x += direction * SPEED * delta
		else:
			direction = 0
		
		if not Input.is_action_pressed("charge_shot"):
			linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED, MAX_SPEED) #basically friction
		else:
			linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED * charge_move_speed_mult, MAX_SPEED * charge_move_speed_mult) #slower moving while charging arrow 
		
	elif get_contact_count() > 0: #on ground, not moving
		linear_velocity.x = move_toward(linear_velocity.x, 0, abs(linear_velocity.x) * 0.25) #slow to 0
		
		linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED, MAX_SPEED) #in extreme cases of speed, but still friction
	
	if $LeftWallbox.has_overlapping_bodies(): #aka is hitting a left wall
		linear_velocity.x = clamp(linear_velocity.x, 0, INF)
	if $RightWallbox.has_overlapping_bodies(): #aka is hitting a right wall
		linear_velocity.x = clamp(linear_velocity.x, -INF, 0)
	
	##MOVEMENT ON Y-AXIS
	if Input.is_action_just_pressed("jump") and in_control:
		if $Floorbox.has_overlapping_bodies():
			apply_central_impulse(Vector2(0, -jump_height))
	
	#WEAPON STUFFF
	if in_control and quiver > 0 and has_bow:
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
					arrow.visible = false
					arrow.collision_layer = 0 #doesn't collide with anything
					base_impulse *= 8 #high knockback
				_: #default
					arrow.collision_mask = prev_arrow_collision_mask
					
			
			if critable:
				base_impulse *= crit_bonus
				arrow.modulate = Color(1.0, 1.0, 0.0, 1.0)
				print('crit!')
			
			#adds arrow impulse
			arrow.apply_impulse(arrow_impulse * base_impulse)
			
			$Projectiles.add_child(arrow)
			if $Projectiles.get_child_count() > 5:
				$Projectiles.remove_child($Projectiles.get_child(0))
			
			apply_impulse(-1 * kickback * base_impulse)
			weapon_animate.play("release", -1, charge_speed_mult)
			
			quiver -= 1
			arrow_released.emit()

func teleport(new_position: Vector2) -> void:
	
	#thank you rando on the internet for teleporting RigidBody2D
	PhysicsServer2D.body_set_state(
	get_rid(),
	PhysicsServer2D.BODY_STATE_TRANSFORM,
	Transform2D.IDENTITY.translated(new_position)
	)

func _on_hitbox_body_entered(_body: Node2D) -> void:
	is_dead = true
	in_control = false
	set_deferred("lock_rotation", false)
	set_deferred("angular_velocity", randf_range(-1,1) * PI * 10)
	##HHEHEEHEHEHEHEHEHEHEHEHEHEH
	UI.animate.play("death_in") ##HERHEREHEHREHR

func _on_floorbox_body_entered(_body: Node2D) -> void:
	$Floorbox/LeftFloorParticle.emitting = true
	$Floorbox/RightFloorParticle.emitting = true
