// I'm copy/pasting this functionality so I can override shit without it being a major pain
/atom/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(!. && user.client)
		if(!(IsAdminGhost(user) || user?.client.prefs.inquisitive_ghost) && (CONFIG_GET(flag/ghost_interaction) && istype(src, /mob/living)))
			var/mob/living/H = src
			H.do_ass_slap(user)

// I'm putting this here because honestly i'm too lazy to find the thing i need
/mob/living/proc/do_ass_slap(mob/dead/observer/user)
	var/mob/living/carbon/human/H = src
	if(src.client?.prefs.cit_toggles & NO_ASS_SLAP)
		to_chat(user, "Your ethereal hand phases through \The [src].")
		return
	playsound(src.loc, 'sound/weapons/slap.ogg', 50, 1, -1)
	if(HAS_TRAIT(src, TRAIT_STEEL_ASS))
		to_chat(src, span_danger("You feel something bounce off your steely asscheeks, but nothing is there..."))
		to_chat(user, span_danger("You slap \The [src]'s ass, but your ethereal hand bounces right off!"))
		playsound(src.loc, 'sound/weapons/tap.ogg', 50, 1, -1)
		return
	if(istype(H))
		H.adjust_arousal(20, "masochism", maso=TRUE)
		if(HAS_TRAIT(H, TRAIT_MASO) && H.has_dna() && prob(10))
			H.mob_climax(forced_climax=TRUE, cause="masochism")
	if(!HAS_TRAIT(src, TRAIT_PERMABONER))
		H.dna.species.stop_wagging_tail(src)
	playsound(src.loc, 'sound/weapons/slap.ogg', 50, 1, -1)
	src.visible_message(\
		span_danger("You hear someone slap \The [src]'s ass, but nobody's there..."),\
		span_notice("Somebody slaps your ass, but nobody is around..."),\
		"You hear a slap.", target=user, target_message=span_notice("You manage to will your ethereal hand to slap \The [src]'s ass."))
	return
