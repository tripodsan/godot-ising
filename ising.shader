shader_type canvas_item;

uniform float u_size = 4.0;
uniform float u_curl_weight = 0.00;
uniform float u_grad_weight = 0.5;
uniform float u_heat = 0.00;
uniform int  u_mouse_mode = 0; 
uniform bool u_mouse_pressed = false;
uniform vec2 u_mouse_position = vec2(0., 0.);
uniform vec2 u_mouse_direction = vec2(0., 0.);

uniform bool u_clear = false;

const float STEP = 1.0;

/**
 * procedural white noise
 */
highp float rand(vec2 co) {
  highp float a = 12.9898;
  highp float b = 78.233;
  highp float c = 43758.5453;
  highp float dt= dot(co.xy ,vec2(a,b));
  highp float sn= mod(dt,3.14);
  return fract(sin(sn) * c);
}

const float PI = 3.141592653589;
const float TAU = 2. * PI;
const vec2 VEC_ONE = vec2(1);

float rnd(vec2 st, float time){
	return fract(sin(dot(st + time * 0.001, vec2(14.9898,78.233))) * 43758.5453);
}

float rndact(vec2 st, float a, float time){
	return fract((rnd(st, time)*10.0 + rnd(st*a, time)*10.0 + rnd(u_mouse_position, time)*10.0)+0.99);
}

float rgb2h(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	return hsv.x;	
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float diffAngles(float a,float b){
  if (a > PI){
    a -= TAU;
  }
  if (a < -PI){
    a += TAU;
  }
  if (b > PI){
    b -= TAU;
  }
  if (b < -PI){
    b += TAU;
  }
  float d = a-b;
  if (d > PI){
    d -= TAU;
  }
  if (d < -PI){
    d += TAU;
  }
  return d;
}

vec3 texture2D(sampler2D tex, vec2 uv) {
  return textureLod(tex, uv, 0.0).rgb;
}

vec3 getGradientAndCurl(vec2 pos, vec2 sz, sampler2D screen, float time) {
  float sumCurl = 0.0;
  float sumWeights = 0.0;
  vec2 grad = vec2(0);
  float sqrtSize2 = 2.0 * sqrt(u_size);
  for (float y = -u_size; y <= u_size; y++) {
    for(float x = -u_size; x <= u_size; x++) {
      if (x == 0. && y == 0.) {
        continue;
       }
      vec2 v = texture2D(screen, sz * vec2(x * STEP + pos.x, y * STEP + pos.y)).xy * 2.0 - VEC_ONE;
      float a = atan(v.y, v.x);
      grad += v;

      float weight = sqrt(x*x+y*y) / sqrtSize2;
      sumCurl += cos(atan(-x,y) - a) * weight;
      sumWeights += weight;
    }
  }
  return vec3(normalize(grad), sumCurl * u_curl_weight / sumWeights);
}

vec2 iter(vec2 pos, vec2 sz, sampler2D screen, float time){
  vec2 st = pos * sz;
  vec2 v = texture2D(screen, st).xy * 2.0 - VEC_ONE;
  float a = atan(v.y, v.x);

  vec3 gradAndCurl = getGradientAndCurl(pos, sz, screen, time);
  float curl = gradAndCurl.z;
  vec2 gradient = gradAndCurl.xy;
  float heat_var = (rndact(pos, a, time) * 2.0 - 1.0) * u_heat;
  float angle_grad = atan(gradient.y, gradient.x);
  float gradient_v = diffAngles(angle_grad, a) * u_grad_weight;
  //float gradient_v = (a - angle_grad) * u_grad_weight;
  a += gradient_v + heat_var + curl;
  if (a > TAU){
    a -= TAU;
  }
  if (a < 0.0){
    a += TAU;
  }
  return vec2(cos(a), sin(a));
}

void fragment() {
  vec2 sz = SCREEN_PIXEL_SIZE;
  vec2 st = SCREEN_UV;
  vec2 pos = FRAGCOORD.xy;

  if (STEP > 1.0 && mod(pos.x, STEP) > 3.0 || mod(pos.y, STEP) > 3.0) {
  //if (false) {
    COLOR.rgb = vec3(0);
  } else {
    vec2 distance_to_mouse = (st / sz) - u_mouse_position; 
    vec2 v = vec2(.0, 0);
    
    if ((u_mouse_pressed && length(distance_to_mouse) < 20.0) || u_clear) {
      if (u_mouse_mode == 0 || u_clear) {
        // random
        float a = rnd(st, TIME) * TAU;
        v = vec2(cos(a), sin(a));
      } else {
        // direction
        v = normalize(u_mouse_direction);
      }
    } 
    else  {
      v = iter(pos, sz, SCREEN_TEXTURE, TIME);
    }

    COLOR.rgb = vec3((v.x + 1.0) / 2.0, (v.y + 1.0) / 2.0, 0.0);
 }
}