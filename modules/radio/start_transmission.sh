#!/bin/bash

# Fonction pour générer un mot de passe aléatoire de 10 caractères
generate_password() {
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 10
}

# Générer un port aléatoire entre 1000 et 10000
PORT=$(shuf -i 1000-10000 -n 1)
RADIO_PORT=$(cat .s/.radio_port)
# Générer un mot de passe aléatoire
MDP=$(generate_password)

# Sauvegarder le port et le mot de passe dans un fichier caché
echo "Port: $PORT, MDP: $MDP" > .s/.credentials

# Sélectionner un fichier aléatoire dans le répertoire "script"
SCRIPTS_DIR="script"
if [[ ! -d "$SCRIPTS_DIR" ]]; then
    echo "Erreur : le répertoire $SCRIPTS_DIR n'existe pas."
    exit 1
fi

# Choisir un fichier au hasard dans le répertoire script
FILE=$(ls "$SCRIPTS_DIR" | shuf -n 1)
FILE_PATH="$SCRIPTS_DIR/$FILE"

# Vérifier si le fichier est lisible
if [[ ! -r "$FILE_PATH" ]]; then
    echo "Erreur : impossible de lire le fichier $FILE_PATH."
    exit 1
fi

# Créer une copie temporaire du fichier à envoyer
TEMP_FILE="${FILE_PATH}.temp"
cp "$FILE_PATH" "$TEMP_FILE"

# Insérer port:mdp dans la copie temporaire selon le nom du fichier
if [[ "$FILE" == "bm.txt" ]]; then
    # Insérer après la ligne 213 et avant la ligne 214
    sed -i "213a $PORT:$MDP" "$TEMP_FILE"
elif [[ "$FILE" == "lotr.txt" ]]; then
    # Insérer après "You shall not pass"
    sed -i "/You shall not pass/a $PORT:$MDP" "$TEMP_FILE"
elif [[ "$FILE" == "mi2.txt" ]]; then
    # Insérer après la 7ème occurrence de "gun"
    # Insérer après la 7ème occurrence du mot "gun"
    awk '{
        count += gsub(/gun/, "&");
        if (count == 7) {
            print $0 "\n'$PORT:$MDP'";
        } else {
            print $0;
        }
    }' "$TEMP_FILE" > "${TEMP_FILE}.new" && mv "${TEMP_FILE}.new" "$TEMP_FILE"
elif [[ "$FILE" == "tgf.txt" ]]; then
    # Insérer après la phrase exacte "What miracles you do for strangers"
    sed -i "/What miracles you do for strangers/a $PORT:$MDP" "$TEMP_FILE"
else
    echo "Fichier non pris en charge."
    rm "$TEMP_FILE"  # Supprimer la copie temporaire en cas d'erreur
    exit 1
fi

# Lire et encoder le contenu du fichier en base64
ENCODED_CONTENT=$(base64 -w 0 "$TEMP_FILE")

# Envoi du message encodé via ncat (en TCP)
echo "$ENCODED_CONTENT" | nc localhost "$RADIO_PORT"
rm "$TEMP_FILE"
exit 0
