shader_type spatial;
render_mode blend_mix,depth_draw_never,cull_disabled,diffuse_burley,specular_disabled,unshaded,depth_test_disabled,shadows_disabled,ambient_light_disabled;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform highp sampler2D texture_depth : hint_depth_texture;
uniform float thing_size;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	
	vec4 vert = vec4(VERTEX, 1.0);
	vert = MODELVIEW_MATRIX  * vert;
	vert = PROJECTION_MATRIX * vert;
	vec3 vert2 = vert.xyz;
	vert2.xyz /= vert.w;
	
	vec2 depth_uv = (vert2.xy + 1.0) / 2.0;
	
	vec4 depth = texture(texture_depth, depth_uv);
	
	//if (vert2.z <= (depth.x * 2.0) - 1.0) {
	if (vert2.z > depth.x) {
		VERTEX+=vec3(UV.x - 0.5, -UV.y + 0.5, 0.0)*thing_size;
	}
}

void fragment() {
	//float depth = texture(DEPTH_TEXTURE, SCREEN_UV).y;
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb * COLOR.rgb;
	ALPHA = albedo.a * albedo_tex.a;
}