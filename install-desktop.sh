#!/bin/bash
##################################################################################

HERE="$(pwd)"

gksudo --help 2>&1 >> /dev/null
[ $? -ne 0 ] && echo "ERROR: Please install gksudo!" && exit
echo here: $HERE

cat > ${HERE}/SALT.desktop <<EOFDSK
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=SALT
Icon=${HERE}/icons/salt_icon.png
Comment=SALT - [S]teadfasterX [A]ll-in-one [L]G [T]ool
Exec=gksudo ${HERE}/salt
EOFDSK
chmod +x ${HERE}/SALT.desktop

echo -e "\nStart icon created!"

if [ -d ${HOME}/Desktop ];then
    cp ${HERE}/SALT.desktop $HOME/Desktop \
      && echo -e "\n\tStart icon installed to your desktop successfully!"
else
    echo -e "\n\tOops - I cannot find your desktop..\n\tThis can happen when you installed Linux in your language.\n\tCopy it to your desktop like this"
    echo -e "\n\tcp ${HERE}/SALT.desktop $HOME/<your-desktop-folder>/\n\n"
fi
