extends Node3D

# SHOULD ONLY HANDLE COORDINATING LEVEL LOADING AND PLAYER SPAWNING, 
# NO MAJOR MECHANICS, LIKE PLAYER OR ENEMY DEATH OR LEVEL TIMES


@export var LevelList: Array[PackedScene]

var CurrentLevelId: int = 0
var CurrentLevel: BaseLevel

@onready var hud: HUD = %HUD
@onready var levelSelector: CanvasLayer = %LEVEL_SELECTOR
@onready var GM: GameManager = %GAME_MANAGER
@onready var mainMenu: CanvasLayer = %MAIN_MENU

func _ready() -> void:
  get_tree().paused = false

  Signals.level_start.connect(_on_level_start)
  Signals.level_restart.connect(func(): _on_level_start(CurrentLevelId))
  Signals.level_start_next.connect(func(): _on_level_start(CurrentLevelId + 1))
  Signals.level_completed.connect(_on_level_completed)

  levelSelector.initialize(LevelList.size())

  mainMenu.show()

  #Signals.level_start.emit(3) # TODO


func _on_level_start(id: int) -> void:
  if id >= LevelList.size(): return


  var t = LevelList[id].instantiate()
  if !t is BaseLevel:
    printerr("Level %d is not BaseLevel" % id)
    return

  get_tree().paused = false
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  GM.isInLevel = true
 
  print("Initializing level %d" % id)
  if CurrentLevel: CurrentLevel.queue_free()
  CurrentLevel = t as BaseLevel
  CurrentLevelId = id
  CurrentLevel.initialize()
  GM.enemiesRemaining = CurrentLevel.enemyCount

  if (CurrentLevel.showTime): GM.startTimer(CurrentLevel.Deadline)
  GM.bulletsRemaining = CurrentLevel.InitialBullets

  add_child(t)

  # if Globals.PL == null: Globals.PL = preload("res://Player/player.tscn").instantiate()
  if Globals.PL: Globals.PL.queue_free()
  Globals.PL = preload("res://Player/player.tscn").instantiate()

  $PlayerContainer.add_child(Globals.PL)
  Globals.PL.position = CurrentLevel.PlayerSpawnPosition.position
  Globals.PL.rotation = CurrentLevel.PlayerSpawnPosition.rotation
  Globals.PL.handle_knife_start_lvl() # Knife should be set up before gun
  Globals.PL.handle_gun_start_lvl(CurrentLevel.playerGun, CurrentLevel.InitialBullets)
  print("MAIN: handle_gun_start_lvl")

  hud.show()
  hud.showEnemies(CurrentLevel.showEnemies)
  hud.showTime(CurrentLevel.showTime)
  hud.showBullets(CurrentLevel.showBullets)


func _on_level_completed() -> void:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  GM.isTimeRunning = false
  hud.hide()

  GM.isInLevel = false

  print("Clearing current level")
  if CurrentLevel: CurrentLevel.queue_free()
  if Globals.PL: Globals.PL.queue_free()
