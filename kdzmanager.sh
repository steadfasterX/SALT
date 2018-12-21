#!/bin/bash
##########################################################################################
#
# SALT - [S]teadfasterX [A]ll-in-one [L]G [T]ool
#
# Copyright (C): 2017-2018, steadfasterX <steadfastX|boun.cr>
#
# LG KDZ MANAGER 
# 
##########################################################################################

# the vars for the lgup-ng
VARS="${0%/*}/salt.vars"
source $VARS
[ $? -ne 0 ] && "ERROR: Missing requirement <$VARS>." && exit 3

# the functions for the lglaf GUI
FUNCS="${0%/*}/salt.func"
source $FUNCS 
[ $? -ne 0 ] && "ERROR: Missing requirement <$FUNCS>." && exit 3

F_LOG "KDZMGR started.."

F_HELP(){
    echo -e "\nCopyright (C) 2017-2018: steadfasterX <steadfastX | boun.cr>"
    echo -e "LICENSE: LGPLv2 (https://www.gnu.org/licenses/old-licenses/lgpl-2.0.txt)\n"
    echo -e "\nUsage:\n----------------------------\n"
    echo -e "\tactions (one or both):"
    echo -e "\t-x | --extract [KDZ FILENAME]    extract a kdz file plus the resulting dz file"
    echo -e "\t                                 note: the current dir will be used as target dir by default"
    echo -e "\t                                       extractedkdz/ and extracteddz/ will be created here"
    echo -e "\t-d | --extractdir <target dir>   if you want to specify another target dir for the KDZ"
    echo -e "\t-s | --slice '<part#> <part#>'   extract only these slices (must be number(s) separated by space and quoted)"
    echo
    echo -e "\t--flash [PATH TO IMAGE FILES]    will flash all image files of that directory (except userdata)"
    echo -e "\t[--with-userdata --flash ...]    will flash all image files including userdata (like a factory reset)"
    echo
    echo -e "\n\tgeneral:"
    echo -e "\t-h | --help                        this output"
    echo -e "\t-t | --test                      test mode: will not extract/flash but print what would be done"
    echo -e "\t-b | --batch                     batch mode: no questions - DANGEROUS!"
    echo -e "\t-D | --debug                     debug mode"
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
BATCH=0
WCACHE=0
DEBUG=0
LISTMODE=0

# check the args!
while [ ! -z $1 ];do
    case "$1" in
        --with-userdata)
        UDATA=1
        shift
        ;;
         --with-cache)
        WCACHE=1
        shift
        ;;
        --flash)
        IMGPATH="$2"
        [ -z "$IMGPATH" ] && echo -e "\nextracting requires the full path to your extracted KDZ/DZ! e.g. $0 full/path/to/extracted/" && F_HELP && exit
        [ ! -d "$IMGPATH" ] && echo -e "\nERROR!! $IMGPATH DOES NOT EXISTS!?" && F_HELP && exit
        if [ ! -d "$LAFPATH" ];then
            echo -e "\nERROR: Expected LG LAF NG here: $LAFPATH" 
            [ "$BATCH" -eq 0 ] && read -p "Should I download it for you? (y/N) " DLLAF
            if [ "$DLLAF" == "y" ]||[ "$BATCH" -eq 1 ];then 
                git clone $LAFGIT $LAFPATH
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
            [ "$BATCH" -eq 0 ] && read -p "Should I download it for you? (y/N) " DLKDZ
            if [ "$DLKDZ" == "y" ]||[ "$BATCH" -eq 1 ];then 
                git clone $KDZGIT $KDZTOOLS
            else
                exit
            fi
        fi
        shift 2
        EXTRACT=1
        ;;
        -d|--extractdir) 
        KDZDIR="$2"
        shift 2
        ;;
        -t|--test)
        TESTMODE=1
        shift
        ;;
        -b|--batch) BATCH=1 ; shift ;;
        -D|--debug) DEBUG=1 ; shift ;;
        -s|--slice) SELPARTS="$2"; shift 2;;
        -l|--list) LISTMODE=1; shift;;
        *)
        F_HELP
        exit
        ;;
    esac
done

# list partitions of a DZ file
FK_LISTPARTS(){
    DZFILE="$(echo ${KDZDIR}/extractedkdz/*.dz)"
    if [ "$BATCH" -eq 1 ];then
        $PYTHONBIN ${KDZTOOLS}/undz -b -l -f "${DZFILE}" 2>>$LOG
    else
        $PYTHONBIN ${KDZTOOLS}/undz -l -f "${DZFILE}"
    fi        
}

