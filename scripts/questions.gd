class_name Questions

const BANK: Array = [
	{"q": "¿Cuánto es 5! ?", "opts": ["24", "60", "120", "720"], "a": 2, "type": "math"},
	{"q": "¿Cuánto es 0! ?", "opts": ["0", "1", "No existe", "10"], "a": 1, "type": "math"},
	{"q": "El número de permutaciones de 4 elementos distintos es:", "opts": ["8", "12", "24", "48"], "a": 2, "type": "math"},
	{"q": "¿Cuántas formas hay de ordenar 3 libros distintos en un estante?", "opts": ["3", "6", "9", "12"], "a": 1, "type": "math"},
	{"q": "¿Cuánto es 4! ?", "opts": ["24", "20", "12", "16"], "a": 0, "type": "math"},
	{"q": "¿Cuánto es 6! ?", "opts": ["720", "360", "120", "5040"], "a": 0, "type": "math"},
	{"q": "¿Cuánto es 3! + 4! ?", "opts": ["30", "40", "26", "34"], "a": 0, "type": "math"},
	{"q": "¿Cuánto es 7! / 5! ?", "opts": ["42", "21", "56", "72"], "a": 0, "type": "math"},
	{"q": "P(6, 2) (permutaciones de 6 tomados de 2 en 2) es:", "opts": ["12", "30", "36", "15"], "a": 1, "type": "math"},
	{"q": "P(5, 3) es igual a:", "opts": ["60", "15", "120", "20"], "a": 0, "type": "math"},
	{"q": "P(8, 1) es igual a:", "opts": ["8", "1", "64", "7"], "a": 0, "type": "math"},
	{"q": "La fórmula de P(n, r) es:", "opts": ["n! / (n-r)!", "n! · r!", "n! / (r-1)!", "(n-r)! / n!"], "a": 0, "type": "math"},
	{"q": "Si P(n, 2) = 56, entonces n es:", "opts": ["7", "8", "9", "10"], "a": 1, "type": "math"},
	{"q": "Las permutaciones circulares de 5 personas alrededor de una mesa son:", "opts": ["120", "24", "60", "20"], "a": 1, "type": "math"},
	{"q": "¿Cuántos anagramas tiene la palabra SALA?", "opts": ["24", "12", "6", "32"], "a": 1, "type": "math"},
	{"q": "Las permutaciones de las letras de LIBRO son:", "opts": ["120", "24", "720", "60"], "a": 0, "type": "math"},
	{"q": "Las permutaciones de las letras de CORAZÓN (la O se repite) son:", "opts": ["2520", "5040", "1260", "720"], "a": 0, "type": "math"},
	{"q": "El producto 10 · 9 · 8 · 7 es igual a:", "opts": ["P(10, 4)", "P(10, 6)", "P(4, 10)", "10!"], "a": 0, "type": "math"},
	{"q": "Capital de Francia:", "opts": ["Madrid", "París", "Roma", "Berlín"], "a": 1, "type": "culture"},
	{"q": "Planeta más grande del sistema solar:", "opts": ["Saturno", "Júpiter", "Neptuno", "Tierra"], "a": 1, "type": "culture"},
	{"q": "Autor de Cien años de soledad:", "opts": ["Mario Vargas Llosa", "Pablo Neruda", "Gabriel García Márquez", "Julio Cortázar"], "a": 2, "type": "culture"},
	{"q": "¿Cuántos continentes hay?", "opts": ["5", "6", "7", "8"], "a": 2, "type": "culture"},
	{"q": "El océano más grande del mundo es:", "opts": ["Atlántico", "Índico", "Ártico", "Pacífico"], "a": 3, "type": "culture"},
	{"q": "Símbolo químico del oro:", "opts": ["Or", "Au", "Ag", "Od"], "a": 1, "type": "culture"},
	{"q": "¿Quién pintó la Mona Lisa?", "opts": ["Miguel Ángel", "Leonardo da Vinci", "Rafael", "Picasso"], "a": 1, "type": "culture"},
	{"q": "¿Cuántos días tiene un año bisiesto?", "opts": ["365", "366", "360", "356"], "a": 1, "type": "culture"},
	{"q": "País de origen del tango:", "opts": ["Brasil", "Uruguay", "Argentina", "México"], "a": 2, "type": "culture"},
	{"q": "¿Cuántos huesos tiene el cuerpo humano adulto?", "opts": ["186", "206", "216", "196"], "a": 1, "type": "culture"},
	{"q": "Instrumento musical de 88 teclas:", "opts": ["Violín", "Guitarra", "Piano", "Flauta"], "a": 2, "type": "culture"},
	{"q": "Metal más abundante en la corteza terrestre:", "opts": ["Hierro", "Cobre", "Aluminio", "Plata"], "a": 2, "type": "culture"},
	{"q": "Isla más grande del mundo:", "opts": ["Madagascar", "Borneo", "Groenlandia", "Nueva Guinea"], "a": 2, "type": "culture"},
	{"q": "Velocidad de la luz (aproximada):", "opts": ["3.000 km/s", "300.000 km/s", "30.000 km/s", "3.000.000 km/s"], "a": 1, "type": "culture"}
]

static func pick_level_questions(count: int) -> Array:
	var math_qs: Array = []
	var culture_qs: Array = []
	for q in BANK:
		if q["type"] == "math":
			math_qs.append(q)
		else:
			culture_qs.append(q)
	math_qs.shuffle()
	culture_qs.shuffle()
	var math_count := int(round(count * 0.6))
	var culture_count := count - math_count
	var picked: Array = []
	for i in math_count:
		picked.append(math_qs[i % math_qs.size()])
	for i in culture_count:
		picked.append(culture_qs[i % culture_qs.size()])
	picked.shuffle()
	return picked
