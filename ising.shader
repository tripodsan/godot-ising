shader_type canvas_item;

// Controlled from GDscript
uniform bool mouse_pressed = false;
uniform vec2 mouse_position = vec2(0., 0.);
uniform vec2 mouse_direction = vec2(0., 0.);

uniform float u_size = 4.0;
uniform float u_curl_weight = 0.00;
uniform float u_grad_weight = 0.5;
uniform float u_heat = 0.00;
uniform int u_mouse = 0; 

/**
 * procedural white noise
 */
highp float rand(vec2 co)
{
  highp float a = 12.9898;
  highp float b = 78.233;
  highp float c = 43758.5453;
  highp float dt= dot(co.xy ,vec2(a,b));
  highp float sn= mod(dt,3.14);
  return fract(sin(sn) * c);
}

const float PI = 3.141592653589;
const float TAU = 2. * PI;

float rnd(vec2 st, float time){
	return fract(sin(dot(st + time * 0.001, vec2(14.9898,78.233))) * 43758.5453);
}

float rndact(vec2 st, float a, float time){
	return fract((rnd(st, time)*10.0 + rnd(st*a, time)*10.0 + rnd(mouse_position, time)*10.0)+0.99);
}

float rgb2h(vec3 c, vec2 st, float a, float time) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	if (hsv.z < 0.1){
		return rndact(st, a, time);
	}
	if (hsv.z > 0.1){
		return hsv.x;	
	}
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

vec2 vecAngle(float a){
	return vec2(cos(a), sin(a));
}

float dotAngles(float a, float b){
	return dot(vecAngle(a), vecAngle(b));
}

vec3 texture2D(sampler2D tex, vec2 uv) {
  return textureLod(tex, uv, 0.0).rgb;
}

vec3 getGradientAndCurl(vec2 pos, vec2 sz, sampler2D screen, float time){
  float sumCurl = 0.0;
  float sumWeights = 0.0;
  float sumGradientX = 0.0;
  float sumGradientY = 0.0;
  vec2 st = pos * sz;
  for (float y = -u_size; y <= u_size; y++) {
    for(float x = -u_size; x <= u_size; x++) {
      vec3 color = texture2D(screen, st + sz * vec2(x, y)).rgb;
      float angleGrad = TAU * rgb2h(color, pos, sumGradientX, time);
      sumGradientX += cos(angleGrad);
      sumGradientY += sin(angleGrad);
      float weight = ((sqrt(x*x+y*y))/(2.0 * sqrt(u_size)));

      float angleCurl = rgb2h(color, pos, sumCurl, time)*TAU;
      sumCurl += ( dotAngles(angleCurl, (atan(-x,y))) * weight );
      sumWeights += weight;
    }
  }
  float norm = sqrt(sumGradientX * sumGradientX + sumGradientY * sumGradientY);

  return vec3(sumGradientX/norm, sumGradientY/norm, sumCurl * u_curl_weight / sumWeights);
}

float iter(vec2 pos, vec2 sz, sampler2D screen, float time){
  vec2 st = pos * sz;
  vec3 color = texture2D(screen, st).rgb;
  
  float hereAngle = TAU * rgb2h(color, pos, 0.0, time);
  vec3 gradAndCurl = getGradientAndCurl(pos, sz, screen, time);
  float curl = gradAndCurl.z;
  vec2 gradient = gradAndCurl.xy;
  float heat_var = (rndact(pos, hereAngle, time)*2.0-1.0)*u_heat;
  float angle_grad = atan(gradient.y, gradient.x);
  float gradient_v = diffAngles(angle_grad,hereAngle) * u_grad_weight;
  float delta = gradient_v + heat_var + curl;
  float outAngle = hereAngle + delta;
  if (outAngle > TAU){
    outAngle -= TAU;
  }
  if (outAngle < 0.0){
    outAngle += TAU;
  }
  outAngle /= TAU;
  return outAngle;
}

void fragment() {
  vec2 sz = SCREEN_PIXEL_SIZE;
  vec2 st = SCREEN_UV;
  vec2 pos = FRAGCOORD.xy;

  vec2 uv_flip = SCREEN_UV;
  uv_flip.y = 1.0 - uv_flip.y;
  vec2 distance_to_mouse = (st / sz) - mouse_position; 
  
  vec3 color = vec3(0.0);
  if (length(distance_to_mouse) < 20.0) {
    if (u_mouse == 0) {
      // random
      color = hsv2rgb(vec3(rnd(st, TIME),1,1));
    } else {
      // direction
      color = hsv2rgb(vec3(mouse_direction.y / TAU, 1.0, 1.0));
    }
  } 
  else  {
    float angle = iter(pos, sz, SCREEN_TEXTURE, TIME);
    color = hsv2rgb(vec3(angle,1,1));
  } 

 COLOR.rgb = color;
}