#!/bin/bash
# Declare variables
export DISPLAY=:0
VNCACTIVE="no"
VNCPORT=":5900"
SLEEP="3"
ADMINIP="192.168.99.50 192.168.99.54"
BRIGHTNESS=1
CONNECTEDDISPLAYS=$(xrandr | grep " connected" | cut -f1 -d " ")
VNCCONNECTED=$(ss -H -t4 state established sport = $VNCPORT | grep -c $VNCPORT)
MOUSEID=$(xinput --list --long | grep XIButtonClass | head -n 1 | egrep -o '[0-9]+')
KEYBOARDID=$(xinput --list --long | grep XIKeyClass | head -n 1 | egrep -o '[0-9]+')

# Main loop function
# Uses SS to determine if the VNC port is in use
# If in use, calls DISABLE_LOCAL function, then loops till VNCACTIVE changes state, at which point calls ENABLE_LOCAL function
MAIN_LOOP () {
VNCCONNECTED=$(ss -H -t4 state established sport = $VNCPORT | grep -c $VNCPORT)
BRIGHTNESS=1
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
    CONNECTINGIP=$(ss -H -t4 state established sport = 5900 | awk 'NR==1{ print $4}' | cut -d ':' -f 1)
    if [[ $ADMINIP =~ $CONNECTINGIP ]]; then
        echo "ADMIN IP ADDRESS DOING NOTHING"
        SLEEP_LOOP
      else
        until [[ $BRIGHTNESS -eq 0 ]]; do
          BRIGHTNESS=$(echo "$BRIGHTNESS-0.02" | bc)
          for i in $CONNECTEDDISPLAYS; do
            xrandr --output $i --brightness $BRIGHTNESS
            sleep 0.0005
          done
        done
      fi
#    xinput disable $MOUSEID
#    xinput disable $KEYBOARDID
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
