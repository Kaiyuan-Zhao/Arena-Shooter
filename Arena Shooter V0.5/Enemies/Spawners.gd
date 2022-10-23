extends YSort

export(int) var restTime = 20

var enemyA = preload("res://Enemies/BasicEnemy.tscn")
var enemyB = preload("res://Enemies/BasicRangedEnemy.tscn")
var boss1 = preload("res://Enemies/BossEnemy1.tscn")
var staff = preload("res://Items/Staff.tscn")
var crossbow = preload("res://Items/Crossbow.tscn")
var rifle = preload("res://Items/Rifle.tscn")
var _UNSAVABLE_PROPERTIES = ["enemyA", "enemyB", "boss1", "staff", "crossbow", "rifle", "enemies", "rng", "timer", "waveUI"]
var timeLeftTillWave = 20
var enemies
var wave = 0 setget set_wave
var rng = RandomNumberGenerator.new()
var bonusCoinsAdded = false
onready var timer = $Timer
onready var waveUI

func _ready():
	yield(get_tree().current_scene, "ready")
	waveUI.connect("skipToWave", self, "_on_Timer_timeout")
	waveUI.wave = wave
	rng.randomize()

func _physics_process(_delta):
	if get_tree().get_nodes_in_group("Enemies").size() > 0:
		bonusCoinsAdded = false
		timer.stop()
	elif timer.is_stopped():
		
		timer.start(restTime)
	else:
		if not bonusCoinsAdded:
			if wave != 1:
				PlayerStats.coins += wave*wave
			bonusCoinsAdded = true
		timeLeftTillWave = timer.time_left
		waveUI.button.text = str("Skip (",ceil(timer.time_left),")")
		
func spawnWave():
	if wave == 30:
		var location = get_child(rng.randi_range(0, get_child_count()-2))
		location.spawn(boss1, null, 20)
	else:
		for _i in range(wave):
			rng.randomize()
			var level = rng.randi_range(max((wave/5+1)-2, 1), (wave/5+1))
			var location = get_child(rng.randi_range(0, get_child_count()-2))
			if wave >= 5:
				if rng.randf() < 0.8:
					location.spawn(enemyA, null, level)
				else:
					if wave >= 15 and wave < 30:
						if rng.randf() < 0.5:
							location.spawn(enemyB, crossbow, level)
						else:
							location.spawn(enemyB, staff, level)
					if wave >= 30:
						if rng.randf() < 0.7:
							location.spawn(enemyB, rifle, level)
						elif rng.randf() < 0.9:
							location.spawn(enemyB, crossbow, level)
						else:
							location.spawn(enemyB, staff, level)
					else:
						location.spawn(enemyB, staff, level)
			else:
				location.spawn(enemyA, null, level)
			yield(get_tree().create_timer(0.05), "timeout")
			

func _on_Timer_timeout():
	timer.stop()
	wave += 1
	waveUI.wave = wave
	spawnWave()

func set_wave(value):
	wave = value
	timer.start(timeLeftTillWave)
	waveUI.wave = wave

func get_save_data() -> Dictionary:
	var d := {}
	for property in get_property_list():
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			if not property.name in _UNSAVABLE_PROPERTIES:
				if property.type != TYPE_OBJECT:
					# ConfigFile can handle any built-in data type
					d[property.name] = get(property.name)
				else:
					# implement get_save_data() in non-node objects.
					d["Object_" + property.name] = get(property.name).get_save_data()
	return d

func load_save_data(d: Dictionary): 
	for property_name in d:
		if property_name.count("Object_") > 0:
			get(property_name).load_save_data(d[property_name])
		else:
			set(property_name, d[property_name])
