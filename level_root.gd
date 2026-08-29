extends Node2D

# Ubah $CanvasLayer/ColorRect menjadi $CanvasLayer/FadeOverlay
@onready var fade_overlay = $CanvasLayer/FadeOverlay

func _ready() -> void:
	if fade_overlay:
		fade_overlay.visible = true
		fade_overlay.color.a = 1.0
		
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color:a", 0.0, 1.0)
		
		await tween.finished
		fade_overlay.visible = false
