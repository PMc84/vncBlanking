#!/bin/bash
CONNECTEDDISPLAYS=$(xrandr | grep " connected" | cut -f1 -d " ")
MOUSEID=$(xinput --list --long | grep XIButtonClass | head -n 1 | egrep -o '[0-9]+')
KEYBOARDID=$(xinput --list --long | grep XIKeyClass | head -n 1 | egrep -o '[0-9]+')

# Kills vncBlanking service and re-enables keyboard/mouse/monitor
echo "############################################################################"
echo "##                                                                        ##"
echo "##  vncBlanking service has been stopped - please restart once complete.  ##"
echo "##                                                                        ##"
echo "############################################################################"
systemctl --user stop vncBlanking.service
for i in $CONNECTEDDISPLAYS; do
  xrandr --output $i --brightness 1
done
xinput enable $MOUSEID
xinput enable $KEYBOARDID
