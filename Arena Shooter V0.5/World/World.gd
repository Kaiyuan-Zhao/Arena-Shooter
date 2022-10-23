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

signal isReady()

func _ready():
	player.glowLayer = glowLayer
	PlayerStats.coins = wave*wave*wave*100
	noGlowLayer.player = player
	spawners.enemies = enemies
	spawners.waveUI = glowLayer.waveUI
	spawners.wave = wave
	ready = true
	if SaveSystem.immediatelyLoad:
		SaveSystem.call_deferred("loadDictionary")
		SaveSystem.immediatelyLoad = false
	
