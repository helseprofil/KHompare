/* 
Programmet gjør følgende:

Dette skjer i følgende trinn: 
A) Bruker mappestrukturen opprettet i "...z1_kopiere"-scriptet.
		...\VALIDERING\NESSTAR_KUBER\2016\KH\...   (evt. \2016\NH\ )
		\Data: kubene får en ny avledet variabel, <endring_pct>, som 
			er endringen fra ett år til det neste i en tidsserie. Pluss to 
			hjelpevariabler <aar1> og <cst>
				(\Histogram_årsvariasjon" - tatt ut)
		\Box_alleaar-til-aar
		\Box_alleverdieravMEIS
		\Tabell
B) Looper over alle kubene og gjør følgende for hver av dem:
		1) Oppretter analysefil og legger i mappen \Data (se ovenfor).
		2) DUPLIKAT-VARSEL innen vedkommende fil.
		3) TABELL med diagnostiske størrelser (er sum av tellere og 
		   gjennomsnittlig MEIS i samme størrelsesorden på ulike geo-nivå?),
		   lagret separat for hver analyserte fil.
		4) BOX PLOTs
			a) alle MEIS-verdier, innen hvert geo-nivå
			b) alle år-til-år-endringer i MEIS-verdier, innen hvert geo-nivå
			
Steinar 27.2.15: Versjon v03 for å KUNNE kjøre mot F:\ (ikke RAMdisk A:\), 
beregnet på å kunne brukes over fjernaksess.
Endret til at kataloger angis som locals øverst i scriptet (ingen hardkodete
kataloger nedover i scriptet, BORTSETT fra at det opprettes en struktur av underkataloger)

v08: Lager "Sum Bydeler" som ved faktisk summere hhv. faktisk 
v10: Ny mappestruktur, separate tabeller, mindre "overlappende" kjøring.
v11: Tilpasset kjøring fra en dialog (.dlg-fil) i samme katalog.
v12: Automatisk splitting av plott med for mange (dvs. for små) delplott. Grensen settes 
     ca i linje 340.
v13: Hindre at graph-kommandoen kræsjer hvis det er fatal feil i dataene. Hoppe 
	over filen og ta neste.
v14: Geofilter i l.440 osv tilrettelagt for fylke 50 Trøndelag og alt som følger av det.
v15: (UNDER ARBEID) Lange kategorinavn tyter utenfor delplottene så det blir vanskelig å se 
	hvilke kategorier som vises i plottet. 

*******************************************************************************
**  				OBS HVIS EN FIL TAR UNORMALT LANG TID:					 **
** 																			 **
**  Sjekk variabelen "ekstradim_levels", som genereres i preppescriptet.	 **
**  Dersom denne inneholder verdier som ikke stammer fra ekstradimensjonene, **
**  må lista i preppescriptet over unntak ved opptelling av ekstradims 		 **
**  oppdateres med denne datafilens variabler.								 **
*******************************************************************************


*/
version 15		//Viktig: Endringer i kommando -mean- i Stata 16 ga kræsj.
******* M A K R O E R  ****************************************************
*Kopierer verdiene satt i Globals av dialogboksen over i Locals, så slipper jeg 
*å redigere alle steder de brukes.
*Profil-årgang: Satt av dialogen
local aargang = "$aargang"

*KH- eller NH-data: Satt av dialogen
local statbank = "$statbank"	//Tillatte verdier: NH , KH

***************************************************/
*SKARPE KATALOGER:

*** Mulig å velge mellom RAMdisk og annen arbeidskatalog:
*local drive = "A:"
local drive = "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\VALIDERING\NESSTAR_KUBER/`aargang'/`statbank'"


/************************************************************************
* MAKROER OG KATALOGER I UTVIKLINGSFASEN

	local aargang = "2019"
	local statbank = "NH"
	local drive = "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\DEVELOP\VALIDERING\NESSTAR_KUBER/`aargang'/`statbank'"
	
	global splittvalg =1	//1 gir analyse, 2 gir "alder, hardkodet" splittmekanisme (linje 330 osv)

	local befolkningsfil = "F:\Prosjekter\Kommunehelsa" ///
	+ "\PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\KH2015NESSTAR\BEFOLK_GK_2015-05-04-09-56.csv"

***************************************************/


