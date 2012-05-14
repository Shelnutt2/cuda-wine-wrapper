#!/bin/bash
# Script to automatically adjust the SLEEPTIME in gpu3 wrapper.
# Copyright 2010 Seth Shelnutt
# Copyright 2010 Bas Couwenberg <sebastic@xs4all.nl>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

trap 'killz' INT
killz(){
	wineserver -k
	echo "Exiting, thank's for using auto-mator"
	exit 0
}

fahcore_pid() {
	if $(ps -C FahCore_15.exe -o pid=)
	then
		export PID=$(ps -C FahCore_15.exe -o pid=)
		return true
	elif $(ps -C FahCore_11.exe -o pid=)
	then
		export PID=$(ps -C FahCore_11.exe -o pid=)
		return true
	else
		echo "No known FahCore found!"
		return false
	fi
}

export SLEEPTIME="3000000"
RUNGPU="nice -n 17 wine Folding@home-Win32-GPU.exe -forcegpu nvidia_g80"
eval $RUNGPU &
sleep 30

while [ fahcore_pid != true ]
do
	sleep 30
done

while true
do
	CPUP=$(top -bn 3 -p $PID | grep "FahCore" | awk -F" " '{ print $9 }')
	CPUP1=$(echo $CPUP | awk -F" " '{ print $1 }')
	CPUP2=$(echo $CPUP | awk -F" " '{ print $2 }')
	CPUP3=$(echo $CPUP | awk -F" " '{ print $3 }')
	CPU=$((($CPUP3 + $CPUP2 + $CPUP1) / 3))

	if [ "$CPU" -le "25" ]
	then
		sleep 60
	elif [ "$CPU" -le "8" ]
	then
		export SLEEPTIME=$(( $SLEEPTIME + 2500 ))
		sleep 5
	else
		export SLEEPTIME=$(( $SLEEPTIME - 5000 ))
		sleep 5
	fi
done


exit 0
