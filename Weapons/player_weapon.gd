extends Node3D
class_name PlayerWeapon

@export var model: Node3D
@export var muzzle: Marker3D
@export var animPlayer: AnimationPlayer
@export var audioPlayer: AudioStreamPlayer3D
@export var weaponRC: RayCast3D

@export_group("Stats")
@export var Damage: float = 100
@export var InitialBullets: int = 1
# @export var ReserveMags: int = 0
@export var FireRate: float = 1
@export var CanShoot: bool = true
@export var AutoFire: bool = false

@onready var TracerScene: PackedScene = preload("res://Weapons/bullet_tracer.tscn")

var remainingBullets: int = InitialBullets:
  set(val):
    remainingBullets = val
    Signals.bullets_changed.emit(remainingBullets)

# var remainingMags: int = ReserveMags:
#   set(val):
#     remainingMags = val
#     Signals.mags_changed.emit(remainingMags)


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

  # if event.is_action_pressed("reload"): _on_reload_pressed()

var lastShotTime: float = -1
func _on_trigger_pressed() -> void:
  var currTime: float = Time.get_ticks_msec()
  if currTime - lastShotTime > 1000 / FireRate && remainingBullets > 0:
    lastShotTime = currTime
    shoot()
  

func _on_trigger_released() -> void: pass

#func can_reload() -> bool: return remainingBullets < InitialBullets

# func _on_reload_pressed() -> void:
#   if animPlayer.current_animation == "Reload": return
#   if !can_reload(): return

#   playAnim("Reload")
#   queueAnim("RESET")

#   await animPlayer.animation_finished
  
#   remainingMags -= 1
#   remainingBullets = InitialBullets


func shoot() -> void:
  playAnim("Shoot")
  queueAnim("RESET")

  weaponRC.target_position = Vector3(0, 0, -1000)
  weaponRC.force_raycast_update()

  var target := weaponRC.global_transform * weaponRC.target_position

  if weaponRC.is_colliding():
    var obj := weaponRC.get_collider()
    target = weaponRC.get_collision_point()


    if obj.has_method("take_damage"): obj.take_damage(Damage)
  showTracers(target)
  remainingBullets -= 1

    
func playAnim(anim: String) -> void:
  animPlayer.clear_queue()
  animPlayer.seek(0)
  animPlayer.play(anim)

func queueAnim(anim: String) -> void: animPlayer.queue(anim)


func showTracers(target: Vector3) -> void:
  if muzzle == null: return
  var bulletDir = (target - muzzle.global_position).normalized()
  var startPos = muzzle.global_position + .2 * bulletDir

  var tracer: BulletTracer = TracerScene.instantiate()
  get_parent().add_sibling(tracer)
  tracer.global_position = startPos
  tracer.TargetPos = target
  tracer.look_at(target)
