extends StaticBody2D


var magnet_color = Color.aquamarine

# delovanje magneta

var magnet_on = true

var x_to_magnet : float
var y_to_magnet : float

var direction_to_magnet :float  	# atan2(y_to_magnet, x_to_magnet) ... kot od telesa do magneta (glede na x os) ... radiani
var distance_to_magnet :float  	# diagonala od telesa do magneta ... c2 = a2 + b2 ... var c = sqrt ((a * a) + (b * b))

var gravity_velocity :float  	# hitrost glede na distanco od magneta ...gravitacijski pospešek
const gravity_force : float = 50000.0 	# sila gravitacije

var velocity = Vector2()
var def_particle_speed : float = 0.5

func _ready() -> void:

	name = "Magnet"
#	add_to_group("magnets")

	$Sprite.modulate = magnet_color
	$part_Blackhole.emitting = true	# v areni določim tist, ki emitajo
	$AnimationPlayer.play("intro")

	$MagnetTajm.start()

func _physics_process(delta: float) -> void:

	if magnet_on == true:

		var body_pod_vplivom = $ForceField.get_overlapping_bodies()

		for body in body_pod_vplivom:

	#		if body != self:	# če bodi ni magnet sam
			if body.is_in_group ("players"):

				# premaknjeno v Global
#				x_to_magnet = global_position.x - body.global_position.x
#				y_to_magnet = global_position.y - body.global_position.y
#				direction_to_magnet = atan2(y_to_magnet, x_to_magnet)
#				distance_to_magnet = sqrt ((x_to_magnet * x_to_magnet) + (y_to_magnet * y_to_magnet))

				direction_to_magnet = Global.get_direction_to(body.global_position, global_position)
				distance_to_magnet = Global.get_distance_to(body.global_position, global_position)

				gravity_velocity = gravity_force / (distance_to_magnet * distance_to_magnet) #

				body.velocity += Vector2(gravity_velocity, 0).rotated(direction_to_magnet)

#				body.bounce_controler = 0.2
#				body.slajdej = true

func _on_ForceField_body_entered(body: Node) -> void:
	print ("VSTOP")
	pass

func _on_MagnetTajm_timeout() -> void:

	if magnet_on == true:
		magnet_on = false
		$part_Blackhole.emitting = false
		$part_Blackhole.speed_scale = 1.5
		$AnimationPlayer.play("outro")
	elif magnet_on == false:
		magnet_on = true
		$part_Blackhole.emitting = true
		$part_Blackhole.speed_scale = def_particle_speed
		$AnimationPlayer.play("intro")
	$MagnetTajm.start()
	pass # Replace with function body.


func pause_me():
	set_physics_process(false)
	$part_Blackhole.speed_scale = 0
	$MagnetTajm.set_paused(true)
	$AnimationPlayer.stop(false)


func unpause_me():
	set_physics_process(true)
	$part_Blackhole.speed_scale = def_particle_speed
	$MagnetTajm.set_paused(false)
	$AnimationPlayer.play()

