extends Enemy
class_name ShootingEnemy


@export_custom(PROPERTY_HINT_NONE, "suffix:deg/s") var ROT_SPEED: float = 30
@export var DETECTION_DIST: float = 20.
@export var DAMAGE: float = 100

@export var BulletTrail: PackedScene
@export var TrailGrad: GradientTexture2D
@onready var BulletScene = preload("res://Enemy/enemy_bullet.tscn")

# var state: State = State.IDLE
var target: Node3D
var rc: RayCast3D
var gun_container: Node3D
var timer: Timer

var initial_y

func _ready() -> void:
  (%PlayerDetectionArea as Area3D).body_entered.connect(_on_body_entered_detection_area)
  (%PlayerDetectionArea as Area3D).body_exited.connect(_on_body_exited_detection_area)
  timer = ($ShootingTimer as Timer)
  timer.timeout.connect(_on_shoot_timeout)
  rc = %GunRC
  rc.target_position = Vector3.FORWARD * DETECTION_DIST
  initial_y = rc.position.y
  gun_container = %GunContainer


func _process(delta: float) -> void:
  match state:
    State.IDLE: _handle_idle(delta)
    State.FOLLOWING: _handle_following(delta)


func _handle_idle(delta: float) -> void:
  $WorldModel/CSGMesh3D.material.albedo_color = Color(1, 0, 0, 1) # FOR DEBUGGING

func _handle_following(delta: float) -> void:
  $WorldModel/CSGMesh3D.material.albedo_color = Color(0, 1, 0, 1) # FOR DEBUGGING
  var dir = (target.global_position - global_position).normalized()
  var target_yaw = atan2(dir.x, dir.z)
  %TurretHeadYawPivot.global_rotation.y = rotate_toward(%TurretHeadYawPivot.global_rotation.y, target_yaw, ROT_SPEED * delta)

  var horizontal_distance = Vector2(dir.x, dir.z).length()
  var target_pitch = - atan2(dir.y, horizontal_distance)
  # target_pitch = clampf(target_pitch, deg_to_rad(-30), deg_to_rad(70))
  %TurretHeadPitchPivot.rotation.x = rotate_toward(%TurretHeadPitchPivot.rotation.x, target_pitch, ROT_SPEED * delta)


func _on_body_entered_detection_area(body: Node3D) -> void:
  if body is Player:
    state = State.FOLLOWING
    target = body
    timer.start()

func _on_body_exited_detection_area(body: Node3D) -> void:
  if body is Player:
    state = State.IDLE
    timer.stop()


func _on_shoot_timeout() -> void:
  if state == State.DESTROYED: return

  if rc.is_colliding() && rc.get_collider() is Player:
    var bullet: EnemyBullet = BulletScene.instantiate()
    bullet.position = gun_container.global_position
    bullet.transform.basis = gun_container.global_transform.basis
    bullet.dir = - gun_container.global_basis.z
    get_parent().add_child(bullet)
    $AnimationPlayer.play("Shoot")
    $AnimationPlayer.seek(0)

func take_damage(_dmg: float) -> void:
  if state == State.DESTROYED: return

  state = State.DESTROYED
  Signals.enemy_died.emit()
  $AnimationPlayer.play("Destroyed")
  $AnimationPlayer.seek(0)
  (%ExplosionParticles as GPUParticles3D).restart()
  (%ContinuosParticles as GPUParticles3D).emitting = true
  timer.timeout.disconnect(_on_shoot_timeout)
