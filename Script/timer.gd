extends Panel


var time = 600.0
var minutes := 0
var seconds := 0
var hold = true
@warning_ignore("unused_signal")
signal time_up


func _physics_process(delta: float) -> void:
	
	if hold == false:	
		time -= delta
		@warning_ignore("narrowing_conversion")
		seconds = fmod(time , 60)
		@warning_ignore("narrowing_conversion")
		minutes = fmod(time , 3600) / 60
		$Min.text = " %01d :" % minutes
		$Sek.text = "%02d" % seconds
		
	if hold == true:
		@warning_ignore("narrowing_conversion")
		seconds = fmod(time , 60)
		@warning_ignore("narrowing_conversion")
		minutes = fmod(time , 3600) / 60
		$Min.text = " %01d :" % minutes
		$Sek.text = "%02d" % seconds

	spielzeit()

func spielzeit():
	if time <= 0:
		time = 0.0
		hold = true
		emit_signal("time_up")
		
func _ready() -> void:
	stop()	
	
func start():
	$".".visible = true
	hold = false
	
func stop():
	hold = true
	$".".visible = false
	
	
