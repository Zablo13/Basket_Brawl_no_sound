extends Area2D

func _physics_process(_delta: float) -> void:
	for area in $".".get_overlapping_areas():
		if area.is_in_group("Hand"):
			area.off()
		
