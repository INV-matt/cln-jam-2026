extends Area3D

@export var level: BaseLevel
@export var Height: float = 20

func _ready() -> void:
  $Mesh.mesh.material.albedo_color = Color(0, 1, 0, 0.25)
  if !get_parent() is BaseLevel:
    printerr("ENDZONE not child of level. Quitting")
    return
  level = get_parent()

  $Coll.shape.height = Height
  $Coll.position.y = Height / 2
  $Mesh.mesh.height = Height
  $Mesh.position.y = Height / 2

  body_entered.connect(_on_entered)
  Signals.timer_timeout.connect(_on_timer_timeout)


func _on_entered(body: Node3D) -> void:
  if body is Player:
    # if level.enemyCount > 0: return # enemies remaining
    Signals.end_zone_entered.emit()

func _on_timer_timeout() -> void:
  $Mesh.mesh.material.albedo_color = Color(1, 0, 0, 0.25)
  #print("Changed Color")
