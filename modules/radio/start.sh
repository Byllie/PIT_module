#!/bin/bash
# Vérifier si .can_go existe avant de commencer
if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
    exit 1
fi

start_time=$(date +%s)
./reset_module.sh

# Vérifier si le fichier .start_time existe déjà
if [[ ! -f .start_time ]]; then
    start_time=$(date +%s)
    echo $start_time > .start_time
fi


# Étape 1 : Récupérer le numéro de série depuis le fichier
SERIAL_FILE="../../serial"
if [[ ! -f $SERIAL_FILE ]]; then
    echo "Erreur : Le fichier $SERIAL_FILE n'existe pas."
    exit 1
fi

SERIAL=$(cat "$SERIAL_FILE")

# Étape 2 : Extraire les lettres majuscules et les convertir en nombres
OFFSET=10000
PORT=1  # Initialiser le port avec 1 pour la multiplication

for (( i=0; i<${#SERIAL}; i++ )); do
    CHAR="${SERIAL:$i:1}"

    # Vérifier si le caractère est une lettre majuscule
    if [[ "$CHAR" =~ [A-Z] ]]; then
        # Calculer la valeur (A=1, B=2, ..., Z=26)
        VALUE=$(( $(printf '%d' "'$CHAR") - 64 ))
        PORT=$(( PORT * VALUE ))  # Multiplier les valeurs entre elles
    fi
done

# Étape 3 : Sauvegarder le numéro de port dans un fichier caché
PORT=$(( PORT + OFFSET ))

echo "$PORT" > .s/.radio_port
echo "Module Radio lancé"
exit 0
