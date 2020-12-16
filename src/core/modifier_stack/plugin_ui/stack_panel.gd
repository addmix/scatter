tool
extends Control


export var add_button: NodePath
export var root: NodePath

var _add: MenuButton
var _root: Control
var _modifier_stack
var _modifier_panel = load(_get_current_folder() + "/modifier_panel.tscn")


func _ready():
	_add = get_node(add_button)
	_root = get_node(root)
	_add.connect("add_modifier", self, "_on_add_modifier")
	rebuild_ui()


func set_node(node) -> void:
	if not node:
		return
	
	if _modifier_stack:
		_modifier_stack.disconnect("stack_changed", self, "_on_stack_changed")
	
	_modifier_stack = node
	_modifier_stack.connect("stack_changed", self, "_on_stack_changed")


func rebuild_ui() -> void:
	_clear()
	for m in _modifier_stack.stack:
		var ui = _modifier_panel.instance()
		_root.add_child(ui)
		ui.set_modifier_name(m.display_name)
		ui.connect("move_up", self, "_on_move_up", [m])
		ui.connect("move_down", self, "_on_move_down", [m])
		ui.connect("remove_modifier", self, "_on_remove", [m])


func _clear() -> void:
	for c in _root.get_children():
		_root.remove_child(c)
		c.queue_free()


func _on_add_modifier(modifier) -> void:
	_modifier_stack.add_modifier(modifier)


func _on_stack_changed() -> void:
	rebuild_ui()


func _get_current_folder() -> String:
	var script: Script = get_script()
	var path: String = script.get_path()
	return path.get_base_dir()


func _on_move_up(m) -> void:
	_modifier_stack.move_up(m)


func _on_move_down(m) -> void:
	_modifier_stack.move_down(m)


func _on_remove(m) -> void:
	_modifier_stack.remove(m)
