extends RigidBody2D

#region Variables, Signals, a whole bunch of stuff

@onready var UI = get_tree().get_first_node_in_group("UI")
@onready var Art: AnimatedSprite2D = $Art
@onready var Animate: AnimationPlayer = $Animate
@onready var Camera: Camera2D = $Camera2D

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
			if weapon_pivot: #is it defined
				weapon_pivot.set_deferred("visible", true)
				
				if Global.joypad: #is joypad on
					$Crosshair.set_deferred('visible', true)

const ARROW = preload("uid://ch6dhgj3k4iki")
const PLATFORM_ARROW = preload("uid://cmijyf4lj0opg")

var prev_arrow_collision_mask = ARROW.instantiate().collision_mask
var quiver = 0 #number of arrows you have
@export var projectile_count: int = 5 #number of arrows that are visible on the screen at max
@export var critable = false #if released this frame, does it crit? (exported for convenince of animation)
var tension_release = true #when the player pulls bowstring back, but decides not to fire an arrow (change arrow type to release tension)

var teleporting = false #used when teleporting with teleport arrow
var teleport_defer = 0 #defers the camera for a few frames so it can catch up with the teleport


const CROSSHAIR_RADIUS = 64 #max distance between player and crosshair
#const CAMERA_PEEK = 30 #moving crosshair offsets camera

signal arrow_released

#endregion

func _ready() -> void:
	$Crosshair.visible = false
	
	if Global.checkpoint != 0:
		weapon_pivot.visible = true
	else:
		weapon_pivot.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if in_control:
		
		if Global.joypad:
			$Crosshair.position = Global.joypad_right_stick * CROSSHAIR_RADIUS
			weapon_pivot.look_at($Crosshair.global_position)
			
		else: 
			var mouse = get_global_mouse_position()
			weapon_pivot.look_at(mouse)
			
			#var weapon_direction = Vector2(cos(weapon_pivot.rotation), sin(weapon_pivot.rotation))
			#var peek = clamp(global_position.distance_to(mouse), 0, CAMERA_PEEK)
			#Camera.offset = weapon_direction * peek
			
	elif Input.is_action_just_pressed("advance") and is_dead:
		get_tree().reload_current_scene()
		
	## DEBUG
	if Input.is_action_just_pressed("debug2") and Global.dev_mode:
		quiver += 1
	if Input.is_action_just_pressed("debug5") and Global.dev_mode:
		has_bow = true
		weapon_pivot.visible = true

func _physics_process(delta: float) -> void:
	
#region X-Axis Movement
	##MOVEMENT on X-axis
	var direction := Input.get_axis("move_left", "move_right")
	
	#this is exactly why I need a state machine... this is absolutely horrible
	if direction:
		
		if get_contact_count() > 0: #on ground
			
			if in_control:
				linear_velocity.x += direction * SPEED * delta
				if not $Sound/PlayerWalk.playing:
					$Sound/PlayerWalk.play()
			
			if not Input.is_action_pressed("charge_shot"):
				linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED, MAX_SPEED) #basically friction
			else:
				linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED * charge_move_speed_mult, MAX_SPEED * charge_move_speed_mult) #slower moving while charging arrow 
		else: #in air
			#I now have proposed velocity, it isn't added if it would make x_vel go further than limit
			#however, allows velocity to be above limit, if it was already there
			#this usually happens when using impulse
			
			var proposed_vel: float = direction * SPEED * delta
			
			if proposed_vel + linear_velocity.x > MAX_SPEED or proposed_vel + linear_velocity.x < -MAX_SPEED:
				pass #the velocity is too much, going overboard
			else:
				linear_velocity.x += proposed_vel
		
	elif get_contact_count() > 0: #on ground, not moving
		linear_velocity.x = move_toward(linear_velocity.x, 0, abs(linear_velocity.x) * 0.25) #slow to 0
		
		linear_velocity.x = clamp(linear_velocity.x,-MAX_SPEED, MAX_SPEED) #in extreme cases of speed, but still friction
	
	if $LeftWallbox.has_overlapping_bodies(): #aka is hitting a left wall
		linear_velocity.x = clamp(linear_velocity.x, 0, INF)
	if $RightWallbox.has_overlapping_bodies(): #aka is hitting a right wall
		linear_velocity.x = clamp(linear_velocity.x, -INF, 0)
	
