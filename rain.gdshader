// NOTE: Shader automatically converted from Redot Engine LTS 26.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_disabled, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D albedo_tex : repeat_disable, filter_linear, source_color;

void vertex() {
	// Billboard Mode: Y-Billboard
	/*MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			vec4(normalize(cross(vec3(0.0, 1.0, 0.0), MAIN_CAM_INV_VIEW_MATRIX[2].xyz)), 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(normalize(cross(MAIN_CAM_INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
			MODEL_MATRIX[3]);*/
	//MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

	// Billboard Keep Scale: Enabled
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	vec4 tex = texture(albedo_tex, UV);

	ALBEDO = albedo.rgb * tex.rgb * COLOR.rgb;
	ALPHA = albedo.a * tex.a * COLOR.a;
}
