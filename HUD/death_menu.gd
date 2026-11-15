extends CanvasLayer


@export var btn_restart: Button
@export var btn_quit: Button


func _ready() -> void:
  btn_restart.pressed.connect(_on_restart)
  btn_quit.pressed.connect(_on_quit)
  hide()


func _on_restart() -> void:
  Signals.level_restart.emit()
  hide()

func _on_quit() -> void:
  Signals.open_level_selector.emit()
  hide()
