log() {
	if [[ "$debug_mode" == "on" ]]; then
		echo "$1"
        fi
        echo "$1" >> out.log
}

#Functia mutare ofera optiuni pentru mutare intr-un alt director sau salvarea in cloud a fisierului
#Aceasta verifica existenta fisierului si a directorului inainte de a face orice alta operatiune pentru a diminiua sansa de a aparea erori
#Optiunea Iesire intoarce utilizatorul la meniul principal in cazul meniului interactiv sau opreste porgramul in cazul utilizarii cu argumente in linia de comanda
mutare() {
while true; do
echo "Selectati o optiune din cele de mai jos!"
select optiune in "Mutare fisier in alt director" "Mutare fisier in github" "Iesire"; do
	if [[ ! -z "$optiune"  && "$optiune" != "Iesire" ]]; then
	     echo "Introduceti numele complet al fisierului"
            read nume_fis
	
  	    if [[ -f $nume_fis && ! -z $nume_fis ]]; then
		echo "Selectati o optiune din cele de mai jos!"
   	    else
		 log "Nu exista un fisier cu acest nume!"	
		 break
	    fi
	fi
		case $optiune in
			"Mutare fisier in alt director")
					echo "Introduceti calea spre directorul unde doriti sa mutati fisierul: "
					read dir_dest
					if [ -d "$dir_dest" ]; then
						director_initial_fis=$(dirname "$nume_fis")
					if [ "$director_initial_fis" == "$dir_dest" ]; then
						log "Fisierul se afla deja in directorul furnizat!"
					else 
						mv "$nume_fis" "$dir_dest"
                                                echo "Fisierul a fost mutat cu succes"
					fi

					else 
						log "Directorul furnizat nu exista!" 
					fi
					break
					;;	
			"Mutare fisier in github")
					cd "$(dirname "$nume_fis")"
					git init
					echo "Introduceti repository-ul:"
					read repo_link
					if ! git remote|grep -q origin; then
    						git remote add origin "$repo_link"
					fi
					git config pull.rebase false
					git pull origin main
					git add "$nume_fis"
					echo "Descriere commit:" 
					read descriere  
                                        git commit -m "$descriere"
					git branch -M main
					if git push -u origin main; then
					echo "Fisierul a fost mutat cu succes!"
					fi
					break
					;;
			"Iesire")
				return 0
				;;
			*)
			log "Optiune invalida"
			break
			;;
		esac
	
done
done
}


# Functie ce cauta fisierele vechi
# Parametri:
# $1 - path valid
# $2 data in unul din formaturile de mai jos 
#
# YYYY-MM-DD  MM intre [01-12] DD intre [01-31] ex 2024-09-01
# ZILE ex 2z
# SAPTAMANI ex 1s
# LUNI ex 6l
# ANI ex 1a
cautare(){
		data_in=$2
        if [[ $data_in =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$ ]]; then  # Format YYYY-MM-DD
	            find $1 -not -newermt $data_in -type f -exec echo {} \; # Echo pt debugging
	    elif [[ $data_in =~ ^[0-9]+z$ ]]; then # Format zile
	            n=${data_in:0:-1}
	            find $1 -mtime +$n -exec echo {} \;
	    elif [[ $data_in =~ ^[0-9]+s$ ]]; then # Format saptamani
	            n=${data_in:0:-1}
	            n=$(( n * 7 ))
	            find $1 -mtime +$n -type f -exec echo {} \;
	    elif [[ $data_in =~ ^[0-9]+l$ ]]; then # Format luni
	            n=${data_in:0:-1}
	            n=$(( n * 30 ))
	            find $1 -mtime +$n -type f -exec echo {} \;
	    elif [[ $data_in =~ ^[0-9]+a$ ]]; then # Format ani
	            n=${data_in:0:-1}
	            n=$(( n * 365 ))
	            find $1 -mtime +$n -type f -exec echo {} \;
	    else # Formatul nu este acceptat
	            log "Format invalid, foloseste --help pentru ajutor" >&2
		fi
}

spatiu_disc() {
     #Salvam valoarea spatiului disponibil pe disc in var folosind comenzile df -m pentru a obtine informatiile in MB despre utilizarea spatiului pe disc, head -n 2 pentru utiliza doar primele 2 linii si tail -n 1 pentru ca avem nevoie doar de ultima linie si cut pentru a prelua exact valoare de care avem nevoie
      var=$(df -m |head -n 2 | tail -n 1 | tr -s ' ' | cut -d ' ' -f 4) 
     
     #Salvam valoarea spatiului total de pe disc in var2
      var2=$(df -m |head -n 2 | tail -n 1 | tr -s ' ' |  cut -d ' ' -f 2) 

    #Pragul reprezinta 10% din spatiul total
      prag=$(($var2/10))

      if [ $var -lt $prag ]; then
             echo "Spatiul pe disc este insuficient!"
      else
             echo "Spatiul pe disc este suficient! Spatiu liber: $var MB"
      fi
}

filtrare_procese() {
#Filtrarea proceselor ce folosesc peste 100 MB de RAM si afisarea lor in format tabelar
ps aux | awk '$6 > 100000 {printf "%-10s %-10s %-10s %-10s\n", $1, $2, $4, $11}' | column -t                
}

