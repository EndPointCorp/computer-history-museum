#!/bin/bash

CONCATE_DUR="150"
CONCATE_NAME="blank"
CONCATE_TYPE="mp3"
SAMPLE="44100"

APPEND="${CONCATE_NAME}.${CONCATE_TYPE}"
BOOST="7"

# Generate Blank Audio
echo "GENERATING BLANK AUDIO TRACK:"
ffmpeg -ar "${SAMPLE}" -t "${CONCATE_DUR}" -f s16le -acodec pcm_s16le -ac 2 -i /dev/zero -acodec libmp3lame -aq 4 -y "${APPEND}"

# Concatenate files
for FILE in {1..20}.mp3; do 
   MOD="${FILE%.mp3}-mod.mp3"
   TMP="${MOD%-mod.mp3}-tmp.mp3"
   echo "JOINING AUDIO:" 
   ffmpeg -f concat -i <(printf "file '$PWD/%s'\n" ./{"${FILE}","${APPEND}"}) -c copy -y "${TMP}"
   echo "BOOSTING AUDIO:" 
   ffmpeg -i "${TMP}" -af "volume=${BOOST}dB" -c:v copy -c:a libmp3lame -q:a 2 -y "${MOD}"
done

# Analyze gain:
# ffmpeg -i 1-mod.mp3 -af "volumedetect" -f null /dev/null 
