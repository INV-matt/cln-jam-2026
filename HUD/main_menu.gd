extends CanvasLayer


@export var btn_Start: Button
@export var btn_Quit: Button


func _ready() -> void:
  btn_Start.pressed.connect(_on_start_pressed)
  btn_Quit.pressed.connect(get_tree().quit)


func _on_start_pressed() -> void:
  Signals.open_level_selector.emit()
  hide()
