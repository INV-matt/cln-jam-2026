extends CharacterBody3D
class_name EnemyBullet

@export var SPEED = 1000
@export var LIFETIME: float = 10000

var dir: Vector3

func _ready() -> void:
  get_tree().create_timer(LIFETIME / 1000).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
  velocity = dir.normalized() * SPEED * delta
  move_and_slide()


func _on_hit(body: Node3D) -> void:
  if body.has_method("take_damage"):
    body.take_damage(100)
  queue_free()