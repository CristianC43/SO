#!/bin/bash
mutare_fisier() {
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

mutare_fisier
