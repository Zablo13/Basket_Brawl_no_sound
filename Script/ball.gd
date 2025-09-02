extends RigidBody2D

@warning_ignore("unused_signal")
signal out
@export var max_speed = 1500
var held = false
var brake = false


func _physics_process(_delta: float) -> void:
	var winsize = get_viewport_rect().size
	if global_position.x < -100 or global_position.x > winsize.x +100 or global_position.y > winsize.y + 100:
		emit_signal("out")
	if $Hurtbox.get_overlapping_areas() == []:
		held = false
	if held == true:
		brake = false
	
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	if state.linear_velocity.length()>max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed
	if brake == true:
		if state.linear_velocity.y < -500:
			state.linear_velocity.y *= 0.99
		if state.linear_velocity.x > 500 or state.linear_velocity.x < -500:
			state.linear_velocity.x *= 0.99
	
	if held == true:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
			
			
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):	
		brake = true
	if body.is_in_group("Basket"):
		held = false


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Basket") and held == true:
		held = false
		var dir = area.global_position.direction_to(global_position)
		apply_impulse(dir * 3000)
