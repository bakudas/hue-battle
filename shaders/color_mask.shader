shader_type canvas_item;

// The color, vector4, for the color used for masking.
uniform vec4 masking_color : hint_color;
// A float for how strong the masking effect will be.
uniform float masking_range = 0.1;

void fragment()
{
	// Get the World (I.E on the screen) pixel from the screen texture at the position of the this fragment pixel.
	// (in other words, get the pixel underneath the pixel we are drawing)
	vec4 world_pixel = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	// First, take the masking color and the world pixel and subtract them. This will give us the difference.
	//
	// However, because we don't know which texture is stronger/higher in value than the other, we need to get the absolute value using abs.
	//
	// Then, get the length of hte absolute difference of the two colors and check if it is MORE than the color mask range. If it is, then discard
	// the pixel. Discarding means the pixel at this fragment position will NOT be drawn.
	// This makes the sprite only draw if it IS on the masking color.
	if (length(abs(masking_color - world_pixel)) >= masking_range)
	{
		discard;
	}
}