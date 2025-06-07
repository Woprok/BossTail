shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 in_color : source_color = vec4(0.36, 0.67, 0.33, 1.0);
uniform vec4 out_color : source_color = vec4(1.0, 0.0, 0.1647, 1.0);
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Make texture be a circle
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);
	vec4 base_color = texture(TEXTURE, UV);
	bool is_target_color = distance(base_color.rgb, in_color.rgb) < 0.05;
	bool is_out_color = distance(base_color.rgb, out_color.rgb) < 0.05;
    if (dist > 0.50) {
        discard;
    }
	else if (dist > 0.47 && (is_target_color || is_out_color)) {
        COLOR = border_color;
    }
	else {

		float cutoff = 1.0 - progress;
		bool in_progress_zone = UV.y > cutoff;
	    // Show only if within fill range
	    if (in_progress_zone && is_target_color) {
	        COLOR = out_color;
	    } else {
	        COLOR = base_color;
	    }
	}
}