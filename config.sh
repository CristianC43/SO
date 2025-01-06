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
