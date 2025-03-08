extends Control

var panel_init_y = 335.0
var panel_next_y = 1350.0
var idx = 0

@onready var text = %TutorialText
@onready var level: Level = $Level
@onready var panel = $Panel

var labels = [
	"Basic concepts",
	"Convoys &  Play Area",
	"Phases",
	"Ammo",
	"Fruit Triggers",
	"Place a fruit",
	"Detonation Timer",
	"Manipulate your placement",
	"Solve the puzzle",
	"Congratulations!",
]

var txt_1 = """
Cosmic Jack is a rhythm puzzle game. 

You have to place fruits in patterns in order to defeat your enemies.

Enemies come in [u]waves[/u]. Each wave consists of one (or more) [u]convoys[/u] of enemies.

"""
var txt_2 = """
Α convoy is simply a series of enemies walking down a path. 
Here you see a wave with 1 convoy that has 4 enemies.

The red highlighted area above indicates the [u]play area[/u].
In each wave you must eliminate all enemies before the exit the play area.

"""

var txt_3 = """
Each wave takes place in 2 phases. The [u]planning phase[/u] and the [u]resolution phase[/u].

In the planning phase you can:
	- study the enemy pathing as it loops constantly.
	- place your fruits and estimate the outcome.

You can already see the enemy pathing preview for the tutorial wave.

"""

var txt_4 = """
Each wave comes with a set of fruit ammo. These are your tools to eliminate your enemies.
Ammo can be found at the bottom right of your screen.

This wave has a single apple as ammo.
"""
var txt_4_1 = """
Fruits have different trigger conditions. For example, the apple explodes 4 [u]beats[/u] after enemy contact.

It's music beats, not seconds!
"""

var txt_5 = """
You can select a fruit by clicking on it.
After you select the apple, move your mouse to the play area and press <left click> to place your fruit.

"""

var txt_6 = """
After placing your fruit, you will notice a countdown on it.
This is a helper counter, in order to help you build some some intuition regarding when the explosion will happen.

This will not be present during the preparation phase in the actual gameplay. It will only be present at the resolution phase.
In the preparation phase, you'll have to count to the beat by yourself!

"""
var txt_7 = """
Some Play area actions:
<ctrl + left click> moves an already placed fruit.
<ctrl + right click> removes an already placed fruit.
<r> restarts the wave enemy movement.
"""

var txt_8 = """
After you feel confident about your placement, you can press the resolve button to transition into the resolution phase.
In this phase the wave actually resolves and you get to see weather your fruit placement solved the puzzle.
"""

var txt_9 = """You finished our tutorial! You can go ahead and play our demo level."""


var texts = [
	{ "text": txt_1, "fn": null },
	{ "text": txt_2 , "fn": slide_2_fn },
	{ "text": txt_3 , "fn": null },
	{ "text": txt_4 , "fn": slide_4_fn },
	{ "text": txt_4_1 , "fn": null },
	{ "text": txt_5 , "fn": slide_5_fn },
	{ "text": txt_6 , "fn": null },
	{ "text": txt_7 , "fn": null },
	{ "text": txt_8 , "fn": slide_8_fn },
	{ "text": txt_9 , "fn": null },
]

var revert_fns = [
	slide_2_fn_revert,
	null,
	slide_4_fn_revert,
	null,
	slide_5_fn_revert,
	null,
	null,
	slide_8_fn_revert,
	null
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level.start_audio()
	text.text = txt_1
	%Title.text = "%s - %s/%s" % [labels[idx], str(idx + 1), str(len(labels))]
	level.wave_completed.connect(on_wave_resolved)
	level.health_depleted.connect(on_wave_resolved)

func _on_next_button_down() -> void:
	idx += 1
	update()

func _on_back_button_down() -> void:
	idx -= 1
	update()

func update():
	render_back()
	render_complete()
	render_next()
	for c in revert_fns.slice(idx, len(revert_fns)):
		if c:
			c.call()
	var i = texts[idx]
	text.text = i["text"]
	%Title.text = "%s - %s/%s" % [labels[idx], str(idx + 1), str(len(labels))]
	if i["fn"]:
		i["fn"].call()

func render_back():
	%Back.visible = idx > 0 
	
func render_complete():
	%Complete.visible = idx == len(texts)  - 1 # adjusting for last element
	%Next.visible = not %Complete.visible
	%Back.visible = not %Complete.visible

func render_next():
	%Next.visible = idx + 2 < len(texts)

func slide_2_fn():
	panel.set_position(Vector2(panel.position.x, panel_next_y))
	level.play_area.visible = true
	level.render_convoys(level.curr_wave())

func slide_2_fn_revert():
	panel.set_position(Vector2(panel.position.x, panel_init_y))
	level.play_area.visible = false
	level.clear_wave()

func slide_4_fn():
	level.create_fruit_list(level.curr_wave())
	level.render_active_fruit_ui()

func slide_4_fn_revert():
	level.clear_fruit_hud()
	
func slide_5_fn():
	level.input_enabled = true
	level.fruit_placed.connect(on_fruit_placed)

func slide_5_fn_revert():
	if level.fruit_placed.has_connections():
		level.fruit_placed.disconnect(on_fruit_placed)
	level.input_enabled = false
	
func slide_8_fn():
	level.resolve_btn.visible = true
	
func slide_8_fn_revert():
	level.resolve_btn.visible = false

func _on_complete_button_down() -> void:
	var menu = load("res://menu/main_menu.tscn").instantiate()
	SceneManager.change_scene.emit(menu)

func on_fruit_placed(node: Node2D):
	node.explosive.loop_explosion_timer(node)

func on_wave_resolved():
	await get_tree().create_timer(0.5).timeout
	level.resolve_btn.visible = false
	level.clear_fruit_hud()
	idx = len(texts) - 1
	update()
