extends StaticBody2D
var locked = false
@warning_ignore("unused_signal")
signal scored
var loops = 3


func _ready() -> void:
	locked = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball") and locked == false:
		emit_signal("scored")
		animation()
		locker()

			
func locker():
	locked = true
	unlock()
	
	
func unlock():
	await get_tree().create_timer(4.0).timeout
	locked = false

		
func animation():
	
	if loops > 0:
		loops -= 1
		$Sprite2D.visible = false		
		$Sprite2D2.visible = true
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.visible = true		
		$Sprite2D2.visible = false	
		await get_tree().create_timer(0.05).timeout
		animation()
	else:
		$Sprite2D.visible = true		
		$Sprite2D2.visible = false	
		loops = 3
		return
	 
