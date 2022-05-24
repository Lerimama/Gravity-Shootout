extends Area2D


var misile_bonus = GameProfiles.level_values["energy_bonus"]
var bonus_color = GameProfiles.level_values["bonus_e_color"]

func _ready() -> void:

#	name = "BonusE"
#	add_to_group("bonusi")

	modulate = bonus_color

	$AnimationPlayer.play("intro")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:

	if anim_name == "intro":
		$AnimationPlayer.play("on_stage")
#		$BonusTajm.start()
	if anim_name == "outro":
		queue_free()
	if anim_name == "picked":
		queue_free()

func _on_BonusTajm_timeout() -> void:
	$AnimationPlayer.play("outro")

func _on_BonusE_body_entered(body: Node) -> void:

	if body.is_in_group("players"):
		$BonusTajm.stop()	# da se animacije za off ne križajo
		$AnimationPlayer.play("picked")

func pause_me():
	$AnimationPlayer.stop(false)

func unpause_me():
	$AnimationPlayer.play()
