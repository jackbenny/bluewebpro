#!/bin/bash

################################################################################
#                                                                              #
#  Copyright (C) 2008 Jack-Benny Persson <jake@cyberinfo.se>                   #
#                                                                              #
#   This program is free software; you can redistribute it and/or modify       #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation; either version 2 of the License, or          #
#   (at your option) any later version.                                        #
#                                                                              #
#   This program is distributed in the hope that it will be useful,            #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program; if not, write to the Free Software                #
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  #
#                                                                              #
################################################################################

### This is the wrapper for BlueWebProtect ###

DAEMON=bluewebpro.sh
DAEMON_LOG=bluewebpro_daemon.log

if test ! -x ${DAEMON} ; then
        echo "Couldn't execute ${DAEMON}"
        exit 1
fi

if test -f ${DAEMON_LOG} ; then
        if test ! -w ${DAEMON_LOG} ; then
                echo "Unable to write logfile - aborted"
                exit
        fi
fi


exec 1>$DAEMON_LOG
exec 2>&1

nohup bash $DAEMON &
echo "Daemon $DAEMON started"
exit 0
