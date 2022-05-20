#!/bin/bash
#
# yt-dlp auto download service for users
#
# Author: ArchPhoenix Team
# Created: 2022-05-20
# Version : 0.1.0
######################
# Configuration      #
######################
# You probably don't need to change anything here
command_file="ytdl.txt"
search_command="/var/services/homes/*/Downloads/$command_file"
acl_group="grp-acl-svc-a-ytdl"
dl_speed="512K"
ytdlp_path="/usr/local/bin/yt-dlp"
nice_command="nice -n 19"
# End of configuration
if [ `ps --no-headers -C$0 | wc -l` -gt 1 ]; then exit 2; fi
unset HISTFILE
for ytdl_order_path in ${search_command}; do
    user=$(stat -c %U $ytdl_order_path)
    user="${user//[$'\t\r\n ']}"
    echo $user
    echo $ytdl_order_path
    grep $acl_group /etc/group | grep $user > /dev/null
    group="$?"
    echo $group
    if [[ "$user" != 'root' ]] && [[ $? -eq "0" ]]; then
        su -s /bin/bash "$user"
        cd ~/Downloads
        if test -f "./$command_file"; then
            $nice_command $ytdlp_path --limit-rate $dl_speed --batch-file ./$command_file
            if [ $? == "0" ]; then
                rm ./$command_file
            else
                echo "Error while downloading videos (code $?)"
            fi
        fi
        unset HISTFILE
        exit
    else
        echo "Not enough privileges for user $user"
    fi
done
