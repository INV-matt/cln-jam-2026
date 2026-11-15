shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec4 color : source_color;
uniform vec4 grid_color: source_color;
uniform float grid_width : hint_range(0, 1) = 0.05;
uniform float grid_dim = 2;
uniform vec3 dimensions = vec3(1, 1, 1);
void fragment() {
	// Called for every pixel the material is visible on.
  vec2 scaled_uv = UV * dimensions.xy;
  
  ALBEDO = vec3(color.rgb);
  float dx = mod(scaled_uv.x / grid_dim, 1.);
  float dy = mod(scaled_uv.y / grid_dim, 1.);
  
  if (dx < grid_width / 2.) ALBEDO = vec3(grid_color.rgb);
  if (dy < grid_width / 2.) ALBEDO = vec3(grid_color.rgb);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
