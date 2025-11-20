#!/bin/bash

USE_THE_CLASH=0

# Exit on error
set -e

source ~/.bash_profile
source /etc/profile

now_time_D=`date +'%Y%m%d'`
now_time_H=`date +'%Y%m%d%H'`
now_time_M=`date +'%Y%m%d%H%M'`

NPR_MP3_D=$(date -u "+%B_%d_%Y")
NPR_MP3_H=$(date -u "+%H")

folder_tmp="/root/Auto_Download_From_NPR/download_NPR/data/tmp"
if [ ! -d $folder_tmp ];then
    `mkdir -p $folder_tmp`
fi

folder_voice_tmp="/root/Auto_Download_From_NPR/download_NPR/data/tmp/tmp_voice"
if [ ! -d $folder_voice_tmp ];then
	`mkdir -p $folder_voice_tmp`
fi

folder_video_tmp="/root/Auto_Download_From_NPR/download_NPR/data/tmp/tmp_video"
if [ ! -d $folder_video_tmp ];then
	`mkdir -p $folder_video_tmp`
fi

folder_voice="/root/Auto_Download_From_NPR/download_NPR/data/voice/VOICE_"$now_time_D
if [ ! -d $folder_voice ];then
	`mkdir -p $folder_voice`
fi

folder_video="/root/Auto_Download_From_NPR/download_NPR/data/video/VIDEO_"$now_time_D
if [ ! -d $folder_video ];then
	`mkdir -p $folder_video`
fi

`rm -f /root/Auto_Download_From_NPR/download_NPR/data/tmp/tmp_voice/*`
`rm -f /root/Auto_Download_From_NPR/download_NPR/data/tmp/tmp_video/*`

# Cron jobs run with a minimal environment, meaning thing like  PATH, PYTHONPATH, and other 
# environment variables in shell are not automatically available in the cron environment.
if [ $USE_THE_CLASH -eq 1 ]; then
	source ~/.bashrc
	export http_proxy="127.0.0.1:7890"
	export https_proxy="127.0.0.1:7890"
	export all_proxy="127.0.0.1:7890"
fi


# Initial fixed URL
URL="https://www.npr.org"

# Log file
LOG_FILE="/root/Auto_Download_From_NPR/download_NPR/shell_command/download_mp3.log"


exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================================="
echo "Starting script execution: $(date)"
echo "Log file position: $LOG_FILE"
echo "=========================================================="

if [ $USE_THE_CLASH -eq 1 ]; then
	# Step 1: Open the clash if the clash is not open
	clash_ID_before=`ps -ef | grep 'clash-linux-amd64-v1.11.0' | grep -v 'grep' | awk '{print $2}'`
	echo "clash ID before: "$clash_ID_before
	if [[ -z $clash_ID_before ]];then	
		echo "the clash is not open, now open it"
		`nohup /root/.config/clash/clash-linux-amd64-v1.11.0 >> /root/Auto_Download_From_NPR/download_NPR/nohup.out 2>&1 &`
		clash_ID_myuse=`ps -ef | grep 'clash-linux-amd64-v1.11.0' | grep -v 'grep' | awk '{print $2}'`
		echo "clash ID myuse: "$clash_ID_myuse
	fi
fi


# Step 2
MP3_DOWNLOAD_LINK="http://public.npr.org/anon.npr-mp3/npr/news/newscast.mp3"

if [ -z "$MP3_DOWNLOAD_LINK" ]; then
    echo "No mp3 128 kpbs, No matching path found in the fetched content. Exitting."
    exit 1
fi

echo $MP3_DOWNLOAD_LINK
echo "This is line number: $LINENO"
if [ $USE_THE_CLASH -eq 1 ]; then
	clash_ID_myuse=`ps -ef | grep 'clash-linux-amd64-v1.11.0' | grep -v 'grep' | awk '{print $2}'`
	if [[ -z $clash_ID_myuse ]];then	
		echo "the clash is not open, now open it"
		`nohup /root/.config/clash/clash-linux-amd64-v1.11.0 >> /root/VOA/download_VOA/nohup.out 2>&1 &`
		clash_ID_myuse=`ps -ef | grep 'clash-linux-amd64-v1.11.0' | grep -v 'grep' | awk '{print $2}'`
		echo "clash ID myuse: "$clash_ID_myuse
	fi
fi

# Step 3 Start download the MP3
echo "This is line number: $LINENO"
echo "Starting download mp3"
`wget -c -t 10 -T 200 --no-check-certificate $MP3_DOWNLOAD_LINK -P /root/Auto_Download_From_NPR/download_NPR/data/tmp/tmp_voice/`
if [ $USE_THE_CLASH -eq 1 ]; then
`kill $clash_ID_myuse`
fi

# Step 4 Check if download success
echo "This is line number: $LINENO"
download_mp3_original_name=$(ls $folder_voice_tmp -1)
if [[ -z $download_mp3_original_name ]];then	
    echo "download failed, there is no mp3 file, exit"
    exit 1
fi
echo "dowload success, the mp3 file original name is $download_mp3_original_name"

md5_flag_new=`md5sum $folder_voice_tmp"/"$download_mp3_original_name | awk '{print $1}'`
echo "the new mp3 md5 flag is $md5_flag_new"
md5_flag_old=`cat /root/Auto_Download_From_NPR/download_NPR/data/tmp/md5.txt | awk '{print $1}'`
echo "the old mp3 md5 flag is $md5_flag_old"

mp3_result=$folder_voice"/NPR_"$NPR_MP3_D"_"$NPR_MP3_H"00_UTC.mp3"
mp4_result=$folder_video"/English_Study_"$NPR_MP3_D"_"$NPR_MP3_H"00_UTC.mp4"

if [[ -z $md5_flag_old ]];then
	`mv /root/Auto_Download_From_NPR/download_NPR/data/tmp/tmp_voice/$download_mp3_original_name $mp3_result`
	`echo $md5_flag_new >/root/Auto_Download_From_NPR/download_NPR/data/tmp/md5.txt`
	`ffmpeg -loop 1 -framerate 1 -i /root/Auto_Download_From_NPR/download_NPR/data/picture/npr_1.png -i $mp3_result -map 0:v -map 1:a -r 10 -b:a 128K -shortest $mp4_result`
else
	if [[ $md5_flag_new != $md5_flag_old ]];then
        `mv /root/Auto_Download_From_NPR/download_NPR/data/tmp/tmp_voice/$download_mp3_original_name $mp3_result`
		`echo $md5_flag_new >/root/Auto_Download_From_NPR/download_NPR/data/tmp/md5.txt`
        `ffmpeg -loop 1 -framerate 1 -i /root/Auto_Download_From_NPR/download_NPR/data/picture/npr_1.png -i $mp3_result -map 0:v -map 1:a -r 10 -b:a 128K -shortest $mp4_result`
	fi
fi
