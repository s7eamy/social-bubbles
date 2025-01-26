shader_type canvas_item;

uniform vec2 center = vec2(0.5);
uniform vec4 inner_color : source_color;
uniform vec4 outer_color : source_color;

void fragment() {
    //vec2 uv = FRAG_COORD.xy / radius
	vec2 uv = UV;
    float dist = length(uv - center);
	float factor = smoothstep(0.0, 1.0, dist);
    vec4 color = mix(inner_color, outer_color, factor);
    COLOR = color;
}
