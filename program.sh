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
		log "Fisierul exista!"
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
				     if [[ -x "$dir_dest" && -w "$dir_dest" ]]; then
					director_initial_fis=$(dirname "$nume_fis")
					if [ "$director_initial_fis" == "$dir_dest" ]; then
						log "Fisierul se afla deja in directorul furnizat!"
					else 
						mv "$nume_fis" "$dir_dest"
                                                echo "Fisierul a fost mutat cu succes"
					fi
				    else 
					log "Directorul furnizat nu are permisiunile necesare"
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
			(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -type f -exec chmod u-x,g-x,o-x {} \;") | crontab -	
			;;
		5)
			test -f archive.tar || touch archive.tar # Se va creea o arhiva daca nu exista deja
			(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -type f -exec tar -rvf archive.tar {} \;") | crontab -
			;;			
		
		6) 
		 	(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -size +100M -type f -exec rm {} \;") | crontab -
			;;

		7)
			dir_nou="$1/backup"
			mkdir -p $dir_nou
			(crontab -l 2>>out.log; echo "0 20 * * 1 find $1 -mtime +60 -type f -exec cp {} $dir_nou \;") | crontab -
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
	    opt6="Stergere fisiere mari"
	    opt7="Backup periodic fisiere"
	    optEXIT="Iesire"

	    select optiune in "$opt1" "$opt2" "$opt3" "$opt4" "$opt5" "$opt6" "$opt7" "$optEXIT"; do
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
while true; do
	opt1="Gasire fisiere vechi"
	opt2="Mutare fisiere"
	opt3="Monitorizare fisiere"
	opt4="Iesire"
	# Meniul principal
	echo "Selectati o optiune din cele de mai jos!"
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
				break
				;;
			2)  # Mutare fisiere
				mutare
				break
				;;
			3)	# Monitorizare
				echo "Introduce path ul unui director"
				read path
				if [[ ! -d $path ]]; then # Testare director valid
        			echo "Path invalid" >&2
				else
					config $path
				fi
				break
				;;
			4)	# Iesire
				exit 0
				;;
			*)  # Altfel
				echo "Comanda invalida" >&2
				break
				;;
	    esac
	done
done   
else

    # Rularea programului cu argumente pe linia de comanda
	 ARGS=$(getopt -o hu -l help,debug:,cautare:,mutare,config:,usage -- "$@")
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

	-u|--usage) 
		echo "Utilizare: ./program [-h|--help] [--debug on|off] [--cautare path] [--mutare] [--config path] [--usage]"					
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

