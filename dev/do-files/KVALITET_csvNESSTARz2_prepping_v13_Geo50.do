/*
jome jan-feb 2015:

Det ser ut som om dette skriptet skal preppe for sammenligning mellom f.eks. 
	2013 og 2012, 2012 og 2011 osv.
For å unngå de største tilfeldige svingningene, Bruke bare de største 
  kommunene.
Det rare i det opprinnelige skriptet er hvor savingen er lagt, midt inni en 
  løkke. Ser ikke ut som den nye variabelen <teller> blir med i den lagrede 
  filen. Kanskje <teller> aldri ble brukt til noe?
  
Endringer i v02: 
	* Legger savingen på slutten av preppingen av hver fil, slik at vi får 
	  med <teller>

Steinar 27.2.15: Versjon v03 for å KUNNE kjøre mot F:\ (ikke RAMdisk A:\), 
beregnet på å kunne brukes over fjernaksess.
Endret til at kataloger angis som locals øverst i scriptet (ingen hardkodete
kataloger nedover i scriptet, BORTSETT fra at det opprettes en struktur av underkataloger)

Endringer i v06: 
	* Folketall brukes litt til vekting. Skifter til BEFOLK_GK for å få med 
	  bydelstall

v09, 1.12.2015: Ny mappestruktur, nytt opplegg for å hindre kjøring av unødvendige filer.

v10_dialog (stbj apr-2016): Tilpasset kjøring fra en dialog (Boxplot_kvalitet.dlg) i samme katalog.

v11_KeepMaster (stbj jun-2016): Når Folketall merges på, droppes alle rader som ikke 
	allerede fantes i datafilen. Slik unngår vi å få laget tomme rader (aktuelt: 
	Bydelsrader med kun GEO og Folketall). Linje ca 165.
	
v12_dynam_bef (jørgen nov-2017): Bruke nyeste tilgjengelige befolkningsfil til å
	lage _Folketall.dta. Ikke så mye for å få korrekte befolkningstall, men for 
	at geo-listen i _Folketall.dta skal matche den i filen som blir analysert. 
	Dersom skriptet finner den "rette" befolkningsfilen, blir den avledede 
	_Folketall.dta tatt vare på slik at _Folketall.dta ikke trengs å rigges på 
	nytt for hver kjøring (tar litt tid). Dersom skriptet bare finner en eldre
	befolk9ngsfil, blir _Folketall.dta kastet etter bruk, slik at det lages en ny 
	_Folketall.dta når den rette befolkningsfilen blir tilgjengelig (det blir 
	nemlig ikke rigget noen ny _Folketall.dta hvis det ligger en der fra før).
	
v13_Geo50 (nov-19 OBS: Mulig at v13 er fikset før dette!) : Nye koder i Geo-filter,
	for 2020-geo, inkl. HReg 81-84. Se linje ca 235.
25.feb.2021: Rundt linje 338 legges det inn "manuell" label på en variabel dersom
	den ikke har fått label "automatisk".
7.apr.2021: Det virker som om oppbyggingen av makroen "befolkningsfil" (en filbane)
	er blitt korrumpert, kanskje i forbindelse med flytting til PDB. Forsøksvis
	fikset med dette:
		local bef = subinstr(`"`bef'"', `"""', "", .) // 7. apr. 2021: fjerne ""

*/

*===============================================================================
version 15
set more off
pause on
******* M A K R O E R  ****************************************************
*Kopierer verdiene satt i Globals av dialogen over i Locals, så slipper jeg 
*å redigere alle steder de brukes.
*Profil-årgang: Satt av dialogen
local aargang = "$aargang"

*KH- eller NH-data: Satt av dialogen
local statbank = "$statbank"	//Tillatte verdier: NH , KH

*Befolkningsfil-søkeord
local befSoekeord="BEFOLK_GK_20*.csv"

/***************
* KATALOGER I UTVIKLINGSFASEN

	local drive = "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\DEVELOP\VALIDERING\NESSTAR_KUBER/`aargang'/`statbank'"

	local befolkningsfil = "F:\Prosjekter\Kommunehelsa" ///
	+ "\PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\KH2015NESSTAR\BEFOLK_GK_2015-05-04-09-56.csv"


***************************************************/
*SKARPE KATALOGER:

