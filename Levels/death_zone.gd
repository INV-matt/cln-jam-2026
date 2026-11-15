extends Area3D


func _ready() -> void:
  body_entered.connect(_on_entered)

func _on_entered(body: Node3D) -> void:
  if body.has_method("take_damage"):
    body.take_damage(1000)