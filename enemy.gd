extends CharacterBody2D

const SPEED = 50.0
var direction = 1

func _physics_process(_delta: float) -> void:
	velocity.x = direction * SPEED
	velocity.y = 0

	move_and_slide()

	# Cek kolesi setelah move_and_slide()
	if is_on_wall():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Jika yang ditabrak BUKAN Player, baru balik arah
			if collider and not collider.is_in_group("player") and collider.name != "Player":
				direction *= -1
				$AnimatedSprite2D.flip_h = (direction == -1)
				break
