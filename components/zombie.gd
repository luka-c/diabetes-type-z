extends CharacterBody3D

var player = null
var player_path: NodePath = "/root/World/Player"

# Audio
const sounds = ["res://audio/zombie1.mp3", "res://audio/zombie2.mp3",
				"res://audio/zombie3.mp3", "res://audio/zombie4.mp3"]
@onready var sounds_player = $zombie_sounds
var can_play = true

const SPEED = 4.0
const ATTACK_RANGE = 2.5
var health = 6

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hit_sound = $AudioStreamPlayer3D
var state_machine


func _ready():
	randomize()
	player = get_node(player_path)
	state_machine = animation_tree.get("parameters/playback")


func _process(delta):
	velocity = Vector3.ZERO
	pick_animation(delta)
	
	if can_play:
		_play_random_sound()
	
	# Check conditions for animation change
	animation_tree.set("parameters/conditions/player_near", _is_player_near())
	animation_tree.set("parameters/conditions/run", true)
	
	move_and_slide()

func pick_animation(delta):
	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_pos = nav_agent.get_next_path_position()
			velocity = (next_pos - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
		"Attack":
			look_at(Vector3(player.global_position.x, 
							global_position.y, 
							player.global_position.z), 
							Vector3.UP)

func _is_player_near() -> bool:
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var direction = global_position.direction_to(player.global_position)
		player.hit(direction)

func _on_area_3d_body_part_hit(damage):
	if health <= 0: return
	hit_sound.play()
	health -= damage
	
	if health <= 0:
		animation_tree.set("parameters/conditions/death", true)
		await get_tree().create_timer(3.0).timeout
		player.on_killed_zombie()
		queue_free()

func _play_random_sound():
	can_play = false
	await get_tree().create_timer(randi() % 10 + 5).timeout # Wait 5-9 seconds
	sounds_player.stream = load(sounds[randi() % 4]) # Choose random sound
	sounds_player.play()
	await get_tree().create_timer(3.0).timeout
	can_play = true
