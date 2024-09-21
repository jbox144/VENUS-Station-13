//Technically the same as /datum/action/small_sprite but for our macro players (I'm one of them)

/datum/action/sizecode_smallsprite
	name = "Toggle Giant Sprite"
	desc = "Others will always see you as giant"
	icon_icon = 'icons/mob/screen_gen_old.dmi'
	button_icon_state = "health1"
	background_icon_state = "bg_alien"
	var/small = FALSE
	//var/image/small_icon

/datum/action/sizecode_smallsprite/Trigger()
	. = ..()
	if(!owner)
		return

	if(!small)
		var/image/I = image(icon = owner.icon, icon_state = owner.icon_state, loc = owner, layer = owner.layer, pixel_x = owner.pixel_x, pixel_y = owner.pixel_y)
		I.override = TRUE
		I.overlays += owner.overlays
		owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smallsprite_sizecode", I)
		//small_icon = I
	else
		owner.remove_alt_appearance("smallsprite_sizecode")

	small = !small
	return TRUE
