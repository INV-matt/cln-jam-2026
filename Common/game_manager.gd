extends Node
class_name GameManager

@onready var Hud: HUD = %HUD
@onready var PauseMenu: CanvasLayer = %PAUSE_MENU
@onready var DeathMenu: CanvasLayer = %DEATH_MENU

var enemiesRemaining := 0:
  set(val):
    enemiesRemaining = val
    Hud.setEnemies(enemiesRemaining)

var isTimeRunning := false
var timeRemaining := 0.: # time remaining in seconds
  set(val):
    timeRemaining = val
    Hud.setTime(timeRemaining)

func startTimer(time: int) -> void:
  timeRemaining = time
  isTimeRunning = true

var bulletsRemaining := 0:
  set(val):
    bulletsRemaining = val
    Hud.setBullets(bulletsRemaining)

var isInLevel := false

func _ready() -> void:
  Globals.GM = self
  Signals.level_resume.connect(_on_level_resume)
  Signals.level_completed.connect(_on_level_completed)
  Signals.end_zone_entered.connect(_on_end_zone_entered)

  Signals.enemy_died.connect(_on_enemy_died)
  Signals.player_died.connect(_on_player_dead)

func _process(delta: float) -> void:
  if isTimeRunning:
    timeRemaining -= delta
    if timeRemaining <= 0: _on_time_timeout()


func _on_enemy_died() -> void:
  enemiesRemaining -= 1


func _on_level_completed() -> void:
  Globals.PL.handle_gun_end_lvl()
  # Signals.level_start_next.emit()

func _on_end_zone_entered() -> void:
  if enemiesRemaining > 0: return # enemies remaining
  if timeRemaining <= 0: return
  Signals.level_completed.emit()

func _on_player_dead() -> void:
  Globals.PL.handle_gun_end_lvl()
  get_tree().paused = true
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  DeathMenu.show()
  Hud.hide()


var has_timeout_occurred = false
func _on_time_timeout() -> void:
  if has_timeout_occurred: return
  has_timeout_occurred = true
  Signals.timer_timeout.emit()

func _on_level_resume() -> void:
  if !isInLevel: return
  get_tree().paused = false
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  isTimeRunning = true
  Hud.show()
  

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_cancel"):
    if %LEVEL_SELECTOR.visible:
      %MAIN_MENU.show()
      return
    PauseMenu.show()
    Hud.hide()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().paused = true
    isTimeRunning = false