/obj/effect/spawner/lootdrop/glowstick/lit/Initialize(mapload)
	. = ..()
	var/obj/item/flashlight/glowstick/found = locate() in get_turf(src)
	if(!found)
		return
	found.on = TRUE
	found.update_icon()
	found.update_brightness()