# Functie de monitorizare
# Parametri:
# $1 - path ul
# $2 - tipul de comanda
monitorizare(){
	case $2 in
		1)
		  #crontab -l listeaza sarcinile cron existente in crontab pentru a le adauga alaturi de noua sarcina, crontab - sterge sarcinile existente si adauga sarcinile pe care le primeste in crontab        
			(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -type f -exec rm {} \;") | crontab -
			echo "Monitorizare adaugata"
			;;
		2)
			(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -type f ! -name "*.old" -exec mv {} {}.old \;") | crontab -  
			;;
		3)
			(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -type f -exec sed -i '1s/^/#### DEPRECATED ####\n/' {} \;") | crontab - 
			;;
		4)
			(crontab -l 2>>out.log; echo "9 1 * * 2 find $1 -mtime +1 -type f -exec chmod u-x,g-x,o-x {} \;") | crontab -	
			;;
		5)
			test -f archive.tar || touch archive.tar # Se va creea o arhiva daca nu exista deja
			(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -type f -exec tar -rvf archive.tar {} \;") | crontab -
			;;			
		
		6) 
			spatiu_disc
			;;

		7)
			filtrare_procese()
			;;
		
		*)
			log "Optiune invalida"
			;;
	esac
}


# Functie meniu de configurare
# Parametri:
# $1 - path valid
config(){
	    echo "Lista configurari monitorizare:"
	    opt1="Stergere fisiere"
	    opt2="Redenumire fisiere extensia .old"
	    opt3="Adaugare linie de ### DEPRECATED ### pe prima linie a fisierelor"
	    opt4="Luare permisiune executare"
	    opt5="Arhivare fisiere"
	    optEXIT="Iesire"

	    select optiune in "$opt1" "$opt2" "$opt3" "$opt4" "$opt5" "$optEXIT"; do
	    	case $REPLY in
	           1)	# Stergere fisiere
					monitorizare $1 1 
					echo "Monitorizarea directorului $1 a inceput"
					;;
	            
               	    2)  # Redenumire fisiere extensia .old
					monitorizare $1 2
					echo "Monitorizarea directorului $1 a inceput"
					;;
	            3)  # Adaugare linie de ### DEPRECATED ### pe prima linie a fisierelor
					monitorizare $1 3
					echo "Monitorizarea directorului $1 a inceput"
	                ;;
	            4)
	            	monitorizare $1 4
	            	echo "Monitorizarea directorului $1 a inceput"
	                ;;
	            5)
	            	monitorizare $1 5
	           	echo "Monitorizarea directorului $1 a inceput"
	                ;;
	            
		    8)	# Iesire
	            	echo "Iesire"
			break
	                ;;

		    6)
			monitorizare $1 6
			;;
		    
		    7)
			monitorizare $1 7
			;;
	            *)
	                log "Cod de configurare invalid" >&2
	                ;;
	                esac
	        done
}

# Main
debug_mode="off"
if [[ $# -eq 0 ]]; then
    # Rularea programului fara argumente pe linia de comanda 
	opt1="Gasire fisiere vechi"
	opt2="Mutare fisiere"
	opt3="Monitorizare fisiere"
	opt4="Iesire"
	# Meniul principal
	select optiune in "$opt1" "$opt2" "$opt3" "$opt4"; do
		case $REPLY in
			1)  # Gasire fisiere vechi
				echo "Introduce path ul unui director"
				read path
       			if [[ ! -d $path ]]; then # Testare director valid
        			echo "Path invalid" >&2
				else
		        	echo "Introdu data (ex 2z, 2024-09-01, 3l)"
	        		read data_in
					cautare $path $data_in
				fi
				;;
			2)  # Mutare fisiere
					mutare
				;;
			3)	# Monitorizare
				echo "Introduce path ul unui director"
				read path
				if [[ ! -d $path ]]; then # Testare director valid
        			echo "Path invalid" >&2
				else
					config $path
				fi
				;;
			4)	# Iesire
				exit 0
				;;
			*)  # Altfel
				echo "Comanda invalida" >&2
				;;
	    esac
	done
else
    # Rularea programului cu argumente pe linia de comanda
	 ARGS=$(getopt -o hu -l help,debug:,cautare:,mutare,config:,monitorizare:,usage -- "$@")
 eval set -- "$ARGS"
 
 while true; do
	case "$1" in
		-h|--help)
			echo "Acest program ofera backup avansat, printre optiunile acestuia se afla gasirea tuturor fisierelor mai vechi de o data calendaristica, mutarea fisierelor, stergerea fisierelor si multe altele. Pentru mai multe detalii accesati usage astfel: ./program.sh -u sau ./program.sh --usage"
			shift
		;;
	
		--debug)
			shift
			if [ "$1" != "" ]; then
				debug_mode="$1"
				shift
			else
			   log "Argumente insuficiente!"
			   exit 1
			fi
		;;
	     --cautare)
		shift
		if [ "$1" != "" ]; then
			cautare "$1"
			shift
		else 
			log "Argumente insuficiente"
			exit 1
		fi
		;;
	    --mutare)
		mutare
		shift
		;;
	    --config)
		shift
                if [ "$1" != "" ]; then
                        config "$1"
			shift
                else 
                        log "Argumente insuficiente"
                        exit 1
                fi
		;;

	#Mai trebuie modificat cu functiile care o sa se adauge
	-u|--usage) 
		echo "Utilizare: ./program [-h|--help] [--debug on|off] [--cautare path] [--mutare] [--config path] [--monitorizare path tip_comanda] [--usage]"					
		shift		
		;;
	--)
		log "Nu mai exista optiuni"
		shift
		break	
		;;
	*)
	 log "Optiune invalida"
	 exit 1
	;;
esac

 	 
done
fi

