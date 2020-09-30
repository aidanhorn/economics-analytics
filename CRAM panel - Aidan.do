* Appending NIDS-CRAM waves into a panel. (Tidy format.)
* This script needs to be edited when future waves are released.
* Aidan Horn (hrnaid001@myuct.ac.za)
* SALDRU, University of Cape Town
* Oct 2020

glo NIDS "C:\Users\hrnaid001\Dropbox\Economics\Survey data\NIDS"
cd "$NIDS"

clear all

local i=1
while `i'<=2 {
	global VersionIN: dir "$NIDS\CRAM Wave `i'" files "NIDS-CRAM_*.dta", respectcase
	global VersionIN = subinstr($VersionIN,"NIDS-CRAM_Wave`i'_","",.)
	global VersionIN = subinstr("$VersionIN",".dta","",.)

	use "$NIDS\CRAM Wave `i'\NIDS-CRAM_Wave`i'_$VersionIN.dta"	// "W1_" needs to be taken out of the Wave 1 file names.
	merge 1:1 pid using "$NIDS\CRAM Wave `i'\derived_NIDS-CRAM_Wave`i'_$VersionIN.dta"
	drop _merge
	
	rename w`i'_* *
	gen wave = `i'
	lab var wave "Wave"
	save wave`i'_merged, replace
	local ++i
}

use wave1_merged, clear
append using wave2_merged

merge m:1 pid using "$NIDS\CRAM Wave 2\Link_File_NIDS-CRAM_Wave2_$VersionIN.dta"
cap drop _merge

save CRAM12.dta, replace

erase wave1_merged.dta
erase wave2_merged.dta

