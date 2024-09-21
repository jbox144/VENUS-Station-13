//Jessie Added this
/datum/techweb_node/bluespace_power_reactor
	id = "bluespace_power_reactor"
	display_name = "Bluespace Power Reactor Technology"
	description = "Even more powerful.. POWA!!!"
	prereq_ids = list("adv_power", "adv_bluespace","bluespace_power")
	design_ids = list("bluespace_cell_reactor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

// Bags of holding node
/datum/techweb_node/bluespace_holding/New()
	// Define extra designs
	var/list/added_designs = list(
		"wallet_holding"
	)

	// Add designs to the list
	LAZYADD(design_ids, added_designs)

	// Return
	. = ..()
