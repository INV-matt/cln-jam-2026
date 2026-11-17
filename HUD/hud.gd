extends CanvasLayer
class_name HUD

@onready var lbl_Bullets: Label = %Bullets
@onready var lbl_Sec: RichTextLabel = %Sec
@onready var lbl_Cent: RichTextLabel = %Cent
@onready var lbl_Enemies: Label = %Enemies

func _ready() -> void:
  Signals.bullets_changed.connect(setBullets)
  hide()


func setTime(value: float) -> void:
  var col = "green" if value > 0 else "red"
  value = abs(value)
  var sec: int = floor(value)
  var cs: float = floor((value - sec) * 100)
  lbl_Sec.text = "[color=%s]%02d[/color]" % [col, sec]
  lbl_Cent.text = "[color=%s].%02d[/color]" % [col, cs]


func showTime(value: bool) -> void:
  if value:
    lbl_Sec.show()
    lbl_Cent.show()
  else:
    lbl_Sec.hide()
    lbl_Cent.hide()

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
