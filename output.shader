shader_type canvas_item;

const float PI = 3.141592653589;
const float TAU = 2. * PI;
const float STEP = 20.0;

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
  vec2 fc = vec2(SCREEN_UV.x / SCREEN_PIXEL_SIZE.x, 1.0 - SCREEN_UV.y / SCREEN_PIXEL_SIZE.y);
  vec2 pos = floor(fc.xy / STEP) * STEP + STEP/2.0;
  vec2 uv = (floor(UV / TEXTURE_PIXEL_SIZE / STEP) * STEP + STEP / 2.0) * TEXTURE_PIXEL_SIZE;

  // sample angle
  vec2 vs = texture(TEXTURE, uv).xy * 2.0 - vec2(1);
  float as = atan(vs.y, vs.x);
  if (as < 0.0){
    as += TAU;
  }
  as /= TAU;

  // real angle
  vec2 v = texture(TEXTURE, UV).xy * 2.0 - vec2(1);
  float a = atan(v.y, v.x);
  if (a < 0.0){
    a += TAU;
  }
  a /= TAU;
  vec3 hue = hsv2rgb(vec3(a, .5, 1.0));
  
  // translate center a bit back
  fc += vs * STEP / 2.1;
  // vector from center of cell to frag coord
  vec2 d = fc - pos;
  // angle of vector
  float b = atan(d.y, d.x);
  if (b < 0.0){
    b += TAU;
  }
  b /= TAU;
  COLOR.rgb = mix(vec3(0), hue, smoothstep(0, 0.04, abs(as-b)) );
  
  
  // Curdled Milk Mode
  //COLOR.rgb = mix(vec3(248.0/255.0,249.0/255.0,222.0/255.0),vec3(240.0/255.0,242.0/255.0,205.0/255.0), a);
    
  // Volcanic Vents Mode
  // COLOR.rgb = mix(vec3(87.0/255.0,90.0/255.0,108.0/255.0),vec3(135.0/255.0,143.0/255.0,198.0/255.0), a);

  // hue mode
  //COLOR.rgb = hsv2rgb(vec3(a, 1.0, 1.0));
    
}