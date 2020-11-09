#!/bin/bash

python2 -m pip show pyserial > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    set -xv
    curl -kL https://bootstrap.pypa.io/get-pip.py | python2
    python2 -m pip uninstall serial
    python2 -m pip uninstall serial --user
    python2 -m pip uninstall pyserial
    python2 -m pip uninstall pyserial --user
    python2 -m pip install pyserial --user
    groups | grep dialout
    if [[ $? -ne 0 ]]; then
        grep dialout /etc/group || getent group dialout >> /etc/group
        usermod -a -G dialout $USER
    fi
    set +xv
fi

#set -xv

PATH=$PATH:~/.local/bin:$(dirname ${0})
CMD=dell_p4317q_serial_control_program.py
MOD=$(basename ${0##*_} | sed -e 's/\.sh$//g')
SHP=50
SHP=100
SHP=75

OPT=$#

# Layout:
# 
# 4x4:
#
#  3 | 4
# ---+---
#  2 | 1
#
# SxS:
#
#  2 | 1

IN0=${1:-vga}
IN1=${2:-dp}
IN2=${3:-mdp}
IN3=${4:-hdmi1}
IN4=${5:-hdmi2}

PIP=bigPip
PIP=smallPip
PLC=bottomLeft
PLC=bottomRight

declare -a INPUT=("${IN0}" "${IN1}" "${IN2}" "${IN3}" "${IN4}")

power_cycle() {
    read -t 4 -p "Are you sure to power-cycling ? [N/y] " NY
    NY=${NY:-N}
    case $NY in
        [Yy]*)
            sleep .5
            ${CMD} set powerstate 0
            sleep 6
            ${CMD} set powerstate 1
            ;;
        [Nn]*)
            ;;
        *)
            ;;
    esac
    echo
}

init_mode_and_sharp() {
    if [[ "${IN0}" =~ help ]];then
        echo "Default settings for input:"
        echo -e "\t" ${INPUT[0]} ${INPUT[1]} ${INPUT[2]} ${INPUT[3]} ${INPUT[4]}
        exit
    elif [[ "${IN0}" =~ off ]];then
        ${CMD} set powerstate 0
        exit	
    elif [[ "${IN0}" =~ on ]];then	
        ${CMD} set powerstate 1
        exit
    elif [[ "${IN0}" =~ reset ]];then	
        ${CMD} set powerstate 0
	sleep 6
        ${CMD} set powerstate 1
        exit
    fi
    ${CMD} set powerstate 1    
    if [ ${MOD} == pip ];then
        local MOD=4k
    fi
    sleep .5
    ${CMD} set pxpmode ${MOD}
    sleep .5
    ${CMD} set sharpness ${SHP}
    sleep .5
    ${CMD} set autoselect 0
}

init_sub() {
    if [ ${MOD} == 4k ];then
        ${CMD} set videoinput ${INPUT[0]}
    elif [ ${MOD} == pip ];then
        ${CMD} set videoinput ${INPUT[0]}
        sleep 2
        ${CMD} set pxpmode ${PIP}
        sleep 6
        ${CMD} set pxplocation ${PLC}
        sleep .5
        ${CMD} set pxpsubinput 1 ${INPUT[1]}
    else
        sleep .5
        INDEX=0
        for IN in ${INPUT[0]} ${INPUT[1]} ${INPUT[2]} ${INPUT[3]} ${INPUT[4]};do
            ${CMD} set pxpsubinput ${INDEX} ${IN}
            sleep 1
            echo ${INDEX}: ${IN}
            INDEX=$((${INDEX}+1))
        done 
    fi
}

init_mode_and_sharp
init_sub
power_cycle
