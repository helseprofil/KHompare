* Unicode-translated med Latin1 encoding, 23.11.2015.

****  OBS:  Scriptet "..z0 Samlet kjøring" må kjøres først, for der settes parametre.
****  

/*
Jørgen M. 8. jan. 2014

F.o.m. 2016 (v08_) hentes data fra KH2016NESSTAR (tilsv. for NH). 
Ved kjøring lagres filer fra R i \DATERT\csv\. De sjekkes (av Nora og Marie), og 
"godkjente" filer kopieres over i KH2016NESSTAR for videre sjekk med boxplot etc.


v07_automatiskNyeste (Jørgen 4/5/2015): Når det gjelder *KOMMUNEDATA*, forut-
	settes følgende:
		-Alle filer skal hentes fra KH2016NESSTAR (el. tilsv. for NH)
		-Bare den nyeste versjonen av hver fil er av interesse, 
		-og bare hvis den ikke er blitt kopiert før.

v08_ny_katalogstruktur (J og S 30.11.15): Rydde i katalogstrukturen. 
	OBS OM UNICODE: Data (csv) fra R vil ikke være unicode, mens Stata14 krever unicode. 
	Derfor kjøres "unicode translate", som oversetter de filene som trenger det.
	NB: Encoding "Latin1" er antakelig riktig for det meste, men dersom de oversatte filene 
	inneholder "rare" tegn må sannsynligvis en annen encoding brukes (se Stata 14 eller senere,
	hjelpefilen (gi kommandoen) "help unicode translate").

v09_dialog (stbj apr-2016): Tilrettelagt for kjøring fra en dialog (.dlg) -fil i samme katalog.
	Erstattet 'exit' med 'continue' i kopieringsløkka - scriptet stoppet. (Stata 17, stbj 22.6.2021)
	
*/ 
*===============================================================================
set more off

*--- M A K R O E R  -----------------------------------------------------------
*Kopierer verdiene satt i Globals av dialogen, over i Locals, så slipper jeg 
*å redigere alle steder de brukes.
*Profil-årgang: Satt av dialogen
local aargang = "$aargang"

*KH- eller NH-data: Satt av dialogen
local statbank = "$statbank"	//Tillatte verdier: NH , KH

*(Ulik path for KH og NH - automatisert)
	if "`statbank'"      == "KH" local katalog = "KOMMUNEHELSA"
	else if "`statbank'" == "NH" local katalog = "NORGESHELSA"

/***************
* KATALOGER I UTVIKLINGSFASEN
		/*			MULIGE ÅRGANGER: 2016, 2017. Kan ikke være lavere enn inneværende år, det sjekkes.
		INNDATA:
		På DEVELOP ligger \Produkter\Kuber\Norgeshelsa <og Kommunehelsa> \Datert\csv, og
		\...\KH2015NESSTAR. For NH ligger både NH2015NESSTAR og ..2016..
		Det er <KH2015NESSTAR>-type kataloger som er datakilde i skarpt script.
		Kopier inn to årganger av hver statbank, så jeg får testet å bytte årgang. DONE.
		UTDATA:
		Skarp: "Drive" settes til \PRODUKSJON\VALIDERING\NESSTAR_KUBER/`aargang'/`statbank'
		Opprett DEVELOP\VALIDERING.... for samme fire som for inndata. DONE.
		*/
	
*INNDATA (*.csv)
 	local datamappe	"F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\DEVELOP\PRODUKTER\KUBER/`katalog'/`statbank'`aargang'NESSTAR"
	
*UTDATA (*.dta)
	*local drive = "A:"		//Hvis man har RAM-disk!
	local drive = "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\DEVELOP\VALIDERING\NESSTAR_KUBER/`aargang'/`statbank'"
	
*Opprette katalogstrukturen for datafiler og plott
	capture mkdir "`drive'"
	capture mkdir "`drive'\Box_alleverdieravMEIS"
	capture mkdir "`drive'\Box_alleaar-til-aar"
	capture mkdir "`drive'\GODKJENT"
	capture mkdir "`drive'\Tabell"
	capture mkdir "`drive'\Timeline_bydel"
	capture mkdir "`drive'\z_Data"
	capture mkdir "`drive'\z_Data\dtakopierPreppet"
	capture mkdir "`drive'\z_Data\dtakopier"
	local nyarbmappe = _rc
	di "Ble mappen `drive'\z_Data\dtakopier  opprettet på nytt i denne kjøringen? `nyarbmappe' (0=ja 693=nei)"

	
	
	
***************************************************/
*SKARPE KATALOGER:
	
*INNDATA (*.csv)
 	local datamappe "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\KUBER/`katalog'/`statbank'`aargang'NESSTAR"
 
*UTDATA (*.dta)
	*local drive = "A:"		//Hvis man har RAM-disk!
	local drive = "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\VALIDERING\NESSTAR_KUBER/`aargang'/`statbank'"
	
