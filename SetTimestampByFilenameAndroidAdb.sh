#! sh

# Change modification time of files by filename format

# File name formats:
# IMG[_-]YYYYMMDD[_-]HHmmss.*$ Generic image file
# VID[_-]YYYYMMDD[_-]HHmmss.*$ Generic video file
# SAVE[_-]YYYYMMDD[_-]HHmmss.*$ Generic image/video file saved
# WhatsApp:
#  IMG-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Image" file
#  VID-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Video" file
#  AUD-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Audio" file
#  STK-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Stickers" file
#  PTT-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Voice Notes" file

# Change file modification date by filename
#   - filename start with 3 to 5 letters;
#   - follow by a char '_' or '-';
#   - follow by 8 numbers from '0' to '9' (YYYYMMDD);
#   - follow by a char '_' or '-';
#   - follow by 2 numbers (hours) or WA for WhatsApp file;
#     - follow by 2 numbers (minutes);
#     - follow by 2 numbers (seconds).
#  the time converted for touch command is in format: YYYYMMDDHHmm.ss
# Return 0 if time changed else 1
# If WhatsApp, WASEQ is tranlated from seq (WA0000 - WA9999) to hhmmss (000000 - 024639) 

SetTimestampByFilename() {
  local f=$(basename "$1")
  local filedate=""
  filedate=$( echo $f | sed -e 's/^\([A-Za-z]\{3,5\}\)[_-]\([0-9]\{8\}\)[_-]\(.\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).*$/\2\3\4.\5/' )
  if [ "x$f" != "x$filedate" -a ${#filedate} -eq 15 ]; then
    # test WA
    wa=$(echo $filedate| sed 's/^[0-9]\{8\}//')
    if [[ ${wa:0:2} == 'WA' ]]; then
      seq_wa="${wa:2:2}${wa:5:2}"
      seq_wa=$( echo $seq_wa | sed 's/^0*//' )
      hh=$(( $seq_wa / 3600 ))
      mm=$(( ($seq_wa - ($hh * 3600)) / 60 ))
      ss=$(( $seq_wa - ($hh * 3600) - ($mm * 60) ))
      hhmmss=$(printf "%02d%02d.%02d" $hh $mm $ss)
      filedate=$( echo $filedate| sed "s/WA.\{5\}/$hhmmss/")
    fi
    readable_date=$(echo $filedate | sed -e 's/^\(....\)\(..\)\(..\)\(..\)\(..\)\.\(..\)/\1\/\2\/\3 \4:\5:\6/')
    echo "$1: setting date to $readable_date ($filedate)"
    touch -t "$filedate" "$1"
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

ver_completa=$(getprop ro.build.version.release)
ver=${ver_completa/.*}
if [ -n "$ver" -a "$ver" -lt 6 ]; then
  echo "Android version $ver_completa not supported"
  exit 3
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
