# Functie ce cauta fisierele vechi
# Primeste ca parametru un path

# Formaturi acceptate:
# YYYY-MM-DD  MM intre [01-12] DD intre [01-31] ex 2024-09-01
# ZILE ex 2z
# SAPTAMANI ex 1s
# LUNI ex 6l
# ANI ex 1a
cautare(){
        if [[ ! -d $1 ]]; then # Testare director valid
        	echo "Path invalid" >&2
        else
	        echo "Introduceti data"
	        read input

	        if [[ $input =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$ ]]; then  # Format YYYY-MM-DD
	                find $1 -not -newermt $input -type f -exec echo {} \; # Echo pt debugging
	        elif [[ $input =~ ^[0-9]+z$ ]]; then # Format zile
	                n=${input:0:-1}
	                find $1 -mtime +$n -exec echo {} \;
	        elif [[ $input =~ ^[0-9]+s$ ]]; then # Format saptamani
	                n=${input:0:-1}
	                n=$(( n * 7 ))
	                find $1 -mtime +$n -type f -exec echo {} \;
	        elif [[ $input =~ ^[0-9]+l$ ]]; then # Format luni
	                n=${input:0:-1}
	                n=$(( n * 30 ))
	                find $1 -mtime +$n -type f -exec echo {} \;
	        elif [[ $input =~ ^[0-9]+a$ ]]; then # Format ani
	                n=${input:0:-1}
	                n=$(( n * 365 ))
	                find $1 -mtime +$n -type f -exec echo {} \;
	        else # Formatul nu este acceptat
	                echo "Format invalid, foloseste --help pentru ajutor" >&2
	        fi
		fi
}


# Functie de monitorizare
# 2 parametri
# $1 - path ul
# $2 - tipul de comanda
monitorizare(){
	case $2 in
		1)
			"echo 0 20 * * 1 find $1 -mtime +60 -type f -exec rm {} \;" | crontab 
			;;
		2)
			echo "0 20 * * 1 find $1 -mtime +60 -type f ! -name "*.old" -exec mv {} {}.old \;" | crontab  
			;;
		3)
  			#TODO: VERIFICA DACA A FOST DEJA MARCAT CA DEPERCATED
			echo "0 20 * * 1 find $1 -mtime +60 -type f -exec sed -i '1s/^/#### DEPERCATED ####\n/' {} \;" | crontab 
			;;
		*)
			;;
	esac
}


# Functie cu meniul de configurare
# Primeste un parametru, path pentru verificare si transmitere mai departe
config(){
		if [[ ! -d $1 ]]; then # Testare director valid
			echo "Path invalid" >&2
		else
	        echo "Lista configurari monitorizare:"
	        opt1="Stergere fisiere"
	        opt2="Redenumire fisiere extensia .old"
	        opt3="Adaugare linie de ### DEPERCATED ### pe prima linie a fisierelor"
	        opt4="Inapoi"

			opt_selectata=0 # Variabila pentru a vedea daca s-a anulat monitorizarea sau nu
							# Default false (0)
	        select optiune in "$opt1" "$opt2" "$opt3" "$opt4"; do
	              	case $REPLY in
	                        1)
	                                VALOARE_CONFIG=1
									                break
	                                ;;
	                        2)
	                                VALOARE_CONFIG=2
	                                break
	                                ;;
	                        3)
	                                VALOARE_CONFIG=3
	                                break
	                                ;;
	                        4)
	                            	opt_selectata=1
	                            	  break
	                                ;;
	                        *)
	                                echo "Cod de configurare invalid" >&2
	                                ;;
	                esac
	        done
			if [[ $opt_selectata -eq 0 ]]; then
	        	monitorizare $1 $VALOARE_CONFIG 
	       		echo "Monitorizarea directorului $1 a incepui. Modul de configurare este $VALOARE_CONFIG"
			else
				echo "Monitorizare anulata"
			fi
		fi
}

log() {
	if [[ "$debug_mode" == "on" ]]; then
		echo "$1"
        fi
        echo "$1" >> out.log
}

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
		 echo "Nu exista un fisier cu acest nume!"	
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
						echo "Fisierul se afla deja in directorul furnizat!"
					else 
						mv "$nume_fis" "$dir_dest"
                                                echo "Fisierul a fost mutat cu succes"
					fi

					else 
						echo "Directorul furnizat nu exista!" 
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
			echo "Optiune invalida"
			break
			;;
		esac
	
done
done
}

# Main
debug_mode="off"
if [[ $# -eq 0 ]]; then
    # Rularea programului normala
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
				cautare $path
				;;
			2)  # Mutare fisiere
				mutare
    # TODO: FUNCTIE MUTARE FISIERE
				;;
			3)	# Monitorizare
				VALOARE_CONFIG=1 # Valoare default
				echo "Introduceti path ul unui director"
				read path
				config $path
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
# TODO: ARGUMENTE LINIE COMANDA	
 ARGS=$(getopt -o hu -l help,debug:,cautare:,mutare,config:,monitorizare:,usage -- "$@")
 eval set -- "$ARGS"
 
 while true; do
	case "$1" in
		-h|--help)
			log "Acest program ofera backup avansat, printre optiunile acestuia se afla gasirea tuturor fisierelor mai vechi de o data calendaristica, mutarea fisierelor, stergerea fisierelor si multe altele. Pentru mai multe detalii accesati usage astfel: ./program.sh -u sau ./program.sh --usage"
			shift
		;;
	
		--debug)
			shift
			if [ "$1" != "" ]; then
				debug_mode="$1"
				shift
			else
			   log "Argumente insuficiente!"
			   exit 0
			fi
		;;
	     --cautare)
		shift
		if [ "$1" != "" ]; then
			cautare "$1"
			shift
		else 
			log "Argumente insuficiente"
			exit 0
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
                        exit 0
                fi
		;;
	--monitorizare)
		shift
		if [ "$1" != "" ]; then
                  arg1="$1"
		  shift    
		  if [ "$1" != "" ]; then
			monitorizare "$arg1" "$1"
			shift
		  else 
			log "Argumente insuficiente"	
		  	exit 0
		   fi
                else 
                        log "Argumente insuficiente"
                        exit 0
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


#TODO: LOGURI