**** KJØRING ******************************
set varabbrev on
set more off
pause on

*******************************************************************************************
* Test 1: Store endringer fra ett år til neste. Sjekker først om vi har min. 2 årganger.
********************************************************************************************



*******************************************************************************
* A) Opprette undermapper: Flyttet til "z1-kopiering"-scriptet
******************************************************************************
/*	Struktur:
	...\VALIDERING\NESSTAR_KUBER\2016\KH\ ...  //Settes som "drive".
			Box_alleverdieravMEIS
			Box_alleaar-til-aar
			Prod-aar-vs-i-fjor     //Erstatter "2014vs2015"
			GODKJENT               //Nora+Marie flytter plottfiler hit manuelt
			Tabell                 //Med enkeltfiler for hver analysert fil
			z_Data\ ...
				dtakopier
				dtakopierPreppet   //Henter filer herfra, lagrer ferdige analysefiler i z_Data.
*/

*******************************************************************************
* LISTE OVER NYESTE PREPPEDE FILER 
*******************************************************************************
* Identifisere hva som er nyeste versjon av hver Nesstar-fil i \dtakopierPreppet
clear
local preppetfiler : dir "`drive'\z_Data\dtakopierPreppet" files "*.dta", respectcase // liste over alle
						// versjoner av alle Nesstar-filer i \dtakopierPreppet
local antallfiler = wordcount(`"`preppetfiler'"')
set obs `antallfiler'
gen fil="" // f.x. BEFOLK_GK_2015-03-03-11-20.dta
gen stamme="" // f.x. BEFOLK_GK
gen versjon="" // f.x. 2015-03-03-11-20
forvalues k=1/`antallfiler' {
	replace fil=word(`"`preppetfiler'"',`k') in `k' // hvert filnavn sin linje
	replace fil= subinstr(fil, `"""', "", .) // få vekk apostroffer fra filnavn
}
replace stamme=regexr(fil,"_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][.]+dta","")
replace versjon=regexs(0) if regexm(fil,"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]")
gen double prodtidspkt=clock(versjon,"YMDhm")
egen double siste=max(prodtidspkt), by(stamme)
codebook stamme
keep if prodtidspkt==siste
levelsof fil, local(nyestepreppetfiler) clean
************************************* END nyeste versjoner **************



*******************************************************************************
* B) Loope over nyeste versjon av kuber
******************************************************************************
noisily di _newline(3) _dup(6) "-" " Kvalitetskontroll " _dup(52) "-"
*quietly {

foreach fil of local nyestepreppetfiler {

	//MÅ VENTE med å åpne loggen for denne filen inntil det er bestemt at den skal 
	//analyseres nå. Ellers slettes jo tidligere utført analyse =dokumentasjonen!

	* --- 1.a. Skippe noen filer som ikke skal analyseres ---------------------
	if "`fil'" == "Storkommuner.dta" ///
	  | regexm("`fil'", "BEFOLK_GK")==1 ///	Slå av og på for å utsette denne tidkrevende fila ...
	  | regexm("`fil'", "BEFOLK_GK_[0-9][0-9][0-9][0-9]")==1 /// Vi trenger bare å sjekke versjonen som er kuttet til 24 årganger.
	  | regexm("`fil'", "WIDE")==1  | regexm("`fil'", "_Folketall")==1 ///  WIDE av Inntektsulikhet passer ikke.
	  | regexm("`fil'", "Forsvaret_Sesjonsdata2013")==1 { //  Forsvaret: har bare én batch.
			noisily di _newline(1) as input substr("`fil'",1,55) "," _column(57) as result " skal ikke analyseres."  
			log close _all
			continue
	} // end "if"
	* --------------------------------------------end Skippe noen filer --------
	
	*** STOPPE her hvis ...***************************************************
	* 	1) Tabell for denne filen allerede er laget tidligere, Og
	* 	2) begge figurene allerede er laget i tidligere kjøring
	* Dette gjøres for å spare tid ved ikke å reprodusere en identisk analyse.
	* Hvis én av de tre ikke finnes, kjøres alle - dermed er de alltid i sync.
	
	*	1) Finnes det allerede en Tabell-loggfil for denne filen?
		local tabellfiler :  dir "`drive'\Tabell" files "*.log", respectcase
		if regexm(`"`tabellfiler'"',subinstr("`fil'",".dta","",.))==1 { // 1=Ja,
		// tabellfilen finnes. Finnes også figurene?
		* 	2) a) Finnes det allerede en alleverdieravMEIS-figur for denne filen?
			local alleverdieravMEIS : dir "`drive'\Box_alleverdieravMEIS" files "*.png", respectcase
			if regexm(`"`alleverdieravMEIS'"',subinstr("`fil'",".dta","",.))==1 { // 1=Ja,
			// det finnes allerede en alleverdieravMEIS-figur, finnes også den andre figuren?
			* 	2) b) Finnes det allerede en årsvariasjon-figur for denne filen?
				local aarsvar_box : dir "`drive'\Box_alleaar-til-aar" files "*.png", respectcase
				if regexm(`"`aarsvar_box'"',subinstr("`fil'",".dta","",.)) { // 1=Ja,
	*pause i stop-rutine
				// det finnes allerede en årsvariasjon-figur også. Drop analyse,  
				// hopp ut av den store løkken og begynn på neste fil.	
					noisily di _newline(1) as input substr("`fil'",1,55) "," _column(57) ///
					as result " er analysert tidligere."  
					log close _all
					continue
				} // end sjekke om årsvariasjonsfigur allerede finnes 
			} // end sjekke om alleverdieravMEIS-figur allerede finnes 
		} // end sjekke om tabellfil allerede finnes 
	******************************************* end STOPP****************

	local tabellnamestub =subinstr("`fil'", ".dta","", 1)	
	log using "`drive'\Tabell/`tabellnamestub'.log", replace	

	use "`drive'\z_Data\dtakopierPreppet\\`fil'", clear
	
	
	noisily di _n(2) as input "`fil'"

	*Ta vare på variabel-label for MEIS, til figurene
	local MEISlabel : variable label MEIS
	//Original MEIS kan være uten label. Bruker var-navnet:
	if "`MEISlabel'" == "" {
		describe MEIS, varlist		//Blir en liste med ett navn
		local MEISlabel = r(varlist)
		}
	noisily di as result `"Label på MEIS: "`MEISlabel'""'	
	
	gsort -ekstradims 
	local xtra = ekstradims
	* beregne vekter
	gen pw=folketall
	label var pw "Folketall, begge kj, alle aldre"
