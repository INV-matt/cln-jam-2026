extends CanvasLayer

@export var btn_resume: Button
@export var btn_restart: Button
@export var btn_quit: Button

func _ready() -> void:
  btn_resume.pressed.connect(_on_resume_pressed)
  btn_restart.pressed.connect(_on_restart_pressed)
  btn_quit.pressed.connect(_on_quit_pressed)
  hide()

func _on_resume_pressed() -> void:
  Signals.level_resume.emit()
  hide()

func _on_restart_pressed() -> void:
  Signals.level_restart.emit()
  hide()

func _on_quit_pressed() -> void:
  Signals.open_level_selector.emit()
  hide()