//Xenobio control console
/mob/camera/aiEye/remote/xenobio
	visible_icon = TRUE
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "generic_camera"
	var/allowed_area = null

/mob/camera/aiEye/remote/xenobio/Initialize(mapload)
	var/area/A = get_area(loc)
	allowed_area = A.name
	. = ..()

/mob/camera/aiEye/remote/xenobio/setLoc(turf/destination)
	var/area/new_area = get_area(destination)
	if(new_area && new_area.name == allowed_area || new_area && new_area.xenobiology_compatible)
		return ..()
	else
		return

/obj/machinery/computer/camera_advanced/xenobio
	name = "Slime management console"
	desc = "A computer used for remotely handling slimes."
	networks = list("ss13")
	circuit = /obj/item/circuitboard/computer/xenobiology
	var/datum/action/innate/slime_place/slime_place_action = /datum/action/innate/slime_place
	var/datum/action/innate/slime_pick_up/slime_up_action = /datum/action/innate/slime_pick_up
	var/datum/action/innate/feed_slime/feed_slime_action = /datum/action/innate/feed_slime
	var/datum/action/innate/monkey_recycle/monkey_recycle_action = /datum/action/innate/monkey_recycle
	var/datum/action/innate/slime_scan/scan_action = /datum/action/innate/slime_scan
	var/datum/action/innate/feed_potion/potion_action = /datum/action/innate/feed_potion
	var/datum/action/innate/hotkey_help/hotkey_help = /datum/action/innate/hotkey_help

	var/obj/machinery/monkey_recycler/connected_recycler
	var/list/stored_slimes
	var/obj/item/slimepotion/slime/current_potion
	var/max_slimes = 10
	var/monkeys = 0

	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	. = ..()

	generate_actions()

	stored_slimes = list()
	for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
		if(get_area(recycler.loc) == get_area(loc))
			connected_recycler = recycler
			connected_recycler.connected += src

/obj/machinery/computer/camera_advanced/xenobio/proc/generate_actions()
	actions += new scan_action(src)
	actions += new hotkey_help(src)

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	QDEL_NULL(current_potion)
	for(var/thing in stored_slimes)
		var/mob/living/simple_animal/slime/S = thing
		S.forceMove(drop_location())
	stored_slimes.Cut()
	if(connected_recycler)
		connected_recycler.connected -= src
	connected_recycler = null
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/handle_atom_del(atom/A)
	if(A == current_potion)
		current_potion = null
	if(A in stored_slimes)
		stored_slimes -= A
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/examine(mob/user)
	. = ..()
	if(monkeys)
		. += span_notice("There [monkeys == 1 ? "is" : "are"] [monkeys] monkey\s stored.")
	var/slime_amount = length(stored_slimes)
	if(slime_amount)
		. += span_notice("There [slime_amount == 1 ? "is" : "are"] [slime_amount] slime\s stored.")
	if(current_potion)
		. += span_notice("[current_potion] is currently loaded, press <b>Alt-click</b> to eject.")

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/xenobio(get_turf(src))
	eyeobj.origin = src
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/cameramob.dmi'
	eyeobj.icon_state = "generic_camera"

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	..()

	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL, PROC_REF(XenoSlimeClickCtrl))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT, PROC_REF(XenoSlimeClickAlt))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT, PROC_REF(XenoSlimeClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT, PROC_REF(XenoTurfClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL, PROC_REF(XenoTurfClickCtrl))
	RegisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL, PROC_REF(XenoMonkeyClickCtrl))

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL)
	..()

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/snacks/cube/monkey))
		monkeys++
		to_chat(user, span_notice("You feed [O] to [src]. It now has [monkeys] monkey cubes stored."))
		qdel(O)
		return
	else if(istype(O, /obj/item/storage/bag))
		var/obj/item/storage/P = O
		var/loaded = FALSE
		for(var/obj/G in P.contents)
			if(istype(G, /obj/item/reagent_containers/food/snacks/cube/monkey))
				loaded = TRUE
				monkeys++
				qdel(G)
		if(loaded)
			to_chat(user, span_notice("You fill [src] with the monkey cubes stored in [O]. [src] now has [monkeys] monkey cubes stored."))
		return
	else if(istype(O, /obj/item/slimepotion/slime))
		var/replaced = FALSE
		if(user && !user.transferItemToLoc(O, src))
			return
		if(!QDELETED(current_potion))
			current_potion.forceMove(drop_location())
			replaced = TRUE
		current_potion = O
		to_chat(user, span_notice("You load [O] in the console's potion slot[replaced ? ", replacing the one that was there before" : ""]."))
		return
	..()

