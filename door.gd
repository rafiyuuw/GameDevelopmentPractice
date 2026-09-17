extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("Closed")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Cek apakah player punya kunci
	if not body.has_key:
		print("Pintu terkunci!")
		body.velocity = Vector2.ZERO
		if body.has_method("shake_camera"):
			body.shake_camera(12.0, 0.25)
		return

	# Jika punya kunci:
	print("Pintu terbuka!")
	if animated_sprite:
		animated_sprite.play("Open")
	
	# Hapus status kunci dari player
	body.has_key = false
	if body.has_method("update_animation"):
		body.update_animation(0.0)
	
	await get_tree().create_timer(0.3).timeout

	# --- LOGIKA TELEPORT & CHECKPOINT SESUAI ALUR BARU ---
	
	# 1. ENTRANCE LEVEL 2 (Door 3)
	if name == "Door3":
		var door1 = get_tree().current_scene.get_node_or_null("Door1")
		if door1:
			# Teleport ke Door 1
			body.global_position = door1.global_position
			# PENTING: Set checkpoint ke Door 1 saat masuk Level 2!
			if "current_checkpoint" in body:
				body.current_checkpoint = door1.global_position

	# 2. CHECKPOINT LEVEL 2 (Door 1)
	elif name == "Door1":
		# Jika Door 1 dilewati/diakses dari dalam Level 2,
		# pastikan checkpoint player diset di posisi Door 1
		if "current_checkpoint" in body:
			body.current_checkpoint = global_position

	# 3. EXIT LEVEL 2 (Door 2)
	elif name == "Door2":
		# Pindah kembali ke Spawn Awal
		if "spawn_position" in body:
			body.global_position = body.spawn_position
			# Reset checkpoint kembali ke Spawn Awal
			if "current_checkpoint" in body:
				body.current_checkpoint = body.spawn_position
