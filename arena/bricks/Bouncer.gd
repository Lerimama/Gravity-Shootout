extends StaticBody2D

var bouncer_color = Color.violet
var bouncer_strenght = 2

func _ready() -> void:

#	name = "Bouncer"
#	add_to_group("bouncers")

	$Sprite.modulate = bouncer_color


func _on_ForceField_body_entered(body: Node) -> void:

	if body.is_in_group ("players"):
		$Sprite.modulate = Color.white
		body.bounce_size = bouncer_strenght
		body.motion_enabled = false
		yield(get_tree().create_timer(5), "timeout")
		body.motion_enabled = true

func _on_ForceField_body_exited(body: Node) -> void:

	if body.is_in_group ("players"):
		$Sprite.modulate = bouncer_color
		body.bounce_size = body.def_bounce_size


func _on_KontroleTajm_timeout(body) -> void:
	body.modulate = body.player_color

func pause_me():
	$KontroleTajm.set_paused(true)

func unpause_me():
	$KontroleTajm.set_paused(false)