#endregion
	
	##MOVEMENT ON Y-AXIS
	if Input.is_action_just_pressed("jump") and in_control:
		if $Floorbox.has_overlapping_bodies():
			apply_central_impulse(Vector2(0, -jump_height))
			$Sound/Jump.play()
	
	#WEAPON STUFFF
	if in_control and quiver > 0 and has_bow and not teleporting:
		if Input.is_action_just_pressed("charge_shot"):
			weapon_animate.play("charge",-1, charge_speed_mult)
			$Sound/BowLoading.play()
			tension_release = false
		
		#presses switch arrow while tension is on the string, releases tension
		if Input.is_action_just_pressed("switch_arrow") and not tension_release:
			tension_release = true
			weapon_animate.play("release", -1, charge_speed_mult / 2)
			
		elif Input.is_action_just_released("charge_shot") and not tension_release:
			var weapon_direction = Vector2(cos(weapon_pivot.rotation), sin(weapon_pivot.rotation))
			var base_impulse = weapon_direction * weapon_animate.current_animation_position
			
			#adds arrow as child, then adds general qualities
			var arrow = null
			
			#specific qualities (based on arrow type)
			match(Global.arrow_type_num):
				
				1: #straight shooting
					arrow = ARROW.instantiate()
					arrow.type = 'antiGrav'
					arrow.gravity_scale = 0
					base_impulse /= 3
					#arrow.modulate = Color(0.0, 1.0, 0.0, 1.0)
				2: #ghost
					arrow = ARROW.instantiate()
					arrow.type = 'ghost'
					base_impulse /= 3
					#arrow.modulate = Color(0.0, 0.0, 0.0, 0.5)
					arrow.collision_mask = 0 #doesn't collide with anything (note that this must be changed back)
				3: #impulse
					arrow = ARROW.instantiate()
					arrow.type = 'impulse'
					arrow.visible = false
					arrow.collision_layer = 0 #doesn't collide with anything
					base_impulse *= 8 #high knockback
				4: #platform
					arrow = PLATFORM_ARROW.instantiate()
					arrow.type = 'platform'
					base_impulse /= 6
					#arrow.modulate = Color(1.0, 1.0, 0.0, 1.0)
					arrow.collision_layer = 10 #layer 2 and 4, meaning it is also a platform
				5: #teleport
					arrow = ARROW.instantiate()
					arrow.type = 'teleport'
					#arrow.modulate = Color(1.0, 0.0, 0.573, 1.0)
					
					Camera.enabled = false
					Camera.position_smoothing_enabled = false
					teleporting = true
				_: #default
					arrow = ARROW.instantiate()
					arrow.type = 'basic'
					arrow.collision_mask = prev_arrow_collision_mask
			
			arrow.position = global_position
			arrow.rotation = weapon_pivot.rotation
			
			if critable:
				base_impulse *= crit_bonus
				arrow.modulate = Color(1.0, 1.0, 0.0, 1.0)
				$Sound/Critical.play()
				print('crit!')
			
			#adds arrow impulse
			if arrow.type != 'platform':
				arrow.apply_impulse(arrow_impulse * base_impulse)
			else:
				arrow.strange_velocity = arrow_impulse * base_impulse
				arrow.position += (arrow.platform_width / 2) * base_impulse #makes platform spawn a little bit away
				
				#bad pass note in REFACTORING
				if not critable:
					arrow.start_death(weapon_animate.current_animation_position)
				else:
					arrow.start_death(weapon_animate.current_animation_position / 1.2)
			
			$Projectiles.add_child(arrow)
			if $Projectiles.get_child_count() > projectile_count:
				$Projectiles.remove_child($Projectiles.get_child(0))
			
			apply_impulse(-1 * kickback * base_impulse)
			weapon_animate.play("release", -1, charge_speed_mult)
			
			$Sound/BowLoading.stop()
			$Sound/ShootArrow.play()
			
			quiver -= 1
			arrow_released.emit()
	
	if teleporting and Input.is_action_just_pressed("switch_arrow"): #teleport cancel
		teleporting = false
		Camera.enabled = true
		Camera.position_smoothing_enabled =  true
		
		for child in $Projectiles.get_children():
			child.queue_free()
			
		
	if not teleporting and not Camera.enabled:
		#defers position_smothing on the camera so it can catch up with the teleport
		
		if teleport_defer == 1:
			Camera.enabled = true
			Camera.position_smoothing_enabled =  true
			teleport_defer = 0
		
		teleport_defer += 1
		
func teleport(new_position: Vector2) -> void:
	
	#thank you rando on the internet for teleporting RigidBody2D
	PhysicsServer2D.body_set_state(
	get_rid(),
	PhysicsServer2D.BODY_STATE_TRANSFORM,
	Transform2D.IDENTITY.translated(new_position)
	)
	
	teleporting = false
	

func _on_hitbox_body_entered(_body: Node2D) -> void:
	
	if not teleporting:
		
		is_dead = true
		in_control = false
		set_deferred("lock_rotation", false)
		set_deferred("angular_velocity", randf_range(-1,1) * PI * 10)
		$Sound/PlayerDead.play()
		UI.Animate.play("death_in")
		
		#sets the Camera to stop following the player
		Camera.position = Camera.get_screen_center_position()
		var CameraNode = Node.new()
		add_child(CameraNode)
		Camera.reparent(CameraNode, false) #makes the Camera parented to a default Node, so it stops following position
	
	#this also creates a case where when the player misses a teleport shot, and both are in the void, they live forever...

func _on_floorbox_body_entered(_body: Node2D) -> void:
	$Floorbox/LeftFloorParticle.emitting = true
	$Floorbox/RightFloorParticle.emitting = true
	$Sound/HitGround.play()

func _on_bow_art_animation_finished() -> void:
	if $WeaponPivot/Bow/BowArt.get_animation() == 'release':
		$WeaponPivot/Bow/BowArt.play("idle")
