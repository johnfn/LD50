shader_type canvas_item;

uniform bool north = false;
uniform bool south = false;
uniform bool east = false;
uniform bool west = false;

uniform bool southwest = false;
uniform bool southeast = false;
uniform bool northwest = false;
uniform bool northeast = false;

uniform bool shrink_y_check = false;

uniform float top_len = 31.0;

void fragment() {
  float max_r = 0.0;
//  COLOR = vec4(vec3(SCREEN_PIXEL_SIZE.y * 400.0), 1.0);
  
  float screen_uv_y = SCREEN_UV.y;
  if (shrink_y_check && false) {
    float px_move = (430.0 - 256.0) * (1.0 - UV.y);
    screen_uv_y -= px_move * SCREEN_PIXEL_SIZE.y;
  }
  float west_x = SCREEN_UV.x - SCREEN_PIXEL_SIZE.x * (1.0 + 1.0 / TEXTURE_PIXEL_SIZE.x / 4.0 * UV.x);
  float east_x = SCREEN_UV.x + SCREEN_PIXEL_SIZE.x * (1.0 + 1.0 / TEXTURE_PIXEL_SIZE.x / 4.0 * (1.0 - UV.x));
  float north_y = SCREEN_UV.y + SCREEN_PIXEL_SIZE.y * (1.0 + 1.0 / TEXTURE_PIXEL_SIZE.y / 4.0 * UV.y);
  float south_y = SCREEN_UV.y - SCREEN_PIXEL_SIZE.y * (1.0 + 1.0 / TEXTURE_PIXEL_SIZE.y / 4.0 * (1.0 - UV.y));

  bool is_top_face = UV.y / TEXTURE_PIXEL_SIZE.y <= top_len;
  bool is_east_face = (1.0 - UV.x) / TEXTURE_PIXEL_SIZE.x <= top_len;
  bool is_west_face = UV.x / TEXTURE_PIXEL_SIZE.x <= top_len;

  if (south && south_y > 0.0 && south_y < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x, south_y)).r);
  }
  if (north && is_top_face && north_y > 0.0 && north_y < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x, north_y)).r);
  }
  if (west && (!shrink_y_check || is_west_face) && west_x > 0.0 && west_x < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(west_x, screen_uv_y)).r);
  }
  if (east && (!shrink_y_check || is_east_face) && east_x > 0.0 && east_x < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(east_x, screen_uv_y)).r);
  }

  if (southwest && south_y > 0.0 && south_y < 1.0 && west_x > 0.0 && west_x < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(west_x, south_y)).r);
  }
  if (southeast && south_y > 0.0 && south_y < 1.0 && east_x > 0.0 && east_x < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(east_x, south_y)).r);
  }
  if (northwest && is_top_face && north_y > 0.0 && north_y < 1.0 && west_x > 0.0 && west_x < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(west_x, north_y)).r);
  }
  if (northeast && is_top_face && north_y > 0.0 && north_y < 1.0 && east_x > 0.0 && east_x < 1.0) {
    max_r = max(max_r, texture(SCREEN_TEXTURE, vec2(east_x, north_y)).r);
  }

  if (max_r < 0.05)
    COLOR = vec4(vec3(0.0), 1.0);
  else
    COLOR = texture(TEXTURE, UV);
}