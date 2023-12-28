extends Control

@onready var play: Button = $MainButtons/Play
@onready var controls: Button = $MainButtons/Controls
@onready var exit: Button = $MainButtons/Exit
@onready var back: Button = $ControlsMenu/Back

@onready var main = $MainButtons
@onready var controls_menu = $ControlsMenu
@onready var click_sound = $ClickSound2

func _ready():
	play.pressed.connect(self._play)
	exit.pressed.connect(self._exit)
	controls.pressed.connect(self._show_controls)
	back.pressed.connect(self._back)
	
	var music = $Music
	music.stream.loop = true

func _exit():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()
	
func _play():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/World.tscn")
	
func _show_controls():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	main.visible = false
	controls_menu.visible = true

func _back():
	click_sound.play()
	await get_tree().create_timer(0.4).timeout
	controls_menu.visible = false
	main.visible = true
