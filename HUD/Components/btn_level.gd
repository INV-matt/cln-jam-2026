extends Button

@export var ID: int

func _ready() -> void:
  text = "Level %d" % ID

func _on_pressed() -> void:
  #print("Level %d chosen" % ID)
  Signals.level_start.emit(ID)