/obj/machinery/computer/camera_advanced/xenobio/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I) && istype(I.buffer,/obj/machinery/monkey_recycler))
		to_chat(user, "<span class='notice'>You link [src] with [I.buffer] in [I] buffer.</span>")
		connected_recycler = I.buffer
		connected_recycler.connected += src
		return TRUE

/datum/action/innate/slime_place
	name = "Place Slimes"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/Activate()
	if(QDELETED(owner) || !isliving(owner))
		return
	var/mob/camera/aiEye/remote/xenobio/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in X.stored_slimes)
			S.forceMove(remote_eye.loc)
			S.visible_message("[S] warps in!")
			X.stored_slimes -= S
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))

/datum/action/innate/slime_pick_up
	name = "Pick up Slime"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_up"

/datum/action/innate/slime_pick_up/Activate()
	if(QDELETED(owner) || !isliving(owner))
		return
	var/mob/camera/aiEye/remote/xenobio/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			if(X.stored_slimes.len >= X.max_slimes)
				break
			if(!S.ckey)
				if(S.buckled)
					S.Feedstop(silent = TRUE)
				S.visible_message("[S] vanishes in a flash of light!")
				S.forceMove(X)
				X.stored_slimes += S
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))


/datum/action/innate/feed_slime
	name = "Feed Slimes"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_down"

/datum/action/innate/feed_slime/Activate()
	if(QDELETED(owner) || !isliving(owner))
		return
	var/mob/camera/aiEye/remote/xenobio/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		if(X.monkeys >= 1)
			var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(remote_eye.loc, TRUE, owner)
			if (!QDELETED(food))
				food.LAssailant = WEAKREF(owner)
				X.monkeys--
				X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
				to_chat(owner, span_notice("[X] now has [X.monkeys] monkey(s) left."))
		else
			to_chat(owner, span_warning("[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored."))
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))


/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/Activate()
	if(QDELETED(owner) || !isliving(owner))
		return
	var/mob/camera/aiEye/remote/xenobio/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler

	if(!recycler)
		to_chat(owner, "<span class='notice'>There is no connected monkey recycler.  Use a multitool to link one.</span>")
		return
	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/carbon/monkey/M in remote_eye.loc)
			if(M.stat)
				M.visible_message("[M] vanishes as [M.p_theyre()] reclaimed for recycling!")
				recycler.use_power(500)
				X.monkeys += recycler.cube_production
				X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
				qdel(M)
				to_chat(owner, "[X] now has [X.monkeys] monkeys available.")
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))

/datum/action/innate/slime_scan
	name = "Scan Slime"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_scan"

/datum/action/innate/slime_scan/Activate()
	if(QDELETED(owner) || !isliving(owner))
		return
	var/mob/camera/aiEye/remote/xenobio/remote_eye = owner.remote_control

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			slime_scan(S, owner)
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))

/datum/action/innate/feed_potion
	name = "Apply Potion"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_potion"

/datum/action/innate/feed_potion/Activate()
	if(QDELETED(owner) || !isliving(owner))
		return

	var/mob/camera/aiEye/remote/xenobio/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(QDELETED(X.current_potion))
		to_chat(owner, span_notice("No potion loaded."))
		return

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			X.current_potion.attack(S, owner)
			break
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))


//Demodularized Code

//Xenobio Hotkeys Port

/datum/action/innate/hotkey_help
	name = "Hotkey Help"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "hotkey_help"

/datum/action/innate/hotkey_help/Activate()
	if(!target || !isliving(owner))
		return
	var/static/list/help = list(
		"<b>Click shortcuts:</b>",
		"Shift-click a slime to pick it up, or the floor to drop all held slimes. (Requires Basic Slime Console upgrade)",
		"Ctrl-click a slime to scan it.",
		"Alt-click a slime to feed it a potion. (Requires Advanced Slime Console upgrade)",
		"Ctrl-click on a dead monkey to recycle it, or the floor to place a new monkey. (Requires Monkey Console upgrade)",
	)
	to_chat(owner, "<blockquote class='info'>[help.Join("\n")]</blockquote>")

//
// Alternate clicks for slime, monkey and open turf if using a xenobio console

// Scans slime
/mob/living/simple_animal/slime/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_CTRL, src)
	..()

