#!/bin/bash

# Dossier contenant les vidéos
input_directory="/home/jpg/Téléchargements/Convertisseur-videos/06"
output_directory="/home/jpg/Téléchargements/Convertisseur-videos/06/test"

# Crée le dossier de sortie s'il n'existe pas
mkdir -p "$output_directory"

# Boucle à travers chaque fichier vidéo dans le dossier
for input_file in "$input_directory"/*.mp4; do
  # Extraire le nom du fichier sans l'extension
  filename=$(basename -- "$input_file")
  filename="${filename%.*}"

  # Définir le chemin de sortie
  output_file="$output_directory/${filename}_converted.mp4"

  # Convertir la vidéo au format h264 en utilisant ffmpeg
  ffmpeg -i "$input_file" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output_file"
done

echo "Conversion terminée pour toutes les vidéos dans $input_directory"
