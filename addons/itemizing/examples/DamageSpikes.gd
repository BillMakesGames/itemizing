extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(damage)


func damage(body:Node3D):
	if body.has_method('adjust_health'): body.adjust_health(-10)