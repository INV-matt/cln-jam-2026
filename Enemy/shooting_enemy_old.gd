extends Enemy
class_name ShootingEnemy_OLD


@export var ROTATION_SPEED: float = 0.01
@export var DETECTION_RADIUS: float = 30.

@export var TracerGradient: GradientTexture2D
@export var TracerScene: PackedScene

@export var Weapon: WeaponResource
@export var rc: RayCast3D

var pl: Node3D
var target: Vector3 = Vector3.FORWARD
var timer: Timer
var isAiming := false
var player_visible := false


var currentMuzzle: Node3D = null

const RC_MAX_DIST = 1000

func _ready() -> void:
  # %PlayerDetectionArea.body_entered.connect(_on_entered)
  # %PlayerDetectionArea.body_exited.connect(_on_exited)
  timer = (%ShootingTimer as Timer)
  timer.timeout.connect(_on_timeout_aim)

  var gun := Weapon.ViewModel.instantiate() as Node3D
  gun.position = Weapon.position
  gun.rotation_degrees = Weapon.rotation
  gun.scale = Weapon.scale
  %GunContainer.add_child(gun)


func _process(delta: float) -> void:
  print(global_position.distance_to(Globals.PL.global_position))
  if global_position.distance_to(Globals.PL.global_position) < DETECTION_RADIUS:
    rc.target_position = Vector3.FORWARD * DETECTION_RADIUS
    
    if rc.is_colliding() && rc.get_collider() is Player:
      player_visible = true
      pl = rc.get_collider()
      target = rc.get_collision_point()
      
      if !isAiming:
        print("Player entered")
        isAiming = true
        timer.start()
    else:
      player_visible = false
    
    var dir = Globals.PL.global_position - global_position
    var angle = atan2(dir.z, dir.x)
    var b = basis.slerp(basis.rotated(Vector3.UP, angle), ROTATION_SPEED)
  
    self.basis = b
  
  else:
    timer.stop()
    isAiming = false


func _on_timeout_aim() -> void:
  if pl == null: return

  isAiming = false

  $WorldModel/CSGMesh3D.material.albedo_color = Color(1, 0, 0, 1)

  get_tree().create_timer(0.5).timeout.connect(_on_timeout_shoot)

func _on_timeout_shoot() -> void:
  $WorldModel/CSGMesh3D.material.albedo_color = Color(0, 1, 0, 1)

  #rc.target_position = target.normalized() * RC_MAX_DIST
  rc.target_position = Vector3(0, 0, -RC_MAX_DIST)

  var t = rc.global_transform * rc.target_position
  if rc.is_colliding():
    var obj := rc.get_collider()
    var norm := rc.get_collision_normal()
    var pt := rc.get_collision_point()
    t = pt

    if obj.has_method("take_damage"): obj.take_damage(Weapon.Damage)
  
  _show_tracers(t)

  isAiming = true
  

func _show_tracers(trg: Vector3) -> void:
  if currentMuzzle == null: return
  var bulletDir = (trg - currentMuzzle.global_position).normalized()
  var startPos = currentMuzzle.global_position + .2 * bulletDir

  if (trg - startPos).length() > 3.0: # dont show if too close to wall
    var tracer: BulletTracer = TracerScene.instantiate()
    tracer.setGradient(TracerGradient)
    get_parent().add_sibling(tracer)
    tracer.global_position = startPos
    tracer.TargetPos = trg
    tracer.look_at(trg)
