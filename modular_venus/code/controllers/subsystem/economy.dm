/datum/controller/subsystem/economy/proc/distribute_funds(amount)
	var/distribution_sum = 0
	for(var/datum/bank_account/department/D in department_accounts)
		distribution_sum += D.budget_ratio
	var/single_part = round(amount / distribution_sum)
	for(var/datum/bank_account/department/D in department_accounts)
		D.adjust_money(single_part * D.budget_ratio)
		if(D.nonstation_account)
			D.adjust_money(amount) // Who'd think Nanotrasen gets a lot of profit from your station
