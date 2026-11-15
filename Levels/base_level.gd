extends Node3D
class_name BaseLevel

@export var PlayerSpawnPosition: Marker3D
@export var EndLevelZone: Area3D

@export_custom(PROPERTY_HINT_NONE, "suffix:s") var Deadline: int
@export var playerGun: PackedScene
@export var InitialBullets: int = 0
@export var enemyCount: int = 0

var enemyList: Array[Enemy]
var playerHasGun: bool = false

var showBullets: bool = true
var showTime: bool = true
var showEnemies: bool = false

 
func initialize() -> void:
  if playerGun == null:
    playerHasGun = false
    showBullets = false
  if Deadline <= 0: showTime = false
  
  for n in %EnemyContainer.get_children():
    if n is Enemy:
      if n.state != n.State.DESTROYED:
        enemyList.push_back(n)
        enemyCount += 1
        showEnemies = true
