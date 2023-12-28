extends Node3D

const SPEED = 150.0
@onready var collider = $Area3D
@onready var particles = $GPUParticles3D
@onready var donut = $Donut
@onready var icing = $Icing

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

func _on_timer_timeout():
	queue_free()

func _on_area_3d_area_entered(area):
	if area.is_in_group("enemy"):
		donut.visible = false
		icing.visible = false
		particles.emitting = true
		area.hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()
