/**
 * angle clockwise from north from point A to point B
 *
 * this is visual angle because pixel shifts don't determine loc.
 * this ignores step x/y as we don't generally use those, so this works on all /atom's
 *
 * this is also visual angle because ss13 uses weird CW of N instead of CCW of E angles (which the rest of the math world does).
 */
/proc/get_visual_angle(atom/start, atom/end)
	if(!start || !end)
		return 0
	var/dy =(32 * end.y + end.pixel_y) - (32 * start.y + start.pixel_y)
	var/dx =(32 * end.x + end.pixel_x) - (32 * start.x + start.pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx/dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

/**
 * angle clockwise from north from point A to point B
 *
 * this is visual angle because pixel shifts don't determine loc.
 *
 * this is also visual angle because ss13 uses weird CW of N instead of CCW of E angles (which the rest of the math world does).
 */
/proc/get_visual_angle_raw(start_x, start_y, start_pixel_x, start_pixel_y, end_x, end_y, end_pixel_x, end_pixel_y)
	var/dy = (32 * end_y + end_pixel_y) - (32 * start_y + start_pixel_y)
	var/dx = (32 * end_x + end_pixel_x) - (32 * start_x + start_pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx/dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

/**
 * angle clockwise from north of a certain x / y offset.
 *
 * this is visual angle because pixel shifts don't determine loc.
 *
 * this is also visual angle because ss13 uses weird CW of N instead of CCW of E angles (which the rest of the math world does).
 */
/proc/get_visual_angle_offset(x, y)
	if(!y)
		return (x >= 0) ? 90 : 270
	. = arctan(x/y)
	if(y < 0)
		. += 180
	else if(x < 0)
		. += 360

/**
 * get angle from center of bounding box of entity A to entity B
 *
 * * entity A and entity B may be atoms or movables or both
 * * does not support step x/y values!
 *
 * @return angle between A and B, as degrees **clockwise from north**
 */
/proc/get_centered_entity_tile_angle(atom/A, atom/B)
	var/dx = B.x * WORLD_ICON_SIZE - A.x * WORLD_ICON_SIZE
	var/dy = B.y * WORLD_ICON_SIZE - A.y * WORLD_ICON_SIZE
	return arctan(dy, dx)
