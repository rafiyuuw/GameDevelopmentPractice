extends Area2D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Cek apakah yang menabrak adalah player dan BELUM punya kunci
	if body.is_in_group("player") and not body.has_key:
		if body.has_method("collect_key"):
			body.collect_key()
			# Sembunyikan visual kunci & matikan deteksi
			visible = false
			set_deferred("monitoring", false)


# Dipanggil saat Player mati/respawn agar kunci muncul lagi di map
func reset_key() -> void:
	visible = true
	set_deferred("monitoring", true)
