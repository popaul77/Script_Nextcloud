#!/bin/bash

for file in *.mp4.3gpp; do
  newfile=$(echo "$file" | sed 's/.mp4//')
  mv "$file" "$newfile"
done
