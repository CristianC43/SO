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
	        echo "Introduce data"
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

# Main
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
				echo "ceva"
    # TODO: FUNCTIE MUTARE FISIERE
				;;
			3)	# Monitorizare
				VALOARE_CONFIG=1 # Valoare default
				echo "Introduce path ul unui director"
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
 echo "ceva"
fi


#TODO: LOGURI
