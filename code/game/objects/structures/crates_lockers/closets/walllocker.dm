//added by cael from old bs12
//not sure if there's an immediate place for secure wall lockers, but i'm sure the players will think of something

/obj/structure/closet/walllocker
	desc = "A wall mounted storage locker."
	name = "Wall Locker"
	icon = 'icons/obj/closets/bases/wall.dmi'
	icon_state = "base"
	density = 0
	anchored = 1
	icon_closed = "wall-locker"
	icon_opened = "wall-lockeropen"
	closet_appearance = /singleton/closet_appearance/wall

//spawns endless (3 sets) amounts of breathmask, emergency oxy tank and crowbar

/obj/structure/closet/walllocker/emerglocker
	name = "emergency locker"
	desc = "A wall mounted locker with emergency supplies."
	var/list/spawnitems = list(/obj/item/tank/emergency/oxygen,/obj/item/clothing/mask/breath,/obj/item/tool/crowbar/red)
	var/amount = 2 // spawns each items X times.
	closet_appearance = /singleton/closet_appearance/wall/emergency //why aren't these real closets.

/obj/structure/closet/walllocker/emerglocker/toggle(mob/user as mob)
	src.attack_hand(user)
	return

/obj/structure/closet/walllocker/emerglocker/attackby(obj/item/W as obj, mob/user as mob)
	return

/obj/structure/closet/walllocker/emerglocker/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if (istype(user, /mob/living/silicon/ai))	//Added by Strumpetplaya - AI shouldn't be able to
		return									//activate emergency lockers.  This fixes that.  (Does this make sense, the AI can't call attack_hand, can it? --Mloc)
	if(!amount)
		to_chat(usr, "<spawn class='notice'>It's empty..")
		return
	if(amount)
		to_chat(usr, "<spawn class='notice'>You take out some items from \the [src].")
		for(var/path in spawnitems)
			new path(src.loc)
		amount--
	return

/obj/structure/closet/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST

//double-size "cabinet" lockers, from Killian
/obj/structure/closet/walllocker_double
	desc = "A wall mounted storage cabinet."
	name = "Wall Cabinet"
	icon = 'icons/obj/closets/bases/wall_double.dmi'
	density = 0
	anchored = 1
	store_mobs = 0
	wall_mounted = 1
	plane = TURF_PLANE
	layer = ABOVE_TURF_LAYER

/obj/structure/closet/walllocker_double/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker_double/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker_double/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker_double/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker_double/kitchen
	desc = "A wall mounted storage cabinet, for the kitchen. Now where's the flour gone..?"
	name = "Kitchen Cabinet"
	icon = 'icons/obj/closets/bases/wall_double.dmi'
	density = 0
	anchored = 1

/obj/structure/closet/walllocker_double/kitchen/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker_double/kitchen/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker_double/kitchen/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker_double/kitchen/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker_double/medical
	name = "Medical Cabinet"
	desc = "A wall mounted medical supply cabinet. Probably full of drugs!"	//not actually full of drugs, sorry!

/obj/structure/closet/walllocker_double/medical/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker_double/medical/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker_double/medical/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker_double/medical/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker_double/hydrant
	name = "fire-safety closet"
	desc = "It's a storage cabinet packed with fire-fighting supplies."
	anchored = 1
	density = 0

	starts_with = list(
		/obj/item/clothing/suit/fire/firefighter,
		/obj/item/clothing/mask/gas,
		/obj/item/flashlight,
		/obj/item/tank/oxygen/red,
		/obj/item/extinguisher,
		/obj/item/clothing/head/hardhat/red)

/obj/structure/closet/walllocker_double/hydrant/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker_double/hydrant/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker_double/hydrant/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker_double/hydrant/east
	pixel_x = 32
	dir = EAST
