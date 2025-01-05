# Functie de monitorizare
# 2 parametri
# $1 - path ul
# $2 - tipul de comanda
monitorizare(){
	case $2 in
		1)
			"echo 0 20 * * 1 find $1 -mtime +60 -type f -exec rm {} \;" | crontab - 
			;;
		2)
			echo "0 20 * * 1 find $1 -mtime +1 -type f ! -name "*.old" -exec mv {} {}.old \;" | crontab  
			;;
		3)
			echo "0 20 * * 1 find $1 -mtime +1 -type f -exec sed -i '1s/^/#### DEPERCATED ####\n/' {} \;" | crontab 
			;;
		*)
			;;
	esac
}


monitorizare ./tema1 3
