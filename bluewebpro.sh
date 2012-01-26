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


# This is a small Bash script to find patterns for known webattacks.
# The scriptet searches for strings in the Apache logfiles and write
# a deny from statement to the .htaccess file.
# This is for Apache only.

### ---Change for your system--- ###
SLEEP_TIME=15  # Run every NN second
HTACCESS=/www/webmail/.htaccess
ACCESS_FILE=/var/log/httpd-access.log
ERROR_FILE=/var/log/httpd-error.log
### ---------------------------- ###



### Test if everything is readable/writeable ###

if test ! -r ${ACCESS_FILE} ; then
        echo "Can't read ${ACCESS_FILE} - aborting"
        exit 1
fi

if test ! -r ${ERROR_FILE} ; then
        echo "Can't read ${ERROR_FILE} - aborting"
        exit 1
fi

if test ! -f ${HTACCESS} ; then
        touch ${HTACCESS}
                if [ $? = 1 ] ; then
                        echo "Unable to create ${HTACCESS} - aborting"
                        exit 1
                fi
fi

if test -f ${HTACCESS} ; then
        if test ! -w ${HTACCESS} ; then
                echo "Can't write to ${HTACCESS} - aborting"
                exit 1
        fi
fi


### How to extract IP numbers ###

get_access_ip()
{
        awk '{print $1}' | uniq | egrep -o '[0-9]{1,3}(\.[0-9]{1,3}){3}'
}

get_error_ip()
{
        awk '{print $8}' | uniq | egrep -o '[0-9]{1,3}(\.[0-9]{1,3}){3}'
}


### Here we define all our searches ###

suspect_dirs()
{
        egrep "/etc/|/home/|/proc/|/tmp|/bin/|/conf/\
        |/usr/|/opt/|/sbin/|/dev/|/kern/|/boot/|/root/|\
        /sys/|/system/" $ACCESS_FILE
}

suspect_dirs_hexcoded()
{
        egrep "%2fetc%2f|%2fhome%2f|%2fproc%2f|%2ftmp|\
        %2fbin%2f|%2fconf%2f|%2fusr%2f|%2fopt%2f|%2fsbin%2f|\
        %2fdev%2f|%2fkern%2f|%2fboot%2f|%2froot%2f|%2fsys%2f|\
        %2fsystem%2f" $ACCESS_FILE
}

dir_travel()
{
        egrep "\.\./\.\./" $ACCESS_FILE
}

win_files()
{
        egrep "*\.exe|*\.bat|*\.cmd" $ACCESS_FILE
}

bad_commands()
{
        egrep "cmd=|wget|chmod|echo|netcat" $ACCESS_FILE
}

hex_codes()
{
        egrep "%2f%2e%2e%2f%2e%2e%2f" $ACCESS_FILE  ### /../../ 
}

misc()
{
        egrep "cd%20/|%2flisten%3b" $ACCESS_FILE
}

w00t()
{
        egrep "w00tw00t.at.ISC.SANS.DFind" $ERROR_FILE
}


### Main ###

(
while true
do
        suspect_dirs | get_access_ip > temp_file
        suspect_dirs_hexcoded | get_access_ip >> temp_file
        dir_travel | get_access_ip >> temp_file
        win_files | get_access_ip >> temp_file
        bad_commands | get_access_ip >> temp_file
        hex_codes | get_access_ip >> temp_file 
        misc | get_access_ip >> temp_file
        w00t | get_error_ip >> temp_file
        cat temp_file | sort | uniq | sed -e 's/^/deny from /' > \
        $HTACCESS       
        cp temp_file /files_cyberwall/webhackers.txt
        sleep ${SLEEP_TIME}
done
)
