extends Viewport

export var pPanel:NodePath

func _ready():
  get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
  render_target_update_mode = Viewport.UPDATE_ALWAYS
  _on_viewport_size_changed()

func _on_viewport_size_changed():
  var margin = Vector2.ZERO
  var panel = get_node(pPanel)
  if panel:
    margin.x = panel.rect_size.x;
  size = get_tree().root.size - margin;