/*	Nevner er en mye bedre vekt enn folketall. Bør skaffes på sikt
		capture replace pw=nevner // nevner er bedre enn folketall 
		if _rc==0 label var pw "sumNEVNER"
		des pw
*/ 
	************************************************************
	* B.2. DUPLIKAT-VARSEL innen vedkommende fil
	************************************************************
	duplicates tag   GEO AARl `xtra', gen(dupl) 
	su dupl
	if r(max)==0 noisily di as result "Ingen duplikater av GEO AAR `xtra'" 
	if r(max)>0 noisily pause Mulighet for duplikater. Sjekk vha. "list if dupl>0". For å bare kjøre videre, skriv q og tast Enter.
	
	
	***********************************************************************
	* B.3. TABELL med diagnostiske størrelser (er sum av tellere og i samme 
		 * størrelsesorden på ulike geo-nivå? Samme spm for gjennomsnittlig 
		 * MEIS?) Dette vises på skjermen, og lagres også i en log-fil.
	************************************************************************

	* --- B.3.a. Tabell headings ----------------------------------------------
	noisily di _newline(1) _column(38) "Teller, sum over år, " as result "prikket" _column(75) as input "MEIS, vektet snitt, " as result "prikket"
	noisily di _column(5) "Xtradim-kombin." _column(38) "Land" _column(49) "Fylke" _column(60) "Kommune" _column(75) "Land" _column(85) "Fylke" _column(95) "Kommuner"  
	* ------------------------------------------ end Tabell headings ----------
	
	* --- B.3.b. Tabellens Linjenavn (tror jeg 11.feb.2015)----------------------
	tempvar konstant
	gen `konstant'=" "
	sort  `xtra' `konstant' 
				* --- Hva er dette for??? Tenkt brukt i tabellen men droppet? -----------
				by `xtra' `konstant': egen maxreduksjon = min(endring_pct) //brukes ikke?
				by `xtra' `konstant': egen maxøkning = max(endring_pct) //brukes ikke?
				* --------------------------- end hva er dette? ----------------------
	levelsof ekstradim_levels,  local(level) // testing må gjøres innenfor hver av de  
								// mulige kombinasjonene av GEO og ekstradimensjoner  
								// som sykdom, kjønn osv. 	

	foreach kombi in `level' {		// analysere hver kommune for utliggere, men 
					// separat for hver sykdoms- og alders-kombinasjon osv.
					// NB: Tror at akkurat dette med utliggere er droppet fra 
					// tabellen (11. feb. 2015, se nedenfor) 
								
	  preserve
		keep if ekstradim_levels==`kombi'
		local kombi_txt=edl_txt  // edl=ekstradimlevels ekstradim=alle dimen-
				// sjoner unntatt de obligatoriske (GEO og AAR)
		
		* --- B.3.c. Tabellens Innhold, del 1 (3 første kolonner): sum av tellerne
					*innen geonivå ---------------------------------------------
		matrix drop _all
		_return drop _all // sletter bl.a. e(b) fra forrige -mean- / -total- 
		mat LAND_t = (999)
		mat FYLKE_t=(999)
		mat KOMMUNE_t=(999) // starter med missing for alle nivåene
		* num_geonivaa har to nivå for kommune (K og k). Dette egner seg ikke 
			*for bergening av sum av teller innen geonivå. Må lage supplementær
		gen geonivaa2 = geonivaa
		replace geonivaa2="K" if geonivaa2=="k"
		encode geonivaa2, gen(num_geonivaa2)
		noisily capture total teller, over(num_geonivaa2)
		di " her er _rc: " _rc
		if _rc==0 { 	// hvis -total- lot seg utføre ...
			mat T=e(b) 
		}
		if _rc==0 & regexm("`e(over_labels)'", "L") {  	// hvis -total- a) lot seg utføre og b) produserte et landstall ...
			mat LAND_t=T[1,"teller:L"] 			// ... så overskriv de opprinnelige missingverdien i LAND_t
		}
		if _rc==0 & regexm("`e(over_labels)'", "F") {  // hvis ikke mean...,over() ga verdi for fylke;...
			mat FYLKE_t=T[1,"teller:F"]
		}
		if _rc==0 & regexm("`e(over_labels)'", "K") {  // hvis ikke mean...,over() ga verdi for kommune;...
			mat KOMMUNE_t=T[1,"teller:K"]
		}
		* -------------------end Tabellens Innhold del 1: sum tellere --------
		* --- B.3.d. Tabellens Innhold, del 2 (3 siste kolonner): mean MEIS 
					*innen geonivå --------------------------------------------
		su MEIS if geonivaa=="L"
		if r(mean)==. { //  
			restore		//    
			di as result "Avsnitt B.3.d: continue fra if r(mean)==."
			save "`drive'\z_Data\\`fil'", replace
			*log close _all	//Hmm: Fikset kræsj på "log already open" for én kjøring, men 
							//skapte problem at loggfilen ble lukket før tabellen var ferdig i en annen...
			continue 
		}
		_return drop _all // sletter bl.a. e(b) fra forrige -mean- / -total- 
		mean MEIS [fweight=pw], over(num_geonivaa2) //endret fra (num_geonivaa) nov. 2017
