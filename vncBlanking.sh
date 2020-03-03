#!/bin/bash
# Declare variables
export DISPLAY=:0
VNCACTIVE="no"
VNCPORT=":5900"
SLEEP="3"
CONNECTEDDISPLAYS=$(xrandr | grep " connected" | cut -f1 -d " ")
# The below command was too broad for my use case - it caused screen dimming and disabled keyboard and mouse on both incoming and outgoing VNC connections
# VNCCONNECTED=$(ss -t4 state established | grep -c $VNCPORT)
# Testing with the following, this should hopefully work better - unfortunately it didn't, as in our case x11vnc is run by root and the script is run by a different user
# VNCCONNECTED=$(lsof -i tcp$VNCPORT | grep vnc | grep -c ESTABLISHED)
# Believe the below should give us what we want - count is 0 when VNCing out as looking at only the source port.
VNCCONNECTED=$(ss -H -t4 state established sport = $VNCPORT | grep -c $VNCPORT)
MOUSEID=$(xinput --list --long | grep XIButtonClass | head -n 1 | egrep -o '[0-9]+')
KEYBOARDID=$(xinput --list --long | grep XIKeyClass | head -n 1 | egrep -o '[0-9]+')

# Main loop function
# Uses SS to determine if the VNC port is in use
# If in use, calls DISABLE_LOCAL function, then loops till VNCACTIVE changes state, at which point calls ENABLE_LOCAL function
MAIN_LOOP () {
# The below command was too broad for my use case - it caused screen dimming and disabled keyboard and mouse on both incoming and outgoing VNC connections
# VNCCONNECTED=$(ss -t4 state established | grep -c $VNCPORT)
# Testing with the following, this should hopefully work better - unfortunately it didn't, as in our case x11vnc is run by root and the script is run by a different user
# VNCCONNECTED=$(lsof -i tcp$VNCPORT | grep vnc | grep -c ESTABLISHED)
# Believe the below should give us what we want - count is 0 when VNCing out as looking at only the source port.
VNCCONNECTED=$(ss -H -t4 state established sport = $VNCPORT | grep -c $VNCPORT)
while :
do
    if (( $VNCCONNECTED >= "1" )); then
        if [[ $VNCACTIVE == "yes" ]]; then
            SLEEP_LOOP
        else
            VNCACTIVE="yes"
            DISABLE_LOCAL
        fi
    else
        if [[ $VNCACTIVE == "no" ]]; then
            SLEEP_LOOP
        else
            VNCACTIVE="no"
            ENABLE_LOCAL
        fi
    fi
done
}

# The following fuction sets the brightness to 0 and disables the local keyboard and mouse input
DISABLE_LOCAL () {
    echo "DISABLE!"
    for i in $CONNECTEDDISPLAYS; do
        xrandr --output $i --brightness 0.9
        sleep 0.1
        xrandr --output $i --brightness 0.8
        sleep 0.1
        xrandr --output $i --brightness 0.7
        sleep 0.1
        xrandr --output $i --brightness 0.6
        sleep 0.1
        xrandr --output $i --brightness 0.5
        sleep 0.1
        xrandr --output $i --brightness 0.4
        sleep 0.1
        xrandr --output $i --brightness 0.3
        sleep 0.1
        xrandr --output $i --brightness 0.2
        sleep 0.1
        xrandr --output $i --brightness 0
    done
    xinput disable $MOUSEID
    xinput disable $KEYBOARDID
    SLEEP_LOOP
}

# The following function sets the brightness to 1 and enables the local keyboard and mouse input
ENABLE_LOCAL () {
    echo "ENABLE!"
    for i in $CONNECTEDDISPLAYS; do
        xrandr --output $i --brightness 1
    done
    xinput enable $MOUSEID
    xinput enable $KEYBOARDID
    SLEEP_LOOP
}

#seperating sleep out so we can call it at different points
SLEEP_LOOP () {
    sleep $SLEEP
    MAIN_LOOP
}

MAIN_LOOP
