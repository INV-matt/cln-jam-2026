extends CanvasLayer


@onready var btn_lvl_scene = preload("res://HUD/Components/btn_level.tscn")

func _ready() -> void:
  Signals.level_completed.connect(_on_level_completed)
  Signals.open_level_selector.connect(_on_open)
  Signals.level_start.connect(func(_x): hide())
  Signals.level_start_next.connect(hide)
  hide()

func initialize(levels: int) -> void:
  for i in range(levels):
    var btn = btn_lvl_scene.instantiate()
    btn.ID = i
    %LevelButtons.add_child(btn)


func _on_level_completed() -> void:
  show()

func _on_open() -> void:
  show()
