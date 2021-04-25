class_name DialogMenu
extends Container

signal shown
signal hidden

export var option_scene: PackedScene

var current_options := []


onready var _panel: Container = find_node('Panel')
onready var _options: Container = find_node('Options')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	connect('gui_input', self, '_clicked')
	
	# Conectarse a eventos de los evnetruchos
	D.connect('dialog_requested', self, '_create_options', [true])
	E.connect('inline_dialog_requested', self, '_create_dialog_options')
	D.connect('dialog_finished', self, 'remove_options')

	hide()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _clicked(event: InputEvent) -> void:
	var mouse_event: = event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == BUTTON_LEFT \
		and mouse_event.pressed:
			pass


# Crea nodos de tipo DialogOption para los casos en los que se muestran opciones
# de diálogo creadas en tiempo de ejecución, o sea, que no están en uno de los
# diálogos almacenados en src/DialogTree
func _create_dialog_options(opts: Array) -> void:
	var tmp_opts := []
	for idx in opts.size():
		prints('idx', idx)
		tmp_opts.append({
			id = '%d' % (idx + 1),
			text = opts[idx],
			visible = true
		})
	_create_options(tmp_opts, true)


func _create_options(options := [], autoshow := false) -> void:
	remove_options()

	if options.empty():
		if not current_options.empty():
			show_options()
		return

	current_options = options.duplicate(true)
	for opt in options:
		var btn: Button = option_scene.instance() as Button

		btn.text = opt.text
		btn.connect('pressed', self, '_on_option_clicked', [opt])

		_options.add_child(btn)

		if not opt.visible:
#			opt.show = false
			btn.hide()
		else:
#			opt.show = true
			btn.show()

	if autoshow: show_options()
	
	yield(get_tree(), 'idle_frame')

	_panel.rect_min_size.y = _options.rect_size.y


func remove_options() -> void:
	if not current_options.empty():
		current_options.clear()

		for btn in _options.get_children():
#			(btn as Button).call_deferred('queue_free')
			_options.remove_child(btn as Button)
#		hide()
	
	yield(get_tree(), 'idle_frame')

	_panel.rect_size.y = 0
	_options.rect_size.y = 0
#
#
#func update_options(updates_cfg := {}) -> void:
#	if not updates_cfg.empty():
#		var idx := 0
#		for btn in get_children():
#			btn = (btn as Button)
#			var id := String(btn.get_index())
#			if updates_cfg.has(id):
#				if not updates_cfg[id]:
#					current_options[idx].show = false
#					btn.hide()
#				else:
#					current_options[idx].show = true
#					btn.show()
#			if btn.is_in_group('FocusGroup'):
#				btn.remove_from_group('FocusGroup')
#				btn.remove_from_group('DialogMenu')
#				guiBrain.gui_collect_focusgroup()
#			idx+= 1
#
#
func show_options() -> void:
	show()
	emit_signal('shown')


func _on_option_clicked(opt: Dictionary) -> void:
	hide()
	D.emit_signal('option_selected', opt)