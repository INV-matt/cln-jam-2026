extends CharacterBody3D
class_name Player


@export_group("Jump Settings")
@export var JUMP_VELOCITY: float = 5.1 # v^2 = 2gh -> 5
@export var AUTO_BHOP: bool = true
@export var JUMP_GRACE_FRAMES: int = 6
@export var COYOTE_FRAMES: int = 6

@export_group("Ground Movement Settings")
@export var WALK_SPEED: float = 10.
@export var SPRINT_MULT: float = 1.5
@export var GROUND_ACCEL: float = 14.
@export var GROUND_DECEL: float = 10.
@export var GROUND_FRICTION: float = 6.
@export var MAX_STEP_HEIGHT: float = .5

@export_group("Air Movement Settings")
@export var AIR_CAP: float = .85
@export var AIR_ACCEL: float = 800.
@export var AIR_MOVE_SPEED: float = 500.

@export_group("Other Settings")
@export var MOUSE_SENSITIVITY: float = .005
@export var GUN_POSITION: Vector3
@export var GUN_ROTATION: Vector3
@export var GUN_SCALE: Vector3
@export var KNIFE_POSITION: Vector3
@export var KNIFE_ROTATION: Vector3
@export var KNIFE_SCALE: Vector3
@export var KNIFE: PlayerKnife

@onready var playerGun = preload("res://Weapons/player_weapon.tscn")


var inputDir := Vector2.ZERO
var targetDir := Vector3.ZERO
var gravity := 0.
var snapped_to_stair_last_frame := false
var last_frame_on_floor := -INF
var last_jump_pressed := -INF

var selected_weapon = 0: # selected_weapon += 1 switches between them
  set(val):
    if selected_weapon % 2 == val % 2: return
    if !currentGun: return

    selected_weapon = val % 2
    
    currentGun.CanShoot = false
    currentGun.hide()
    KNIFE.CanShoot = false
    KNIFE.hide()

    if selected_weapon == 0:
      KNIFE.CanShoot = true
      KNIFE.show()
    else:
      currentGun.CanShoot = true
      currentGun.show()


func _ready() -> void:
  gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

  for child in %WorldModel.find_children("*", "VisualInstance3D"): # make 3d model not visible from player camera
    child.set_layer_mask_value(1, false)
    child.set_layer_mask_value(2, true)


func _process(delta: float) -> void:
  inputDir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward").normalized()
  targetDir = self.global_transform.basis * Vector3(inputDir.x, 0, -inputDir.y)


func _physics_process(delta: float) -> void:
  if is_on_floor():
    last_frame_on_floor = Engine.get_physics_frames()

  if is_on_floor() || snapped_to_stair_last_frame:
    if (Input.is_action_just_pressed("jump") || (AUTO_BHOP && Input.is_action_pressed("jump")) \
    || Engine.get_physics_frames() - last_jump_pressed <= JUMP_GRACE_FRAMES):
      _handle_jump()

    _handle_floor_movement(delta)
  else:
    if Input.is_action_just_pressed("jump") || (AUTO_BHOP && Input.is_action_pressed("jump")):
      last_jump_pressed = Engine.get_physics_frames()
      if Engine.get_physics_frames() - last_frame_on_floor <= COYOTE_FRAMES:
        _handle_jump()

    _handle_air_movement(delta)

  move_and_slide()

 
func _unhandled_input(event: InputEvent) -> void:
  # if event is InputEventMouseButton: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  # elif event.is_action_pressed("ui_cancel"): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  if event.is_action_pressed("toggle_weapon"): selected_weapon += 1
  elif event.is_action_pressed("select_gun"): selected_weapon = 1
  elif event.is_action_pressed("select_knife"): selected_weapon = 0

  if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
    if event is InputEventMouseMotion:
      rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
      %PlayerCamera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
      %PlayerCamera.rotation.x = clamp(%PlayerCamera.rotation.x, -PI / 2, PI / 2)
    if event is InputEventMouseButton:
      if (event.button_index == MOUSE_BUTTON_WHEEL_UP || event.button_index == MOUSE_BUTTON_WHEEL_DOWN) && event.pressed:
        selected_weapon += 1
    

### CUSTOM FUNCTIONS