*Opprette katalogstrukturen for datafiler og plott
	capture mkdir "`drive'"
	capture mkdir "`drive'\Box_alleverdieravMEIS"
	capture mkdir "`drive'\Box_alleaar-til-aar"
	capture mkdir "`drive'\GODKJENT"
	capture mkdir "`drive'\Tabell"
	capture mkdir "`drive'\Timeline_bydel"
	capture mkdir "`drive'\z_Data"
	capture mkdir "`drive'\z_Data\dtakopierPreppet"
	capture mkdir "`drive'\z_Data\dtakopier"
	local nyarbmappe = _rc
	di "Ble mappen `drive'\z_Data\dtakopier  opprettet på nytt i denne kjøringen? `nyarbmappe' (0=ja 693=nei)"
	
********************************************************************************************/
	
*Klargjøre for Unicode Translate: OBS endre encoding dersom det dukker opp "rare" tegn i de ferdige filene!
clear
unicode encoding set Latin1

*------------------------------------------------------------(END makroer)---

cd "`datamappe'"

*--- SJEKKE AT VI STÅR I RETT WORKING DIRECTORY ------------------------------
		/*Inndata-mappen må være pwd for å kjøre unicode translate.
		  LA INN et ledd til i assert-sjekken (stbj 03.11.2015): 
		  Dersom pwd ikke inneholder et årstall, blir "innevProfilaar" blank, dvs Missing,
		  og Missing ER større enn dagens årstall. 
		  Må m.a.o. også sjekke at "innevProfilaar" ikke er Missing.
		  */
clear
set obs 1
gen innevProfilaar = regexs(1) if regexm("`c(pwd)'","([0-9][0-9][0-9][0-9])")
local innevProfilaar=innevProfilaar
noisily di as result "Sjekker at vi står i rett directory"
assert real(innevProfilaar) >= real(word(c(current_date),3)) & real(innevProfilaar)<.
*------------------------------------------------------------(END pwd)------


*--- LISTE OVER NYESTE CSV-FILER ---------------------------------------
* Identifisere hva som er nyeste versjon av hver Nesstar-fil i inndatakatalogen.
clear
local csvfiler : dir "`datamappe'" files "*.csv", respectcase // liste over alle
								// versjoner av alle Nesstar-filer i DATERT\csv
local antallfiler = wordcount(`"`csvfiler'"')
set obs `antallfiler'
gen fil="" 						// f.x. BEFOLK_GK_2015-03-03-11-20.csv
gen stamme="" 					// f.x. BEFOLK_GK
gen versjon="" 					// f.x. 2015-03-03-11-20
forvalues k=1/`antallfiler' {
	replace fil=word(`"`csvfiler'"',`k') in `k' // hvert filnavn sin linje
	replace fil= subinstr(fil, `"""', "", .) // få vekk apostroffer fra filnavn
}
replace stamme=regexr(fil,"_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][.]+csv","")
replace versjon=regexs(0) if regexm(fil,"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]")
gen double prodtidspkt=clock(versjon,"YMDhm")
egen double siste=max(prodtidspkt), by(stamme)
codebook stamme
keep if prodtidspkt==siste
replace fil=subinstr(fil, ".csv", "", 1)
levelsof fil, local(nyestecsvfiler) clean
*-----------------------------------------(END nyeste csv-versjoner)----------



*--- KOPIERING --------------------------------------------------------------
* Kopierer nyeste versjon av hver Nesstar-fil i inndatakatalogen, så lenge den 
	*ikke er blitt kopiert tidligere.
* a) Liste over filer som allerede er kopiert:
local eksisterendekopier : dir "`drive'\z_Data\dtakopier" files "*.dta", respectcase
foreach nyestecsvfil of local nyestecsvfiler {
	*--- STOPPE her hvis ...--------------------------------------------------
	* a. ... en identisk kopi av den nyeste csv-filen allerede finnes 
		if regexm(`"`eksisterendekopier'"',"`nyestecsvfil'")==1 {
			di as input "IKKE kopiert: `nyestecsvfil'  - FORDI den fins fra før"
			continue
		}
	* b. ... filen ikke egner seg for boxplots
		if regexm("`nyestecsvfil'","Dode1.1")==1 ///
		 | regexm("`nyestecsvfil'","SKJENKETIDSSLUTT")==1 {
			di as input "IKKE kopiert: `nyestecsvfil'  - FORDI den er unntatt fra boxplots i kopieringsscriptet"
			continue
		}
	* --- KOPIERE hvis filen *ikke* finnes fra før ---------------------------
	* Stata 14 leser æøå på annen måte enn tidligere, og disse dataene skal ikke tilbake til R:
	clear	//Kreves før unicode translate. `Datamappe' må være pwd.
	unicode translate "`nyestecsvfil'.csv"
	
	insheet using "`datamappe'\\`nyestecsvfil'.csv", delimiter(";") clear case
	save "`drive'\z_Data\dtakopier\\`nyestecsvfil'.dta", replace
	di as result "Kopiert: `nyestecsvfil'"
}
*----------------------------------------------------(END kopiering) ----------

cd "$Path"	//Sette pwd tilbake til dialogens og scriptenes path. Makroen settes av dialogen.
