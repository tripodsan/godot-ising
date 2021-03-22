shader_type canvas_item;

const float PI = 3.141592653589;
const float TAU = 2. * PI;
const float STEP = 10.0;

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
  vec2 uv = floor(FRAGCOORD.xy / STEP) * STEP * TEXTURE_PIXEL_SIZE; 
  //vec2 uv = FRAGCOORD.xy * TEXTURE_PIXEL_SIZE; 
  
  vec2 v = texture(TEXTURE, uv).xy * 2.0 - vec2(1);
  float a = atan(v.y, v.x);
  if (a < 0.0){
    a += TAU;
  }
  a /= TAU;
  
  
  // Curdled Milk Mode
  //COLOR.rgb = mix(vec3(248.0/255.0,249.0/255.0,222.0/255.0),vec3(240.0/255.0,242.0/255.0,205.0/255.0), a);
    
  // Volcanic Vents Mode
  // COLOR.rgb = mix(vec3(87.0/255.0,90.0/255.0,108.0/255.0),vec3(135.0/255.0,143.0/255.0,198.0/255.0), a);

  // hue mode
  COLOR.rgb = hsv2rgb(vec3(a, 1.0, 1.0));
    
}