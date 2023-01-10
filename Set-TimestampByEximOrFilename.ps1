<#
.SYNOPSIS
Change modification/creation time of image/video files by exim date or filename format

.DESCRIPTION
Change modification/creation time of image/video files by exim date or filename format

 EXIM:
   image: use tag 'ExifDTOrig' (id 36868) or 'ExifDTDigitized' (id 36867)

 File name formats:
 IMG[_-]YYYYMMDD[_-]HHMMSS.*$ Generic image file
 VID[_-]YYYYMMDD[_-]HHMMSS.*$ Generic video file
 SAVE[_-]YYYYMMDD[_-]HHMMSS.*$ Generic image/video file saved
 WhatsApp:
  IMG-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Image" file
  VID-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Video" file
  AUD-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Audio" file
  STK-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Stickers" file
  PTT-YYYYMMDD-WAMMSS.*$ Generic "WhatsApp Voice Notes" file

.PARAMETER File
Specifies the file or directory name
#>

[CmdletBinding()]
param (
  [Parameter(Mandatory)] [string]$File
)


<#
.DESCRIPTION
Change file modification/creation date by filename

  - filename start with 3 to 5 letters;
  - follow by a char '_' or '-';
  - follow by 8 numbers from '0' to '9' (YYYYMMDD);
  - follow by a char '_' or '-';
  - follow by 2 numbers (hours) or WA for WhatsApp file;
  - follow by 2 numbers (minutes);
  - follow by 2 numbers (seconds).

.PARAMETER File
Specifies the file name

.OUTPUTS
System.String. Set-TimestampByFilename returns a string "OK" if time changed else "ERR"
#>
function Set-TimestampByFilename() {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)] [string]$File
  )
  if (! (Test-Path $File)) {
    return "ERR: ${File}: not exist"
  }
  $fileName=$(Get-Item $File).Name
  if (! ($fileName -match '^[A-Za-z]{3,5}[_-](\d{4})(\d{2})(\d{2})[_-](WA|\d{2})(\d{2})(\d{2}).*$')) {
    return "ERR: Invalid file name format: ${fileName}"
  }
  $filedate=$Matches[1] + '/' + $Matches[2] +'/'+ $Matches[3] +' '+ $Matches[4] +':'+ $Matches[5] +':'+ $Matches[6]
  $filedate = $filedate -replace 'WA','00'
  $(Get-Item $File).creationtime=$(Get-Date $filedate)
  $(Get-Item $File).lastwritetime=$(Get-Date $filedate)
  Write-Host "${File}: setting date to ${filedate}"
  return "OK"
}

<#
.DESCRIPTION
Change file modification/creation date by Exif

.PARAMETER File
Specifies the file name

.OUTPUTS
System.String. Set-TimestamByExif returns a string "OK" if time changed else "ERR"
#>
function Set-TimestamByExif() {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)] [string]$File
  )
  if (! (Test-Path $File)) {
    return "ERR: ${File}: not exist"
  }
  $fullName=$(Get-Item $File).FullName
  $image = New-Object -ComObject Wia.ImageFile
  try {
    $image.LoadFile($fullName);
  }
  catch {
    return "ERR: ${File}: not an image file"
  }
  if ($image.Properties.Length -eq 0) {
    return "ERR: ${File}: not an image file"
  }
  if ( $image.Properties.Exists('ExifDTOrig')) {
    $filedate=$image.Properties.Item('ExifDTOrig').Value
  }
  elseif ($image.Properties.Exists('ExifDTDigitized')) {
    $filedate=$image.Properties.Exists('ExifDTDigitized').Value
  }
  else {
    return "ERR: ${File}: Exif date not found"
  }
  if ($filedate -match '^\d\d\d\d:\d\d:\d\d \d\d:\d\d:\d\d$') {
    $filedate_obj=[datetime]::ParseExact($filedate,'yyyy:MM:dd HH:mm:ss',$null)
  }
  else {
    return "ERR: ${File}: Exif date unrecognized format ($filedate)"
  }
  $(Get-Item $File).creationtime=$filedate_obj
  $(Get-Item $File).lastwritetime=$filedate_obj
  Write-Host "${File}: setting exif date to ${filedate}"
  return "OK"
}

<#
.DESCRIPTION
Wrapper function for Set-TimestamByExif and Set-TimestampByFilename

.PARAMETER File
Specifies the file name

.OUTPUTS
System.String. returns a string "OK" if time changed else "ERR"
#>
function Set-Timestamp() {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)] [string]$File
  )
  $ret=Set-TimestamByExif -File $File
  if ($ret -match '^ERR') {
    $ret2=Set-TimestampByFilename -File $File
    if ($ret2 -match '^ERR') {
      Write-Host "$ret, $ret2"
    }
  }
}

if ( Test-Path -PathType leaf $File) {
  $fix=Set-Timestamp -File $File
}
elseif ( Test-Path -PathType Container $File) {
  Get-ChildItem $File | ForEach-Object {
    if (Test-Path -PathType leaf $_.Fullname) {
      $fix=Set-Timestamp -File $_.Fullname
    }
  }
}
else {
  Write-Host "ERR: ${File}: bad file/dir path"
}

