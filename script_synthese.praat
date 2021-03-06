#cleinfo
#script de rendu de synthèse vocale


#compteur j
j=0 
########################################### emplacement des fichiers
#form emplacement fichiers
	#comment Le chemin de fichier son et celui de Textgrid
	#text Son /Users/SI/Documents/phonétique/son.wav
	#text Textgrid /Users/SI/Documents/phonétique/transcription.TextGrid
	#comment Tapez votre mot en SAMPA avec les pauses de debut et fin
	#text mot _pakE_ _m@ny_ sOlo_
	#comment Rentrez l'emplacement où enregistrer votre mot synthétisé (forme .wav)
	#text enregistrement /Users/SI/Documents/phonétique/
#endform

############################################ procédures boîte de dialogue

form quel mot voulez vous synthétiser?
	comment Choix forcé entre paquet menu solo
	choice orthographe_mot:3
		button paquet
		button menu
		button solo
word orthographe_mot
endform
#if orthographe_mot$= "menu"
	#pause  tout va bien 

############################################# procédures de 'son', 'transcription', 'base', 'dictionnaire'

transcription=Read from file... /Users/SI/Documents/phonétique/transcription.TextGrid
son=Read from file... /Users/SI/Documents/phonétique/son.wav
son2=Read from file... /Users/SI/Documents/phonétique/'orthographe_mot$'.wav
base=Create Sound from formula... sineWithNoise 1 0 0.1 44100 0
select 'son'   
zeros=To PointProcess (zeroes)... 1 yes no 
dico = Read Table from tab-separated file... /Users/SI/Documents/phonétique/dico.txt

############################################ procédures dictionnaire pour mot choisi 'paquet'

if orthographe_mot$="paquet"
	select 'dico'
	Extract rows where column (text)... orthographe "is equal to" paquet
	resultat = Get number of rows
	for x from 1 to resultat
		orthographe$=Get value... x orthographe
		if orthographe$=orthographe_mot$
			pho$=Get value... x phonetique
			#donner transcription phonetique des mots choisis		
  			mot$="_'pho$'_"
                	printline Vous avez choisi un de trois mots: 'orthographe$', sa forme SAMPA est: 'mot$'
		endif
	endfor 
endif

############################################## procédures dictionnaire pour mot choisi 'menu'
	
	if orthographe_mot$= "menu"
		select 'dico'
		Extract rows where column (text)... orthographe "is equal to" menu
		resultat = Get number of rows
		for x from 1 to resultat
			orthographe$=Get value... x orthographe
			if orthographe$=orthographe_mot$				
				pho$=Get value... x phonetique
  				mot$="_'pho$'_"
               			printline Vous avez choisi un de trois mots: 'orthographe$', sa forme SAMPA est: 'mot$'
			endif
		endfor 
	endif

############################################## procédures dictionnaire pour mot choisi 'solo'

		if orthographe_mot$= "solo"
			select 'dico'
			Extract rows where column (text)... orthographe "is equal to" solo
			resultat = Get number of rows
			for x from 1 to resultat
				orthographe$=Get value... x orthographe
				if orthographe$=orthographe_mot$
					
					pho$=Get value... x phonetique
  					mot$="_'pho$'_"
                			printline Vous avez choisi un de trois mots: 'orthographe$', sa forme SAMPA est: 'mot$' 
				endif
			endfor
		endif 

###############################################  procédures: une recherche des diphones dans la transcription pour le mot choisi

select 'transcription'
nb_intervalles=Get number of intervals... 1 
longueur_mot=length(mot$)
#trouver=0
for y from 1 to longueur_mot-1       
	diphone_mot$=mid$(mot$, y, 2) 	
		for intervalle from 1 to nb_intervalles-1   
			select 'transcription'
			contenu_intervalle$=Get label of interval... 1 intervalle
			contenu_intervalle_suivant$=Get label of interval... 1 'intervalle' + 1
			diphone$=contenu_intervalle$ + contenu_intervalle_suivant$
			if diphone$=diphone_mot$
				j=j+1
				printline On a trouvé le diphone numéro 'j': 'diphone$'
								
################################################ procédures: rendre les diphoes aux son

				select 'transcription'
				start=Get start point... 1 'intervalle' 
				mid=Get end point... 1 'intervalle'	 
				end=Get end point... 1 'intervalle' + 1 
				cou1=(start+mid)/2
				cou2=(mid+end)/2
				select 'zeros' 
				index1=Get nearest index... cou1
				time1=Get time from index... index1   
				index2=Get nearest index... cou2
				time2=Get time from index... index2
				#printline 'y': 'diphone$' de 'cou1' à 'cou1'
				select 'son' 
				extrait=Extract part... time1 time2 Gaussian1 1 no
				select 'base'
				plus 'extrait'
				base=Concatenate
			endif
		endfor
endfor

################################################## procédures: enlever F0 et enregistrer les diphones concatennés automatiquement dan notre PC

select 'extrait'
for y from 1 to longueur_mot-1
	plus 'extrait'
endfor
plus 'transcription'
plus 'son'
plus 'zeros'
Remove
select 'base'
Save as WAV file... 'orthographe_mot$'.wav
select 'base'
Remove

################################################## procédures modifier durées

#procedure changer_duree(lieu, diphone$)
son2=Read from file... /Users/SI/Documents/phonétique/'orthographe_mot$'.wav
        select  'son2'
	#select 'base'
	manip = To Manipulation... 0.01 75 600
	select 'manip'
	duree = Extract duration tier
	select 'duree'
	Add point... 0.3 1
	select 'duree'   
        #changer le fichier sur la durée
	plus 'manip'
	Replace duration tier
	#refaiire le fichier son
	#Edit
	#fichier_final = Get resynthesis (overlap-add)
	#Rename...'diphone$'
#endproc

#################################################### procédures changer pitch

#procedure changer_duree(lieu , diphone$)
	select  'son2'
	#select 'base'
	manip = To Manipulation... 0.01 75 600
	select 'manip'
	pitch = Extract pitch tier
	select 'pitch'
	fin = Get end time
	#prendre la duree totale du son
	milieu = fin/2
	Remove points between... 0 fin  
	#dans le pitch enlever tous les points dans modify, se retrouver  tout droit par défaut à 100
	Add point... 0.3 1
	select 'duree'  
	plus 'manip'
	Replace duration tier
	#refaire le fichier son
	#Rename...'diphone$'
	select Manipulation 'orthographe_mot$'
	View & Edit
	fichier_final = Get resynthesis (overlap-add)
#endproc




