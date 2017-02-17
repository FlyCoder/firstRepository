#!/bin/bash
while true
do
#get current time flag
now_time=`date "+%G%m%d%H%M%S"`
log_date=`date "+%G-%m-%d-%H"`
tmp_file="/tmp/tmp_file"${now_time}
postfix=${log_date}"_logging"
prefix="coder/my.log"
file_name=${prefix}${postfix}
dest_file="/home/coder/data/url-"${now_time}".log"
rule="url\":\"htt.*?\""
#to create file
tail -f /home/coder/my.log*_logging | LC_ALL=C grep -P rule | LC_ALL=C grep -Po "http[^\"]*" > $tmp_file &
last_count=-1
while true
do
    if [ ! -f $file_name ]; then
        #echo $file_name" does not exist now."
        break
    fi
    if [ -f $tmp_file ]; then
        count=`cat $tmp_file | wc -l`
        if (($count >= 40000)) || [ $count -eq $last_count ]; then
            #echo "count >= 40000, or no change, break now"
            break
        fi
        last_count=$count
    fi
    sleep 1s
done
#mv the tmp file to the another data dir
if [ -f $tmp_file ]; then
    ##echo 'found file:'$tmp_file
    count=`cat $tmp_file | wc -l`
    if (($count > 20)); then
       #echo 'line count is '$count
       #echo 'mv file'$tmp_file'to log dir'
        sed -i 's/$/standard/' $tmp_file
        mv $tmp_file $dest_file
    else
       #echo 'rm file:'$tmp_file
	/usr/bin/rm $tmp_file
    fi
else
   :
   #echo 'not found tmp file:'$tmp_file
fi
process_tag="/home/coder/my.log"
pid=`ps -ef | grep "tail" | grep $process_tag |  awk -F ' ' '{print $2}'`
#echo 'find tail process id:'$pid
kill -9 $pid
if [ $? -eq 0 ];then
   #echo 'kill tail success'
   :
else
   #echo 'kill tail fail'
   :
fi
sleep 5s
done
