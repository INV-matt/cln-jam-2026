extends CharacterBody3D
class_name Enemy

enum State {
  IDLE,
  FOLLOWING,
  DESTROYED
}

@export var MaxHealth: float = 1
@onready var health: float = MaxHealth

var state: State = State.IDLE

func take_damage(dmg: float) -> void:
  if state == State.DESTROYED: return
  Signals.enemy_died.emit()
  state = State.DESTROYED
  (%ExplosionParticles as GPUParticles3D).restart()
  (%ContinuosParticles as GPUParticles3D).emitting = true

  # health -= dmg
  # if health <= 0:
  # queue_free()
