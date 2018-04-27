awk '/[Bb]ot|[Ss]pider/ { next; }/ \/[0-9]{4}\/[0-9]{2}\/[0-9]{2}\/[A-z-]*.html/{if (length($7) < 40) print $7 }' access_log* | sort | uniq -c | sort -n -r

