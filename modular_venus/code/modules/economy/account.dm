#define BUDGET_RATIO_TYPE_SINGLE 1 // For Service & Civilian budget
#define BUDGET_RATIO_TYPE_DOUBLE 2 // and for the rest

/datum/bank_account/department
	var/budget_ratio = NONE
	var/nonstation_account = TRUE

/datum/bank_account/department/civilian
	budget_ratio = BUDGET_RATIO_TYPE_SINGLE
	nonstation_account = FALSE

/datum/bank_account/department/service
	budget_ratio = BUDGET_RATIO_TYPE_SINGLE
	nonstation_account = FALSE

/datum/bank_account/department/cargo
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE

/datum/bank_account/department/science
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE

/datum/bank_account/department/engineering
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE

/datum/bank_account/department/medical
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE

/datum/bank_account/department/security
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE
