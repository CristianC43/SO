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
		4)
			echo "9 1 * * 2 find $1 -mtime +1 -type f -exec chmod u-x,g-x,o-x {} \;" | crontab
			;;
		5)
			test -f archive.tar || touch archive.tar # Se va creea o arhiva daca nu exista deja
			echo "0 20 * * 1 find $1 -mtime +60 -type f -exec tar -rvf archive.tar {} \;" | crontab
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
		opt4="Luare permisiune executare"
		opt5="Arhivare fisiere"
	    optEXIT="Inapoi"

	    select optiune in "$opt1" "$opt2" "$opt3" "$opt4" "$opt5" "$optEXIT"; do
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
	            4)
	            	monitorizare $1 4
	            	echo "Monitorizarea directorului $1 a inceput"
	                break
	                ;;
	            5)
	            	monitorizare $1 5
	           	 	echo "Monitorizarea directorului $1 a inceput"
	                break
	                ;;
	            6)	# Inapoi
	            	echo "Monitorizare anulata"
					break
	                ;;

	            *)
	                echo "Cod de configurare invalid" >&2
	                ;;
	                esac
	        done
}

config lab2
