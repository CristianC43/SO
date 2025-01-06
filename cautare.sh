# Functie ce cauta fisierele vechi
# Parametri:
# $1 - path valid,  $2 data in unul din formaturile de mai jos
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
