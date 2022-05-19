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
# End of configuration
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
            /usr/local/bin/yt-dlp --limit-rate $dl_speed --batch-file ./$command_file
            rm ./ytdl.txt
        fi
        unset HISTFILE
        exit
    else
        echo "Not enough privileges for user $user"
    fi
done