*pause after -mean MEIS-
		mat M=e(b) 
*pause after -mat M=e(b)-
		mat li M
*pause after -mat li M-
		mat coleq M = MEIS // ellers varierer coleq, e.g. MEIS_MA3, MEIS_MA10 osv
*pause rett før matrisekræsj i ver.16
		mat LAND = M[1,"MEIS:L"]
		if !regexm("`e(over_labels)'", "F") {  // hvis ikke mean...,over() ga verdi for fylke;...
			mat FYLKE=(999)
		}
		else {
			mat FYLKE=M[1,"MEIS:F"]
		}
		if !regexm("`e(over_labels)'", "K") {  // hvis ikke mean...,over() ga verdi for kommune;...
			mat KOMMUNE=(999)
		}
		else {
			mat KOMMUNE=M[1,"MEIS:K"]
		}		
		* -------------------end Tabellens Innhold del 2: mean MEIS --------
		
		* --- B.3.e. Skrive ut Tabellens linje nr. i -------------------------- 
		noisily di _column(5) as txt "`kombi_txt'" _column(34) /* %5s endr_snitt ///
		_column(43) %5s endr_lavest "  " %5s endr_hoeyest _column(59) %5s endr_4xSD */ /// 
		%10.0fc LAND_t[1,1] _column(46) %10.0fc FYLKE_t[1,1] _column(59) %10.0fc KOMMUNE_t[1,1] ///		
		_column(73) %6.1f LAND[1,1] _column(84) %6.1f FYLKE[1,1] _column(95) %6.1f KOMMUNE[1,1]	
		* ------------------------ end Skrive ut Tabellens linje nr. i -------- 
	  restore
		
	} // end -foreach- sykdoms- og alderskombinasjon osv
	noisily di _dup(109) "-"
	sort GEO AARl `xtra' `konstant' 

	save "`drive'\z_Data\\`fil'", replace
	
