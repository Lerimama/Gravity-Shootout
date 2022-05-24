extends RigidBody2D

func hit():
	$Sprite.modulate = Color.blue
	$Blink_time.start()
	


func _on_Blink_time_timeout() -> void:
	print("hit")
	$Sprite.modulate = Color.white
	pass # Replace with function body.
