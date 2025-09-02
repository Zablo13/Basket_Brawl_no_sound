extends Node2D


func _ready() -> void:
	focus_VS()

func _on_single_pressed() -> void:
	%Game.training()
	$".".visible = false

func _on_vs_pressed() -> void:
	%Game.vs()
	$".".visible = false
	
func _on_teams_pressed() -> void:
	%Game.teams()
	$".".visible = false
	
func _on_quit_pressed() -> void:
	get_parent().get_tree().quit()

func _physics_process(_delta: float) -> void:	
	navi()


func _on_coop_pressed() -> void:
	%Game.coop()
	$".".visible = false

func focus_VS():
	$VS.grab_focus()

func navi():
	if $VS.has_focus():
		if Input.is_action_just_pressed("ui_down"):
			$Quit.grab_focus()
		if Input.is_action_just_pressed("ui_up"):
			$Single.grab_focus()
		if Input.is_action_just_pressed("ui_left"):
			$Coop.grab_focus()
		if Input.is_action_just_pressed("ui_right"):
			$Teams.grab_focus()
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		$VS.grab_focus()
		