*pause on
*pause SJEKK GEO	
	
	*******************************************************************
	* B.4. BOX PLOTs
	*********************************************************************
	sort GEO AARl `xtra' `konstant' 	
	local figurnamestub =subinstr("`fil'", ".dta","", 1)	
	local figurnamestub =subinstr("`figurnamestub'", ".","", .)	

		
	* SPLITTE FIGURENE OVER FLERE SIDER:
	* To mulige metoder, velges i oppstartdialogboksen.

	* Metode 1: ANALYSERE DIMENSJONENE:
	/* Er totalt antall delplott større enn antallgrensen for plott per side (se rett under denne teksten)?
	   HVIS JA: Tell kategorier i ekstradimensjonene. Beregn antall plott: Start med 
	   dim. som har FÆRREST kategorier, og legg til dimensjoner inntil oppsplittingen 
	   gir lavt nok antall delplott per side. Legg var-navnene til de valgte dimensjonene
	   i var. "figursplitt". Den styrer selve splittingen litt lengre ned i scriptet.
			(Anm.: Mer elegant ville være å analysere ekstradims og velge en kombinasjon som
			ga et max- og hvis mulig også et min-antall plott per side.)
	*/
	if $splittvalg ==1 { //Ny metode er valgt
	local antallgrense = 25		//Plottene har et "kvadratisk" antall delplott som max.
	gen figursplitt = "ingen"
	summarize ekstradim_levels
	local ant_komb = r(max)		//Dette er totalt antall delplott.
	local splittdims =""		//Til oppsamling av hva det skal splittes på
	
	if `ant_komb' > `antallgrense' { //Splitting trengs.
		local ekstra_dim = "`xtra'"					//Er var-navnene på alle ekstradims (se l.198)
		local i =0									//Initiere en teller
		*Telle opp kategorier per variabel.
*di "ekstradim: `ekstra_dim'."		
		foreach var of local ekstra_dim {	
*di "Hei, variabel: `var'"		
			local i =`i'+1
			levelsof(`var'), local(varlevels) clean			//Teller kategorier
			local ant_i_var`i' = wordcount("`varlevels'")	//Lagrer ant.kateg. i var nr. `i'
*di "løkkeslutt for `var'"			
		} //End -foreach, Telle opp kategorier per variabel.-
		local ant_ekstradims =`i'							//Antall ekstradims som skal behandles videre
	
		/*	Byttet fra denne til MINSTE, se neste avsnitt.		
					*Splitte først etter den største, og evt. deretter etter neste ...
					while `ant_komb' > `antallgrense' {
						*Finn ekstradim med flest kategorier
						local ant_hittil=0						//Initiere 
						local nummer_hittil=. 					//Ditto  
						forvalues j=1/`ant_ekstradims' {
							if `ant_i_var`j''> `ant_hittil' {
								local ant_hittil 	= `ant_i_var`j''	
								local nummer_hittil = `j'
							} //End -if-
						} //End -finn ekstradim med flest kategorier-
			*/	
		*Splitte først etter den MINSTE, og evt. deretter etter neste ...

		while `ant_komb' > `antallgrense' & `ant_ekstradims' > 0 {
				//Har opplevd kræsj fordi ant_ekstradims ble telt ned til null, det kræsjer i forvalues-kommandoen.
			*Finn ekstradim med FÆRREST kategorier
			local ant_hittil=100					//Initiere 
			local nummer_hittil=. 					//Ditto  
			forvalues j=1/`ant_ekstradims' {
*di "forvalues j= `j' ..."			
				if `ant_i_var`j''< `ant_hittil' {
					local ant_hittil 	= `ant_i_var`j''	
					local nummer_hittil = `j'
*di "ant_hittil `ant_hittil', nummer_hittil `nummer_hittil'."
				} //End -if-
			} //End -finn ekstradim med FÆRREST kategorier-

			*Lagre den største/MINSTE, og dropp den fra lista - gjør klar for evt. ny runde i løkka
			////Bytt evt makronavn mellom `minstedim' og `storstedim', hvis vi bytter rekkefølgen, for å unngå forvirring
			local minstedim : word `nummer_hittil' of `ekstra_dim'
