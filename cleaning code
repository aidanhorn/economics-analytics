log using "MustIClean", replace
* The following program cleans variables and shows what has been done, with label lists for you to check everything.
local NegClean = 0
local SpecialValuesClean = 0
local MissingValues "inlist(\`Var', 88, 89, 99, 888, 999, 8888, 9999)"	// these are the error values in your data.
foreach Var of varlist _all { 	// change varlist for this program to run quicker.
	capture confirm numeric variable `Var', exact 	// Is `Var' numeric? -count- will give an error if not.
	if !_rc {
		quietly count if `Var' <= 0 | `MissingValues'
		if r(N) == 0 {		// Don't bother about those variables that do not have dubious values.
		}
		else {
			di ""
			di "count if `Var' == 0"
			count if `Var' == 0
			di "count if `Var' < 0"
			count if `Var' < 0
				if r(N) > 0 {
					local NegYes = 1	// I'll use this to count how many variables are cleaned.
				}
				else {
					local NegYes = 0
				}
			di "count if `MissingValues'"
			count if `MissingValues'
				if r(N) > 0 {
					local WeirdYes = 1
				}
				else {
					local WeirdYes = 0
				}
			local ValueLabel: value label `Var'		// captures the value label for `Var'
			if "`ValueLabel'" != "" {		// prevents the program from displaying EVERY single value label list
				label list `ValueLabel'		// This is for you to check what needs cleaning.
			}
			
			replace `Var' = .	if `Var' < 0		// The cleaning machine.
			if `NegYes' == 1 {
				local NegClean = `NegClean' + 1
			}
			
			quietly count if `Var' > 10000 & `Var' < .		// This number needs to be above your highest error value.
			if r(N) > 0 {		// exclude continuous variables (i.e. income variables) - Do you think this is a neat trick?
			}
			else  {
				replace `Var' = .	if `MissingValues'		// The cleaning machine.
				if `WeirdYes' == 1	{
					local SpecialValuesClean = `SpecialValuesClean' + 1
				}
			}
			
		}
	}
}
di "Negative values were made missing on `NegClean' variables." // 0
/* This can be confirmed with the following code:
foreach Var of varlist _all {
	capture confirm numeric variable `Var', exact 	// Is `Var' numeric? -count- will give an error if not.
	if !_rc {
		quietly count if `Var' < 0
		if r(N) > 0 {
			di "`Var' has r(N) negative values"
		}
	}
}
*/
di "Weird values, like 8888, were made missing on `SpecialValuesClean' variables."

log close	
view "MustIClean.smcl" // check log file for output
