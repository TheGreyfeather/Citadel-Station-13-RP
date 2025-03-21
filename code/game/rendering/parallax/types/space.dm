/datum/parallax/space

/datum/parallax/space/CreateObjects()
	. = ..()
	. += new /atom/movable/screen/parallax_layer/space/layer_1
	. += new /atom/movable/screen/parallax_layer/space/layer_2
	. += new /atom/movable/screen/parallax_layer/space/layer_3

/atom/movable/screen/parallax_layer/space/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1
	parallax_intensity = PARALLAX_LOW

/atom/movable/screen/parallax_layer/space/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2
	parallax_intensity = PARALLAX_MED

/atom/movable/screen/parallax_layer/space/layer_3
	icon_state = "layer3"
	speed = 1.4
	layer = 3
	parallax_intensity = PARALLAX_HIGH

/atom/movable/screen/parallax_layer/space/random
	blend_mode = BLEND_OVERLAY
	speed = 3
	layer = 3
	parallax_intensity = PARALLAX_INSANE

/atom/movable/screen/parallax_layer/space/random/space_gas
	icon_state = "space_gas"

/atom/movable/screen/parallax_layer/space/random/asteroids
	icon_state = "asteroids"
