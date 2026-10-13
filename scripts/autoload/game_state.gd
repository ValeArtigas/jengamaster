extends Node

signal turn_changed(index: int)
signal stats_changed()
signal tower_changed(height: int, stacked: int)

enum Mode { SINGLE, VERSUS }

const START_LIVES := 3
const SAVE_PATH := "user://torre_saber.cfg"

# Altura maxima que puede alcanzar la torre.
const MAX_TOWER_FLOORS := 20

# Monedas con las que inicia el jugador (por fines de prueba).
const STARTING_COINS := 200

# Puntos otorgados por cada bloque consolidado en la cima.
const STACK_POINTS_BASE := 40
const HEIGHT_POINT_BONUS := 12

# Catalogo de ambientaciones comprables con monedas.
const ENVIRONMENTS := [
	{"name": "Selva Tropical", "price": 0, "desc": "Palmeras y vegetacion"},
	{"name": "Desierto", "price": 60, "desc": "Dunas, cactus y sol"},
	{"name": "Marina", "price": 100, "desc": "Arrecife, corales y peces"},
]

class PlayerData:
	var name: String = "Jugador"
	var color: Color = Color.WHITE
	var coins: int = 0
	var stars: int = 0
	var lives: int = 3
	var correct: int = 0
	var wrong: int = 0
	var blocks: int = 0        # bloques apilados con exito en la cima
	var extracted: int = 0     # bloques intentados / extraidos
	var height_points: int = 0 # puntos ganados por altura alcanzada
	var alive: bool = true

var mode: int = Mode.SINGLE
var players: Array = []
var current_player: int = 0
var level: int = 1
var best_score: int = 0

# Estado compartido de la torre (mecanica de la cima).
var tower_height: int = 0    # pisos actuales de la torre
var stacked_blocks: int = 0  # bloques consolidados en la cima
var peak_height: int = 0     # altura maxima alcanzada en la partida
var goal_height: int = 0     # altura objetivo para ganar

# Monedero persistente y tienda de ambientaciones.
var wallet: int = STARTING_COINS
var owned_envs: Array = [0]
var selected_env: int = 0

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
	tower_height = 0
	stacked_blocks = 0
	peak_height = 0
	goal_height = 0
	turn_changed.emit(current_player)
	tower_changed.emit(tower_height, stacked_blocks)
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
	wallet += amount
	stats_changed.emit()
	save_game()

func add_star(amount: int) -> void:
	active().stars += amount
	stats_changed.emit()
	save_game()

# --- Mecanica de la cima / crecimiento de la torre ---

func configure_tower(floors: int) -> void:
	tower_height = floors
	peak_height = floors
	goal_height = MAX_TOWER_FLOORS
	stacked_blocks = 0
	tower_changed.emit(tower_height, stacked_blocks)
	stats_changed.emit()

func set_tower_height(height: int) -> void:
	tower_height = height
	peak_height = maxi(peak_height, height)
	tower_changed.emit(tower_height, stacked_blocks)

func stack_points_for(height: int) -> int:
	return STACK_POINTS_BASE + maxi(height, 0) * HEIGHT_POINT_BONUS

func register_stack(points: int) -> void:
	stacked_blocks += 1
	var p: PlayerData = active()
	p.blocks += 1
	p.height_points += points
	tower_changed.emit(tower_height, stacked_blocks)
	stats_changed.emit()

func goal_reached() -> bool:
	return goal_height > 0 and tower_height >= goal_height

# --- Tienda de ambientaciones ------------------------------------------

func environment_name(id: int) -> String:
	if id >= 0 and id < ENVIRONMENTS.size():
		return str(ENVIRONMENTS[id]["name"])
	return "?"

func environment_desc(id: int) -> String:
	if id >= 0 and id < ENVIRONMENTS.size():
		return str(ENVIRONMENTS[id]["desc"])
	return ""

func environment_price(id: int) -> int:
	if id >= 0 and id < ENVIRONMENTS.size():
		return int(ENVIRONMENTS[id]["price"])
	return 0

func owns_env(id: int) -> bool:
	return owned_envs.has(id)

func can_afford(id: int) -> bool:
	return wallet >= environment_price(id)

func buy_env(id: int) -> bool:
	if id < 0 or id >= ENVIRONMENTS.size():
		return false
	if owns_env(id):
		return true
	if not can_afford(id):
		return false
	wallet -= environment_price(id)
	owned_envs.append(id)
	selected_env = id
	save_game()
	return true

func select_env(id: int) -> void:
	if owns_env(id):
		selected_env = id
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
	return p.correct * 10 + p.blocks * 15 + p.stars * 20 + p.coins + p.height_points

func record_score(value: int) -> void:
	if value > best_score:
		best_score = value
		save_game()

func load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_score = int(cfg.get_value("records", "best_score", 0))
		wallet = int(cfg.get_value("wallet", "coins", STARTING_COINS))
		var owned: Variant = cfg.get_value("shop", "owned", [0])
		if owned is Array:
			owned_envs = owned
		if not owned_envs.has(0):
			owned_envs.append(0)
		selected_env = int(cfg.get_value("shop", "selected", 0))
	if not owns_env(selected_env):
		selected_env = 0

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("records", "best_score", best_score)
	cfg.set_value("wallet", "coins", wallet)
	cfg.set_value("shop", "owned", owned_envs)
	cfg.set_value("shop", "selected", selected_env)
	cfg.save(SAVE_PATH)
