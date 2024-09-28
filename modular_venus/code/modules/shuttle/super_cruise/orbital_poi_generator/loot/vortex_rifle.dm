/obj/item/gun/energy/vortex
	name = "vortex rifle"
	desc = "A powerful rifle of alien origin that fires powerful energy darts."
	icon_state = "vortex"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/vortex)

/obj/item/gun/energy/vortex/examine(mob/user)
	. = ..()
	if(isabductor(user))
		. += "<span class='abductor'>It has a subspace power core installed.</span>"

/obj/item/ammo_casing/energy/vortex
	name = "vortex blast"
	desc = "what the hell?"
	projectile_type = /obj/item/projectile/energy/vortex
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	heavy_metal = FALSE
	e_cost = 100
	select_name = "vortex blast"

/obj/item/projectile/energy/vortex
	name = "vortex beam"
	alpha = 0
	damage = 0
	damage_type = BURN
	is_reflectable = TRUE
	flag = ENERGY
	range = 10
	projectile_phasing = ALL
	projectile_piercing = NONE

/obj/item/projectile/energy/vortex/Range()
	new /obj/effect/temp_visual/hierophant/blast(get_turf(src), firer, FALSE)
	return ..()
