extends Node2D

var rng = RandomNumberGenerator.new()

func spawn(enemyType, weaponScene, level):
	rng.randomize()
	var enemy = enemyType.instance()
	if weaponScene != null:
		enemy.weaponScene = weaponScene
	get_parent().enemies.call_deferred("add_child", enemy)
	enemy.level = level
	yield(enemy, "ready")
	enemy.global_position = global_position
