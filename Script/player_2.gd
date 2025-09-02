extends CharacterBody2D #Player1 1.6 Polished & Cleaned 

#Die Variablen
@export var hadoken = preload("res://Scenes/fireball_2.tscn")#P!
@export var speed = 700
@export var jump_speed = -900
@export var gravity = 2000
@export var dash_speed = 1600
@export_range(0.0 , 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25
var jumps := 3
var jetpack := 300
var dash = true
var dashed = false
var can_float = false
var floating = false
var fast_fall = false
var can_hold = false
var held = false
var power := 0
var stun = false
var stunblei = false
var punching = false
var can_punch = true
var can_toss = true
var stomp = false
var microstun = false
var dash_cooler = 0.0
var parry = false
var parrycooler = false
var parry_down = 0.0
var tauntcooler = false
var whirl = false
var speed_up = false
var check = false	
var count = 0.0	
var count2 = 0.0
var stuntime = 0.0		
var tauntcheck = false	
var p1 = false
var p2 = false
var p3 = false
var bump = false
var bumptimer = 0.0

	
#Startfunktion, versteckt Grafiken
func _ready() -> void:
	
	$Bigstunsprite.visible = false
	$Smallstunsprite.visible = false
	$Flamesprite.visible = false
	$Offsprite.visible = false
	$Center/Armsprite/Boxersprite.visible = false
	$Center/Armsprite/Catchersprite.visible = false
	$ProgressBar.show_percentage = false
	$ProgressBar.visible = false
	$crack1.visible = false
	$crack2.visible = false
	$crack3.visible = false
	$Flamesprite2.visible = false
	$shield.visible = false
	$Playersprite/angry.visible = false
	$Playersprite/walk1.visible = false
	$Playersprite/walk2.visible = false
	$Playersprite/taunt1.visible = false
	$Playersprite/taunt2.visible = false
	$Playersprite/taunt3.visible = false
	$Playersprite/sad1.visible = false
	$Playersprite/sad2.visible = false
	$Playersprite/stunfaced.visible = false
	$Playersprite/stunfaced2.visible = false
	$Playersprite/stunfaced3.visible = false
	$run1.visible = false
	$run2.visible = false
	$Playersprite/helm.visible = false
	$kiai.visible = false
	
	
#Das Herzstück, der Physik Prozess. Alle Prozesse, die regelmässig für Physik gebraucht werden hier rein!	
func _physics_process(delta: float) -> void:
	
	gravitation(delta) #delta = Zeit, Gravitation wirkt immer stärker je länger sie wirkt.
	get_input()
	move_and_slide() #Eingebaute Godot Funktion, um aus get Input Bewegung zu erzeugen
	throw() #Der Spielerwurf und Ball fangen
	drop()	#Block Würfe				
	dashing() #Dash Eingabe und Cooldowns
	jump() #:D
	punish() #Zuschlagen
	toss() #Schmetterwürfe
	animation() 
	hitter() #Die Spielerhand
	stomper() #Die Jump Attacke
	powerbar() #Power Balken für Würfe
	counter() #Die Parade		
	slower() #Ball bremst Bewegung
	walking() #Laufanimation
	taunting() #Taunt
	counting(delta)
	fire()
	firecooler()
	firing()
	bumping()
	
			
func gravitation(delta): #Zeitabhängige Funktion
		#Gravitation
	if is_on_floor(): #Refresh Sprung und Jetpack am Boden
		check = true
		jumps = 3
		jetpack = 300
		fast_fall = false
		if dashed == false:
			can_float = false
	
	if not is_on_floor() and dashed == false:
		check = false
		
	if dashed == true or whirl == true: #Keine Gravitation während Dash
		return
			
	if floating == false: #Normale Gravitation
		velocity.y += gravity * delta
	
	if floating == true: #Jetpack an Gravitation
		if held == false:
			jetpack -= 2
		if held == true:
			jetpack -= 3
		@warning_ignore("integer_division")
		velocity.y += gravity / 8 * delta
		if jetpack <= 0:
			floating = false
			can_float = false

	if fast_fall == true: #Fast fall Gravitation
		velocity.y += gravity * 3 * delta
		
	if stunblei == true: #Gravitationslock bei Stun
		velocity.y += gravity * 10 * delta
	
	
func slower(): #P! velocity.x
	if held == false and tauntcheck == false:
		if velocity.y < -1000:
			velocity.y = -1000
	#Geschwindigkeitsabnahme mit Ball
	if held == true and dashed == false: #Bremse auf X mit Ball nach vorn ohne Dash
		if velocity.x < -300: #P! +/-
			velocity.x = -300 #P! +/-	
		if velocity.y < -800:
			velocity.y = -800
	if held == true and dashed == true: #Bremse auf X mit Ball nach vorn mit Dash
		if velocity.x < -800: #P! +/-
			velocity.x = -800 #P! +/-
		if velocity.y < -800: #Bremse nach oben
			velocity.y = -800
	if floating == true and held == false: #Jetpack Maxspeed nach oben ohne Ball
		if Input.is_action_pressed("jump2"):
			velocity.y -= 5 #schweben beim Jetpack
		if velocity.y < -500: #Bremse nach oben
			velocity.y = -500
	if floating == true and held == true: #Jetpack Maxspeed nach oben mit Ball
		if Input.is_action_pressed("jump2"):
			velocity.y -= 3 #schweben beim Jetpack
		if velocity.y < -300: #Bremse nach oben
			velocity.y = -300
	if speed_up == true:
		speed = 800
	if speed_up == false:
		speed = 700
					
					
func get_input():
		#Movement rechts links		
	if dashed == true or bump == true: #Keine Beeinflussung vom Dash
		return
	var dir = Input.get_axis("move_left2" , "move_right2") #Achse aus links rechts bestimmen
	if dir != 0 and stun == false: #Bei Richtungseingabe Bewegung ausrechnen
		velocity.x = lerp(velocity.x , dir * speed , acceleration)
	if dir != 0 and stun == true: #Bei Richtungseingabe Bewegung ausrechnen
		velocity.x = lerp(velocity.x , dir * speed * 0.2, acceleration)
	else:
		velocity.x = lerp(velocity.x , 0.0 , friction) #Ohne Eingabe nachrutschen durch Reibung
	

func walking():
	
	if is_on_floor() and velocity.x != 0 and dashed == false and stomp == false:
		if $Playersprite/stand.visible == true:
			$Playersprite/stand.visible = false
			$Playersprite/walk1.visible = true
			$Playersprite/walk2.visible = false
			await get_tree().create_timer(0.2).timeout
			$Playersprite/walk1.visible = false
			$Playersprite/walk2.visible = true
			await get_tree().create_timer(0.2).timeout
			$Playersprite/walk2.visible = false		
			$Playersprite/stand.visible = true
		
	if velocity.x == 0:
		$Playersprite/stand.visible = true
		$Playersprite/walk1.visible = false		
		$Playersprite/walk2.visible = false		
	if not is_on_floor() or dashed == true:
		$Playersprite/stand.visible = true
		$Playersprite/walk1.visible = false		
		$Playersprite/walk2.visible = false
		
		
func jump():#Springen :)

	if Input.is_action_just_pressed("jump2") and jumps > 0: #Abfrage Sprung Input
		jumps -= 1
		velocity.y = jump_speed #Die Sprungkraft
		if jumps == 0:
			floatable()
	#Jetpack zünden			
	if Input.is_action_pressed("jump2") and can_float == true:
		floating = true
	#Jetpack aus ohne Druck auf Jump			
	if Input.is_action_just_released("jump2"):
		floating = false
	#Fast fall mit Druck nach unten			
	if Input.is_action_pressed("move_down2") and floating == false and !Input.is_action_pressed("catch2"):
		fast_fall = true
	#Fast fall aus ohne Druck nach unten
	if Input.is_action_just_released("move_down2") or is_on_floor():
		fast_fall = false
		
		
func dashing():
	#Hier der Dash
	if dash == true:
		if Input.is_action_just_pressed("dash_right2"): #Input abfragen
			dash = false
			dashed = true
			if not is_on_floor(): #Die Stampfattacke
				stomp = true
				henshin()
			if is_on_floor():
				henshin() #Die tatsächliche Bewegung
			await get_tree().create_timer(0.4).timeout #Cooldowns
			dashed = false
			stomp = false
	#L2 Power reset Knopf
	if Input.is_action_pressed("dash_left2"): #Input abfragen
		power = 0

		
func _on_catcher_body_exited(body: Node2D) -> void:#Ball meldet sich ab bei Verlust
	if body.is_in_group("Ball"): #Gruppe von Collider abfragen
		held = false
			
			
func get_throw_dir() -> Vector2:
	#Die Wurfrichtung bestimmen und den Arm justieren
	var new_throw_dir = Vector2() #leerer Vektor wird erstellt
	new_throw_dir = Input.get_vector("move_left2" , "move_right2" , "move_up2" , "move_down2") #Vektor aus Stickrichtung erzeugt
	if new_throw_dir != Vector2.ZERO: #Bei Vektor ungleich 0 wird der Wurf gepowert
		power += 1 
	if new_throw_dir == Vector2.ZERO and held == true: #Ohne Eingabe hält der Spieler den Ball über Kopf
		new_throw_dir = Vector2(0 , -1) #Ball über Kopf bei neutralem Stick
	return new_throw_dir.normalized() #neuen Vector zurückgeben


func throw():
	#Fangen und der normale Wurf
	var throw_dir = get_throw_dir() #Armrichtung holen und fangen
	if Input.is_action_just_pressed("catch2") and held == false and stun == false and microstun == false and punching == false: #Input lauschen
		$Center.look_at(throw_dir *100000) #Hand folgt Stickrichtung
		power = 0
		catcher() #Hand weiß färben und zum Fangen aktivieren
		
	if Input.is_action_pressed("catch2"): #lauscht auf Input
		$Center.look_at(throw_dir *100000) #Hand folgt Stickrichtung
		if held == true and $".."/Ball.held == true:
			$".."/Ball.global_transform.origin = %ball_marker.global_position #Hier hält der Ball magisch an der Hand
						
	if Input.is_action_just_released("catch2") and held == true: #Der normale Wurf
		off() #Ball loslassen
		if power > 200: #Power auf 200 begrenzen
			power = 200			
		$".."/Ball.apply_impulse(throw_dir * power * 150) #Die Wurfkraft
		$".."/Ball.apply_torque_impulse(throw_dir.x * power * 3000) #Die Ballrotation brechnet sich hier
				
	if held == false and whirl == false and throw_dir == Vector2.ZERO: #Ohne Ball und Richtung Hand vor Spieler
			$Center.look_at($normalizer.global_position) #Schaue auf die Normalizer-Node
	
	
func stunned():
	#Der böse Stun wird hier beschrieben
	if parry == false:
		stuntime = 0.0
		stun = true
		stunblei = true
		can_float = false
		can_punch = false
		can_hold = false
		dash = false
		punching = false
		whirl = false
		off() #Ballabgabe
		stunani() #Stun Sterne - Animation
		stunface() #Stun Animation
		

func stunani():
	
	if stun == true:
		$Playersprite.visible = true
		$run2.visible = false
		$run1.visible = false
	#Die Stun - Stern Animation
	$Bigstunsprite.visible = true
	await get_tree().create_timer(0.5).timeout #Timer
	$Smallstunsprite.visible = true
	$Bigstunsprite.visible = false
	await get_tree().create_timer(0.5).timeout #Timer
	$Smallstunsprite.visible = false
	$Bigstunsprite.visible = true
	await get_tree().create_timer(0.5).timeout #Timer
	$Smallstunsprite.visible = true
	$Bigstunsprite.visible = false
	await get_tree().create_timer(0.5).timeout #Timer
	$Smallstunsprite.visible = false
	$Bigstunsprite.visible = false
	
	
func stunface():
	if stun == true:
		$Playersprite/stunfaced.visible = true
	await get_tree().create_timer(0.5).timeout #Timer
	if stun == true:	
		$Playersprite/stunfaced2.visible = true
	await get_tree().create_timer(0.5).timeout #Timer
	if stun == true:
		$Playersprite/stunfaced3.visible = true
	await get_tree().create_timer(0.5).timeout #Timer
	if stun == true:
		$Playersprite/stunfaced.visible = false
		$Playersprite/stunfaced3.visible = false
	await get_tree().create_timer(0.5).timeout #Timer
	if stun == true:
		$Playersprite/stunfaced2.visible = false
	else:
		$Playersprite/stunfaced.visible = false
		$Playersprite/stunfaced2.visible = false
		$Playersprite/stunfaced3.visible = false
		
		
func floatable():#Freigabe Jetpack
	if stun == false:
		can_float = true


func bumping():
	
	for body in %Hurtbox.get_overlapping_bodies():
		if body.is_in_group("Player") and dashed == false and body.dashed == true and body != $".":
			bump = true
			var dir = body.global_position.direction_to(global_position).normalized()
			velocity = dir * 2500
		if body.is_in_group("Player") and dashed == false and body.bump == true and body != $".":
			bump = true
			var dir = body.global_position.direction_to(global_position).normalized()
			velocity = dir * 1000		


func off(): #Zum loslassen des Balls. Wird für Würfe benötigt sowie Kollisionen in der Luft.
	#Ballverlust oder Abgabe
	$".."/Ball.held = false #Ball macht sich frei
	held = false #Spieler hält Ball nicht mehr
	can_hold = false #Kein erneutes greifen
	microstun = true #Keine Ballaufnahme möglich durch Microstun
	$Offsprite.visible = true #Rotes Off-Sternchen wird angezeigt
	await get_tree().create_timer(0.2).timeout #Timer 0.2 Sek
	microstun = false #Spieler kann wieder greifen
	$Offsprite.visible = false #Rotes Off-Sternchen wird ausgeblendet
	
	
func punish():
	
	if whirl == false and punching == true:
		var throw_dir = get_throw_dir() #Handrichtung holen
		if throw_dir != Vector2.ZERO:
			$Center.look_at(throw_dir *100000)	#Schulter schaut auf Stickeingabe!
		if throw_dir == Vector2.ZERO:
			$Center.look_at($normalizer.global_position)
			
	if Input.is_action_just_pressed("punch2") and punching == true and whirl == false and p3 == false:
		punching = false
		can_punch = false
		can_toss = false
		count2 = 0.0
		
	#Zuschlagen
	if Input.is_action_just_pressed("punch2") and held == false and stun == false and can_punch == true and parry == false and whirl == false and punching == false and p3 == false:#Input lauschen
		can_punch = false
		punching = true
		can_toss = false
		count = 0.0
		angry()
		
		if Input.is_action_pressed("move_left2") and check == true:
			whirling_left()
		if Input.is_action_pressed("move_right2") and check == true:
			whirling_right()
		if Input.is_action_pressed("move_up2") and check == true:
			whirling_up()
		if Input.is_action_pressed("move_down2") and check == true:
			whirling_down()			
		if whirl == false and not is_on_floor():		
			await get_tree().create_timer(0.5).timeout #Timer
			punching = false

		
func catcher():
	#Die weiße Hand wird zum Fangen aktiv
	if can_hold == false:
		can_hold = true
		await get_tree().create_timer(1.0).timeout #Timer
		can_hold = false
	

func animation():
	#Sprites an / aus je nach Bedingung
	if punching == true: #Punch Sprite
		$Center/Armsprite/Boxersprite.visible = true
	if punching == false:
		$Center/Armsprite/Boxersprite.visible = false
	if can_hold == true: #weiße Hand
		$Center/Armsprite/Catchersprite.visible = true
	if can_hold == false:
		$Center/Armsprite/Catchersprite.visible = false
	#Jetpack Flammen-Animation
	if floating == false:
		$Flamesprite.visible = false
		$Flamesprite2.visible = false
	if jetpack > 100 and floating == true:
		$Flamesprite.visible = true
	if dashed == true and jetpack > 100:
		$Flamesprite.visible = true
	if dashed == true and jetpack <= 100:
		$Flamesprite2.visible = true
	if jetpack <= 100 and floating == true:
		$Flamesprite.visible = false
		$Flamesprite2.visible = true
	if parry == true:
		$shield.visible = true
		$Playersprite/helm.visible = true
	if parry == false:
		$shield.visible = false
		$Playersprite/helm.visible = false		
	if can_punch == true and stun == false:
		$punchin.visible = true					
	if can_punch == false or stun == true:
		$punchin.visible = false
		
							
func angry():
	$Playersprite/angry.visible = true
	await get_tree().create_timer(2.0).timeout
	$Playersprite/angry.visible = false
	
	
func hitter():#Die Spielerhand
	
	for body in %Catcher.get_overlapping_bodies(): #Kollisionsabfrage wer ist in der Hand
		
		var throw_dir = $".".global_position.direction_to(body.global_position).normalized() #Winkel zum Gegner oder Ball
		#Boxen
		if body.is_in_group("Team1") and punching == true and body.parry == false: #Gegner Stun bei aktiven Schlag
			body.stunned() #Beim Gegner Stunfunktion auslösen
			body.velocity = (throw_dir * 2000) #Rückstoss des Gegners
			body.bump = true
		#Schubsen	
		if body.is_in_group("Team1") and stun == false and punching == false and held == false and body.punching == false and body.stun == false and body.dashed == false: #Gegner schubsen
			if body.is_in_group("Hand"):
				velocity = (throw_dir * -1)
				bump = true
			if dashed == true:
				body.velocity = (throw_dir * 1000) #Rückstoss des Gegners
				body.bump = true
			else:
				body.velocity = (throw_dir * 500) #Rückstoss des Gegners
				body.bump = true	
		#Konter		
		if body.is_in_group("Team1") and punching == true and body.parry == true: #Der Konter bei aktiven Block
			body.reset()
			body.taunt()
			stunned() #Stun
			velocity = throw_dir * -5000
											
		if body.is_in_group("Ball") and punching == true: #Den Ball boxen
			$".."/Ball.held = false
			body.apply_impulse(throw_dir * 6000) #Rückstosskraft
		
		if body.is_in_group("Basket"):
			off()
		
		#Ball fangen
		if Input.is_action_pressed("catch2") and held == false and stun == false and can_hold == true:
			if body.is_in_group("Ball"):
				dash_cooler += 3.0
				held = true
				$".."/Ball.held = true #Der Ball klebt nun am Spieler
		#Gegner schnappen	
			if body.is_in_group("Team1") and body.stun == true and can_hold == true:#P! R/L
				if Input.is_action_pressed("move_right2"):
					body.stunned()
					body.stuntime = 1.0
					body.position.x -= 100 #P! +/-
					$Center.look_at(Vector2(10000, 1000)) #P! +/-
					await get_tree().create_timer(0.2).timeout #Timer
					$Center.look_at(Vector2(-10000, 1000)) #P! +/-
					body.velocity.x = -1000 #P! +/-
					body.bump = true 
				else:	
					body.stunned()
					body.stuntime = 1.0
					body.position.x += 100 #P! +/-
					$Center.look_at(Vector2(-10000, 1000)) #P! +/-
					await get_tree().create_timer(0.2).timeout #Timer
					$Center.look_at(Vector2(10000, 1000)) #P! +/-
					body.velocity.x = 2000  #P! +/-
					body.bump = true
										
		for area in %Catcher.get_overlapping_areas():
			if area.is_in_group("Basket"):
				off()	
			if area.is_in_group("Hand") and area.is_in_group("Team1") and area.punching == true and punching == true:
				var dir = area.global_position.direction_to(global_position)
				velocity = dir * 5000
				
				
func stomper():
	#Die Stampfattacke
	if stomp == true and is_on_floor(): #Ausgelöst durch Bodenberührung mit aktivem Stomp
		for body in $Stomper.get_overlapping_bodies(): #Stopmer fragt wer im Radius liegt
			if body.is_in_group("Team1") and stomp == true:
				var dir = global_position.direction_to(body.global_position).normalized() #Vektor von eigener Position zum Gegner wird erstellt
				if body.parry == false: #Check ob Gegner Parry aktiv ist
					body.stunned() #Stun beim Gegner
					body.velocity = dir * 5000 #Rückstoss beim Gegner in Vektorrichtung. Velocity(CharakterNode) statt externer Kraft(apply impulse) bei RigidBody
				
			if body.is_in_group("Ball") and stomp == true: #Stampfer gegen Ball
				var dir = global_position.direction_to(body.global_position).normalized()#Vektor von eigener Position zum Ball wird erstellt
				dir.y = -2
				body.apply_impulse(dir * 15000) #Ball wird weggestoßen
				body.apply_torque_impulse(10000 * dir.x) #Balldrehung
		#Sound und Animation		
		angry()
		stomp = false
		$crack1.visible = true
		await get_tree().create_timer(0.1).timeout #Timer
		if is_on_floor():
			$crack1.visible = false
			$crack2.visible = true
		await get_tree().create_timer(0.1).timeout #Timer
		if is_on_floor():
			$crack3.visible = true
		await get_tree().create_timer(0.1).timeout #Timer
		if is_on_floor():
			$crack2.visible = true
			$crack3.visible = false
			$crack1.visible = false
		await get_tree().create_timer(0.1).timeout #Timer
		$crack2.visible = false
		$crack3.visible = false
		$crack1.visible = false
		
	#Das normale auf den Kopf springen	
	for body in $Stomper/Smallstomper.get_overlapping_bodies():
		if body.is_in_group("Team1") and body.parry == false and stun == false:
			body.stunned()
			velocity.y -= 500


func powerbar():
	#Die Ladeleiste für Wurfpower
	if power > 0:
		$ProgressBar.visible = true #sichtbar machen
		$ProgressBar.max_value = 200 #max Wert setzen
		$ProgressBar.value = power #Var Power als Source festlegen
		
	if held == false: #Ohne Ball
			power = 0 #keine Power
			$ProgressBar.visible = false #keine Leiste
			
	if power == 0 and held == true: #Mit Ball mit 0 Power
		$ProgressBar.value = 0 #leere Leiste zeigen


func counter():
	#Der Block / Parry wird aktiv
	if Input.is_action_just_pressed("drop2") and parrycooler == false and held == false and stun == false and punching == false:
		parade()


func drop():#P!
	#Die 3 Würfe auf der Block Taste stehen hier
	var throw_dir = get_throw_dir() #Armbewegung als Wurfrichtung holen
	if power > 200: #Power auf 200 begrenzen
		power = 200	
	if Input.is_action_just_pressed("drop2") and held == true: #Gegen sofortigen Konter bei Ballabgabe wird Parry blockiert
		if Input.is_action_pressed("move_right2") and held == true: #P! left / right
			off()
			var shot = Vector2(throw_dir.x * power * -40 , throw_dir.y * power * 100)
			$".."/Ball.apply_torque_impulse(-100000) #P! Drehimpuls +/-
			$".."/Ball.apply_impulse(shot) #Wurfkraft
		else: #oben unten vorne Drop Wurf
			var shot = Vector2(throw_dir.x * power * 50 , throw_dir.y * power * 50)
			off()
			$".."/Ball.apply_torque_impulse(-350000) #P! Drehimpuls +/-
			$".."/Ball.apply_impulse(shot) #Wurfkraft
	

func toss():#P!
	#Die Schmetterwürfe
	if Input.is_action_pressed("punch2") and held == true and can_toss == true: #Schmetter hinten
		if Input.is_action_pressed("move_right2"): #P! rechts / links
			var dist = global_position.direction_to(Vector2(0 , 300)) #P! Basket (1920,300 od. 0,300)
			dist.x *= 20000
			dist.y *= -5 * dist.x #P! +/-dist
			if dist.y > -3000: #mindest Y-Stärke
				dist.y = -3000
			off()
			$".."/Ball.apply_torque_impulse(1000000) #P! +/- Drehimpuls
			$".."/Ball.apply_impulse(dist) #Wurfkraft
			can_punch = false
			can_toss = false
			count2 = 0.0
			angry()
		else:#Schmettern nach vorne
			off() #Ballabgabe
			$".."/Ball.apply_impulse(Vector2(-15000 , -3000)) #P! +/- X, y bleibt gleich, Wurfkraft
			$".."/Ball.apply_torque_impulse(1500000) #P! +/- Drehimpuls
			can_punch = false
			can_toss = false
			count2 = 0.0
			angry()
			

func henshin():
	#Die Bewegung beim Dash
	var dir = get_throw_dir()#Stickrichtung holen
	floatable() #Jetpack einschaltbar
	if dashed == true:
		if dir != Vector2.ZERO: #Bei Richtungseingabe ungleich 0
			velocity = get_throw_dir() * dash_speed #in Stick-Richtung dashen mit Dash_speed
		if dir == Vector2.ZERO and Input.is_action_pressed("dash_right2"): #Ohne Richtung mit Ball nach oben
			velocity = Vector2.ZERO
			check = true


func taunting():
	if Input.is_action_just_pressed("dash_left2") and held == false and stun == false and tauntcooler == false:
		taunt()


func taunt():
	tauntcooler = true
	tauntcheck = true
	$Playersprite/taunt1.visible = true
	await get_tree().create_timer(0.2).timeout
	$Playersprite/taunt2.visible = true 
	await get_tree().create_timer(0.2).timeout
	$Playersprite/taunt3.visible = true
	await get_tree().create_timer(0.2).timeout
	$Playersprite/taunt3.visible = false
	await get_tree().create_timer(0.2).timeout
	$Playersprite/taunt2.visible = false
	await get_tree().create_timer(0.2).timeout
	$Playersprite/taunt1.visible = false
	tauntcheck = false
	await get_tree().create_timer(5.0).timeout
	tauntcooler = false


func cry():
	$Playersprite/taunt1.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad1.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = true
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad2.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/sad1.visible = false
	await get_tree().create_timer(0.3).timeout
	$Playersprite/taunt1.visible = false


func parade():
	
	parry = true
	parrycooler = true
	await get_tree().create_timer(0.5).timeout #Timer
	parry = false


func whirling_right():
	
	if stun == false:
		whirl = true
		speed_up = true
		punching = true
		$Playersprite.visible = false
		$run2.visible = true
		$Center.look_at(Vector2(-10000, 1000))
		
		await get_tree().create_timer(0.1).timeout
		if stun == false:
			velocity.x = 5000
			$Center.look_at(Vector2(10000, 1000))
			
			await get_tree().create_timer(0.1).timeout
			if stun == false:
				$run2.visible = false
				$run1.visible = true
				$Center.look_at(Vector2(-10000, 1000))
				
				await get_tree().create_timer(0.1).timeout
				if stun == false:
					$run1.visible = false
					$Playersprite.visible = true
					$Center.look_at(Vector2(10000, 1000))
					
					await get_tree().create_timer(0.1).timeout
					if stun == false:
						$Playersprite.visible = false
						$run2.visible = true
						velocity.y -= 150
						if Input.is_action_pressed("catch2"):
							punching = false
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							catcher()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return		
						if Input.is_action_pressed("drop2") and parrycooler == false:	
							parrycooler = true
							punching = false
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							parade()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return		
						await get_tree().create_timer(0.1).timeout
						if stun == false:
							$Center.look_at(Vector2(1000, -10000))
							#Follow Ups		
							if Input.is_action_pressed("jump2") and whirl == true:
								velocity.y += 100
								
							if Input.is_action_pressed("dash_left2") and whirl == true:
								velocity.y -= 1500
								$run2.visible = false
								$Playersprite.visible = true
								
							if Input.is_action_pressed("punch2") and whirl == true:
								punching = true
								if Input.is_action_pressed("move_up2"):
									whirling_up()
								else:
									whirling_right()
	
						await get_tree().create_timer(0.5).timeout
						if Input.is_action_pressed("move_down2") and stun == false and not is_on_floor():
							fast_fall = true
							stomp = true	
						whirl = false
						$run2.visible = false
						$Playersprite.visible = true
						punching = false
	await get_tree().create_timer(2.5).timeout
	stomp = false
	speed_up = false


func whirling_left():
	
	if stun == false:
		whirl = true
		speed_up = true
		punching = true
		$Playersprite.visible = false
		$run2.visible = true
		$Center.look_at(Vector2(10000, 1000))
		
		await get_tree().create_timer(0.1).timeout
		if stun == false:
			velocity.x = -5000
			$Center.look_at(Vector2(-10000, 1000))
			
			await get_tree().create_timer(0.1).timeout
			if stun == false:
				$run2.visible = false
				$run1.visible = true
				$Center.look_at(Vector2(10000, 1000))
				
				await get_tree().create_timer(0.1).timeout
				if stun == false:
					$run1.visible = false
					$Playersprite.visible = true
					$Center.look_at(Vector2(-10000, 1000))
					
					await get_tree().create_timer(0.1).timeout
					if stun == false:
						$Playersprite.visible = false
						$run2.visible = true
						velocity.y -= 150
						if Input.is_action_pressed("catch2"):
							punching = false
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							catcher()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return		
						if Input.is_action_pressed("drop2") and parrycooler == false:	
							punching = false
							parrycooler = true
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							parade()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return												
						await get_tree().create_timer(0.1).timeout
						if stun == false:
							$Center.look_at(Vector2(1000, -10000))
							#Follow Ups		
							if Input.is_action_pressed("jump2") and whirl == true:
								velocity.y += 100
															
							if Input.is_action_pressed("dash_left2") and whirl == true:
								velocity.y -= 1500
								$run2.visible = false
								$Playersprite.visible = true
								
							if Input.is_action_pressed("punch2") and whirl == true:
								punching = true
								if Input.is_action_pressed("move_up2"):
									whirling_up()
								else:
									whirling_left()								

						await get_tree().create_timer(0.5).timeout
						if Input.is_action_pressed("move_down2") and stun == false and not is_on_floor():
							fast_fall = true
							stomp = true	
						whirl = false
						$run2.visible = false
						$Playersprite.visible = true
						punching = false
	await get_tree().create_timer(2.5).timeout
	stomp = false
	speed_up = false


func whirling_up():
	
	if stun == false:
		whirl = true
		speed_up = true
		punching = true
		$Center.look_at(Vector2(1000, 10000))
		
		await get_tree().create_timer(0.1).timeout
		if stun == false:
			velocity.y -= 300
			$Center.look_at(Vector2(-10000, 1000)) #P! +/- X
			
			await get_tree().create_timer(0.1).timeout
			if stun == false:
				$Center.look_at(Vector2(-10000, -10000)) #P! +/- X
				
				await get_tree().create_timer(0.1).timeout
				if stun == false:
					$Center.look_at(Vector2(1000, -10000))
					
					await get_tree().create_timer(0.1).timeout
					if stun == false:
						$Playersprite.visible = false
						$run2.visible = true
						velocity.y -= 100
						if Input.is_action_pressed("catch2"):
							punching = false
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							catcher()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return
						if Input.is_action_pressed("drop2") and parrycooler == false:
							parrycooler = true	
							punching = false
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							parade()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return								
						await get_tree().create_timer(0.1).timeout
						if stun == false:
							$Center.look_at(Vector2(1000, -10000))
							#Follow Ups		
							if Input.is_action_pressed("jump2") and whirl == true:
								velocity.y += 300
								
							if Input.is_action_pressed("dash_left2") and whirl == true:
								velocity.y -= 1500
								$run2.visible = false
								$Playersprite.visible = true
								
							if Input.is_action_pressed("punch2") and whirl == true:
								punching = true
								if Input.is_action_pressed("move_left2"):
									whirling_left()
								if Input.is_action_pressed("move_right2"):
									whirling_right()
								else:
									whirling_down()						

						await get_tree().create_timer(0.5).timeout
						if Input.is_action_pressed("move_down2") and stun == false and not is_on_floor():
							stomp = true	
						whirl = false
						$run2.visible = false
						$Playersprite.visible = true
						punching = false
	await get_tree().create_timer(2.5).timeout
	stomp = false
	speed_up = false	
	
	
func whirling_down():
	
	if stun == false:
		whirl = true
		speed_up = true
		punching = true
		$Playersprite.visible = false
		$run2.visible = true
		$Center.look_at(Vector2(10000, 1000)) #P! +/-
		
		await get_tree().create_timer(0.1).timeout
		if stun == false:
			$Center.look_at(Vector2(-10000, 1000)) #P! +/-
			
			await get_tree().create_timer(0.1).timeout
			if stun == false:
				$run2.visible = false
				$run1.visible = true
				$Center.look_at(Vector2(1000, 10000))
				
				await get_tree().create_timer(0.1).timeout
				if stun == false:
					velocity.y -= 100
					$run1.visible = false
					$Playersprite.visible = true
					$Center.look_at(Vector2(1000, -10000))
					
					await get_tree().create_timer(0.1).timeout
					if stun == false:
						$Playersprite.visible = false
						$run2.visible = true
						if Input.is_action_pressed("catch2"):
							punching = false
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							catcher()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return		
						if Input.is_action_pressed("drop2") and parrycooler == false:
							parrycooler = true	
							punching = false
							$run2.visible = false
							$Playersprite.visible = true
							whirl = false
							parade()
							await get_tree().create_timer(2.0).timeout
							speed_up = false
							return							
						if Input.is_action_pressed("jump2") and whirl == true:
							velocity.y += 300
						if Input.is_action_pressed("dash_left2") and whirl == true:
							velocity.y -= 1500
							$run2.visible = false
							$Playersprite.visible = true
								
						if Input.is_action_pressed("punch2") and whirl == true:
							punching = true
							if Input.is_action_pressed("move_left2"):
								whirling_left()
							if Input.is_action_pressed("move_right2"):
								whirling_right()
							else:
								whirling_up()
						if Input.is_action_pressed("move_down2"):
							stomp = true						
					await get_tree().create_timer(0.5).timeout	
					whirl = false
					$run2.visible = false
					$Playersprite.visible = true
					punching = false
	await get_tree().create_timer(2.5).timeout
	stomp = false	
	speed_up = false	


func counting(delta):
	if punching == true:
		count2 = 0.0
		count += delta
	if count >= 5.0:
		stunned()	
	if punching == false:
		count = 0.0
		count2 += delta
	if count2 >= 4.0:
		can_toss = true
		can_punch = true	
	if stun == true:
		stuntime += delta
	if stuntime >= 2.0:
		stun = false
		stunblei = false
		parrycooler = false
	if stun == false:
		stuntime = 0.0
	if parrycooler == true:
		parry_down += delta
	if parry_down >= 3.0:
		parrycooler = false
		parry_down = 0.0
	if dash == false:
		dash_cooler += delta
	if dash_cooler >= 3.0:
		dash = true
		dash_cooler = 0.0
	if dash == true:
		dash_cooler = 0.0
	if bump == true:
		bumptimer += delta
	if bumptimer >= 0.25:
		bump = false
		bumptimer = 0.0
		 		

func _on_catcher_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hand") and area.is_in_group("Team1") and area.punching == true and punching == true:
		var dir = area.global_position.direction_to(global_position)
		velocity = dir * 5000


func fire():
	if Input.is_action_pressed("move_down2"):
		p1 = true
	if Input.is_action_pressed("move_left2") and p1 == true: #P! R/L
		p1 = false
		p2 = true
	if Input.is_action_just_released("move_down2") and Input.is_action_pressed("move_left2") and p2 == true and can_punch == true:#P! R/L
		p2 = false
		p3 = true
		
		
func firing():
	if Input.is_action_pressed("punch2") and p3 == true and can_punch == true and stun == false:
		p3 = false
		can_punch = false
		can_toss = false
		count2 = 0.0
		angry()
		catcher()
		$kiai.visible = true
		var o = hadoken.instantiate()
		get_parent().add_child(o)
		o.global_position = $normalizer.global_position
		await get_tree().create_timer(1.0).timeout		
		$kiai.visible = false

				
func firecooler():		
	if p1 == true:
		await get_tree().create_timer(0.2).timeout		
		p1 = false
	if p2 == true:
		await get_tree().create_timer(0.2).timeout		
		p2 = false	
	if p3 == true:
		await get_tree().create_timer(0.2).timeout		
		p3 = false


func reset():
	stunblei = false
	whirl = false
	fast_fall = false
	stun = false
	punching = false
	dashed = false
	stomp = false
	can_punch = true
	dash = true
	parrycooler = false
	dash_cooler = 0.0
	stuntime = 0.0
	count = 0.0
	count2 = 0.0
	parry_down = 0.0
	tauntcooler = false
	parry_down = 0.0

func backfire():
	angry()
	catcher()
	$kiai.visible = true
	var o = hadoken.instantiate()
	get_parent().add_child(o)
	o.global_position = $normalizer.global_position
	await get_tree().create_timer(1.0).timeout		
	$kiai.visible = false	
