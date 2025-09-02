extends RigidBody2D

var speed = 0
var dir = Vector2.ZERO
var lock = false

func _physics_process(delta: float) -> void:
	move_and_collide(dir * speed * delta)

		
func get_dir():
	if position.x >= 1800:
		dir.x = -1
	if position.x <= 120:
		dir.x = 1
	else:
		dir.x = randf_range(-1 , 1)
	
	if position.y >= 700:
		dir.y = -1
	else:
		dir.y = randf_range(-1 , 1)
		

func _on_timer_timeout() -> void:
	speed = randi_range(1, 30)
	get_dir()
