for n in *.png; do convert $n -resize 980x "${n%.png}-scaled.png"; done
