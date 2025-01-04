# Functie cu meniul de configurare
config(){
        echo "Lista configurari monitorizare:"
        opt1="Stergere fisiere"
        opt2="Redenumire fisiere extensia .old"
        opt3="Adaugare linie de ### DEPERCATED ### pe prima linie a fisierelor"
        opt4="Exit"
        select optiune in "$opt1" "$opt2" "$opt3" "$opt4"; do
                case $REPLY in
                        1)
                                echo 1
                                ;;
                        2)
                                echo 2
                                ;;
                        3)
                                echo 3
                                ;;
                        4)
                                echo 4
                                exit
                                ;;
                        *)
                                echo "Comanda invalida" >&2
                                ;;
                esac
        done
}

config
