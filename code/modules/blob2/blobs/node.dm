var/list/blob_nodes = list()

/obj/structure/blob/node
	name = "blob node"
	base_name = "node"
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	integrity_max = 50
	health_regen = 3
	point_return = 50

/obj/structure/blob/node/Initialize(mapload)
	. = ..()
	blob_nodes += src
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/blob/node/Destroy()
	blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/node/update_icon()
	cut_overlays()
	. = ..()
	var/list/overlays_to_add = list()
	color = null
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		name = "[overmind.blob_type.name] [base_name]"
		blob_overlay.color = overmind.blob_type.color
	overlays_to_add += blob_overlay
	overlays_to_add += mutable_appearance('icons/mob/blob.dmi', "blob_node_overlay")

	add_overlay(overlays_to_add)

/obj/structure/blob/node/process(delta_time)
	set waitfor = FALSE
	if(overmind) // This check is so that if the core is killed, the nodes stop.
		pulse_area(overmind, 10, BLOB_NODE_PULSE_RANGE, BLOB_NODE_EXPAND_RANGE)
