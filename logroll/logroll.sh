#!/usr/bin/sh

#use flag delete with script to delete all log files, otherwise script by itself only removes log files older than 30 days


#location of Lev directory

LEV=/data/gdm4/config/Lev1

#number of days to keep log files
purgedays=30

#find directories that contain .log files or .out files, also picks up log files with *log.YYYY-MM-DD.txt files as well

dirlist=`find ${LEV}/ -type d \( -name "Configure*" -o -name bin \) -prune -o -type f -regextype posix-extended -regex '.*(log.[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9].txt$|\.out$|\.log$)' -print | awk -F\/ '{$NF=""; print $0}' | sed 's/[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-9][0-9]_[0-9][0-9]_[0-9][0-9]/\*/g' | sort | uniq | tr " " "\/"`

#delete all log files if delete argument is given
if [[ ${1} = delete ]]; then
        isup=`$LEV/sas.servers status | grep "is UP" | wc -l`
        if [[ ${isup} -gt 0 ]]; then
                echo "Stop SAS Servers before deleting logs"
                exit
        fi
        echo "deleting all log files in $LEV"
        for dir in ${dirlist}
        do
                rm -f ${dir}/*log.[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9].txt *.out$ *.log$
        done

elif [[ ${1} = roll ]]; then

#delete only log files that have not been modified in the past 30 days
        echo "deleting log files older than ${purgedays}"
        for dir in ${dirlist}
        do
                find ${dir} -maxdepth 1 -type f -regextype posix-extended -regex '.*(log.[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9].txt$|\.out$|\.log$)' -mtime +${purgedays} -print -delete 1>/dev/null
        done
else
        echo "arguments [delete|roll] delete will delete all log files, SAS must be down before you run, roll will delete log files that have not been modified in past ${purgedays} days, SAS can be up for roll"
fi