*** Mulig å velge mellom RAMdisk og annen arbeidskatalog:
	*local drive = "A:"
	local drive = "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\VALIDERING\NESSTAR_KUBER/`aargang'/`statbank'"
*** Befolkningsfil. Brukes til vektede snitt av MEIS i kvalitetskontrolltabellen
*** og til å skille store og små kommuner (som plottes hver for seg i boxplots).
*** Benytter fortrinnsvis årets fil (som er i sync mtp. geo-koder), subsidiært 
*** fjorårets fil (men da med en advarsel). 
local bef: dir "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\KH`aargang'NESSTAR" ///
	files "`befSoekeord'" , respectcase
local bef = subinstr(`"`bef'"', `"""', "", .) // 7. apr. 2021: fjerne ""

if length(`"`bef'"')>1 {
	local befolkningsfil = "F:\Forskningsprosjekter\PDB 2455 - Helseprofiler og til_" ///
	+ "\PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\KH`aargang'NESSTAR/" ///
	+ `"`bef'"'
}

if length(`"`bef'"')<1 {  // Hvis vi ikke finner en BEF-fil i den ønskede mappen
qui {
	n di as error "Befolkningsfil: skriptet forventer å finne en fil i KH`aargang'NESSTAR"
	n di as error "som matcher `befSoekeord', men det skjedde ikke. Prøver derfor"
	n di as error "i fjorårets mappe som en nødløsning. Merk at dette vil gi mis-"
	n di as error "på folketall for evt. nye kommuner. Om det ikke finnes en fil"
	n di as error "her heller, stopper skriptet."
	n di as error "     (Befolkningsfilen brukes til a) vektede snitt av MEIS i "
	n di as error "kvalitetskontrolltabellen og b) til å skille store og små"
	n di as error "kommuner (som plottes hver for seg i boxplots). )" 
}
	pause on
	pause kommando "q" for å gå videre
	* Prøver i fjorårets mappe
	local aargangMinusEn=`aargang'-1
	local bef: dir "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\KH`aargangMinusEn'NESSTAR" ///
	files "`befSoekeord'" , respectcase
di length(`"`bef'"')
	if length(`"`bef'"')>1 {
		local befolkningsfil = "F:\Prosjekter\Kommunehelsa" ///
		+ "\PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\KH`aargangMinusEn'NESSTAR\" ///
		+ `bef'
		* BEF-filen bør slettes etter bruk hvis den er fra fjorårets mappe.
		local fjoraarsfil="ja" // denne makroen hentes frem når vi er ferdige med å bruke bef-filen
	}
	else {
	qui {
		n di as error "Finner ikke fil som matcher `befSoekeord'  i verken "
		n di as error "KH`aargang'NESSTAR eller KH`aargangMinusEn'NESSTAR, så"
		n di as error "skriptet 'KVALITET_csvNESSTARz2_prepping...' avsluttes her."	
		assert length(`"`bef'"')>1 
	}
	}

}	
********************************************************************************************/

*===============================================================================
****** KJØRING ******

set varabbrev on
set more off
capture mkdir "`drive'\z_Data\dtakopierPreppet"

