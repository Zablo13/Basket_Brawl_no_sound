extends Camera2D
var training = false
var VS = false
var MVS = false 
var COOP = false

func _physics_process(_delta: float) -> void:
		
	var ball_pos = %Ball.global_position.y
	
	if ball_pos > 0:
		$".".offset.y = 0
	if ball_pos < 100:
		$".".offset.y = ball_pos - 100
	if training == true:#Spieler1 Pfeil
		var pos = int(($".."/Player.global_position.y -999) *-0.01)
		var player1_pos = $".."/Player.global_position
		if ball_pos > 0:
			$Pfeil1.visible = false
		
		if ball_pos - player1_pos.y < -1000:
			$Pfeil1.visible = true
			$Pfeil1.global_position.x = $".."/Player.global_position.x -30
			$Pfeil1.global_position.y = ball_pos + 900
			$Pfeil1.text = str(pos)
			
	if VS == true:
		if is_instance_valid($".."/Player2):
			var pos2 = int(($".."/Player2.global_position.y -999) *-0.01)
			var player2_pos = $".."/Player2.global_position
			#Spieler2 Pfeil
			if ball_pos > 0:
				$Pfeil2.visible = false

			if ball_pos - player2_pos.y < 1000:
				$Pfeil2.visible = true
				$Pfeil2.global_position.x = $".."/Player2.global_position.x -30
				$Pfeil2.global_position.y = ball_pos + 900
				$Pfeil2.text = str(pos2)
	
	if COOP == true:
		if is_instance_valid($".."/buddy):
			var pos3 = int(($".."/buddy.global_position.y -999) *-0.01)
			var player3_pos = $".."/buddy.global_position
			#Spieler2 Pfeil
			if ball_pos > 0:
				$Pfeil3.visible = false

			if ball_pos - player3_pos.y < 1000:
				$Pfeil3.visible = true
				$Pfeil3.global_position.x = $".."/buddy.global_position.x -30
				$Pfeil3.global_position.y = ball_pos + 900
				$Pfeil3.text = str(pos3)
	
			
	if MVS == true:
		if is_instance_valid($".."/Player2) and is_instance_valid($".."/Player3) and is_instance_valid($".."/Player4): 
			var pos3 = int(($".."/Player3.global_position.y -999) *-0.01)
			var player3_pos = $".."/Player3.global_position
			var pos4 = int(($".."/Player4.global_position.y -999) *-0.01)
			var player4_pos = $".."/Player4.global_position
		#Spieler3 Pfeil
			if ball_pos > 0:
				$Pfeil3.visible = false

			if ball_pos - player3_pos.y < 1000:
			
				$Pfeil3.visible = true
				$Pfeil3.global_position.x = $".."/Player3.global_position.x -30
				$Pfeil3.global_position.y = ball_pos + 900
				$Pfeil3.text = str(pos3)
		
		#Spieler4 Pfeil
			if ball_pos > 0:
				$Pfeil4.visible = false

			if ball_pos - player4_pos.y < 1000:
				$Pfeil4.visible = true
				$Pfeil4.global_position.x = $".."/Player4.global_position.x -30
				$Pfeil4.global_position.y = ball_pos + 900
				$Pfeil4.text = str(pos4)
		
