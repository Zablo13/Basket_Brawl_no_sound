extends Node2D


func _on_game_time_up() -> void:
	$Main_menu.visible = true
	$Main_menu.focus_VS()


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("menu_button"):
		
		$Main_menu.visible = true
		$Main_menu.focus_VS()
		
