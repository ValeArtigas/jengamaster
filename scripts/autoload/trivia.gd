extends Node

const PATH := "res://preguntas.json"
const CATEGORY_UNIDAD := "Unidad_III"
const CATEGORY_CULTURA := "Cultura_General"
const CATEGORY_ANY := ""

var questions: Array = []

func _ready() -> void:
	load_database()

func load_database() -> void:
	questions.clear()
	if not FileAccess.file_exists(PATH):
		push_error("No se encontro preguntas.json en %s" % PATH)
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_ARRAY:
		questions = parsed
	else:
		push_error("preguntas.json no tiene el formato esperado")

func random_question(category: String = CATEGORY_ANY) -> Dictionary:
	var pool: Array = questions
	if category != CATEGORY_ANY:
		pool = questions.filter(func(q): return str(q.get("categoria", "")) == category)
	if pool.is_empty():
		pool = questions
	if pool.is_empty():
		return {}
	return (pool[randi() % pool.size()] as Dictionary).duplicate(true)

func reward_type_of(q: Dictionary) -> String:
	return str(q.get("recompensa_tipo", "moneda"))
