//Yeah, I hate this as well
/area/layenia
	name = "Layenia"
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CULT_PERMITTED
	requires_power = TRUE
	outdoors = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	ambientsounds = MINING
	atmos = FALSE
	flags_1 = NONE

/area/layenia/cloudlayer
	name = "Layenia clouds"
	icon_state = "space"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	atmos = FALSE

/area/layenia/powered
	name = "Layenia Powered"
	icon_state = "centcom"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	flags_1 = NONE
	outdoors = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	atmos = FALSE
