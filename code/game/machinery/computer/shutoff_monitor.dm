/obj/machinery/computer/shutoff_monitor
	name = "automated shutoff valve monitor"
	desc = "Console used to remotely monitor shutoff valves on the station."
	icon_keyboard = "power_key"
	icon_screen = "power_monitor"
	light_color = "#a97faa"
	circuit = /obj/item/circuitboard/shutoff_monitor
	var/datum/tgui_module_old/shutoff_monitor/monitor

/obj/machinery/computer/shutoff_monitor/Initialize(mapload)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/shutoff_monitor/Destroy()
	QDEL_NULL(monitor)
	..()

/obj/machinery/computer/shutoff_monitor/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	..()
	monitor.ui_interact(user)

/obj/machinery/computer/shutoff_monitor/update_icon()
	..()
	if(!(machine_stat & (NOPOWER|BROKEN)))
		add_overlay("ai-fixer-empty")
	else
		cut_overlay("ai-fixer-empty")
