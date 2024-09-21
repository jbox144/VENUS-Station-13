/obj/structure/lavaland/ash_walker/spawn_mob() //Rewrite of the one in code\modules\ruins\objects_and_mobs\ash_walker_den.dm
	if(meat_counter < ASH_WALKER_SPAWN_THRESHOLD)
		return
	new spawned_obj(get_step(loc, pick(GLOB.alldirs)), ashies)
	visible_message(span_danger("One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!"))
	meat_counter -= ASH_WALKER_SPAWN_THRESHOLD

/obj/structure/lavaland/ash_walker/western
	spawned_obj = /obj/effect/mob_spawn/human/ash_walker/western
	species = /datum/species/lizard/ashwalker/western

/obj/structure/lavaland/ash_walker/eastern
	spawned_obj = /obj/effect/mob_spawn/human/ash_walker/eastern
	species = /datum/species/lizard/ashwalker/eastern
