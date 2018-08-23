#!/bin/bash
##################################################################################

HERE="$(pwd)"

MYID=$(id -u)

[ "$MYID" -ne 0 ] && echo -e "\nCom'on start me with sudo like:\n\n    sudo bash $0\n" && exit

REALUSER=$SUDO_USER
HOME=/home/$SUDO_USER

echo "$@" | grep -ql help
if [ $? -eq 0 ];then
    cat <<_EOFH

    This installer is part of SALT (https://bit.do/SALTatXDA)


    Usage info
   ------------------------

    no arguments        Will run the installer and prompt for installation mode

    --help              This output
    --remove            Will remove all traces of SALT (will prompt before doing so)



_EOFH
    exit 0
fi

echo "$@" | grep -ql remove
if [ $? -eq 0 ];then
    echo -e "\nDo you really wanna remove all traces of SALT now?\n"
    read -p "<y|N> " REM
    if [ "$REM" == "y" ];then
        [ -f "${HOME}/.local/share/applications/SALT.desktop" ] && rm "${HOME}/.local/share/applications/SALT.desktop" && echo "... removed ${HOME}/.local/share/applications/SALT.desktop"
        [ -f /usr/share/applications/SALT.desktop ] && rm /usr/share/applications/SALT.desktop && echo "... removed /usr/share/applications/SALT.desktop"
        [ -f ${HOME}/.config/user-dirs.dirs ] && source ${HOME}/.config/user-dirs.dirs
        [ ! -z "$XDG_DESKTOP_DIR" ] && [ -d "$XDG_DESKTOP_DIR" ] && DESKDIR="$XDG_DESKTOP_DIR"
        [ -z "$DESKDIR" ] && DESKDIR="${HOME}/Desktop"
        [ -f "${DESKDIR}/SALT.desktop" ] && rm "${DESKDIR}/SALT.desktop" && echo "... removed ${DESKDIR}/SALT.desktop"
        [ -f /etc/sudoers.d/salt_sudo ] && rm /etc/sudoers.d/salt_sudo && echo "... removed /etc/sudoers.d/salt_sudo"
        [ -f /usr/share/polkit-1/actions/it.binbash.pkexec.salt.policy ] && rm /usr/share/polkit-1/actions/it.binbash.pkexec.salt.policy && echo "... removed /usr/share/polkit-1/actions/it.binbash.pkexec.salt.policy"
        echo -e "SALT uninstalled.\nPls remove the install dir MANUALLY."
        exit 0
    else
        echo aborted
        exit 4
    fi
fi

echo -e "\n\t1) use pkexec/policyKit (default)\n\t   Will also install a SALT policy\n"
echo -e "\t2) use gksudo (not available anymore on many distributions)\n\t   Will also install a sudoers config\n"
echo -e "\t3) use a custom auth binary (will ask for a path)\n"

while [ -z "$ANS" ];do
    read -p "Your choice (1, 2 or 3): " ANS
    [ -z "$ANS" ] && ANS=1
    if [ "$ANS" != 1 -a "$ANS" != 2  -a "$ANS" != 3 ];then
        echo -e "\n??? what do you wanna say? only 1, 2 or 3 are valid answers. Try again:"
        unset ANS
    fi
done

echo -e "\n"

case $ANS in 
    1)
    ./addPolicy.py ${HERE}/salt
    if [ $? -eq 0 ];then
        echo "... pkexec policy applied"
    else
        echo -e "\n!!! ERROR while applying pkexec policy! ABORTED\n\n"
        exit 3
    fi
    EXE=pkexec
    ;;
    2)
    cat >/tmp/salt_sudo << _EOFSU
# SALT (https://bit.do/SALTatXDA)
$REALUSER     ALL=(ALL) NOPASSWD: ${HERE}/salt *
_EOFSU
    echo -e "... sudo syntax check:"
    visudo -c -f /tmp/salt_sudo
    if [ $? -eq 0 ];then
        mv /tmp/salt_sudo /etc/sudoers.d/
        visudo -c -f /etc/sudoers.d/salt_sudo
        [ $? -ne 0 ] && rm /etc/sudoers.d/salt_sudo && echo -e "\n!!! ERROR occured while applying sudo config! changes have been REVERTED! ABORTED.\n\n" && exit 3
        echo -e "... sudo config applied"
        EXE=gksudo
    else
        echo -e "\n\nABORTED! NOTHING HAS CHANGED! Error while validating temp sudo file..\n\n"
        exit 3
    fi
    ;;
    3)
    echo -e "\n\nYou wanna use a custom auth method. Please specify the full path to the binary."
    while [ -z "$EXE" ];do
        read -p "full path: " EXE
        [ ! -x "$EXE" ] && echo -e "\npff... no way! $EXE is not an executable binary! Try again.." && unset EXE
    done
    ;;
    *)
    ;;
esac

cat > ${HERE}/SALT.desktop <<EOFDSK
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=SALT
Icon=${HERE}/icons/salt_icon.png
Comment=SALT - [S]teadfasterX [A]ll-in-one [L]G [T]ool
Exec=${EXE} ${HERE}/salt
EOFDSK
chmod +x ${HERE}/SALT.desktop

[ -f ${HERE}/SALT.desktop ] && chown $REALUSER "${HERE}/SALT.desktop" && echo -e "... personal start icon (./SALT.desktop) has been prepared successfully"

# installing the desktop icon
[ -f ${HOME}/.config/user-dirs.dirs ] && source ${HOME}/.config/user-dirs.dirs
[ ! -z "$XDG_DESKTOP_DIR" ] && [ -d "$XDG_DESKTOP_DIR" ] && DESKDIR="$XDG_DESKTOP_DIR"
[ -z "$DESKDIR" ] && DESKDIR=${HOME}/Desktop

if [ -d "$DESKDIR" ];then
    cp ${HERE}/SALT.desktop "$DESKDIR" \
      && chown $REALUSER "${DESKDIR}/SALT.desktop" \
      && echo -e "... start icon installed to your desktop successfully"
else
    echo -e "\n\tOops - I cannot find your desktop folder..\n\tThis can happen when you installed Linux in your language.\n\tCopy it to your desktop like this"
    echo -e "\n\tcp ${HERE}/SALT.desktop $REALHOME/<your-desktop-folder>/\n\n"
fi

# install to the standard application store
[ -d /usr/share/applications/ ] && cp ${HERE}/SALT.desktop /usr/share/applications/

echo -e "\nAll done! SALT has been installed to your desktop and is available in your start menu as well\n\n"
