extends Node

var _screen: Node = null

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--autostart="):
			call_deferred("_on_mode_selected", int(arg.split("=")[1]))
			return
	show_menu()

func show_menu() -> void:
	_clear()
	var menu := MainMenu.new()
	add_child(menu)
	_screen = menu
	menu.mode_selected.connect(_on_mode_selected)

func _on_mode_selected(mode: int) -> void:
	GameState.reset_match(mode)
	_clear()
	var game := GameController.new()
	add_child(game)
	_screen = game
	game.exit_requested.connect(show_menu)

func _clear() -> void:
	if is_instance_valid(_screen):
		_screen.queue_free()
	_screen = null
