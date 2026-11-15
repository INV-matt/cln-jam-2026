extends Node

@warning_ignore_start("unused_signal")
signal level_start(levelId: int)
signal level_start_next()
signal level_restart()
signal level_resume()
signal end_zone_entered()
signal level_completed()
signal timer_timeout()


signal bullets_changed(remaining: int)
# signal mags_changed(mags: int)

signal enemy_died()
signal enemy_changed(new: int)
signal player_died()

signal reload_anim_finished()

signal open_level_selector()

@warning_ignore_restore("unused_signal")