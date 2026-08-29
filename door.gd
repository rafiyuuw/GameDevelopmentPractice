extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("Closed")
		
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if "has_key" in body:
		if body.has_key:
			print("Kunci cocok! Pintu terbuka.")
			if animated_sprite:
				animated_sprite.play("Open")
			
			await get_tree().create_timer(0.3).timeout
			get_tree().call_deferred("reload_current_scene")
		else:
			print("Pintu terkunci!")
			# 1. Bikin kamera bergetar lebih kencang (intensitas 12.0)
			if body.has_method("shake_camera"):
				body.shake_camera(12.0, 0.25)
			
			# 2. Dorong player sedikit ke belakang biar terasa benturannya
			if body is CharacterBody2D:
				body.velocity.x = -body.velocity.x * 0.5
