extends StaticBody2D

var exploder_score = 100

var exploder_color_1 = Color.purple
var exploder_color_2 = Color.pink
var exploder_color_3 = Color.white

var def_particle_speed = 5

func _ready() -> void:

#	name = "Exploder"
#	add_to_group("exploders")

	$Sprite.modulate = exploder_color_1


func _on_ForceField_body_entered(body: Node) -> void:

	if body.is_in_group ("bullets"):

		if $Sprite.modulate == exploder_color_1:
			$Sprite.modulate = exploder_color_2
		elif $Sprite.modulate == exploder_color_2:
			$Sprite.modulate = exploder_color_3
		elif $Sprite.modulate == exploder_color_3:
			$part_Blowup.modulate = exploder_color_3
			$AnimationPlayer.play("outro")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	queue_free()

func pause_me():
	$part_Blowup.speed_scale = 0
	$AnimationPlayer.stop(false)


func unpause_me():
	$part_Blowup.speed_scale = def_particle_speed
	$AnimationPlayer.play()

