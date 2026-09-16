extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var spawn_position: Vector2 = global_position # Simpan posisi spawn awal

var is_dead: bool = false
var has_key: bool = false
var is_invincible: bool = false # Variabel penanda kebal/blinking


func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Jika sedang blinking/invincible, kunci gerakan
	if is_invincible:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Gravitasi normal
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Lompat
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Pergerakan Kiri/Kanan
	var direction := Input.get_axis("moveleft", "moveright")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction)
	
	# PASTI KAN move_and_slide() DIPANGGIL DULUAN
	move_and_slide()
	
	# Deteksi tabrakan DIPERIKSA SETELAH move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider:
			# Cek jika collider ada di group "enemy" ATAU nama nodenya mengandung kata "Enemy" / "enemy" / "obsta"
			if collider.is_in_group("enemy") or "enemy" in collider.name.to_lower() or collider.name == "obsta":
				die()
				break # Keluar dari loop setelah mati
			elif collider.name == "JumpPad":
				velocity.y = -500.0
				var pad_sprite = collider.get_node_or_null("AnimatedSprite2D")
				if pad_sprite:
					pad_sprite.play("bounce")


# Dipanggil oleh node Key saat diambil
func collect_key() -> void:
	has_key = true
	print("Kunci diambil!")


func die() -> void:
	# Abaikan jika player sudah mati atau dalam masa kebal
	if is_dead or is_invincible:
		return
	
	is_dead = true
	shake_camera(8.0, 0.25)
	
	await get_tree().create_timer(0.25).timeout
	respawn()


func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	is_dead = false
	has_key = false
	
	# Paksa animasi kembali ke diam (default) saat respawn
	update_animation(0.0)
	
	# Kembalikan node kunci di level agar muncul lagi
	var key_node = get_tree().current_scene.get_node_or_null("Key")
	if key_node and key_node.has_method("reset_key"):
		key_node.reset_key()
	elif key_node:
		key_node.visible = true
		key_node.set_deferred("monitoring", true)

	# Mulai efek melayang & kedip-kedip selama 1.5 detik
	start_spawn_blinking(1)


func start_spawn_blinking(duration: float) -> void:
	is_invincible = true
	
	# Bikin Tween untuk animasi kedip transparansi sprite
	var tween = create_tween().set_loops()
	tween.tween_property(animated_sprite, "modulate:a", 0.2, 0.1)
	tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.1)
	
	# Tunggu sesuai durasi (misal 1.5 detik)
	await get_tree().create_timer(duration).timeout
	
	# Kembalikan tampilan & kontrol ke normal
	tween.kill()
	animated_sprite.modulate.a = 1.0
	is_invincible = false


# Kamera Shake
func shake_camera(intensity: float = 5.0, duration: float = 0.2) -> void:
	if not camera:
		return
		
	var tween = create_tween()
	for i in range(6):
		var random_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "offset", random_offset, duration / 6.0)
	
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)


func update_animation(direction: float) -> void:
	if has_key:
		if direction < 0:
			if animated_sprite.sprite_frames.has_animation("walk_left_with_key"):
				animated_sprite.play("walk_left_with_key")
			else:
				animated_sprite.play("walk_left")
		elif direction > 0:
			if animated_sprite.sprite_frames.has_animation("walk_right_with_key"):
				animated_sprite.play("walk_right_with_key")
			else:
				animated_sprite.play("walk_right")
		else:
			if animated_sprite.sprite_frames.has_animation("default_with_key"):
				animated_sprite.play("default_with_key")
			else:
				animated_sprite.play("default")
	else:
		if direction < 0:
			animated_sprite.play("walk_left")
		elif direction > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("default")
