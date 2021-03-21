extends ColorRect

export var pSize:NodePath
export var pCurl:NodePath
export var pGrad:NodePath
export var pHeat:NodePath
export var pMouse:NodePath

var u_size:int = 4
var u_curl:float = 0.1
var u_grad:float = 0.5
var u_heat:float = 0.01
var u_mouse:int = 0

var prevMouse:Vector2

func _ready()->void:
  get_node(pSize).value = u_size
  get_node(pSize).connect('value_changed', self, 'set_u_size');
  get_node(pCurl).value = u_curl
  get_node(pCurl).connect('value_changed', self, 'set_u_curl');
  get_node(pGrad).value = u_grad
  get_node(pGrad).connect('value_changed', self, 'set_u_grad');
  get_node(pHeat).value = u_heat
  get_node(pHeat).connect('value_changed', self, 'set_u_heat');
  (get_node(pMouse) as OptionButton).select(u_mouse);
  get_node(pMouse).connect('item_selected', self, 'set_u_mouse');

func _process(delta: float) -> void:
  var mp = get_global_mouse_position();
  var dm = mp - prevMouse;
  prevMouse = mp;
  material.set_shader_param("mouse_position", mp)
  material.set_shader_param("mouse_direction", cartesian2polar(dm.x, dm.y))
  material.set_shader_param("u_size", u_size)
  material.set_shader_param("u_curl_weight", u_curl)
  material.set_shader_param("u_grad_weight", u_grad)
  material.set_shader_param("u_heat", u_heat)
  material.set_shader_param("u_mouse", u_mouse)

func set_u_size(value:float)->void:
  u_size = value
func set_u_curl(value:float)->void:
  u_curl = value
func set_u_grad(value:float)->void:
  u_grad = value
func set_u_heat(value:float)->void:
  u_heat = value
func set_u_mouse(value:int)->void:
  u_mouse = value
