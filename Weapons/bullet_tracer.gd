extends Node3D
class_name BulletTracer

@export var TracerGradient: GradientTexture2D

@export var SPEED: float = 50. # m/s
@export var LIFETIME: float = 5000. # ms
@export var LENGTH: float = 0
@export var TargetPos := Vector3.ZERO


var start_pos: Vector3
var timer: Timer

func _ready() -> void:
  setGradient(TracerGradient)
  LENGTH = %TracerMesh.mesh.section_length * %TracerMesh.mesh.sections
  %TracerMesh.position.z = - LENGTH / 2
  get_tree().create_timer(LIFETIME / 1000).timeout.connect(queue_free)
  start_pos = global_position


func _process(delta: float) -> void:
  var dir = TargetPos - global_position
  var ds = dir.normalized() * SPEED * delta
  ds = ds.limit_length(dir.length())
  global_position += ds

  if (TargetPos - global_position).length() < LENGTH: queue_free()
  if (global_position - start_pos).length() > 50: queue_free()

func setGradient(gradient: GradientTexture2D) -> void:
  %TracerMesh.mesh.material.albedo_texture = gradient
  %TracerMesh.mesh.material.emission_texture = gradient
