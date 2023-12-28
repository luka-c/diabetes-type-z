extends Node3D

const SPEED = 180.0

@onready var mesh = $CandyMesh
@onready var collider = $Area3D
@onready var particles = $GPUParticles3D

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

func _on_timer_timeout():
	queue_free()

func _on_area_3d_area_entered(area):
	if area.is_in_group("enemy"):
		mesh.visible = false
		particles.emitting = true
		area.hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()
