# Functie de monitorizare, primeste ca parametru un path


# Luni fiecare saptamana ora 20:00
monitorizare(){
	echo "0 20 * * 1 find $1 -mtime +60 -type f -exec rm {} \;" | crontab - 
}

monitorizare ./lab3

