#!/bin/bash

BINDIR=~/.local/bin
. ${BINDIR}/require-host_func.sh

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

eval $CMD $*
