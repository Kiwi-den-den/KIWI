cap program drop kiwi2_start
program define kiwi2_start
set more off
set trace off
version 13.1
clear
**************************************************************************************************************************

**************************************************************************************************************************
forvalues x = $start_yr(1)$end_yr {
		global current_year  `x'
		global next_year = 1 + `x'
		local loc "${source}${current_year}"
		cd "`loc'"
		
		global file_prefix "fmli*.dta"

**********************************************Create a log of file names then reads the log to get the file names to import into STATA************	
		! dir  $file_prefix  /s/b > "${source}files_to_append_list.txt" 
		cap file close myfile 
		file open myfile using "${source}files_to_append_list.txt", read
		file read myfile line /* read in the the next line of the list. The list can be manually manipulated if necessary */
		use `line'
		* destring _all, replace /* This fix is only occasionally needed. Can not identify the source of the problem */
		file read myfile line 
		
		local k = 1
while r(eof)==0 & `k'!=4 { /* Sends a rc(1) when the end of the list is reached to terminate the loop*/
		append using `line', force
		file read myfile line 
		local k = `k'+1
	} 
	
	cap destring qintrvmo qintrvyr, replace	
	if qintrvyr<100{
	replace qintrvyr = qintrvyr+1900
	}

**********************************************	
************************************************************************
************************************************************************
*********************************************************************
foreach X of global by_mark{ 

if "`X'"== "Age_of_reference_person"{
	gen  Age_of_reference_person = .
			replace  Age_of_reference_person = 1 if missing(Age_of_reference_person) & age_ref<25
			replace  Age_of_reference_person = 2 if missing(Age_of_reference_person) & age_ref>=25 &  age_ref<=34
			replace  Age_of_reference_person = 3 if missing(Age_of_reference_person) & age_ref>=35	&  age_ref<=44
			replace  Age_of_reference_person = 4 if missing(Age_of_reference_person) & age_ref>= 45 &  age_ref<=54
			replace  Age_of_reference_person = 5 if missing(Age_of_reference_person) & age_ref>= 55 &  age_ref<=64
			replace  Age_of_reference_person = 6 if missing(Age_of_reference_person) & age_ref>= 65 &  age_ref<=74
			replace  Age_of_reference_person = 7 if missing(Age_of_reference_person) & age_ref>= 75 
			
}

if  "`X'"== "Composition_of_consumer_unit"{
		gen Composition_of_consumer_unit = fam_type
			cap destring Composition_of_consumer_unit,replace
			replace Composition_of_consumer_unit = 6 if Composition_of_consumer_unit ==7
			replace Composition_of_consumer_unit = 7 if Composition_of_consumer_unit ==8 | Composition_of_consumer_unit ==9
			
}


if "`X'"== "Quintiles_of_income_before_taxes"{
	cap confirm variable inc_rnkm 
	tempvar by_inc_rnkm
			if !_rc ==0 {
			gen `by_inc_rnkm' = inc_rank
			}
			else {
			gen `by_inc_rnkm' = inc_rnkm
			}
			gen  Quintiles_of_income_before_taxes = cond(`by_inc_rnkm'>=0 & `by_inc_rnkm' <.20,1,.)
			replace  Quintiles_of_income_before_taxes = 2 if missing( Quintiles_of_income_before_taxes) & `by_inc_rnkm'>=0.20 & `by_inc_rnkm' <.4  & `by_inc_rnkm'!=.
			replace  Quintiles_of_income_before_taxes = 3 if missing( Quintiles_of_income_before_taxes) & `by_inc_rnkm'>=0.4  & `by_inc_rnkm' <.6  & `by_inc_rnkm'!=.
			replace  Quintiles_of_income_before_taxes = 4 if missing( Quintiles_of_income_before_taxes) & `by_inc_rnkm'>=0.60 & `by_inc_rnkm' <.80 & `by_inc_rnkm'!=.
			replace  Quintiles_of_income_before_taxes = 5 if missing( Quintiles_of_income_before_taxes) & `by_inc_rnkm'>=0.80 & `by_inc_rnkm' !=.
		
			
			}



if "`X'"== "year"{
gen year = qintrvyr
}

if "`X'"== "Housing_tenure"{
cap destring cutenure, replace 
gen Housing_tenure=cutenure
	replace Housing_tenure =. if Housing_tenure ==3 |Housing_tenure>=5
	
		}



if "`X'"== "Race_of_reference_person"{

cap destring ref_race
 gen Race_of_reference_person=ref_race
}

if "`X'"== "Income_before_taxes"{

cap confirm variable fincbtxm
			if !_rc ==0 {
			gen by_fincbtxm =  fincbtax 
			}
			else {
			gen by_fincbtxm = fincbtxm
			}
			gen Income_before_taxes = . 
			replace Income_before_taxes = 1 if by_fincbtxm<5000 
			replace Income_before_taxes = 2 if by_fincbtxm>=5000 &   by_fincbtxm<=9999 
			replace Income_before_taxes = 3 if by_fincbtxm>=10000 &  by_fincbtxm<=14999 
			replace Income_before_taxes = 4 if by_fincbtxm>=15000 &  by_fincbtxm<=19999 
			replace Income_before_taxes = 5 if by_fincbtxm>=20000 &  by_fincbtxm<=29999 
			replace Income_before_taxes = 6 if by_fincbtxm>=30000 &  by_fincbtxm<=39999 
			replace Income_before_taxes = 7 if by_fincbtxm>=40000 &  by_fincbtxm<=49999 
			replace Income_before_taxes = 8 if by_fincbtxm>=50000 &  by_fincbtxm<=69999 
			replace Income_before_taxes = 9 if by_fincbtxm>=70000 
		
}

if "`X'"== "Size_of_consumer_unit"{
encode fam_size, gen(Size_of_consumer_unit)
	recode Size_of_consumer_unit (5/100=5)
			
}

if "`X'"== "Population_size_of_area_of_residence"{
gen Population_size_of_area_of_residence = popsize

}

if "`X'"== "Number_of_earners_in_consumer_unit"{
gen Number_of_earners_in_consumer_unit = no_earnr
			recode Number_of_earners_in_consumer_unit (5/100=5)
			
}

if "`X'"== "Region_of_residence"{
gen Region_of_residence= region	
}
if "`X'"== "Occupation_of_reference_person"{
gen Occupation_of_reference_person = occucod1 
			replace Occupation_of_reference_person = 1 if Occupation_of_reference_person<=3
			replace Occupation_of_reference_person = 2 if Occupation_of_reference_person>=4 & Occupation_of_reference_person<=7
			replace Occupation_of_reference_person = 3 if Occupation_of_reference_person>=8 & Occupation_of_reference_person<=10
			replace Occupation_of_reference_person = 4 if Occupation_of_reference_person>=11 & Occupation_of_reference_person<=13
			replace Occupation_of_reference_person = 5 if Occupation_of_reference_person>=14 & Occupation_of_reference_person<=15
			replace Occupation_of_reference_person = 6 if Occupation_of_reference_person>=16 & Occupation_of_reference_person<=17
			replace Occupation_of_reference_person = 7 if Occupation_of_reference_person==18
		
}
}
************************************************************************
if ${cpi_add}==1{
	
	if ${current_year} == 1984 {
             global  c_cpi	105.3	
	}	

	if ${current_year} == 1985 {
             global  c_cpi	108.7	
	}	

	if ${current_year} == 1986 {
             global  c_cpi	110.3	
	}	

	if ${current_year} == 1987 {
             global  c_cpi	115.3	
	}	

	if ${current_year} == 1988 {
             global  c_cpi	120.2	
	}	

	if ${current_year} == 1989 {
             global  c_cpi	125.6	
	}	

	if ${current_year} == 1990 {
             global  c_cpi	133.5	
	}	

	if ${current_year} == 1991 {
             global  c_cpi	137.4	
	}	

	if ${current_year} == 1992 {
             global  c_cpi	141.8	
	}	

	if ${current_year} == 1993 {
             global  c_cpi	145.7	
	}	

	if ${current_year} == 1994 {
             global  c_cpi	149.5	
	}	

	if ${current_year} == 1995 {
             global  c_cpi	153.7	
	}	

	if ${current_year} == 1996 {
             global  c_cpi	158.3	
	}	

	if ${current_year} == 1997 {
             global  c_cpi	161.6	
	}	

	if ${current_year} == 1998 {
             global  c_cpi	164	
	}	

	if ${current_year} == 1999 {
             global  c_cpi	168.2	
	}	

	if ${current_year} == 2000 {
             global  c_cpi	174	
	}	

	if ${current_year} == 2001 {
             global  c_cpi	177.7	
	}	

	if ${current_year} == 2002 {
             global  c_cpi	181.3	
	}	

	if ${current_year} == 2003 {
             global  c_cpi	185	
	}	

	if ${current_year} == 2004 {
             global  c_cpi	190.9	
	}	

	if ${current_year} == 2005 {
             global  c_cpi	199.2	
	}	

	if ${current_year} == 2006 {
             global  c_cpi	201.8	
	}	

	if ${current_year} == 2007 {
             global  c_cpi	208.936	
	}	

	if ${current_year} == 2008 {
             global  c_cpi	216.573	
	}	

	if ${current_year} == 2009 {
             global  c_cpi	216.177	
	}	

	if ${current_year} == 2010 {
             global  c_cpi	218.711	
	}	

	if ${current_year} == 2011 {
             global  c_cpi	226.421	
	}	

	if ${current_year} == 2012 {
             global  c_cpi	231.317	
	}	

	if ${current_year} == 2013 {
             global  c_cpi	233.546	
	}	

	if ${cpi_baseyear} == 1984 {	
	 global    base_year	105.3	
	}	

	if ${cpi_baseyear} == 1985 {		
	 global    base_year	108.7	
	}	

	if ${cpi_baseyear} == 1986 {		
	 global    base_year	110.3	
	}	

	if ${cpi_baseyear} == 1987 {		
	 global    base_year	115.3	
	}	

	if ${cpi_baseyear} == 1988{		
	 global    base_year	120.2	
	}	

	if ${cpi_baseyear} ==1989{		
	 global    base_year	125.6	
	}	

	if ${cpi_baseyear} == 1990{		
	 global    base_year	133.5	
	}	

	if ${cpi_baseyear} == 1991{		
	 global    base_year	137.4	
	}	

	if ${cpi_baseyear} == 1992{		
	 global    base_year	141.8	
	}	

	if ${cpi_baseyear} == 1993{		
	 global    base_year	145.7	
	}	

	if ${cpi_baseyear} == 1994{		
	 global    base_year	149.5	
	}	

	if ${cpi_baseyear} == 1995{		
	 global    base_year	153.7	
	}	

	if ${cpi_baseyear} == 1996{		
	 global    base_year	158.3	
	}	

	if ${cpi_baseyear} == 1997{		
	 global    base_year	161.6	
	}	

	if ${cpi_baseyear} == 1998{		
	 global    base_year	164	
	}	

	if ${cpi_baseyear} == 1999{		
	 global    base_year	168.2	
	}	

	if ${cpi_baseyear} == 2000{		
	 global    base_year	174	
	}	

	if ${cpi_baseyear} == 2001{		
	 global    base_year	177.7	
	}	

	if ${cpi_baseyear} == 2002{		
	 global    base_year	181.3	
	}	

	if ${cpi_baseyear} == 2003{		
	 global    base_year	185	
	}	

	if ${cpi_baseyear} == 2004{		
	 global    base_year	190.9	
	}	

	if ${cpi_baseyear} == 2005{		
	 global    base_year	199.2	
	}	

	if ${cpi_baseyear} == 2006{		
	 global    base_year	201.8	
	}	

	if ${cpi_baseyear} == 2007{		
	 global    base_year	208.936	
	}	

	if ${cpi_baseyear} == 2008{		
	 global    base_year	216.573	
	}	

	if ${cpi_baseyear} == 2009{		
	 global    base_year	216.177	
	}	

	if ${cpi_baseyear} == 2010{		
	 global    base_year	218.711	
	}	

	if ${cpi_baseyear} == 2011{		
	 global    base_year	226.421	
	}	

	if ${cpi_baseyear} == 2012{		
	 global    base_year	231.317	
	}	

	if ${cpi_baseyear} == 2013{		
	 global    base_year	233.546	
	}	

global cpi   ${c_cpi} / ${base_year}
}	
else {
global cpi  1
}	

************************************************************************	
if  ${rb_wt_on}==1{
tempvar mo_scope
	gen `mo_scope'=.
    replace `mo_scope'=0 if qintrvyr==${current_year} & qintrvmo==1
	replace `mo_scope'=1 if qintrvyr==${current_year} & qintrvmo==2
    replace `mo_scope'=2 if qintrvyr==${current_year} & qintrvmo==3
	replace `mo_scope'=3 if qintrvyr==${current_year} & qintrvmo>=4 & qintrvmo<=12
	replace `mo_scope'=3 if qintrvyr==${next_year} 	  & qintrvmo==1
    replace `mo_scope'=2 if qintrvyr==${next_year}    & qintrvmo==2
    replace `mo_scope'=1 if qintrvyr==${next_year}    & qintrvmo==3


tempvar p_wght current_pop_subset agg_pop

 gen `p_wght'= `mo_scope'*finlwt21
	egen `current_pop_subset'= total(`p_wght'), by(${by_mark})	
	gen `agg_pop' =`current_pop_subset'/12
 

foreach cvar of global dialog_var_list {
 
	 if "`cvar'" == "Alcoholic_beverages"{	
	 
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	 
	}	

 if "`cvar'" == "Babysitting_and_day_care"{	
	local Z	bbyday	
		 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}	

 if "`cvar'" == "Cars_and_trucks_new"{	
	local Z	cartkn	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}

 if "`cvar'" == "Cars_and_trucks_used"{	
	local Z	cartku	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}

 if "`cvar'" == "Clothing_Apparel_and_services"{	
	local Z	appar	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}	

 if "`cvar'" == "Clothing_for_boys_2_to_15"{	
	local Z	boyfif	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}

 if "`cvar'" == "Clothing_for_children_under_2"{	
	local Z	chldrn	

	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}

 if "`cvar'" == "Clothing_for_Girls_2_to_15"{	
	local Z	grlfif	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Clothing_for_Men_6_and_over"{	
	local Z	mensix	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Clothing_for_Men_and_boys"{	
	local Z	menboy	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Clothing_Other_apparel_products_and_services"{	
	local Z	othapl	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Clothing_women_and_girls_"{	
	local Z	womgrl	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Clothing_women_clothing_16_and_over"{	
	local Z	womsix	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}	

 if "`cvar'" == "Domestic_Services"{	
	local Z	domsrv	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Domestic_services_excluding_child_care"{	
	local Z	dmsxcc	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Education"{	
	local Z	educa	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Electricity"{	
	local Z	elctrc	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Entertainment"{	
	local Z	entert	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))
	}

 if "`cvar'" == "Entertainment_Other_equipment_and_services"{	
	local Z	othent	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Equipment_and_services_Other"{	
	local Z	otheqp	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Fees_and_admission"{	
	local Z	feeadm	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}	

 if "`cvar'" == "Floor_coverings"{	
	local Z	flrcvr	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Food"{	
	local Z	food	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Food_at_home"{	
	local Z	fdhome	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}	

 if "`cvar'" == "Food_away_excluding_meals_as_pay"{	
	local Z	fdxmap	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Food_away_from_home"{	
	local Z	fdaway	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Footwear"{	
	local Z	footwr	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Fuel_oil"{	
	local Z	fuloil	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Fuel_oil_and_other_fuel"{	
	local Z	allful	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Fuels_other"{	
	local Z	othfls	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Furniture"{	
	local Z	furntr	
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Gasoline_and_motor_oil"{	
	local Z	gasmo	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}	

 if "`cvar'" == "Health_care"{	
	local Z	health	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Health_insurance"{	
	local Z	hlthin	
tempvar sum_var
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "House_furnishings_and_equipment"{	
	local Z	houseq	
tempvar sum_var
	tempvar mo_step
	gen `mo_step' = .
	replace `mo_step'= (`var_fill'cq * finlwt21) if qintrvyr == ${current_year} & qintrvmo <=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'pq *finlwt21) if qintrvyr == ${next_year} & qintrvmo<=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'cq + `var_fill'pq)*finlwt21 if `mo_step'==. & qintrvyr == ${current_year} & qintrvmo>=4 
	${by_sort} egen `sum_var' = sum(`mo_step'*(${cpi}))	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}

 if "`cvar'" == "Household_Expenses_Other"{	
	local Z	othhex	
tempvar sum_var
	tempvar mo_step
	gen `mo_step' = .
	replace `mo_step'= (`var_fill'cq * finlwt21) if qintrvyr == ${current_year} & qintrvmo <=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'pq *finlwt21) if qintrvyr == ${next_year} & qintrvmo<=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'cq + `var_fill'pq)*finlwt21 if `mo_step'==. & qintrvyr == ${current_year} & qintrvmo>=4 
	${by_sort} egen `sum_var' = sum(`mo_step'*(${cpi}))	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Household_operations"{	
	local Z	housop	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}
 if "`cvar'" == "Household_textiles"{	
	local Z	textil	
tempvar sum_var
	 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}
 if "`cvar'" == "Housing"{	
	local Z	hous	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Life_and_other_personal_insurance"{	
	local Z	lifins	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Local_public_transportation_excluding_on_trips"{	
	local Z	trnoth	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Lodging_other"{	
	local Z	othlod	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Maintenance_and_repairs"{	
	local Z	mainrp	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Maintenance_repairs_insurance_and_other_expenses"{	
	local Z	mrpins	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Major_appliances"{	
	local Z	majapp	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Meals_as_pay"{	
	local Z	fdmap	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Medical_services"{	
	local Z	medsrv	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Medical_supplies"{	
	local Z	medsup	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}	

 if "`cvar'" == "Natural_gas"{	
	local Z	ntlgas	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Owned_dwellings"{	
	local Z	owndwe	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Personal_care"{	
	local Z	persca	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Personal_insurance_and_pensions"{	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Pets_toys_and_playground_equipment"{	
	local Z	pettoy	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Prescription_drugs_and_medical_supplies"{	
	local Z	predrg	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Property_taxes"{	
	local Z	proptx	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Public_transportation"{	
	local Z	pubtra	
tempvar sum_var
	tempvar mo_step
	gen `mo_step' = .
	replace `mo_step'= (`var_fill'cq * finlwt21) if qintrvyr == ${current_year} & qintrvmo <=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'pq *finlwt21) if qintrvyr == ${next_year} & qintrvmo<=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'cq + `var_fill'pq)*finlwt21 if `mo_step'==. & qintrvyr == ${current_year} & qintrvmo>=4 
	${by_sort} egen `sum_var' = sum(`mo_step'*(${cpi}))	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Public_transportation_on_trips"{	
	local Z	trntrp	
tempvar sum_var
	tempvar mo_step
	gen `mo_step' = .
	replace `mo_step'= (`var_fill'cq * finlwt21) if qintrvyr == ${current_year} & qintrvmo <=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'pq *finlwt21) if qintrvyr == ${next_year} & qintrvmo<=3 & `mo_step'== .
	replace `mo_step'= (`var_fill'cq + `var_fill'pq)*finlwt21 if `mo_step'==. & qintrvyr == ${current_year} & qintrvmo>=4 
	${by_sort} egen `sum_var' = sum(`mo_step'*(${cpi}))	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}

 if "`cvar'" == "Reading"{	
	local Z	read	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Rent_excluding_rent_as_pay"{	
	local Z	rntxrp	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Rented_dwellings"{	
	local Z	rendwe	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Retirement_pensions_and_social_security"{	
	local Z	retpen	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Shelter"{	
	local Z	shelt	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Small_appliances_and_miscellaneous_housewares"{	
	local Z	smlapp	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Telephone"{	
	local Z	teleph	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Television_radios_and_sound_equipment"{	
	local Z	tvrdio	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Total_expenditures"{	
	local Z	totex4	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}	

 if "`cvar'" == "Transportation"{	
	local Z	trans	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}	

 if "`cvar'" == "Utilities_fuels_and_public_services"{	
	local Z	util	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Vehicle_finance_charges"{	
	local Z	vehfin	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Vehicle_insurance"{	
	local Z	vehins	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Vehicle_rental_licenses_and_other_charges"{	
	local Z	vrntlo	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))	
	}

 if "`cvar'" == "Vehicles_other"{	
	local Z	othveh	
 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}

 if "`cvar'" == "Water_and_other_public_services"{	

 gen cu_`Z'=.
	replace cu_`Z'= `Z'pq 	*finlwt21   	 if qintrvyr==${current_year}& qintrvmo>=1 & qintrvmo<=3 
	replace cu_`Z'= (`Z'cq + `Z'pq)*finlwt21  if qintrvyr==${current_year}& qintrvmo>=4 & qintrvmo<=12 
	replace cu_`Z'= `Z'cq  *finlwt21          if qintrvyr==${next_year}& qintrvmo>=1 & qintrvmo<=3 
	
	egen agg_`Z'=total(cu_`Z'), by(${by_mark})
	gen `cvar' =((agg_`Z' / `agg_pop')*(${cpi}))		
	}
	*end of foreach followed by end of if loop
} 
}
else if ${rb_wt_on}==0 { 
tempvar p_wght current_pop_subset
gen `p_wght' = finlwt21/4
egen `current_pop_subset'=sum(`p_wght')	, by(${by_mark})

 foreach cvar of global dialog_var_list {
	 if "`cvar'" == "Alcoholic_beverages"{	
	local Z	alcbev	
	tempvar sum_var	
	${by_sort} egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*${finlwt}]*${cpi})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Babysitting_and_day_care"{	
	local Z	bbyday	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Cars_and_trucks_new"{	
	local Z	cartkn	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Cars_and_trucks_used"{	
	local Z	cartku	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_Apparel_and_services"{	
	local Z	appar	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_for_boys_2_to_15"{	
	local Z	boyfif	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_for_children_under_2"{	
	local Z	chldrn	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_for_Girls_2_to_15"{	
	local Z	grlfif	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_for_Men_6_and_over"{	
	local Z	mensix	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_for_Men_and_boys"{	
	local Z	menboy	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_Other_apparel_products_and_services"{	
	local var_fill 	othapl	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_women_and_girls_"{	
	local var_fill 	womgrl	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Clothing_women_clothing_16_and_over"{	
	local var_fill 	womsix	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Domestic_Services"{	
	local var_fill 	domsrv	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Domestic_services_excluding_child_care"{	
	local var_fill 	dmsxcc	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Education"{	
	local var_fill 	educa	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Electricity"{	
	local var_fill 	elctrc	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Entertainment"{	
	local var_fill 	entert	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Entertainment_Other_equipment_and_services"{	
	local var_fill 	othent	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Equipment_and_services_Other"{	
	local var_fill 	otheqp	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Fees_and_admission"{	
	local var_fill 	feeadm	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Floor_coverings"{	
	local var_fill 	flrcvr	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Food"{	
	local var_fill 	food	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Food_at_home"{	
	local var_fill 	fdhome	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Food_away_excluding_meals_as_pay"{	
	local var_fill 	fdxmap	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Food_away_from_home"{	
	local var_fill 	fdaway	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Footwear"{	
	local var_fill 	footwr	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Fuel_oil"{	
	local var_fill 	fuloil	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Fuel_oil_and_other_fuel"{	
	local var_fill 	allful	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Fuels_other"{	
	local var_fill 	othfls	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Furniture"{	
	local var_fill 	furntr	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Gasoline_and_motor_oil"{	
	local var_fill 	gasmo	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Health_care"{	
	local var_fill 	health	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Health_insurance"{	
	local var_fill 	hlthin	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "House_furnishings_and_equipment"{	
	local var_fill 	houseq	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Household_Expenses_Other"{	
	local var_fill 	othhex	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Household_operations"{	
	local var_fill 	housop	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Household_textiles"{	
	local var_fill 	textil	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Housing"{	
	local var_fill 	hous	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Life_and_other_personal_insurance"{	
	local var_fill 	lifins	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Local_public_transportation_excluding_on_trips"{	
	local var_fill 	trnoth	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Lodging_other"{	
	local var_fill 	othlod	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Maintenance_and_repairs"{	
	local var_fill 	mainrp	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Maintenance_repairs_insurance_and_other_expenses"{	
	local var_fill 	mrpins	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Major_appliances"{	
	local var_fill 	majapp	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Meals_as_pay"{	
	local var_fill 	fdmap	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Medical_services"{	
	local var_fill 	medsrv	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Medical_supplies"{	
	local var_fill 	medsup	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Natural_gas"{	
	local var_fill 	ntlgas	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Owned_dwellings"{	
	local var_fill 	owndwe	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Personal_care"{	
	local var_fill 	persca	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Personal_insurance_and_pensions"{	
	local var_fill 	perins	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Pets_toys_and_playground_equipment"{	
	local var_fill 	pettoy	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Prescription_drugs_and_medical_supplies"{	
	local var_fill 	predrg	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Property_taxes"{	
	local var_fill 	proptx	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Public_transportation"{	
	local var_fill 	pubtra	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Public_transportation_on_trips"{	
	local var_fill 	trntrp	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Reading"{	
	local var_fill 	read	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	


 if "`cvar'" == "Rent_excluding_rent_as_pay"{	
	local var_fill 	rntxrp	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Rented_dwellings"{	
	local var_fill 	rendwe	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Retirement_pensions_and_social_security"{	
	local var_fill 	retpen	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Shelter"{	
	local var_fill 	shelt	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Small_appliances_and_miscellaneous_housewares"{	
	local var_fill 	smlapp	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Telephone"{	
	local var_fill 	teleph	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Television_radios_and_sound_equipment"{	
	local var_fill 	tvrdio	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Total_expenditures"{	
	local var_fill 	totex4	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Transportation"{	
	local var_fill 	trans	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Utilities_fuels_and_public_services"{	
	local var_fill 	util	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Vehicle_finance_charges"{	
	local var_fill 	vehfin	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Vehicle_insurance"{	
	local var_fill 	vehins	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Vehicle_rental_licenses_and_other_charges"{	
	local var_fill 	vrntlo	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Vehicles_other"{	
	local var_fill 	othveh	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	

 if "`cvar'" == "Water_and_other_public_services"{	
	local var_fill 	watrps	
	tempvar sum_var	
	 egen `sum_var' = sum([(`var_fill'cq + `var_fill'pq)*(`p_wght')]*${cpi}), by(${by_mark})	
	g `cvar'  = `sum_var' / `current_pop_subset'	
	}	
}	
}		

************************************************************************		
keep ${by_mark}	${dialog_var_list} 

save "${out_loc}${File_ID}yr_${current_year}" , replace
	file close myfile	
	
	
	
	} 			/* for values loop end */
	
global out_file_path  "${out_loc}${File_ID}_out_yr_${current_year}" 
clear
cd ${out_loc} /* select directory */
! dir ${File_ID}*.dta  /s/b > ${out_loc}filelist.txt /*id the file */
file open myfile using ${out_loc}filelist.txt, read 
file read myfile line
use `line'
save ${out_file_path} , replace
file read myfile line
while r(eof)==0 { /* while you're not at the end of the file */
	append using `line', force 
	file read myfile line
	}
file close myfile
duplicates drop
collapse (mean) ${dialog_var_list}, by (${by_mark}) 
save ${out_file_path}, replace

foreach X of global by_mark{ 

if "`X'"== "Age_of_reference_person"{ 
 cap label define age_of_reference_person 1 " Under 25 years" 2 "25-34 years" 3 "35-44 years" 4 "45-54" 5 "55-64 years" 6 "65-74 years" 7  "75 years and older" 
			cap  label values Age_of_reference_person  age_of_reference_person 
}
if  "`X'"== "Composition_of_consumer_unit"{		
			cap  label define family_type 1 "H\W Only" 2 "H\W Oldest child <6" 3 "H\W Oldest child 6-17"  4 "H\W Oldest child 18+" 5 " Other H\W CU" 6 "One Parent, child under 18" 7 " Single person and other CUs" 
			cap  label values family_type  family_type
}			 
			 
if  "`X'"== "Highest_education_level_of_any_member"	{		 
		cap 	label define h_edu 1 "Less than high school graduate" 2 "HS graduate"  3 "Some college" 4 "Two year degree" 5 "Bachelors degree" 6 "Graduate or professional degree"
		cap 	label values highest_ed h_edu				 
}

if "`X'"== "Quintiles_of_income_before_taxes"{			
		cap 	 label define Quintiles_of_income_before_taxes 1 "Lowest 20 percentile " 2 "Second 20 percentile" 3 "Third 20 percentile"  4 "Fourth 20 percentile" 5 "Highest 20 percentile" 
		cap 	 label values Quintiles_of_income_before_taxes Quintiles_of_income_before_taxes
}
if "`X'"== "Housing_tenure"{			
		cap 	 label define Housing_tenure 1 "Owned w/mort." 2 "Owned w/o mort."  4 "Renter" 
		cap 	 label values Housing_tenure Housing_tenure
}

if "`X'"== "Race_of_reference_person"{		
		cap 	 label define Race_of_reference_person 1 "Caucasian" 2 "Black or African-American"  3 "Native American" 4 "Asian" 5 "Pacific Islander" 6 "Multi-race" 
		cap 	 label values Race_of_reference_person Race_of_reference_person
}
if "`X'"== "Income_before_taxes"{			
			cap  label define Income_before_taxes 1 " Under $5,000" 2 "$5,000 to $9,999" 3 "10,000 to $14,999" 4 "$15,000 to $19,999" 5 "$20,000 to $29,999" 6 "$30,000 to $39,999" 7  "$40,000 to $39,999" 8 "$50,000 to $69,999" 9 "$70,000 and more"
			cap  label values Income_before_taxes Income_before_taxes
}
if "`X'"== "Size_of_consumer_unit"{			
			cap  label define Size_of_consumer_unit 1 "One person" 2 "Two people"  3 "Three people" 4 "Four people" 5 "Five+ people" 
			cap  label values Size_of_consumer_unit Size_of_consumer_unit 
}
if "`X'"== "Population_size_of_area_of_residence"{			
			cap  label define Population_size_of_area_of_residence 1 "More than 4 mil" 2 "1.2-4 million"  3 "0.33-1.19 million" 4 "125-329.9 thousand" 5 "< 125k"
			cap  label values Population_size_of_area_of_residence Population_size_of_area_of_residence
}
if "`X'"== "Population_size_of_area_of_residence"{			
			cap  label define Number_of_earners_in_consumer_unit  1 "One earner" 2 "Two earners"  3 "Three earners" 4 "Four earners" 5 "Five+ earners" 
			cap  label values Number_of_earners_in_consumer_unit Number_of_earners_in_consumer_unit
}
}


local i = 1
tempvar count_year 
gen `count_year' =  ${end_yr} - ${start_yr}
if `count_year' <=12{
if `count_year' <=5 {
foreach X of global dialog_var_list{ 
local gr graph
graph bar (mean) "`X'" , over($by_var2, label(angle(forty_five) labsize(vsmall))) over($by_var0, label(angle(forty_five) labsize(vsmall))) name(gr`i',replace)  ytitle(, size(vsmall)) ylabel(, labsize(vsmall))  xsize(20) ysize(10)
	if "$by_var1" != " "{
cap graph bar (mean) "`X'" , over($by_var2, label(angle(forty_five) labsize(vsmall))) over($by_var1, label(angle(forty_five) labsize(vsmall))) name(br`i',replace)  ytitle(, size(vsmall)) ylabel(, labsize(vsmall))  xsize(20) ysize(10)
	}
*sum `X', detail
mean(`X'),over(${by_mark})
local i=`i'+1
}	
}
if `count_year' >=6  & `count_year' <=10   {
foreach X of global dialog_var_list{ 
local gr graph
graph bar (mean) "`X'" , over($by_var2, label(angle(forty_five) labsize(tiny)))  over($by_var0, label(angle(forty_five) labsize(vsmall)))  name(gr`i',replace)  ytitle(, size(vsmall)) ylabel(, labsize(vsmall)) xsize(20) ysize(10)
	if "$by_var1" != " "{
cap graph bar (mean) "`X'" ,over($by_var2, label(angle(forty_five) labsize(tiny)))  over($by_var1, label(angle(forty_five) labsize(vsmall)))  name(br`i',replace)  ytitle(, size(vsmall)) ylabel(, labsize(vsmall)) xsize(20) ysize(10)
	}
*sum `X', detail
mean(`X'),over(${by_mark})
local i=`i'+1
}	
}

if `count_year' >=10  {
foreach X of global dialog_var_list{ 
local gr graph
graph bar (mean) "`X'" , over($by_var2, label(angle(forty_five) labsize(tiny)))  over($by_var0, label(angle(forty_five) labsize(tiny)))  name(gr`i',replace)  ytitle(, size(vsmall)) ylabel(, labsize(vsmall))  xsize(20) ysize(10)
	if "$by_var1" != " "{
cap graph bar (mean) "`X'" ,over($by_var2, label(angle(forty_five) labsize(tiny)))  over($by_var1, label(angle(forty_five) labsize(tiny)))  name(br`i',replace)  ytitle(, size(vsmall)) ylabel(, labsize(vsmall))  xsize(20) ysize(10)
	}
*sum `X', detail
mean(`X'),over(${by_mark})
local i=`i'+1
}	
}

}
else {
window stopbox note  "Too many years selected for graph to display correctly. Reduce the size of the times series if you would like a plot"
foreach X of global dialog_var_list{ 
*sum `X', detail
mean(`X'),over(${by_mark})
}
}
macro drop _all
program drop _all
end

*************************************************************************************************************************************

