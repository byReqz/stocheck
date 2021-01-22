#!/bin/bash
# license: gpl-3

if [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) != $(md5sum $0 | cut -c -32) ]] && [[ -z $1 ]] || [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) != $(md5sum $0 | cut -c -32) ]] && [[ $1 != "--update" ]] || [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) != $(md5sum $0 | cut -c -32) ]] && [[ $1 != "-u" ]];then
  echo "#############################################"
  echo -e "\e[4mnote: newer version detected, use -u to update\e[0m"
  echo "#############################################"
  echo ""
fi
while [ ! -n "$1" ]; do
if [[ -n $(ls /sys/block | grep sd) ]];then
    echo "===  sata drive check: ==="
    for x in {a..z};do
      scan=$(smartctl --scan)
      if [[ -n $(echo $scan | grep /dev/sd$x) ]];then
        echo "------------------- /dev/sd$x --------------------";
        smartctl -H -i /dev/sd$x;
        echo "-------------------------------------------------";
      fi
    done
if [[ -n $(ls /dev | grep nvme) ]];then
    echo "===  nvme drive check: ==="
    for x in {0..4};do
      scan=$(smartctl --scan)
      if [[ -n $(echo $scan | grep /dev/nvme$x) ]];then
	    echo "------------------- /dev/nvme$x --------------------";
	    smartctl -H -i /dev/nvme$x;
	    echo "---------------------------------------------------";
      fi
    done
else
    exit
fi
fi
done
while [ ! -z "$1" ]; do
      if [[ $1 == "-u" ]] || [[ "$1" == "--update" ]];then
        if [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) != $(md5sum $0 | cut -c -32) ]];then
          wget -O $0 --quiet "https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh"
          echo "#############################################"
          echo -e "\e[4mscript has been updated to the newest version\e[0m"
          echo "#############################################"
          exit
        elif [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) = $(md5sum $0 | cut -c -32) ]];then
         echo "#############################################"
         echo "no newer version found"
         echo "#############################################"
         exit
        fi
      elif [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
         echo "Usage: $0 (options) <ip> (y/n)"
         echo "Options:"
         echo " -u/--update -- update the script"
         echo " -h/--help -- show help"
         exit
      fi
done
