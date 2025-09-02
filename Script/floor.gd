extends StaticBody2D

var score1 := 0
var score2 := 0
var closed = false
@export var time = 600.0
@warning_ignore("unused_signal")
signal reset
@warning_ignore("unused_signal")
signal time_up
@warning_ignore("unused_signal")
signal angry1
@warning_ignore("unused_signal")
signal angry2
@warning_ignore("unused_signal")
signal cry1
@warning_ignore("unused_signal")
signal cry2
var count := 0
var time_up_send = false


func _ready() -> void:
	announcer()


func _on_basket_scored() -> void:
	
	if closed == false:
		if score1 < 9:
			closed = true
			score1 += 1
			%Score1.text = str(score1)
			emit_signal("reset")
			if score1 - score2 <= 4: 
				emit_signal("angry2")
			if score1 - score2 >= 5: 
				emit_signal("cry2")			
			await get_tree().create_timer(3.0).timeout
			closed = false
			
		else:
			%Score1.text = "Game"
			@warning_ignore("narrowing_conversion")
			time = 0.0
			emit_signal("time_up")
			emit_signal("cry2")
	else: 
		pass


func _on_basket_2_scored() -> void:
	if closed == false:
		if score2 < 9:
			closed = true
			score2 += 1
			%Score2.text = str(score2)
			emit_signal("reset")
			if score2 - score1 <= 4: 
				emit_signal("angry1")
			if score2 - score1 >= 5: 
				emit_signal("cry1")
			await get_tree().create_timer(3.0).timeout
			closed = false
			
		else:
			%Score2.text = "Game"
			@warning_ignore("narrowing_conversion")
			time = 0.0
			emit_signal("time_up")
			emit_signal("cry1")
	else: 
		pass


func announcer():
	#Die 3 2 1 Anzeige
	if count > 0:
		%Announcer.visible = true
		%Announcer.text = str(count)
		await get_tree().create_timer(1.0).timeout
		count -= 1
		announcer()
	else:
		%Announcer.visible = false
		count = 3


func reset_score():
	$CanvasLayerUI/Timer.stop()
	score1 = 0
	score2 = 0
	%Score1.text = str(score1)
	%Score2.text = str(score2)


func spielzeit():
	$CanvasLayerUI/Timer.time = time
	await get_tree().create_timer(3.0).timeout
	$CanvasLayerUI/Timer.start()
	time_up_send = false
	
#Scoring nach Zeitablauf:
func _on_timer_time_up() -> void:
	
	if time_up_send == false:
		time_up_send = true
		if score1 > score2:
			%Score1.text = str("Game ", score1)
			%Score2.text = str(score2)
			emit_signal("cry2")
		if score1 < score2:
			%Score1.text = str(score1)
			%Score2.text = str("Game ", score2)
			emit_signal("cry1")
		if score1 == score2:
			%Score1.text = str("Draw ", score1)
			%Score2.text = str("Draw ", score2)
		emit_signal("time_up")
	if time_up_send == true:
		pass
