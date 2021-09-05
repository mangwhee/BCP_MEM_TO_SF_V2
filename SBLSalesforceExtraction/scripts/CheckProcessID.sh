#!/bin/ksh

current_pid=$$
parent_pid=$(ps -o ppid= -p "$current_pid")
echo "My PID : $current_pid"

## Clear log file older than 15 day
#find $script_path/log/contact_bat_daily_*.log -mtime +15 -exec rm {} \;
#find $script_path/log/BAT_CONTACT_* -mtime +15 -exec rm {} \;

pid=`ps -fu $(whoami) |grep -w "$(basename $0)" |grep -v grep | grep -v "$parent_pid" |wc -l`
if [[ $pid -gt 0 ]]
then
        ps -fu $(whoami) |grep -w "$(basename $0)" |grep -v grep | grep -v "$parent_pid" | awk '{print "Found PID "$2" is running"}'
        dt_val=`date '+%Y-%m-%d %H:%M:%S'`
        echo "${dt_val}|INF:|Exit 9 : Batch import is running."
        exit 9
fi