shader_type sky;

uniform vec3 skyColor: source_color;
uniform vec3 horizonColor: source_color;
uniform sampler2D skyTexture;
void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	float col = clamp(EYEDIR.y / 0.05, 0.0, 1.0);
	vec3 finalcolor = mix(horizonColor, skyColor, col);
	COLOR = texture(skyTexture, vec2(SKY_COORDS.x + TIME / 200.0, SKY_COORDS.y)).rgb;
}
