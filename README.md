# SetTimestampByExifOrFilename

[![GPL License](https://img.shields.io/badge/license-GPL-blue.svg)](https://www.gnu.org/licenses/) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/EnioCarboni)

**SetTimestampByExifOrFilename** is useful for fixing the creation or modification date of an image or video file.

Let's think about when you copy images from one disk to another, without the appropriate precautions on the original date of the images, or when you recover from a backup or when you restore the WhatsApp archive in a new mobile phone.

Sorting by date doesn't work anymore in the image and video gallery!

So we could use some paid software or apps or try these simple scripts.

These scripts works under **Linux**, **Windows** and **Android**.

For both **Linux** and **Windows** the original date is first looked for in the metadata inside the file (**exif**) and if not found in the file name itself.

In the **Android** script, the original date is taken from the file name only.

## How the original date is derived

### Exif Metadata

* images: use tag '*CreateDate*' or '*ExifDTOrig*' (id 36868) if present or '*DateTimeOriginal*' or '*ExifDTDigitized*' (id 36867)
* videos (only **Linux**): use tag '*MediaCreateDate*'

Note: on **Linux** you can use `exiftool -D -S <image_file>` to see the id tag

### File name formats:

* IMG[_-]YYYYMMDD[_-]HHmmss.*$ Generic image file
* VID[_-]YYYYMMDD[_-]HHmmss.*$ Generic video file
* SAVE[_-]YYYYMMDD[_-]HHmmss.*$ Generic image/video file saved
* ^[A-Za-z]{3,5}[_-]YYYYMMDD[_-]hhmmss.*$ Generic format
* WhatsApp:
  *  IMG-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Image" file
  *  VID-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Video" file
  *  AUD-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Audio" file
  *  STK-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Stickers" file
  *  PTT-YYYYMMDD-WASEQ.*$ Generic "WhatsApp Voice Notes" file
  *  ^[A-Za-z]{3,5}[_-]YYYYMMDD[_-]WASEQ.*$ Generic "WhatsApp format" file

Note: On WhatsApp file the "WASEQ" is tranlated from seq (WA0000 - WA9999) to hhmmss (000000 - 024639)
## Linux

### Synopsis

```
  SetTimestampByExifOrFilename.sh <file|directory>
```

To extract the *exif metadata*, the **exiftool** command is used and must be installed separately otherwise only the file name will be used to know the file creation date.

**exiftool** can be installed easily based on the Linux distribution:

* **Ubuntu and derivatives**: `apt install -y libimage-exiftool-perl`
* **RHEL 9**: 
  * subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
  * dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
* **AlmaLinux 9**, **Rocky Linux 9**:
  * dnf config-manager --set-enabled crb
  * dnf install epel-release
* **RHEL 8**: 
  * subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
  * dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
* **AlmaLinux 8**, **Rocky Linux 8**:
  * dnf config-manager --set-enabled powertools
  * dnf install epel-release
* **RHEL 7**:
  * subscription-manager repos --enable rhel-\*-optional-rpms --enable rhel-\*-extras-rpms --enable rhel-ha-for-rhel-\*-server-rpms
  * yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
* **CentOS 7**:
  * yum install epel-release

### Example 1: Fix date on single image file

```
  SetTimestampByExifOrFilename.sh $HOME/Images/IMG_20230108_122531.jpg
```

### Example 2: Fix dates on all images file on a directory

```
  SetTimestampByExifOrFilename.sh $HOME/Images
```

# Windows

### Synopsis

```
  Set-TimestampByExifOrFilename.ps1 -File <file|directory>

  Get-Help ./Set-TimestampByExifOrFilename.ps1
```

### Example 3: Fix date on single WhatsApp image file

```
  ./Set-TimestampByExifOrFilename.ps1 -File IMG_20221109_WA1356.jpg
```

### Example 4: Fix dates on all images file on a directory

```
./Set-TimestampByExifOrFilename.ps1 -File Images
```


# Android

### Synopsis

```

  SetTimestampByFilenameAndroidAdb.sh <file|directory>
```

To use this script on Android you need to connect the device to the computer via USB cable and then connect from the PC with the **adb** command.

To use the **adb** command and to be able to connect, you need to enable **Developer Options** and then **usb debugging**.

If you don't know how to do it, search online for "**How Do I Enable USB Debugging**".

**adb** can be found at https://developer.android.com/studio/releases/platform-tools#downloads

**Note**: *SetTimestampByFilenameAndroidAdb.sh* use commands **sed** and **basename** available from [Android 6.0](https://android.googlesource.com/platform/system/core/+/master/shell_and_utilities/README.md#android-6_0-marshmallow) (Marshmallow)

### Get primary internal storage path

The primary storage path is in environment variable $EXTERNAL_STORAGE or is /sdcard

```
  adb devices
  pri_storage=$(adb shell 'echo $EXTERNAL_STORAGE')
  pri_storage=${pri_storage:-/sdcard}
  echo $pri_storage
```

We use $pri_storage variable later in adb command.

### Copy the script into the device

To copy the script we enter the folder that contains it and use the commands:

```
  adb devices
  adb push SetTimestampByFilenameAndroidAdb.sh $pri_storage
  adb shell ls -al ${pri_storage}/
```

At this point the script is inside the internal memory of the Android device.

#### Example 5: Fix date on single image and video file of Camera in internal memory

```
  adb shell
  s=$EXTERNAL_STORAGE
  s=${s:-/sdcard}
  echo $s
  cd $s
  sh ./SetTimestampByFilenameAndroidAdb.sh DCIM/Camera/IMG_20230105_123335.jpg
  sh ./SetTimestampByFilenameAndroidAdb.sh DCIM/Camera/VID_20230105_124001.mp4
```

#### Example 6: Fix date on single WhatsApp image file

```
  adb shell
  s=$EXTERNAL_STORAGE
  s=${s:-/sdcard}
  echo $s
  cd $s
  sh ./SetTimestampByFilenameAndroidAdb.sh "Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/IMG-20230102-WA0007.jpg"
```

#### Example 7: Fix date on all WhatsApp image files

```
  adb shell
  s=$EXTERNAL_STORAGE
  s=${s:-/sdcard}
  echo $s
  cd $s
  sh ./SetTimestampByFilenameAndroidAdb.sh "Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images"
```

## COPYRIGHT

      Copyright (c) 2023 Enio Carboni - Italy

      This file is part of SetTimestampByExifOrFilename.

      SetTimestampByExifOrFilename is free software: you can redistribute it and/or modify it under the
      terms of the GNU General Public License as published by the Free Software
      Foundation, either version 3 of the License, or (at your option) any later
      version.

      SetTimestampByExifOrFilename is distributed in the hope that it will be useful, but WITHOUT ANY
      WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
      FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
      details.

      You should have received a copy of the GNU General Public License along
      with SetTimestampByExifOrFilename.  If not, see <http://www.gnu.org/licenses/>.
