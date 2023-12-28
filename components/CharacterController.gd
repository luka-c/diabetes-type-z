extends CharacterBody3D

const RUN_SPEED = 10.0
const WALK_SPEED = 5.0
var speed = WALK_SPEED

const JUMP_VELOCITY = 6
const CAMERA_SENSITIVITY = 0.001
const HIT_STAGGER = 6.0

# Camera shake constants
const SHAKE_FREQUENCY = 2.0
const SHAKE_AMPLITUDE = 0.07
var t_shake = 0.0

var gravity = 9.8
signal player_hit
signal killed_zombie
var health = 5

var current_weapon: int = 0
var can_shoot = true
var bullet = load("res://components/candy_bullet.tscn")
var donut = load("res://components/donut.tscn")
var instance

@onready var head = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var gun_animation = $Head/Camera3D/DesertEagle/Animation
@onready var gun_raycast = $Head/Camera3D/DesertEagle/RayCast3D

# Audio
@onready var walk_sound = $Walk
@onready var run_sound = $Run

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * CAMERA_SENSITIVITY)
		camera.rotate_x(-event.relative.y * CAMERA_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Swap weapons
	if Input.is_action_just_pressed("swap"):
		change_weapon()
		
	# Shoot
	if Input.is_action_pressed("shoot") and can_shoot:
		if !gun_animation.is_playing():
			gun_animation.play("shoot")
			instance = bullet.instantiate() if current_weapon == 0 else donut.instantiate()
			instance.position = gun_raycast.global_position
			instance.transform.basis = gun_raycast.global_transform.basis
			get_parent().add_child(instance)

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Sprint
	if Input.is_action_pressed("sprint") and is_on_floor():
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
		
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
			if Input.is_action_pressed("sprint"):
				if not run_sound.playing:
					run_sound.play()
			else:
				if not walk_sound.playing:
					walk_sound.play()
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
		walk_sound.stop()
		run_sound.stop()
		
	t_shake += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = head_shake(t_shake)

	move_and_slide()


func head_shake(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * SHAKE_FREQUENCY) * SHAKE_AMPLITUDE
	pos.x = cos(time * SHAKE_FREQUENCY / 2) * SHAKE_AMPLITUDE
	return pos
	
func change_weapon():
	can_shoot = false
	var revolver = $Head/Camera3D/DesertEagle/Animation
	var cannon = $Head/Camera3D/hand_cannon/AnimationPlayer
	
	if current_weapon == 0:
		current_weapon = 1
		revolver.play("switch")
		await get_tree().create_timer(0.3).timeout
		cannon.play_backwards("switch")
		gun_animation = $Head/Camera3D/hand_cannon/AnimationPlayer
		gun_raycast = $Head/Camera3D/hand_cannon/RayCast3D
	else:
		current_weapon = 0
		cannon.play("switch")
		await get_tree().create_timer(0.3).timeout
		revolver.play_backwards("switch")
		gun_animation = $Head/Camera3D/DesertEagle/Animation
		gun_raycast = $Head/Camera3D/DesertEagle/RayCast3D
	
	can_shoot = true
		
func hit(direction):
	emit_signal("player_hit")
	health -= 1
	velocity += direction * HIT_STAGGER
	
func on_killed_zombie():
	emit_signal("killed_zombie")
