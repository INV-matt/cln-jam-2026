extends Node3D
class_name PlayerKnife

@export var model: Node3D
@export var animPlayer: AnimationPlayer
@export var audioPlayer: AudioStreamPlayer3D
@export var knifeRC: RayCast3D

@export_group("Stats")
@export var Damage: float = 100
@export var FireRate: float = .5
@export var CanShoot: bool = true
@export var AutoFire: bool = true
@export var HitDst: float = 3


func _ready() -> void:
  for n in find_children("*", "MeshInstance3D"): (n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

var trigger_pressed := false:
  set(v):
    if trigger_pressed != v:
      trigger_pressed = v
      if trigger_pressed: _on_trigger_pressed()
      else: _on_trigger_released()

func _unhandled_input(event: InputEvent) -> void:
  if !is_inside_tree(): return
  if CanShoot && event.is_action_pressed("shoot"): trigger_pressed = true
  elif event.is_action_released("shoot"): trigger_pressed = false

var lastShotTime: float = -1
func _on_trigger_pressed() -> void:
  var currTime: float = Time.get_ticks_msec()
  if currTime - lastShotTime > 1000 / FireRate:
    lastShotTime = currTime
    stab()

func _on_trigger_released() -> void: pass

func stab() -> void:
  playAnim("Stab")
  queueAnim("RESET")

  knifeRC.target_position = Vector3(0, 0, -HitDst)
  knifeRC.force_raycast_update()

  if knifeRC.is_colliding():
    var obj := knifeRC.get_collider()
    if obj.has_method("take_damage"): obj.take_damage(Damage)

func playAnim(anim: String) -> void:
  animPlayer.clear_queue()
  animPlayer.seek(0)
  animPlayer.play(anim)

func queueAnim(anim: String) -> void: animPlayer.queue(anim)
