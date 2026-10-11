extends Node

signal turn_changed(index: int)
signal stats_changed()

enum Mode { SINGLE, VERSUS }

const START_LIVES := 3
const SAVE_PATH := "user://torre_saber.cfg"

class PlayerData:
	var name: String = "Jugador"
	var color: Color = Color.WHITE
	var coins: int = 0
	var stars: int = 0
	var lives: int = 3
	var correct: int = 0
	var wrong: int = 0
	var blocks: int = 0
	var alive: bool = true

var mode: int = Mode.SINGLE
var players: Array = []
var current_player: int = 0
var level: int = 1
var best_score: int = 0

func _ready() -> void:
	load_save()

func reset_match(p_mode: int) -> void:
	mode = p_mode
	players = []
	players.append(_make_player("Jugador 1", Color("#1de9b6")))
	if mode == Mode.VERSUS:
		players.append(_make_player("Jugador 2", Color("#ff5298")))
	current_player = 0
	level = 1
	turn_changed.emit(current_player)
	stats_changed.emit()

func _make_player(n: String, c: Color) -> PlayerData:
	var p := PlayerData.new()
	p.name = n
	p.color = c
	p.lives = START_LIVES
	return p

func player(i: int) -> PlayerData:
	return players[i]

func active() -> PlayerData:
	return players[current_player]

func opponent_index() -> int:
	return (current_player + 1) % players.size()

func advance_turn() -> void:
	current_player = opponent_index()
	turn_changed.emit(current_player)

func add_coin(amount: int) -> void:
	active().coins += amount
	stats_changed.emit()
	save_game()

func add_star(amount: int) -> void:
	active().stars += amount
	stats_changed.emit()
	save_game()

func lose_life() -> bool:
	var p: PlayerData = players[current_player]
	p.lives -= 1
	if p.lives <= 0:
		p.lives = 0
		p.alive = false
	stats_changed.emit()
	return p.alive

func alive_players() -> Array:
	return players.filter(func(p): return p.alive)

func score_of(p: PlayerData) -> int:
	return p.correct * 10 + p.blocks * 5 + p.stars * 20 + p.coins

func record_score(value: int) -> void:
	if value > best_score:
		best_score = value
		save_game()

func load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_score = int(cfg.get_value("records", "best_score", 0))

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("records", "best_score", best_score)
	cfg.save(SAVE_PATH)
