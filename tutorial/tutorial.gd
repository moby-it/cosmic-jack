extends Control

var panel_init_y = 335.0
var panel_next_y = 1400.0

@onready var level: Level = $Level
@onready var panel = $Panel
var txt_1 = """
Cosmic Jack is a rhythm puzzle game. 

You have to place fruits in patterns in order to defeat your enemies.

Enemies come in waves. Each wave consists of one (or more) convoys of enemies.
	"""
var txt_2 = """
Α convoy is simply a series of enemies walking down a path. Here you see a wave with 1 convoy that has 4 enemies.
The gray area above indicates the play area.

"""
var txt_3 = """
Cosmic Jack is a rhythm game. Notice the animations and the music. Everything should be ON BEAT.
This applies for your ammo as well.
"""

var txt_4 = """
Each wave comes with a set of fruit ammo. These are your tools to eliminate your enemies.

Fruits have different trigger conditions. For example, the apple explodes 4 beats after enemy contact.

"""

var txt_5 = """
Each wave takes place in 2 phases. The Planning phase and the Resolution phase.
Right now, you see the planning phase.
In the planning phase the enemy movement loops constantly, as a preview.

"""
var txt_6 = """
In the planning phase you can place your fruits anywhere you want. You can select a fruit by clicking on it's sprite.
After you select the apple, move your mouse to the play area to place your fruit.

"""
var txt_6_1 = """
After placing your fruit, you will notice a countdown on it. This is the countdown that is in sync with the song beat.
It helps you estimate when the fruit will explode.
This will not be present in the actual gameplay, you'll have to count to the beat by yourself!

"""
var txt_7 = """
Play area actions:
<ctrl + left click> moves an already placed fruit.
<ctrl + right click> removes an already placed fruit.
<r> restarts the wave enemy movement.
"""

var txt_8 = """
After you feel confident about your placement, you can press the resolve button to resolve the wave.
"""

var txt_9 = """[font_size=62]Congratulations, you finished our tutorial! You can go ahead and play our demo level.[/font_size]"""

@onready var text = %TutorialText
var idx = 0

var texts = [
	{ "text": txt_1, "fn": null },
	{ "text": txt_2 , "fn": slide_2_fn },
	{ "text": txt_3 , "fn": null },
	{ "text": txt_4 , "fn": slide_4_fn },
	{ "text": txt_5 , "fn": null },
	{ "text": txt_6 , "fn": slide_6_fn },
	{ "text": txt_6_1 , "fn": slide_6_fn },
	{ "text": txt_7 , "fn": null },
	{ "text": txt_8 , "fn": slide_8_fn },
	{ "text": txt_9 , "fn": null },
]

var revert_fns = [
	slide_2_fn_revert,
	null,
	slide_4_fn_revert,
	null,
	slide_6_fn_revert,
	null,
	slide_8_fn_revert,
	null
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level.start_audio()
	text.text = txt_1
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
	level.clear_fruit_hud()
	level.create_fruit_list(level.curr_wave())
	level.fruit_placed.connect(on_fruit_placed)
	
func slide_4_fn_revert():
	level.clear_fruit_hud()
	level.fruit_placed.disconnect(on_fruit_placed)
func slide_6_fn():
	level.input_enabled = true

func slide_6_fn_revert():
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
