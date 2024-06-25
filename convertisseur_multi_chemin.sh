#!/bin/bash

# Directory containing the media files
directory="/home/jpg/Téléchargements/Convertisseur-videos/2024/04" # update your directory
output_format="avi"

# Change to the specified directory
cd "$directory"

# Loop through all files in the directory
for file in *; do
    # Skip directories
    if [ -d "$file" ]; then
        continue
    fi

    # Extract the base name and extension
    base_name=$(basename "$file")
    extension="${file##*.}"

    # Construct the output file name
    output_file="${base_name%.*}.${output_format}"

    # Use ffmpeg to convert the file
    echo "Converting file: $file"
    ffmpeg -loglevel quiet -i "$file" "$output_file"

    echo "Converted $file to $output_file"
done

rm *.3gpp
