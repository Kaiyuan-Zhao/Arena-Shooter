extends Node2D

var ready = false
export(int) var wave = 0

onready var spawners = $Spawners
onready var enemies = $Enemies
onready var store = $NoGlowLayer/store
onready var player = $Player
onready var glowLayer = $GlowLayer
onready var noGlowLayer = $NoGlowLayer
onready var tileset = $Tileset
onready var camera = $Camera

func _ready():
	player.glowLayer = glowLayer
	#PlayerStats.coins = 50*wave*floor(5*sqrt(wave))
	noGlowLayer.player = player
	spawners.enemies = enemies
	spawners.waveUI = glowLayer.waveUI
	spawners.wave = wave
	ready = true

func _process(delta):
	if Input.is_action_just_pressed("enter"):
		#get_tree().paused = true
		if store.visible:
			store.visible = false
		else:
			store.visible = true
