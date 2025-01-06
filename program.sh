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
	            echo "Format invalid, foloseste --help pentru ajutor" >&2
		fi
}


# Functie de monitorizare
# Parametri:
# $1 - path ul
# $2 - tipul de comanda
monitorizare(){
	case $2 in
		1)
			echo "0 20 * * 1 find $1 -mtime +60 -type f -exec rm {} \;" | crontab 
			;;
		2)
			echo "0 20 * * 1 find $1 -mtime +60 -type f ! -name "*.old" -exec mv {} {}.old \;" | crontab  
			;;
		3)
			echo "0 20 * * 1 find $1 -mtime +60 -type f -exec sed -i '1s/^/#### DEPERCATED ####\n/' {} \;" | crontab 
			;;
		*)
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
	    opt3="Adaugare linie de ### DEPERCATED ### pe prima linie a fisierelor"
	    opt4="Inapoi"

	    select optiune in "$opt1" "$opt2" "$opt3" "$opt4"; do
	    	case $REPLY in
	        	1)	# Stergere fisiere
					monitorizare $1 1 
					echo "Monitorizarea directorului $1 a inceput"
					break
	                ;;
                2)  # Redenumire fisiere extensia .old
					monitorizare $1 2
					echo "Monitorizarea directorului $1 a inceput"
                    break
					;;
	            3)  # Adaugare linie de ### DEPERCATED ### pe prima linie a fisierelor
					monitorizare $1 3
					echo "Monitorizarea directorului $1 a inceput"
	                break
	                ;;
	            4)	# Inapoi
	            	echo "Monitorizare anulata"
					break
	                ;;
	            *)
	                echo "Cod de configurare invalid" >&2
	                ;;
	                esac
	        done
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
       			if [[ ! -d $path ]]; then # Testare director valid
        			echo "Path invalid" >&2
				else
		        	echo "Introdu data (ex 2z, 2024-09-01, 3l)"
	        		read data_in
					cautare $path $data_in
				fi
				;;
			2)  # Mutare fisiere
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
	echo "ceva"
fi