func _handle_floor_movement(delta: float) -> void:
  var cur_speed_target_dir: float = velocity.dot(targetDir)
  var speed_to_cap = _get_movement_speed() - cur_speed_target_dir # this enables air strafing

  if speed_to_cap > 0:
    var accel_speed = GROUND_ACCEL * _get_movement_speed() * delta
    accel_speed = min(accel_speed, speed_to_cap)
    velocity += accel_speed * targetDir

  var friction_control = max(GROUND_DECEL, velocity.length())
  var friction_drop = friction_control * GROUND_FRICTION * delta
  var speed_after_friction_ratio = max(velocity.length() - friction_drop, 0.0)
  if velocity.length() > 0: speed_after_friction_ratio /= velocity.length()
  velocity *= speed_after_friction_ratio


func _handle_air_movement(delta: float) -> void:
  velocity.y -= gravity * delta

  # cs:s air movement
  var cur_speed_target_dir: float = velocity.dot(targetDir)
  var cap_speed = min((AIR_MOVE_SPEED * targetDir).length(), AIR_CAP)
  var speed_to_cap = cap_speed - cur_speed_target_dir # this enables air strafing

  if speed_to_cap > 0:
    var accel_speed = AIR_ACCEL * AIR_MOVE_SPEED * delta
    accel_speed = min(accel_speed, speed_to_cap)
    velocity += accel_speed * targetDir

  if is_on_wall():
    var wall_norm = get_wall_normal()
    var is_vert = abs(wall_norm.dot(Vector3.UP)) < 0.1

    if _is_surface_too_steep(wall_norm) && !is_vert:
      motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
    else:
      motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
    
    _clip_velocity(wall_norm, 1, delta)


func _handle_jump() -> void:
  velocity.y = JUMP_VELOCITY

func _get_movement_speed() -> float:
  if Input.is_action_pressed("sprint"): return WALK_SPEED * SPRINT_MULT
  
  return WALK_SPEED

func _is_surface_too_steep(normal: Vector3) -> bool:
  return normal.angle_to(Vector3.UP) > floor_max_angle

func _body_test_motion(from: Transform3D, motion: Vector3, result: PhysicsTestMotionResult3D = null) -> bool:
  if !result: result = PhysicsTestMotionResult3D.new()
  
  var params = PhysicsTestMotionParameters3D.new()
  params.from = from
  params.motion = motion

  return PhysicsServer3D.body_test_motion(get_rid(), params, result)


func _clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
  var backoff := velocity.dot(normal) * overbounce
  if backoff >= 0: return
  velocity -= normal * backoff

  var adjust = velocity.dot(normal) # double pass
  if adjust < 0.: velocity -= normal * adjust

func take_damage(damage: float) -> void:
  if damage > 0:
    Signals.player_died.emit()
    queue_free()

var currentGun: PlayerWeapon
func handle_gun_start_lvl(gun: PackedScene, bullets: int) -> void:
  if gun == null: return
  currentGun = gun.instantiate()
  %PlayerCamera.add_child(currentGun)
  currentGun.position = GUN_POSITION
  currentGun.rotation_degrees = GUN_ROTATION
  currentGun.scale = GUN_SCALE
  currentGun.weaponRC = %WeaponRC
  currentGun.InitialBullets = bullets
  currentGun.remainingBullets = bullets
  currentGun.show()

  print(currentGun.remainingBullets)
  
  selected_weapon = 1

func handle_gun_end_lvl() -> void:
  if currentGun: currentGun.queue_free()

func handle_knife_start_lvl() -> void:
  KNIFE.position = KNIFE_POSITION
  KNIFE.rotation_degrees = KNIFE_ROTATION
  KNIFE.scale = KNIFE_SCALE
  KNIFE.knifeRC = %WeaponRC
  KNIFE.show()

func handle_knife_end_lvl() -> void:
  pass

var _pickup_sound = preload("res://Weapons/Bullet_Pickup/Pickup_Bullet.wav")
func pickup_bullet(bullets: int) -> bool:
  if currentGun == null: return false
  currentGun.remainingBullets += bullets
  %AudioPlayer.stream = _pickup_sound
  $AudioPlayer.play()
  print(currentGun.remainingBullets)
  return true