*di "minstedim `minstedim'"			
			local splittdims = "`splittdims'" + " `minstedim'"
*di "splittdims `splittdims'"
			local ekstra_dim : subinstr local ekstra_dim "`minstedim'" "" //Sletter ordet fra lista
*di "ekstra_dim `ekstra_dim'"
			local ant_ekstradims = `ant_ekstradims' -1
*di "ant_ekstradims `ant_ekstradims'" 
			*Del på antallet og gå rundt til while-testen
			local ant_komb = `ant_komb' / `ant_hittil'
		} //End -while-
*di "rett etter while-løkka"	
		tempvar gruppeinndeling
		egen `gruppeinndeling' = concat(`splittdims') //Slår sammen alle splittdims og splitter etter alle kombinasjoner
		replace figursplitt = `gruppeinndeling'
	
	} //End -splitt-analyse -
	} //end -valgt ny metode-
	else { //Gammel metode er valgt
	
	* Metode 2: HARDKODETE FILNAVN-STUBS MED TILHØRENDE SPLITT-VARIABEL (original metode).
				gen figursplitt="ingen"
				if ///
				   regexm("`fil'", "ARBLEDIGE_")==1 ///
				 | regexm("`fil'", "BEFOLK_GK")==1 ///
				 | regexm("`fil'", "BEFPROG")==1 ///
				 | regexm("`fil'", "e0_NH_L")==1 ///
				 | regexm("`fil'", "e30_utdn_NH_L")==1 ///
				 | regexm("`fil'", "e30_utdn_DIFF_NH_L")==1 ///
				 | regexm("`fil'", "FRUKT_LKU_L")==1 ///
				 | regexm("`fil'", "HKR")==1 ///
				 | regexm("`fil'", "KREFTREG_samlet_NH")==1 ///
				 | regexm("`fil'", "KMI_LKU_")==1 ///
				 | regexm("`fil'", "KUHR_")==1 ///
				 | regexm("`fil'", "NPR_somatisk_NH")==1 ///
				 | regexm("`fil'", "RR_NH")==1 ///
				 | regexm("`fil'", "RFU_NH_ROYK")==1 ///
				 | regexm("`fil'", "RFU_NH_SNUS")==1 ///
				 | regexm("`fil'", "Utdanningsnivå_NH")==1 { 	// Disse filene genererer for mange 
					replace figursplitt = ALDER 				// boxplots for én figur, må splittes på alder.
				} // --------------------------------end -if- filer som må ha alderssplittede figurer----------
				* ---splitt etter andre dimensjoner------------------------------------------------------------
				if regexm("`fil'", "UFORE_")==1 { 		// Splittes etter type uføretrygd
					replace figursplitt = YTELSE
				} // ------end splitt ufore -----
				* ---splitt etter FLERE dimensjoner (20.01.2016)-----------------------------------------------
				if regexm("`fil'", "RESEPT_20")==1 ///
				 | regexm("`fil'", "DAAR_GK")==1 ///
				 | regexm("`fil'", "DAAR_nokkel")==1 {
					tempvar gruppeinndeling
					egen `gruppeinndeling' = concat(ALDER KJONN) //Slår sammen de to og splitter etter alle kombinasjoner
					replace figursplitt = `gruppeinndeling'
				}


				* --------------------end if-setninger filer som splittes etter annet enn alder----------------

	} //end else -gammel splittmetode valgt-

	* Dimensjonere overskriftene i delplottene
	  //Det er plass til ca 23 tegn pluss de kommaene som skytes inn (varierer litt pga proporsjonal font). 
	  //Sjekker maxlengde av kategorinavnene, og setter en skaleringsfaktor som brukes i grafen.
	  //"edl_txt" er string med alle kombinasjoner, den gir maxlengden.
	  local maxlengde : type edl_txt	//Lagrer "str23" eller hva nå typen er.
	  local maxlengde = subinstr("`maxlengde'", "str", "",.)  //Sitter igjen med bare tallet for lengden.
	  local skalering = 23/`maxlengde'
	  if `skalering'>1 local skalering =1		//Vi skal ikke forstørre korte tekster!
	  
	
