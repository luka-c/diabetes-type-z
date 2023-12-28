extends Node3D

# Health
@onready var hit_rect = $CanvasLayer/ColorRect
@onready var scoreLabel: Label = $CanvasLayer/ScoreValue
@export var hearts: Array[TextureRect]
@onready var player = $Player
var heart_index: int
var score: int = 0

# Spawning
@onready var spawn_points = $SpawnPoints
@onready var nav_region = $NavigationRegion3D
@onready var timer = $ZombieSpawnTimer
var zombie = load("res://components/zombie.tscn")
var start
var instance

# Audio
@onready var click_sound = $CanvasLayer/ClickSound
@onready var music = $CanvasLayer/Music

# Menus
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var restart_menu = $CanvasLayer/RestartMenu
@onready var controls_menu = $CanvasLayer/ControlsMenu
@onready var menu_animations: AnimationPlayer = $CanvasLayer/MenuAnimations

# Buttons
@onready var resume: Button = $CanvasLayer/PauseMenu/Resume
@onready var controls: Button = $CanvasLayer/PauseMenu/Controls
@onready var exit: Button = $CanvasLayer/PauseMenu/Exit
@onready var restart: Button = $CanvasLayer/RestartMenu/Restart
@onready var back: Button = $CanvasLayer/ControlsMenu/Back


func _ready():
	_start_level()
	randomize()
	start = Time.get_ticks_msec() * 1000
	heart_index = hearts.size() - 1
	
	resume.pressed.connect(self._resume)
	exit.pressed.connect(self._exit)
	controls.pressed.connect(self._show_controls)
	restart.pressed.connect(self._restart)
	back.pressed.connect(self._back)


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		_pause()
	_check_timer()


func _on_player_player_hit():
	if heart_index >= 0:
		hearts[heart_index].visible = false
		heart_index -= 1
		hit_rect.visible = true
		await get_tree().create_timer(0.2).timeout
		hit_rect.visible = false
		
		# Check for death
		if heart_index < 0:
			_player_death()


func _on_player_killed_zombie():
	score += 50
	scoreLabel.text = str(score)


# Start animation
func _start_level():
	player.process_mode = Node.PROCESS_MODE_DISABLED
	restart_menu.visible = false
	var door_sound = $CanvasLayer/DoorSound
	door_sound.play()
	await get_tree().create_timer(7.0).timeout
	
	var camera = $Player/Head/Camera3D
	var click_sound = $CanvasLayer/ClickSound2
	click_sound.play()
	await get_tree().create_timer(0.35).timeout
	camera.visible = true
	
	music.stream.loop = true
	music.play()
	
	var ui = $CanvasLayer
	ui.visible = true
	player.process_mode = Node.PROCESS_MODE_INHERIT
#	menu_animations.play("fade_in")


func _player_death():
	var death_sound = $CanvasLayer/DeathSound
	death_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	restart_menu.visible = true


# Pause menu
func _exit():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()


func _pause():
	if get_tree().paused == false:
		get_tree().paused = true
		pause_menu.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _resume():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().paused = false
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _show_controls():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	pause_menu.visible = false
	controls_menu.visible = true


func _back():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	controls_menu.visible = false
	pause_menu.visible = true


func _restart():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().reload_current_scene()
	if get_tree().paused == true:
		get_tree().paused = false


func _on_zombie_spawn_timer_timeout():
	_spawn_zombie()


func _spawn_zombie():
	var random_index = randi() % spawn_points.get_child_count()
	var random_spawn = spawn_points.get_child(random_index).global_position
	await get_tree().create_timer(3.0).timeout
	instance = zombie.instantiate()
	nav_region.add_child(instance)
	instance.position = random_spawn


func _check_timer():
	var current_time = Time.get_ticks_msec() * 1000
	if (current_time - start <= 400):
		match (current_time - start):
			25:
				timer.wait_time = 6
			50:
				timer.wait_time = 5
			75:
				timer.wait_time = 4
			150:
				timer.wait_time = 3
			250:
				timer.wait_time = 2
			350:
				timer.wait_time = 1
			400:
				timer.wait_time = 0.5
