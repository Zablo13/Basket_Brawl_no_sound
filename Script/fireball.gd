extends RigidBody2D

var speed = Vector2(30, 0)


func _ready() -> void:
	$F2.visible = false

	
func _physics_process(_delta: float) -> void:
	apply_impulse(speed)
	if position.x > 2000:
		queue_free()
	ani()

	for body in $Hurt.get_overlapping_bodies():
		var dir = global_position.direction_to(body.global_position)
		if body.is_in_group("Player") and body.parry == false:
			body.stunned()
			body.bump = true
			body.velocity = dir * 5000
			queue_free()
		if body.is_in_group("Player") and body.parry == true:
			body.reset()
			body.backfire()
			body.taunt()
			queue_free()
		if body.is_in_group("Ball"):
			body.apply_impulse(Vector2(5000,-15000))
			queue_free()
		if body.is_in_group("Fireball2"):
			queue_free()
		if body.is_in_group("Wall"):
			queue_free()


func ani():
	var dice = randf_range(0 , 1)
	if dice >= 0.5:
		$F1.visible = false
		$F2.visible = true
	if dice < 0.5:
		$F1.visible = true
		$F2.visible = false
