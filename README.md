# jengamaster🧱 (Godot)

¡Bienvenido a **jengamaster**! Una experiencia interactiva de estrategia, precisión y física en tiempo real desarrollada en **Godot**, donde competirás por mantener la estabilidad de la torre sin hacerla colapsar.

---

## 🎮 Modos de Juego

* 👤 **1 Jugador (Modo En Solitario):** Pon a prueba tu pulso y supera tu propio récord retirando la mayor cantidad de bloques posibles.
* 👥 **2 Jugadores (Multijugador Local):** Desafía a un amigo en turnos alternados para ver quién comete el error que derribe la torre.

---

## 🌴 Entornos y Personalización

* 🏝️ **Tienda de Entornos:** Personaliza tu experiencia de juego comprando y seleccionando diferentes escenarios temáticos (Isla Tropical, Entornos Marinos y más).
* ⚙️ **Generación Dinámica:** Los elementos decorativos y del mapa se ajustan en tiempo real según el entorno seleccionado.

---

## ⚡ Características Técnicas y Físicas

* 🎲 **Simulación de Físicas 3D:** Modelado preciso de peso, masa, fricción y centro de gravedad para cada bloque.
* ❓ **Mecánicas Interactivas:** Sistema integrado de eventos y trivias durante la partida.
* 🔊 **Audio y Menús:** Control de audio global y gestión de interfaz fluida.

---

## 🛠️ Estructura del Proyecto

```text
res://
├── scenes/               # Escenas principales del juego (main.tscn)
├── scripts/              # Lógica y controladores en GDScript
│   ├── autoload/         # Gestores globales (audio, estado del juego, trivias)
│   ├── ui/               # Scripts de la interfaz de usuario (menús, HUD, overlays)
│   ├── environment_builder.gd  # Generador de entorno y mapa 3D
│   ├── jenga_block.gd    # Lógica y física de los bloques
│   └── tower_builder.gd  # Algoritmo de construcción de la torre
└── shaders/              # Materiales y efectos visuales customizados
