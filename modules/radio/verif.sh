#!/bin/bash

if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
    exit 1
fi
function verifier_temps_ecoule() {
    # Lire l'heure de début enregistrée
    if [[ -f .start_time ]]; then
        start_time=$(cat .start_time)
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))

        # Convertir le temps écoulé en minutes et secondes
        minutes=$((elapsed_time / 60))
        seconds=$((elapsed_time % 60))

        # Afficher le temps écoulé
        echo "Le mini-jeu a été résolu en $minutes minutes et $seconds secondes."

        # Enregistrer le temps total dans le fichier .final_time
        echo "$minutes minutes et $seconds secondes" > .final_time

        # Supprimer le fichier de l'heure de début pour éviter les conflits
        rm .start_time

        # Rajouter le temps dans le .module_OK
        echo "$minutes minutes et $seconds secondes" >> .module_OK
    else
        echo "L'heure de début n'a pas été enregistrée."
    fi
}

error_file=".error"

increment_error() {
    current_errors=$(cat "$error_file")
    new_errors=$((current_errors + 1))
    echo "$new_errors" > "$error_file"
    echo "Sur le module Vi, vous avez fait $(cat "$error_file") erreur(s)."
}

if [ ! -f "$error_file" ]; then
    echo 0 > "$error_file"
fi
# Vérifier que le fichier ~/.credentials existe pour récupérer les informations
if [[ ! -f .s/.credentials ]]; then
    echo "Erreur, Veuillez lancer le module."
    exit 1
fi

# Lire le fichier ~/.credentials pour obtenir le port et le mot de passe
CREDENTIALS=$(cat .s/.credentials)
PORT=$(echo "$CREDENTIALS" | awk -F ', ' '{print $1}' | awk -F ': ' '{print $2}')
MDP=$(echo "$CREDENTIALS" | awk -F ', ' '{print $2}' | awk -F ': ' '{print $2}')

# Lancer le serveur netcat en mode TCP pour écouter sur le port spécifié
echo "Serveur en écoute"
echo "Attente du mot de passe encodé en base64..."

# Attendre une seule connexion et récupérer le mot de passe
RECEIVED_PASSWORD=$(nc -l "$PORT")

# Décoder le mot de passe reçu
DECODED_PASSWORD=$(echo "$RECEIVED_PASSWORD" | base64 --decode)

# Vérifier si le mot de passe décodé est correct
if [[ "$DECODED_PASSWORD" == "$MDP" ]]; then
    echo "Module désamorcé"
    echo "Module désamorcé" > ./.module_OK  # Crée un fichier de flag pour arrêter le compteur
    verifier_temps_ecoule
    [ -f "$error_file" ] && rm -f "$error_file"
    # Lancer le script reset_module.sh
else
    echo "Erreur : mot de passe incorrect."
    increment_error
fi
exit 0
