extends TextureRect

export var pRender:NodePath
onready var nRender = get_node(pRender)

var prevMouse:Vector2

func _input(event: InputEvent) -> void:
  if !(event is InputEventMouse): return

  var mp = event.position;
  var dm = mp - prevMouse;
  prevMouse = mp

  nRender.u_mouse_position = mp
  nRender.u_mouse_direction = dm;
  if event is InputEventMouseButton:
    nRender.u_mouse_pressed = event.pressed

