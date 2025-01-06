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

monitorizare $1 $2
