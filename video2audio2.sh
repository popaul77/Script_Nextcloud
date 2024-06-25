#!/bin/bash

# Vérifier si le fichier contenant les URL est passé en argument
if [ -z "$1" ]; then
    echo "Usage: $0 <fichier>"
    exit 1
fi

# Vérifier si le fichier existe
if [ ! -f "$1" ]; then
    echo "Le fichier $1 n'existe pas."
    exit 1
fi

# Lire le fichier ligne par ligne et télécharger l'audio
while IFS= read -r url
do
    # Obtenir le titre de la vidéo sans télécharger
    title=$(yt-dlp --get-title "$url")

    # Nom du fichier audio attendu
    audio_file="${title}.mp3"

    # Vérifier si le fichier audio existe déjà
    if [ -f "$audio_file" ]; then
        echo "Le fichier $audio_file existe déjà, passage à la vidéo suivante."
        continue
    fi

    # Télécharger l'audio si le fichier n'existe pas
    yt-dlp -x --audio-format mp3 --audio-quality 0 "$url" -o "%(title)s.%(ext)s"
    echo "Téléchargement de $audio_file terminé"
done < "$1"

echo "Tous les téléchargements sont terminés"