*pause rett før plott	
	
	* --- B.4.a. BOXPLOT MEIS, middelverdi og spredning innen geo-nivå-------
	gen order=1 if GEO==0 // rekkefølge inni boxplottet
	replace order=2 if GEO>0
	replace order=2.5 if GEO>80
	replace order=3 if GEO>100 
	replace order=4 if storkommune==0
	replace order=5 if GEO>30000
	clonevar store_geo=num_geonivaa if (geonivaa=="L" | geonivaa=="F" | geonivaa=="K" | geonivaa=="B")
	levelsof figursplitt, local(figur)
	replace pw=1 if pw==. & geonivaa=="B" // pw for bydeler mangler
				// i hjelpefilen for befolkning, men vekting av bydels-
				// tallene gir ikke særlig mening uansett. 

	* --- FEILHÅNDTERING: Hvis graphkommandoen kræsjer, gi en melding og hopp videre til neste fil. ---
		* Capture fanger opp feilen, men hindrer all output. Noisily viser fram output (graf!) eller feilmelding likevel.
	foreach splitt in `figur' {		
		capture noisily graph hbox MEIS [fweight=pw] if figursplitt=="`splitt'", ///
		  by(`xtra' `konstant', ///
			rescale compact ///
			title(`"`fil',  Figurdato: `: di %tdCYND date(c(current_date),"DMY")'_kl. `: di %tcHHMM clock(c(current_time),"hms")'"', size(small))  ///
			subtitle(`"Alle verdier i Nesstar-kuben. Label for plottet variabel: "`MEISlabel'". Fleksibel skala."' "(Høyere rater desto lavere geo-nivå kan skyldes prikking som selektivt fjerner lave rater i små populasjoner.)", size(vsmall)) ///
		  ) /// 
		  over(num_geonivaa, sort(order)) ///
		  outergap(0) ytitle("")  medtype(cline) medline(lpattern(blank)) ///
		  m(1, m(none) mlabel(GEO) mlabangle(90)  mlabposition(6) mlabsize(vsmall))	///
		  subtitle(, size(*`skalering'))	//Overskrift i hvert delplott
		if _rc!=0 continue  //dvs. hopp til starten av løkka

		graph export "`drive'\Box_alleverdieravMEIS\\`figurnamestub'_alleMEIS_Spl_`splitt'.png", width(3000) replace	
		* ----------------------------end MEIS, middelverdi og spredning  -----
		
		
		
		* --- B.4.b. BOXPLOT MEIS, år-til-år-variasjon -------------------------
		su AARl
		if r(min) == r(max) {
			//Lagre en dummyfil, for å hindre unødvendig omigjen-kjøring av resten av analysen.
			capture file open dummy using "`drive'\Box_alleaar-til-aar\\`figurnamestub'_INTENTIONALLY_EMPTY_FILE.png", write 
			capture file close dummy
			
			noisily di "Filen har bare én årgang, jeg lager ikke årsvariasjon-figur. " 
			noisily di "OBS dummyfil opprettet, for å hindre unødvendig omigjen-kjøring av resten av analysen."
			log close _all
			continue 	// droppe årsvariasjonsfigurer hvis filen bare har én årgang 
		} // end -if- bare ett år i tidsserien	
		graph hbox endring_pct if figursplitt=="`splitt'" , ///
			by(`xtra' `konstant', compact ///
			title(`"`fil',  Figurdato: `: di %tdCYND date(c(current_date),"DMY")'_kl. `: di %tcHHMM clock(c(current_time),"hms")'"', size(small)) ///
			subtitle(`"Alle prosentvise år-til-år-endringer innen tidsseriene i Nesstar-kuben. Kun 130 største kommuner. Label for plottet variabel: "`MEISlabel'"."', size(vsmall)) ///
			)  ///
			over(store_geo, sort(order)) ///
			outergap(0) ///
			m(1, m(none) mlabel(GEO) mlabangle(90)  mlabposition(6) mlabsize(vsmall)) ///
			yline(0, lcolor(maroon) lpattern(shortdash)) ytitle("") ///
			subtitle(, size(*`skalering'))	//Overskrift i hvert delplott
		graph export "`drive'\Box_alleaar-til-aar\\`figurnamestub'_aar-til-aar_Spl_`splitt'.png",  width(3000) replace
		* ----------------------------end MEIS, år-til-år-variasjon ----------
	} // end -foreach- figur eller sub-figur (evt. hver aldersgruppe på egen figur)	

	* TIMELINE for bydeler, sum bydeler og kommune
	* Forsøksvis lages det bare én figur for hver by på hvert ark. Derfor trengs
	* full oppsplitting på alle dimensjoner
	
	qui su MEIS if GEO>30000
	if `r(N)'>0 { // Hvis det er bydelstall i filen ...
		* Ny <figursplitt2> som bestemmer hvor mange ark figurene trenger
		capture egen figursplitt2 = concat(`xtra')
		capture gen figursplitt2 = "ingen" // utføres hvis linjen over kræsjet
		levelsof figursplitt2, local(figur2)
		su AARl if  GEO>30000 & MEIS<.
		local aarmin = `r(min)'
		di "`aarmin'"
		* Keep bydeler og deres byer
		tempvar  bydelsbyflagg
		levelsof By, local(bdbyer) // By=kommunen til hver bydel (preppeskript)
		gen `bydelsbyflagg'=0
		foreach bdby of local bdbyer { //for hver by som har bydeler ...
			replace `bydelsbyflagg'=1 if string(GEO)=="`bdby'"
		}
		keep if GEO>30000 | `bydelsbyflagg'==1 // Keep by- og bydelstall
		* Kaste om på filen
		tempfile bydelstall
		preserve 
		keep if GEO>30000 			// keep bydelstall og vektet snitt
		egen aarMin=min(AARl) if MEIS<., by(By)
		rename MEIS bydels_MEIS
		drop GEO
		rename By GEO
		label var bydels_MEIS "Bydeler"
		label var w_MEIS "Vektet snitt bydeler"
		keep GEO AAR `xtra' bydels_MEIS w_MEIS aarMin figursplitt2
		sort GEO AAR `xtra' 
		save `bydelstall'
		restore
		keep if `bydelsbyflagg'==1 	// keep kommunetall
		label var MEIS "Kommune"		
		keep GEO AAR `xtra' AARl aar1 MEIS
		sort GEO AAR `xtra' 
		merge GEO AAR `xtra' using `bydelstall'
		foreach splitt2 in `figur2' {	
			capture tw 	(line MEIS AARl,  lwidth(thick) lc(gs0) sort) ///
				(sc  bydels_MEIS AARl, m(Oh)) ///
				(line w_MEIS AARl, sort lc(orange)) ///
				if AARl>=aarMin & figursplitt2=="`splitt2'" ///
				, by(GEO `xtra', rescale legend(position(6)) ///
				title(`"`fil',  Figurdato: `: di %tdCYND date(c(current_date),"DMY")'_kl. `: di %tcHHMM clock(c(current_time),"hms")'"', size(small)) ///
				subtitle(`"Kommunetall sammenlignet med bydelstall. Årganger uten bydelstall er utelatt. Label for plottet variabel: "`MEISlabel'"."', size(vsmall)) ///
				) ///
				legend(r(1)) subtitle(, size(*`skalering'))
			capture graph export "`drive'\Timeline_bydel\\`figurnamestub'_TimelineBydel_Spl_`splitt2'.png",  width(3000) replace
	}		
	
	log close _all
} // end if Hvis det er bydelstall... 
log close _all
} // end foreach fil 


*project, creates("`drive'\csvkopierPreppet\Boxplot_geonivå\RR_KOLS_w.png")

pause off
exit
} // end quietly
