extends Node3D

@export var BulletsGiven: int = 2

@export_group("MeshBob Settings")
@export var period: float = 4
@export var amplitude: float = 0.1
var phase = 0

var active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  %PickUpArea.body_entered.connect(_on_entered)
  phase = randf() * TAU

# Called every frame. 'delta' is the elapsed time since the previous frame.
var t := 0.
func _process(delta: float) -> void:
  %Mesh.position.y = amplitude * (1 + sin(t * TAU / period + phase))
  t += delta

func _on_entered(body: Node3D) -> void:
  if !active: return
  if body.has_method("pickup_bullet"):
    if body.pickup_bullet(BulletsGiven):
      active = false
      queue_free()
