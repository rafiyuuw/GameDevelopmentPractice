extends Area2D

func _ready() -> void:
	# Menggunakan self.body_entered agar dipastikan memanggil signal milik Area2D
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect_key"):
		body.collect_key()
		# Sembunyikan visual dan matikan area deteksi
		visible = false
		set_deferred("monitoring", false)


# Fungsi untuk memunculkan kunci kembali saat player respawn/mati
func reset_key() -> void:
	visible = true
	set_deferred("monitoring", true)