******************************************************************************
*0) Plukke ut de største kommunene (>10 000 innbyggere i <2012>), for å unngå 
*   de største tilfeldige endringer. 
******************************************************************************
*a. Sjekke om vi trenger å laste inn befolkningsfilen
local preppedefiler : dir "`drive'\z_Data\dtakopierPreppet" files "*.dta", respectcase 
if regexm(`"`preppedefiler'"',"_Folketall")==0 { // Hvis _Folketall ikke finnes
	*b. Lage _Folketall (vektingsfilen)
	insheet using `"`befolkningsfil'"', clear case delimiter(;)
	tempvar aar_num
	gen `aar_num'=real(substr(AAR,1,4))
	su `aar_num'
	keep if `aar_num'==r(max) & KJONN==0 & ALDER=="0_120"
	drop `aar_num'
	sort GEO
	keep GEO TELLER
	rename TELLER folketall
	save "`drive'\z_Data\dtakopierPreppet\_Folketall", replace 
	*project, creates(`drive'\z_Data\dtakopierPreppet\_Folketall.dta)
}


*************************************************************************************
*0') Tilrettelegge filene: Skaffe oversikt over 
*	a) filer som skal kjøres, 
*				UTDATERT: ENTEN filliste i Global, definert i script "z1".
*		(ELLER) full liste i en katalog
*	b) hva som er de største kommunene, og flagge disse,
*	c) hva som ekstradimensjoner i den enkelte fil,
* 	d) nivåkombinasjoner av ekstradimensjonene, og
*	e) lagre 
*************************************************************************************
* quietly {

*--- LISTE OVER NYESTE VERSJONER av dta-kopier ---------------------------------------
* Identifisere hva som er nyeste versjon av hver dta-kopi i ...\`drive'\z_Data\dtakopier\
clear
local dtakopier : dir "`drive'\z_Data\dtakopier" files "*.dta", respectcase // liste over alle
								// versjoner av alle Nesstar-filer i inndatakatalogen, 
								// PRODUKTER\KUBER\KOMMUNEHELSA\KH2016NESSTAR 
								// (eller tilsv for NH. OBS årgang skifter.)
local antallfiler = wordcount(`"`dtakopier'"')
set obs `antallfiler'
gen fil="" // f.x. BEFOLK_GK_2015-03-03-11-20.csv
gen stamme="" // f.x. BEFOLK_GK
gen versjon="" // f.x. 2015-03-03-11-20
forvalues k=1/`antallfiler' {
	replace fil=word(`"`dtakopier'"',`k') in `k' // hvert filnavn sin linje
	replace fil= subinstr(fil, `"""', "", .) // få vekk apostroffer fra filnavn
}
replace stamme=regexr(fil,"_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][.]+dta","")
replace versjon=regexs(0) if regexm(fil,"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]")
gen double prodtidspkt=clock(versjon,"YMDhm")
egen double siste=max(prodtidspkt), by(stamme)
codebook stamme
keep if prodtidspkt==siste
replace fil=subinstr(fil, ".dta", "", 1)
levelsof fil, local(nyestedtakopier) clean
*-----------------------------------------(END nyeste dta-versjoner)----------



/*
		*STEINARS TILNÆRMING: UTDATERT DES-2015
		*** OBS - UTVALG AV FILER: ***
		*--------------------------------------------------
		*ENTEN: Forhåndsdefinert liste: Plukker opp global definert i forrige script. 
		* Da skal linja nedenfor kommenteres ut:
		global filer : dir "`drive'\z_Data\dtakopier" files "*.dta", respectcase
		*ELLER: Full liste: la linja ovenfor stå aktiv.
		*----------- slutt utvalg av filer ----------------
*/

foreach fil of local nyestedtakopier {
	*foreach fil in $filer {					 			// STEINARS, se ovenfor
	*foreach fil in ARBLEDIGE_2015-05-06-09-32 {
	/*if "`fil'"=="Statistikkbanken_Befolkning_LFKB_FULL_SUM2014.dta" | "`fil'"=="Statistikkbanken_Framskrevetbef_LFKBOslo_2012_09482_LONG_mTOT.dta"   {
		exit //disse filene har ikke rater eller har BEFOLKNING som teller (kluss)
	} // end -if- filnavn*/ 
	* noisily di _newline(3) as input _dup(6) "-" " 	start `fil'" _dup(22) "-"
	* STOPP her hvis det allerede finnes en preppet versjon av filen
	if regexm(`"`preppedefiler'"',"`fil'")==1 {
		di as input "Preppet tidligere: `fil'"
		exit
	}
	di as result "Preppes nå: `fil'"
	use "`drive'\z_Data\dtakopier\\`fil'", clear
	capture rename geo-spvflagg, upper //Små bokstaver i std-vars kræsjer i neste linje.
	capture rename geo , upper			//belte og bukseseler ...
	capture rename aar , upper	
	capture rename kjonn , upper	
	capture rename alder , upper	
	sort GEO
	merge m:1 GEO using "`drive'\z_Data\dtakopierPreppet\_Folketall" , keep(match master) 
			//Beholder de radene som matchet, og evt. Master-rader (dvs. fra datafilen) som ikke matchet.	
			
**********
*pause etter befolk-merge			
**********

	drop _merge
	gen storkommune=(folketall>=10000 & folketall<.)
	gen geonivaa="L"
	replace geonivaa="F" if GEO>0 & GEO<=80		// 2020
	replace geonivaa="H" if GEO>=81 & GEO<=84	//
	replace geonivaa="K" if GEO>=100
	replace geonivaa="B" if GEO>30000
	replace geonivaa="k" if storkommune==0 & GEO>=100 & GEO<8099
	
	*Numerisk geonivå, til bruk i grafene: Tallverdier som tillater nye nivåer innimellom.
	label define geonivaa 0 "L" 10 "H" 20 "F" 30 "K" 40 "k" 50 "B"
	encode geonivaa, gen(num_geonivaa) label(geonivaa)
	
	* IDENTIFISERE EKSTRADIMENSJONER
	gen ekstradims="" 		//liste over variable (in spe)
	foreach var of varlist _all {  // Går gjennom alle variablene i filen og
		// legger dem til listen over ekstradimensjoner, lagret i variabelen
		// <ekstradims>, med mindre den tilhører den lange listen med unntak.
		// F.eks. er en variabel IKKE en ekstradim hvis den heter GEO, AAR osv.
		replace ekstradims = "`var'" + " " + ekstradims in 1 if ///
		"`var'"!="AAR" & ///
		"`var'"!="Adjusted" & ///
		"`var'"!="adjusted" & ///
		"`var'"!="ADJUSTED" & ///
		"`var'"!="ANT_OPPGITT" & ///
		"`var'"!="teller_aarlig" & ///
		"`var'"!="Ant_pers" & ///
		"`var'"!="ANTALL" & ///
		"`var'"!="antall" & ///
		"`var'"!="Antall_personer" & ///
		"`var'"!="antallaar" & ///
		"`var'"!="ANTLEDIGE" & ///
		"`var'"!="Crude" & ///
		"`var'"!="crude" & ///
		"`var'"!="CRUDE" & ///
		"`var'"!="DEKNINGSGRAD" & ///
		"`var'"!="dekningsgrad" & ///
		"`var'"!="E0" & ///
		"`var'"!="ekstradims" & ///
		"`var'"!="FODTE" & ///
		"`var'"!="folketall" & ///
		"`var'"!="GEO" & ///
		"`var'"!="geonivaa" & ///
		"`var'"!="GINI" & ///
		"`var'"!="MALTALL" & ///
		"`var'"!="MEDIAN_INNTEKT" & ///
		"`var'"!="MEDIANINNTEKT_AH" & ///
		"`var'"!="NETTO" & ///
		"`var'"!="NEVNER" & ///
		"`var'"!="nevner" & ///
		"`var'"!="nevner_aarlig" & ///
		"`var'"!="num_femGeonivaa" & ///
		"`var'"!="num_geonivaa" & ///
		"`var'"!="PERSONER" & ///
		"`var'"!="Personer" & ///
		"`var'"!="personer_distribnett" & ///
		"`var'"!="per1000" & ///
		"`var'"!="PRIKK" & ///
		"`var'"!="PROGNOSEAAR" & ///
		"`var'"!="prosentandel" & ///
		"`var'"!="RATE" & ///
		"`var'"!="storkommune" & ///
		"`var'"!="sumnevner" & ///
		"`var'"!="sumNEVNER" & ///
		"`var'"!="SUMNEVNER" & ///
		"`var'"!="sumteller" & ///
		"`var'"!="sumTELLER" & ///
		"`var'"!="SUMTELLER" & ///
		"`var'"!="TELLER" & ///
		"`var'"!="TILVEKST" & ///
		"`var'"!="v6" & ///
		"`var'"!="v7" & ///
		"`var'"!="VERDI" & ///
		regexm("`var'","_MA")==0 & ///
		regexm("`var'","BEF")==0 & ///
		regexm("`var'","FLx")==0 & ///	
		regexm("`var'","LANDSNORM")==0 & ///
		regexm("`var'","MEIS")==0  & ///
		regexm("`var'","RATE")==0 & ///
		regexm("`var'","SMR")==0 & ///
		regexm("`var'","smr")==0 & ///
		regexm("`var'","SPVFLAGG")==0 
		replace ekstradims = ekstradims + "`var'" +" " in 1 if "`var'"=="TYPE_MAAL" //Blir ekskludert av 
																					//en regexm ovenfor!
		noisily di as input "`var', ekstradims = " as result ekstradims // Her
		// vises ekstradim-listen etter hver variabel som er inspisert. Bruk 
		// listen til å sjekke at ikke feil variabler er blitt lagt til listen 
		// over ekstradims. De eneste "standarddims", dvs. dimensjoner som  
		// finnes i alle filer, er GEO og AAR. Ekstradims er dimensjoner som 
		// IKKE finnes i alle filer, f.eks. kjønn, alder og legemiddel  
	} // end -foreach- var
	local ekstradims=ekstradims	// Sammenligning mellom siste årgang og 
				// årgangen før må gjøres innenfor hver av de mulige kombi-
				// nasjonene av GEO og ekstradimensjoner som sykdom, 
				// kjønn osv., så vi må finne ut hvilke dimensjonskombinasjoner 
				// som finnes i den aktuelle filen. GEO-verdiene kjenner vi, men 
				// på de neste linjene kartlegges hvilke kombinasjoner denne 
				// filen har av eventuelle ekstradimensjoner
	noisily di as input "-egen ... group-  :"
	egen ekstradim_levels=group(`ekstradims'), label
	* Problem: Ingen ekstadimensjoner, ingen label. Og da kræsjer -decode-. Vi
	  *må derfor opprette verdilabelen "ekstradim_levels" manuelt hvis det ikke 
	  *skjedde automatisk ovenfor:
	label dir
	if regexm("`r(names)'", "ekstradim_levels")==0 {
	    label define ekstradim_levels 1 "INGEN_xtraDIM"
		label values ekstradim_levels ekstradim_levels
	}
	noisily di as result "OK" _newline(1) as input "-decode-  :"
	decode ekstradim_levels, gen(edl_txt)
	noisily di as result "OK" _newline(1) as input "-gsort-  :"
	capture gsort `ekstradims' -ekstradims -ekstradim_levels -edl_txt
	noisily di as result "OK" _newline(1) as input "-save-  :"
	*save "`drive'\z_Data\dtakopierPreppet\\`fil'", replace // gammel plassering av -save-
	noisily di as result "OK" _newline(1) 
*pause
	* TELLER :	
	* Og så finne telleren (kræsjer hvis det finnes 0 eller 2+ kandidater):
	foreach var of varlist _all {		
		if regexm("`fil'","Statistikkbanken_Inntektsulikhet_LFK_09114")==1 ///
		 | regexm("`fil'","StatistikkbankenBEFOLKNING_BEARBEID_STATB_Yrkesaktiv_LFKB")==1 ///
		 | regexm("`fil'","StatistikkbankenBEFOLKNING_BEARBEID_STATB_KjonnsBalanse_LFKB")==1 ///
		 | regexm("`fil'","Statistikkbanken_Arbeidsledige_andel_LFK_2005_2012_06900_01603_TN")==1 ///
		 | regexm("`fil'","Statistikkbanken_Medianinntekt")==1 /// disse indikatorene har ikke teller.
		 ///
		 | regexm(`"`var'"', "sumTELLER") ///
		 | regexm(`"`var'"', "SUMTELLER") { //Denne variabelen kan forekomme, men skal ikke brukes her.
		continue
		}
		if (regexm(`"`var'"', "TELLER") ///
		 | (regexm(`"`var'"', "ANTALL") & !regexm(`"`var'"', "ANTALL_GANGER") & !regexm(`"`var'"', "ANTALLGANGER")) ///
		 | regexm(`"`var'"', "Antall_personer")   ///
		 | regexm(`"`var'"', "Ant_pers")   ///
		 | regexm(`"`var'"', "COUNT")   ///
		 | regexm(`"`var'"', "avekt")  ///
		 | regexm(`"`var'"', "REG_ARBEIDSLEDIGE")  ///
		 | regexm(`"`var'"', "ANTLEDIGE")  ///
		 | regexm(`"`var'"', "aroyk_beg")  ///
		 | regexm(`"`var'"', "barnens")  ///
		 | regexm(`"`var'"', "grad_tlf")  ///
		 | regexm(`"`var'"', "antens")  ///
		 | regexm(`"`var'"', "Ant_fullfortgrad_8")  ///
		 | regexm(`"`var'"', "UFORE")  ///
		 | (regexm(`"`var'"', "PERSONER") & !regexm("`fil'","Statistikkbanken_LAVINNTEKT"))  ///PERSONER er ikke telleren i denne filen
		 | regexm(`"`var'"', "FODTE")  ///
		 | regexm(`"`var'"', "MEDIAN_INNTEKT")  ///
		 | regexm(`"`var'"', "TILVEKST")  ///
		 | regexm(`"`var'"', "BEF")  ///
		 | regexm(`"`var'"', "NETTO")  ///
		 | regexm(`"`var'"', "DODE")   ///
		 | regexm(`"`var'"', "antall")   ///
		 | regexm(`"`var'"', "teller_aarlig")   ///
		 | regexm(`"`var'"', "Antall")) { ///
			destring `var', force replace
			*noisily di "clonevar"
			clonevar teller = `var' 
			*noisily di "clonevar ferdig"
			label variable teller "`var'"
			noisily des teller
		} // end -if- for teller (normal)
	} // end -foreach- var

	* MEIS (flyttet til dette skriptet i v.08, 12. mai 2015)
	* Skippe noen filer som ikke skal analyseres 
	if /* "`fil'" == "Statistikkbanken_Befolkning_LFKB_FULL_SUM2013.dta" | */ "`fil'" == "Storkommuner.dta" | ///
	  regexm("`fil'", "WIDE")==1  ///  
	  | regexm("`fil'", "Forsvaret_Sesjonsdata2013")==1 { // WIDE av Inntektsulikhet passer ikke. Forsvaret: har bare én batch
		noisily di _newline(1) as input substr("`fil'",1,55) "," _column(57) as result " skal ikke analyseres."  
		exit
	} // end "if"
	sort GEO AAR 
	*noisily di "`fil'"
	*noisily di "destring Teller: "
	capture destring teller TELLER, replace force //variabelen som skal testes for utliggere...
	levelsof AAR, local(aarganger)
	local antaar=wordcount(`"`aarganger'"')
	
	* ---- B.1.b. I kuber som ikke har MEIS*; generere MEIS fra RATE* el.l. -----
	*noisily di "generere MEIS fra RATE* el.l."
	local x
	foreach var of varlist _all {
		local x `x' `var'		// x = liste over alle variabelnavnene i filen
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","RATE")==1 { // Hvis "MEIS" ikke finnes, men det finnes en "RATE", ...
		clonevar MEISfrarate = RATE // Opprette en variabel MEIS når MEIS ikke allerede finnes i filen
		label variable MEIS "klonet fra crude RATE"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","RATE")==0 & regexm("`x'","P90_P10")==1 { // Inntektsulikhet...
		clonevar MEISfrarate = P90_P10 // 
		label variable MEIS "klonet fra crude P90_P10"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","RATE")==0 & regexm("`x'","MALTALL")==1 { // Medianinntekt
		clonevar MEISfrarate = MALTALL // 
		label variable MEIS "klonet fra crude MALTALL"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","RATE")==0 & regexm("`x'","VERDI")==0  & regexm("`x'","MALTALL")==0 & regexm("`x'","BEF0101")==1  { // Befolkning
		clonevar MEISfrarate = BEF0101 // 
		label variable MEIS "klonet fra crude BEF0101"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","FLx")==1 { // forventet levealder
		clonevar MEISfrae0 = FLx // Opprette en variabel MEIS når MEIS ikke allerede finnes i filen
		label variable MEIS "klonet fra FLxXXX"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","[Aa][Dd][Jj][Uu][Ss][Tt][Ee][Dd]")==1 { // fra Stata-samlebåndet
		capture rename adjusted Adjusted	//Håndtere begge varianter...
		capture rename ADJUSTED Adjusted	//Dette er teit. Bedre å rename alle variabler til UPPERcase rett etter innlesing!
		clonevar MEISfraAdjusted = Adjusted // Opprette en variabel MEIS når MEIS ikke allerede finnes i filen
		label variable MEIS "klonet fra Adjusted rate"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","[Aa]djusted")==0 & regexm("`x'","[Cc]rude")==1 { // fra Stata-samlebåndet når det ikke fins std.rate
		capture rename crude Crude		//Håndtere begge varianter...
		clonevar MEISfraCrude = Crude // Opprette en variabel MEIS når MEIS ikke allerede finnes i filen
		label variable MEIS "klonet fra Crude rate"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","RATE")==0 & regexm("`x'","per1000")==1 { 
		clonevar MEISfrarate = per1000 // 
		label variable MEIS "klonet fra crude per1000"
	}
	if regexm("`x'","MEIS")==0 & regexm("`x'","prosentandel")==1 { // Hvis "MEIS" ikke finnes, men det finnes en "prosentandel", ...
		clonevar MEISfrarate = prosentandel // Opprette en variabel MEIS når MEIS ikke allerede finnes i filen
		label variable MEIS "klonet fra crude prosentandel"
	}
	* ------------------------ end generere MEIS fra RATE i kuber uten MEIS ----
	capture destring MEIS, replace force //variabelen som skal testes for utliggere...
	* Lage vektede bydelsgjennomsnitt av MEIS (til sammenligning med kommuneverdien)
	tempvar sumfolketallbydeler f_MEIS
	gsort -ekstradims 
	local xtra = ekstradims
	gen By=floor(GEO/100) if GEO>30000 & GEO<.
	egen `sumfolketallbydeler'=total(folketall), by(By AAR `xtra')
	gen double `f_MEIS' = MEIS*folketall
	egen w_MEIS=total(`f_MEIS') if GEO>30000 & GEO<., by(By AAR `xtra')
	replace w_MEIS=w_MEIS/`sumfolketallbydeler'
	label var w_MEIS "bydelsgjennomsnitt, vektet med folketall i 2012, begge kjønn, alle aldre"
	label var By "Kommune med bydelstall"
	local endring		// "nullstiller" denne makroen
	local endring_na 	= ""		// "nullstiller" denne makroen, na=not available
	/*
	if `antaar'<2 {
		local endring_na "Ikke sjekket, <2 årganger."
		local endring 			// "nullstiller" denne makroen
	} // end "if"
	*/
	noisily di _newline(1) as input substr("`fil'",1,55) "," _column(57) `antaar' ///
	 as input "årg., ekstradim: " ekstradims  
	* --- 1.c. Avlede variabel for Endringer fra år til år ---------------------
	capture drop aar1
	capture drop endring_pct

	* Output fra Stata-samlebåndet har numerisk, ettårig AAR, mens fra Access/R har string
	local erstring : type AAR
	if strmatch("`erstring'", "str*") { 
		gen AARl=real(substr(AAR,1,4))
	} 	//end IF
	else {
		gen AARl=AAR
	}
	su AARl
	gen  aar1=(AARl==r(min))  // flagge første året i hver tidsserie
	sort  GEO `xtra' AARl
	*Endring i % fra ett år til neste. 14/1/2014: Tidligere ville 0 ett år og f.eks. 4 
	* året etter, gitt missing på endring. For å unngå dette er det nå lagt til 0.001 i nevner.
	gen endring_pct=100*(MEIS-MEIS[_n-1])/(MEIS[_n-1]+0.001) if aar1<1 & (storkommune==1 | geonivaa=="B")
	label variable endring_pct "Årlige endringer MEIS (evt. RATE) i de 130 største GEO, %"
	gen cst = " " // triks. MÅ ha minst én variabel i by-komandoen nedenfor
	local konstant cst
	* ------------------------------------ end Endringer fra år til år -------
	capture drop _* // droppe eventuelle tempvars som har bitt seg fast
	save "`drive'\z_Data\dtakopierPreppet\\`fil'", replace
	di as input _dup(20) "-" " 	end `fil'" _dup(6) "-"
} // end foreach fil
*} // end quietly

* Fjerne befolkningsfilen hvis den var hentet fra fjorårets godkjentmappe som nødløsning
if "`fjoraarsfil'"=="ja" {
	erase "`drive'\z_Data\dtakopierPreppet\_Folketall.dta"
}


