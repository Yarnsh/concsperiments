shader_type spatial;

render_mode unshaded, cull_back, fog_disabled;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// TODO: need the depth of all visual things, so throw this material on the camera once I get that set up
	float depth = FRAGCOORD.z;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	ALBEDO = vec3(1.0 - SCREEN_UV.x, 1.0 - (linear_depth / 50.0), 1.0 - SCREEN_UV.y);
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
}