extends YSort

export(int) var restTime = 5

var enemyA = preload("res://Enemies/BasicEnemy.tscn")
var enemyB = preload("res://Enemies/BasicRangedEnemy.tscn")
var staff = preload("res://Items/Staff.tscn")
var crossbow = preload("res://Items/Crossbow.tscn")
var rifle = preload("res://Items/Rifle.tscn")

var enemies
var wave = 0
var rng = RandomNumberGenerator.new()

onready var timer = $Timer
onready var waveUI

func _ready():
	yield(get_tree().current_scene, "ready")
	waveUI.wave = wave
	rng.randomize()

func _physics_process(delta):
	if get_tree().get_nodes_in_group("Enemies").size() > 0:
		timer.stop()
	elif timer.is_stopped():
		timer.start(restTime)
	else:
		print(timer.time_left)
		
func spawnWave():
	for i in range(wave):
		rng.randomize()
		var level = rng.randi_range(max((wave/5+1)-2, 1), (wave/5+1))
		var location = get_child(rng.randi_range(0, get_child_count()-2))
		if rng.randf() < 0.8:
			location.spawn(enemyA, null, level)
		else:
			if wave >= 15 and wave < 30:
				if rng.randf() < 0.5:
					location.spawn(enemyB, crossbow, level)
				else:
					location.spawn(enemyB, staff, level)
			if wave >= 30:
				if rng.randf() < 0.4:
					location.spawn(enemyB, rifle, level)
				elif rng.randf() < 0.7:
					location.spawn(enemyB, crossbow, level)
				else:
					location.spawn(enemyB, staff, level)
	

func _on_Timer_timeout():
	wave += 1
	waveUI.wave = wave
	spawnWave()
