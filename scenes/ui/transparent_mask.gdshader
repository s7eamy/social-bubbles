shader_type canvas_item;

uniform vec2 mask_position; // Position of the mask in local coordinates
uniform vec2 mask_size;     // Size of the mask (width and height)
uniform vec4 panel_color = vec4(1.0, 1.0, 1.0, 1.0); // Panel color with default value

void fragment() {
    vec2 uv = FRAGCOORD.xy;

    // Check if the current fragment is inside the mask rectangle
    if (uv.x > mask_position.x && uv.x < mask_position.x + mask_size.x &&
        uv.y > mask_position.y && uv.y < mask_position.y + mask_size.y) {
        discard; // Make it transparent
    }

    COLOR = panel_color;
}
