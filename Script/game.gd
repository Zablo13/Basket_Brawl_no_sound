extends Node2D

var is_out = false
@warning_ignore("unused_signal")
signal time_up
@export var player2 = preload("res://Scenes/player_2.tscn")
@export var player3 = preload("res://Scenes/player_3.tscn")
@export var player4 = preload("res://Scenes/player_4.tscn")
@export var buddy = preload("res://Scenes/buddy.tscn")

func _ready() -> void:
	#versteckz Playerpfeile
	$Camera2D/Pfeil1.visible = false
	$Camera2D/Pfeil2.visible = false
	$Camera2D/Pfeil3.visible = false
	$Camera2D/Pfeil4.visible = false
	
	
func _on_floor_reset() -> void:
	abstoss()
	unlock_basket()
	
func _on_ball_out() -> void:
	if is_out == false:
		is_out = true
		abstoss()
		await get_tree().create_timer(3.5).timeout
		is_out = false


func abstoss():
	
	$Floor.announcer()
	await get_tree().create_timer(3.0).timeout
	
	$Player.position.x = 720
	$Player.position.y = 1000
	$Player.reset()
	if is_instance_valid($Player2):
		$Player2.position.x = 1200
		$Player2.position.y = 1000
		$Player2.reset()
	if is_instance_valid($Player3):
		$Player3.position.x = 520 
		$Player3.position.y = 1000
		$Player3.reset()
	if is_instance_valid($Player4):
		$Player4.position.x = 1400
		$Player4.position.y = 1000
		$Player4.reset()
	if is_instance_valid($buddy):
		$buddy.position.x = 520 		
		$buddy.position.y = 1000
		$buddy.reset()
	%Ball.global_position.x = 960
	%Ball.global_position.y = 100
	%Ball.linear_velocity = Vector2.ZERO
	%Ball.angular_velocity = 0

func training():
	
	$Floor.reset_score()
	if is_instance_valid($Player2):
		$Player2.queue_free()
	if is_instance_valid($Player3):
		$Player3.queue_free()
	if is_instance_valid($Player4):
		$Player4.queue_free()
	if is_instance_valid($buddy):
		$buddy.queue_free()	
	$Camera2D.training = true
	$Camera2D.VS = false
	$Camera2D.MVS = false
	abstoss()
	unlock_basket()
	
func vs():
	
	$Camera2D.training = true
	$Camera2D.VS = true
	$Camera2D.MVS = false
	$Camera2D.COOP = false
	if not is_instance_valid($Player2):
		var o = player2.instantiate()
		add_child(o)
		o.position.x = 1200
		o.position.y = -300
	if is_instance_valid($Player3):
		$Player3.queue_free()
	if is_instance_valid($Player4):
		$Player4.queue_free()
	if is_instance_valid($buddy):
		$buddy.queue_free()	
	$Floor.time = 600
	$Floor.spielzeit()
	$Floor.reset_score()
	abstoss()
	unlock_basket()	
		
func coop():
	
	$Camera2D.training = true
	$Camera2D.VS = false
	$Camera2D.MVS = false
	$Camera2D.COOP = true
	
	if not is_instance_valid($buddy):
		var o = buddy.instantiate()
		add_child(o)
		o.position.x = 520
		o.position.y = -300
	if is_instance_valid($Player2):
		$Player2.queue_free()
	if is_instance_valid($Player3):
		$Player3.queue_free()
	if is_instance_valid($Player4):
		$Player4.queue_free()
	$Floor.reset_score()
	abstoss()
	unlock_basket()			
		
		
func teams():
	
	$Camera2D.training = true
	$Camera2D.VS = true
	$Camera2D.MVS = true
	$Camera2D.COOP = false
	if not is_instance_valid($Player2):
		var o = player2.instantiate()
		add_child(o)
		o.position.x = 1200
		o.position.y = -300
	if not is_instance_valid($Player3):
		var o = player3.instantiate()
		add_child(o)
		o.position.x = 520
		o.position.y = -300
	if not is_instance_valid($Player4):
		var o = player4.instantiate()
		add_child(o)
		o.position.x = 1400
		o.position.y = -300
	if is_instance_valid($buddy):
		$buddy.queue_free()	
	$Floor.reset_score()
	abstoss()
	$Floor.time = 600
	$Floor.spielzeit()
	unlock_basket()

func menu_reset() -> void:
	$Floor.reset_score()
	abstoss()
	$Floor.time = 600
	$Floor.spielzeit() 
	unlock_basket()

func _on_floor_time_up() -> void:
	emit_signal("time_up")
	lock_basket()

func unlock_basket():
	%Basket.locked = false
	%Basket2.locked = false
	
func lock_basket():
	%Basket.locked = true
	%Basket2.locked = true


func _on_floor_angry_1() -> void:
	$Player.angry()
	if is_instance_valid($Player3):
		$Player3.angry()


func _on_floor_angry_2() -> void:
	if is_instance_valid($Player2):
		$Player2.angry()
	if is_instance_valid($Player4):
		$Player4.angry()


func _on_floor_cry_1() -> void:
	$Player.cry()
	if is_instance_valid($Player3):
		$Player3.cry()


func _on_floor_cry_2() -> void:
	if is_instance_valid($Player2):
		$Player2.cry()
	if is_instance_valid($Player4):
		$Player4.cry()
