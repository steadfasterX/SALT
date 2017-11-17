#!/bin/bash
##################################################################################

HERE="$(pwd)"

source ${HERE}/salt.vars

cat > ${HERE}/SALT.desktop <<EOFDSK
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=S.A.L.T
Icon=${HERE}/$SICONS/salt_icon.png
Comment=SALT - [S]teadfasterX [A]ll-in-one [L]G [T]ool
Exec=${HERE}/salt
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
