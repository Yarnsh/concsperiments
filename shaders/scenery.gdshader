// NOTE: Shader automatically converted from Redot Engine LTS 26.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley;

uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap, repeat_enable;

void vertex() {
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);

	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;

	ALBEDO = albedo_tex.rgb;
	EMISSION = ALBEDO * COLOR.rgb;
}
