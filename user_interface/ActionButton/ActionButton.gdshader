shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // Make texture be a circle
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);
    if (dist > 0.5) {
        discard;
    }
    COLOR = texture(TEXTURE, UV);// * COLOR;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
