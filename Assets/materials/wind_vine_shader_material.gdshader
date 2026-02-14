shader_type spatial;


uniform float wind_strength = 0.0; // driven by singleton
uniform float wind_speed = 1.0;
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0);
uniform float phase_offset = 0.0;
uniform sampler2D albedo_tex; // no hint at all
uniform vec3 vine_color = vec3(0.0, 1.0, 0.0);

// for swaying
const float MAX_HEIGHT = 5.0;


void vertex() {
	float sway_factor = 1.0 - VERTEX.y / MAX_HEIGHT; // 1 at bottom, 0 at top
	VERTEX.xyz += wind_direction * sin(TIME * wind_speed + phase_offset) * wind_strength * sway_factor * 0.5;
	// simple sway ignoring UV
	//VERTEX.xyz += wind_direction * sin(TIME * wind_speed + phase_offset) * wind_strength * 0.5;
}

void fragment() {
    ALBEDO = vine_color;
}
