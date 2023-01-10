#! sh

# Change modification time of files by filename format

# File name formats:
# IMG[_-]YYYYMMDD[_-]HHMMSS.*$ Generic image file
# VID[_-]YYYYMMDD[_-]HHMMSS.*$ Generic video file
# SAVE[_-]YYYYMMDD[_-]HHMMSS.*$ Generic image/video file saved
# WhatsApp:
#  IMG-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Image" file
#  VID-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Video" file
#  AUD-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Audio" file
#  STK-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Stickers" file
#  PTT-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Voice Notes" file

# Change file modification date by filename
#   - filename start with 3 to 5 letters;
#   - follow by a char '_' or '-';
#   - follow by 8 numbers from '0' to '9' (YYYYMMDD);
#   - follow by a char '_' or '-';
#   - follow by 2 numbers (hours) or WA for WhatsApp file;
#   - follow by 2 numbers (minutes);
#   - follow by 2 numbers (seconds).
#  the time converted for touch command is in format: YYYYMMDDHHmm.ss
# Return 0 if time changed else 1

SetTimestampByFilename() {
  local f=$(basename "$1")
  local filedate=""
  filedate=$( echo $f | sed -e 's/^\([A-Za-z]\{3,5\}\)[_-]\([0-9]\{8\}\)[_-]\(.\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).*$/\2\3\4.\5/' -e 's/WA/00/' )
  if [ "x$f" != "x$filedate" -a ${#filedate} -eq 15 ]; then
    readable_date=$(echo $filedate | sed -e 's/^\(....\)\(..\)\(..\)\(..\)\(..\)\.\(..\)/\1\/\2\/\3 \4:\5:\6/')
    echo "$1: setting date to $readable_date ($filedate)"
    touch -t "$filedate" $1
    return 0
   else
     echo "Invalid file name format: $1" >&2
     return 1
  fi
}

if [ -z "$@" ]; then
  echo "empty file/dir path"
  exit 1
else
  if [ ! -f "$@" -a ! -d "$@" ]; then
    echo "$@: bad file/dir path"
    exit 2
  fi
fi

if [ -f "$@" ]; then
  SetTimestampByFilename "$@"
else
  for file in "$@"/*; do
    if [ -f "$file" ]; then
      SetTimestampByFilename "$file"
    fi
  done
fi
