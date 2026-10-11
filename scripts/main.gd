extends Node

const SAVE_PATH := "user://jengamaster.cfg"

var coins: int = 0
var stars: int = 0
var best_score: int = 0
var max_level: int = 1

func _ready() -> void:
	load_save()
	show_menu()

func add_coins(amount: int) -> void:
	coins += amount
	save_game()

func add_stars(amount: int) -> void:
	stars += amount
	save_game()

func record_score(value: int) -> void:
	if value > best_score:
		best_score = value
		save_game()

func set_max_level(value: int) -> void:
	if value > max_level:
		max_level = value
		save_game()

func load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		coins = cfg.get_value("progress", "coins", 0)
		stars = cfg.get_value("progress", "stars", 0)
		best_score = cfg.get_value("progress", "best_score", 0)
		max_level = cfg.get_value("progress", "max_level", 1)

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "coins", coins)
	cfg.set_value("progress", "stars", stars)
	cfg.set_value("progress", "best_score", best_score)
	cfg.set_value("progress", "max_level", max_level)
	cfg.save(SAVE_PATH)

func show_menu() -> void:
	clear_children()
	var menu := Menu.new(self)
	add_child(menu)
	menu.game_requested.connect(show_game)

func show_game() -> void:
	clear_children()
	var game := Game.new(self, 1)
	add_child(game)
	game.menu_requested.connect(show_menu)

func clear_children() -> void:
	for child in get_children():
		child.queue_free()
