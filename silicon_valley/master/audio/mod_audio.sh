#!/bin/bash

CONCATE_DUR="150"
CONCATE_NAME="blank"
CONCATE_TYPE="mp3"
SAMPLE="44100"

APPEND="${CONCATE_NAME}.${CONCATE_TYPE}"

# Generate Blank Audio
ffmpeg -ar "${SAMPLE}" -t "${CONCATE_DUR}" -f s16le -acodec pcm_s16le -ac 2 -i /dev/zero -acodec libmp3lame -aq 4 -y "${APPEND}"

# Concatenate files
for FILE in {1..20}.mp3; do 
   ffmpeg -f concat -i <(printf "file '$PWD/%s'\n" ./{"${FILE}","${APPEND}"}) -c copy -y "${FILE%.mp3}-mod.mp3"
done 