//Feeds a potion to slime
/mob/living/simple_animal/slime/AltClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_ALT, src)
	..()

//Picks up slime
/mob/living/simple_animal/slime/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_SHIFT, src)
	..()

//Place slimes
/turf/open/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_SHIFT, src)
	..()

//Place monkey
/turf/open/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_CTRL, src)
	..()

//Pick up monkey
/mob/living/carbon/monkey/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_MONKEY_CLICK_CTRL, src)
	..()

// Scans slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickCtrl(mob/living/user, mob/living/simple_animal/slime/S)
	if(!GLOB.cameranet.checkTurfVis(S.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/camera/aiEye/remote/xenobio/E = user.remote_control
	var/area/mobarea = get_area(S.loc)
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		slime_scan(S, user)

//Feeds a potion to slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickAlt(mob/living/user, mob/living/simple_animal/slime/S)
	if(!GLOB.cameranet.checkTurfVis(S.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/turf/slime_location = S.loc
	var/mob/camera/aiEye/remote/xenobio/E = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(slime_location)
	if(QDELETED(X.current_potion))
		to_chat(user, span_warning("No potion loaded."))
		return
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		slime_location.balloon_alert(user, "applying [current_potion]")
		X.current_potion.attack(S, user)

//Picks up slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickShift(mob/living/user, mob/living/simple_animal/slime/S)
	if(!GLOB.cameranet.checkTurfVis(S.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/turf/slime_location = S.loc
	var/mob/camera/aiEye/remote/xenobio/E = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(slime_location)
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		if(X.stored_slimes.len >= X.max_slimes)
			to_chat(user, span_warning("Slime storage is full."))
			return
		if(S.ckey)
			to_chat(user, span_warning("The slime wiggled free!"))
			return
		if(S.buckled)
			S.Feedstop(silent = TRUE)
		S.visible_message("[S] vanishes in a flash of light!")
		S.forceMove(X)
		X.stored_slimes += S
		slime_location.balloon_alert(user, "[length(X.stored_slimes)]/[max_slimes] in storage")

//Place slimes
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/open/T)
	if(!GLOB.cameranet.checkTurfVis(T))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/camera/aiEye/remote/xenobio/E = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if(turfarea.name == E.allowed_area || turfarea.xenobiology_compatible)
		for(var/mob/living/simple_animal/slime/S in X.stored_slimes)
			S.forceMove(T)
			S.visible_message("[S] warps in!")
			X.stored_slimes -= S

//Place monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickCtrl(mob/living/user, turf/open/T)
	if(!GLOB.cameranet.checkTurfVis(T))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/camera/aiEye/remote/xenobio/E = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if(turfarea.name == E.allowed_area || turfarea.xenobiology_compatible)
		if(X.monkeys >= 1)
			var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(T, TRUE, user)
			if (!QDELETED(food))
				food.LAssailant = WEAKREF(user)
				X.monkeys--
				X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
				to_chat(user, span_notice("[X] now has [X.monkeys] monkey(s) stored."))
				T.balloon_alert(user, "[X.monkeys] left")
		else
			to_chat(user, span_warning("[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored."))
			T.balloon_alert(user, "no monkeys available")

//Pick up monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoMonkeyClickCtrl(mob/living/user, mob/living/carbon/monkey/M)
	if(!isturf(M.loc) || !GLOB.cameranet.checkTurfVis(M.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/turf/monkey_location = M.loc
	var/mob/camera/aiEye/remote/xenobio/E = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(monkey_location)
	if(!X.connected_recycler)
		to_chat(user, "<span class='notice'>There is no connected monkey recycler.  Use a multitool to link one.</span>")
		return
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		if(!M.stat)
			return
		M.visible_message("[M] vanishes as [p_theyre()] reclaimed for recycling!")
		X.connected_recycler.use_power(500)
		X.monkeys += connected_recycler.cube_production
		X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
		qdel(M)
		to_chat(user, span_notice("[X] now has [X.monkeys] monkey(s) available."))
		monkey_location.balloon_alert(user, "[X.monkeys] available")

/obj/machinery/computer/camera_advanced/xenobio/AltClick(mob/user)
	. = ..()
	if(!QDELETED(current_potion) && user.canUseTopic(src, BE_CLOSE, no_tk = NO_TK))
		to_chat(user, span_notice("You eject [current_potion] from [src]."))
		if(!user.put_in_hands(current_potion))
			current_potion.forceMove(drop_location())
		current_potion = null
