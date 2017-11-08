#!/bin/bash
##########################################################################################
#
# LG KDZ MANAGER 
# Copyright (C) 2017: steadfasterX <steadfastX | boun.cr>
# 
# LICENSE: LGPLv2 (https://www.gnu.org/licenses/old-licenses/lgpl-2.0.txt)
##########################################################################################
LAFPATH=~/programs/lglafng
KDZTOOLS=~/programs/kdztools

F_HELP(){
    echo -e "\nCopyright (C) 2017: steadfasterX <steadfastX | boun.cr>"
    echo -e "LICENSE: LGPLv2 (https://www.gnu.org/licenses/old-licenses/lgpl-2.0.txt)\n"
    echo -e "\nUsage:\n----------------------------\n"
    echo -e "\tactions (one or both):"
    echo -e "\t-x | --extract [KDZ FILENAME]    extract a kdz file plus the resulting dz file"
    echo -e "\t                                 note: the current dir will be used as target dir"
    echo -e "\t                                       extractedkdz/ and extracteddz/ will be created here"
    echo
    echo -e "\t--flash [PATH TO IMAGE FILES]    will flash all image files of that directory (except userdata)"
    echo -e "\t[--with-userdata --flash ...]    will flash all image files including userdata (like a factory reset)"
    echo
    echo -e "\n\tgeneral:"
    echo -e "\t-h | --help                        this output"
    echo -e "\t-t | --test                      test mode: will not extract/flash but print what would be done"
    echo -e "\n"
    echo -e "\n\tExamples:\n"
    echo -e "\tkdzmanager.sh -x ~/Downloads/h815v20p.kdz  (extract only)"
    echo -e "\tkdzmanager.sh --with-userdata --flash extracted (will flash all files from dir extracted - with userdata!)"
    echo -e "\tkdzmanager.sh --test --flash my/dir/ (will tell you what would be flashed from my/dir - without flashing!)"
    echo -e "\tkdzmanager.sh -x ~/Downloads/h815v20p.kdz --flash ./extracteddz/ (will extract and flash the result in 1 run)"
    echo 
}

[ $# -eq 0 ] && F_HELP && exit

FLASHING=0
EXTRACT=0
TESTMODE=0
UDATA=0

# check the args!
while [ ! -z $1 ];do
    case "$1" in
        --with-userdata)
        UDATA=1
        shift
        ;; 
        --flash)
        IMGPATH="$2"
        [ -z "$IMGPATH" ] && echo -e "\nextracting requires the full path to your extracted KDZ/DZ! e.g. $0 full/path/to/extracted/" && F_HELP && exit
        [ ! -d "$IMGPATH" ] && echo -e "\nERROR!! $IMGPATH DOES NOT EXISTS!?" && F_HELP && exit
        if [ ! -d "$LAFPATH" ];then
            echo -e "\nERROR: Expected LG LAF NG here: $LAFPATH" 
            read -p "Should I download it for you? (y/N) " DLLAF
            if [ "$DLLAF" == "y" ];then 
                git clone https://github.com/steadfasterX/lglaf.git $LAFPATH
            else
                exit
            fi
        fi
        FLASHING=1
        shift 2
        ;;
        -x|--extract)
        FULLKDZ="$2"
        [ -z "$FULLKDZ" ] && echo -e "\nextracting requires the full path to a KDZ! e.g. $0 full/path/to/kdz/kdzfilename.kdz" && F_HELP && exit
        [ ! -f "$FULLKDZ" ] && echo -e "\nERROR!! $FULLKDZ DOES NOT EXISTS!?" && F_HELP && exit
        if [ ! -d "$KDZTOOLS" ];then
            echo -e "\nERROR: Expected kdztools here: $KDZTOOLS" 
            read -p "Should I download it for you? (y/N) " DLKDZ
            if [ "$DLKDZ" == "y" ];then 
                git clone https://github.com/steadfasterX/kdztools.git $KDZTOOLS
            else
                exit
            fi
        fi
        shift 2
        EXTRACT=1
        ;;
        -t|--test)
        TESTMODE=1
        shift
        ;;
        *)
        F_HELP
        exit
        ;;
    esac
done


# extract KDZ and DZ
if [ $EXTRACT -eq 1 ];then
    echo -e "\nWill extract all files to: $(pwd)"
    echo -e "\n\n***********\nWARNING:\n***********\nKDZ files contain the userdata image which can be very big (e.g. 23 GB on a LG G4)\nEnsure you have enough free disk space before continuing!\nYou can continue even when you have not enough free space but the result will be incomplete (still useful maybe)\n"
    read -p "I understood and want to continue (press ENTER)" DUMMY

    if [ $TESTMODE -eq 0 ];then
        python2 ${KDZTOOLS}/unkdz -f "$FULLKDZ" -x -d extractedkdz
        python2 ${KDZTOOLS}/undz -s -f extractedkdz/*.dz -d extracteddz
    else
        echo "TESTMODE only:"
        echo "CMD: python2 ${KDZTOOLS}/unkdz -f $FULLKDZ -x -d extractedkdz"
        echo "CMD: python2 ${KDZTOOLS}/undz -s -f extractedkdz/*.dz -d extracteddz"
    fi

    echo -e "\n\nALL FINISHED! Your extracted files are in: $(pwd)/extracteddz\n"
fi

# flash partitions
if [ $FLASHING -eq 1 ];then
    # authenticate once
    if [ $TESTMODE -eq 0 ];then
        sudo python2 ${LAFPATH}/auth.py
    else
        echo "TESTMODE only:"
        echo "CMD: sudo python2 ${LAFPATH}/auth.py"
    fi
    # check if we want to leave out userdata (default)
    # gpt will be handled in a different manner (not ready yet)
    if [ $UDATA -eq 0 ];then
        GREPOUT="userdata|gpt"
    else
        GREPOUT="gpt"
    fi
    
    # flash
    for part in $(find $IMGPATH -type f -name *.image|egrep -vi "($GREPOUT)");do
        RMPATH=${part##*/}
        REMPART=${RMPATH/\.image/}
        echo -e "... flashing: $part to ${REMPART}"
        # redirecting the misleading error output (sorry dirty workaround atm..)
        if [ $TESTMODE -eq 0 ];then
            sudo python2 ${LAFPATH}/partitions.py --restore $part $REMPART 2>/dev/null
        else
            echo "TESTMODE only:"
            echo "CMD: sudo python2 ${LAFPATH}/partitions.py --restore $part $REMPART"
        fi
    done
fi

echo -e "\n\nAll done.\n\n"
