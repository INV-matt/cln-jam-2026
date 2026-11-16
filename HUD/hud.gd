extends CanvasLayer
class_name HUD

@onready var lbl_Bullets: Label = %Bullets
@onready var lbl_Time: RichTextLabel = %Time
@onready var lbl_Enemies: Label = %Enemies

func _ready() -> void:
  Signals.bullets_changed.connect(setBullets)
  hide()


func setTime(value: float) -> void:
  var col = "green" if value > 0 else "red"
  value = abs(value)
  var sec: int = floor(value)
  var cs: float = floor((value - sec) * 100)
  lbl_Time.text = "[color=%s][code]%02d:%02d[/code][/color]" % [col, sec, cs] # A QUANTO PARE IL MENO È UNA FUCKING CIFRA


func showTime(value: bool) -> void:
  if value: lbl_Time.show()
  else: lbl_Time.hide()

func setEnemies(value: int) -> void:
  if value <= 0: lbl_Enemies.hide()
  else: lbl_Enemies.show()

  lbl_Enemies.text = "ENEMIES: %d" % value

func showEnemies(value: bool) -> void:
  if value: lbl_Enemies.show()
  else: lbl_Enemies.hide()

func setBullets(value: int) -> void:
  lbl_Bullets.text = "BULLETS: %d" % value


func showBullets(value: bool) -> void:
  if value: lbl_Bullets.show()
  else: lbl_Bullets.hide()