# extract a KDZ file
FK_EXTRACTKDZ(){
    if [ "$BATCH" -eq 1 ];then
        $PYTHONBINLEGACY ${KDZTOOLS}/unkdz -f "$FULLKDZ" -x -d "${KDZDIR}/extractedkdz" 2>>$LOG
    else
        $PYTHONBINLEGACY ${KDZTOOLS}/unkdz -f "$FULLKDZ" -x -d "${KDZDIR}/extractedkdz"
    fi
}

# extract a DZ
FK_EXTRACTPARTS(){
    DZFILE="$(echo ${KDZDIR}/extractedkdz/*.dz)"
    if [ "$BATCH" -eq 1 ];then
        $PYTHONBIN ${KDZTOOLS}/undz -b -s $SELPARTS -f "${DZFILE}" -d "${KDZDIR}/extracteddz"
        #python2 ${KDZTOOLS}/undz -b -s $SELPARTS -f "${DZFILE}" -d "${KDZDIR}/extracteddz"
    else
        $PYTHONBIN ${KDZTOOLS}/undz -s $SELPARTS -f "${DZFILE}" -d "${KDZDIR}/extracteddz"
        #python2 ${KDZTOOLS}/undz -s $SELPARTS -f "${DZFILE}" -d "${KDZDIR}/extracteddz"
    fi
    # delete unneeded parse files
    rm -rvf ${KDZDIR}/extracteddz/*.params
    # rename GPT files to ensure they will not flashed by accident
    for gpt in $(find ${KDZDIR}/extracteddz/ -type f |grep -i GPT);do mv -v "$gpt" "${gpt/\.image/.gpt}";done
}

if [ $LISTMODE -eq 1 ];then
    BATCH=1
    FK_EXTRACTKDZ 2>&1 >>$LOG
    FK_LISTPARTS 2>>$LOG | sort -u -t : -k 2 | sort -t : -k 3| egrep -v "(unallocated)"
else
    # extract KDZ and DZ
    if [ $EXTRACT -eq 1 ];then
        [ -z "$KDZDIR" ] && KDZDIR="$(echo ~/Downloads)"
        echo -e "\nWill extract all files to: $KDZDIR"
        echo -e "\n\n***********\nWARNING:\n***********\nKDZ files contain the userdata image which can be very big (e.g. 23 GB on a LG G4)\nEnsure you have enough free disk space before continuing!\nYou can continue even when you have not enough free space but the result will be incomplete (still enough maybe)\n"
        [ "$BATCH" -eq 0 ] && read -p "I understood and want to continue (press ENTER)" DUMMY
    
        if [ $TESTMODE -eq 0 ];then
            DZFILE=$(find "${KDZDIR}/extractedkdz/" -name '.*\.dz' 2>/dev/null)
            [ ! -f "$DZFILE" ] && FK_EXTRACTKDZ
            FK_EXTRACTPARTS
            # delete userdata partition when not needed
            [ "$UDATA" -eq 0 ] && echo "You have selected to delete userdata partition" && rm -rfv "${KDZDIR}/extracteddz/userdata*"
            # delete cache partition when not needed
            [ "$WCACHE" -eq 0 ] && echo "You have selected to delete cache partition" && rm -rfv "${KDZDIR}/extracteddz/cache*"
            # clean DZ file
            [ $DEBUG -eq 0 ] && rm -fv "${KDZDIR}/extractedkdz/*.dz"
        else
            echo "TESTMODE only:"
            echo "CMD: $PYTHONBINLEGACY ${KDZTOOLS}/unkdz -f $FULLKDZ -x -d ${KDZDIR}/extractedkdz"
            echo "CMD: $PYTHONBIN ${KDZTOOLS}/undz -s -f ${KDZDIR}/extractedkdz/*.dz -d ${KDZDIR}/extracteddz"
        fi
    
        echo -e "\n\nALL FINISHED! Your extracted files are in: ${KDZDIR}/extracteddz\n"
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
        for part in $(find "$IMGPATH" -type f -maxdepth 0 -name *.image|egrep -vi "($GREPOUT)");do
            RMPATH="${part##*/}"
            REMPART="${RMPATH/\.image/}"
            echo -e "... flashing: $part to ${REMPART}"
            # redirecting the misleading error output (sorry dirty workaround atm..)
            if [ $TESTMODE -eq 0 ];then
                sudo python2 ${LAFPATH}/partitions.py --restore "$part" $REMPART 2>/dev/null
            else
                echo "TESTMODE only:"
                echo "CMD: sudo python2 ${LAFPATH}/partitions.py --restore $part $REMPART"
            fi
        done
    fi
fi
[ "$BATCH" -eq 0 ] && echo -e "\n\nAll done.\n\n"
F_LOG "KDZMGR ended.."
