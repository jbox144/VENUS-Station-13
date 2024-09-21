/datum/atom_hud/data/human/antagtarget
	hud_icons = list(ANTAGTARGET_HUD)

/***********************************************
 Mob's target prefs
************************************************/

/mob/living/carbon/human/proc/set_antag_target_indicator()
	var/image/holder = hud_list[ANTAGTARGET_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size

	if(!client || !client.prefs) // No client / prefs, show nothing
		holder.icon_state = null
		return

	var/mob/living/carbon/human/H = client.mob
	if(!istype(H)) // Not human, show nothing
		holder.icon_state = null
		return

	var/datum/antagonist/slaver/S = locate() in H.mind.antag_datums
	if(S) // Is a slaver antag. Slavers do not need to see eachother's consent prefs.
		holder.icon_state = null
		return

	if(client.prefs.be_victim)
		switch(client.prefs.be_victim)
			if(BEVICTIM_NO)
				holder.icon_state = "hudtarget-no"
				return
			if(BEVICTIM_YES)
				holder.icon_state = "hudtarget-yes"
				return

	holder.icon_state = "hudtarget-ask"
