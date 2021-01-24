#!/bin/bash
# license: gpl-3

if [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) != $(md5sum $0 | cut -c -32) ]] && [[ -z $1 ]] || [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) != $(md5sum $0 | cut -c -32) ]] && [[ $1 != "--update" ]] || [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh | md5sum | cut -c -32) != $(md5sum $0 | cut -c -32) ]] && [[ $1 != "-u" ]];then
  echo "#############################################"
  echo -e "\e[4mnote: newer version detected, use -u to update\e[0m"
  echo "#############################################"
  echo ""
fi
while [ ! -n "$1" ]; do
  raidcheck="$(lspci)"
  if [[ -z "$raidcheck" ]];then
    if [[ -n $(ls /sys/block | grep sd) ]];then
        echo "===  sata drive check: ==="
        for x in {a..z};do
          scan=$(smartctl --scan)
          if [[ -n $(echo $scan | grep /dev/sd$x) ]];then
            echo "------------------- /dev/sd$x --------------------"
            smartctl -H -i /dev/sd$x;
            echo "-------------------------------------------------"
          else
            exit
          fi
        done
        if [[ -z $(ls /dev | grep nvme) ]];then
          exit
        fi
    fi
    if [[ -n $(ls /dev | grep nvme) ]];then
        echo "===  nvme drive check: ==="
        for x in {0..4};do
          scan=$(smartctl --scan)
          if [[ -n $(echo $scan | grep /dev/nvme$x) ]];then
          echo "------------------- /dev/nvme$x --------------------"
          smartctl -H -i /dev/nvme$x;
          echo "---------------------------------------------------"
          fi
        done
        if [[ -z $(ls /dev | grep sd) ]];then
          exit
        fi
    fi
    if [[ -n $(ls /dev | grep nvme) ]] || [[ -n $(ls /sys/block | grep sd) ]] || [[ ! "$raidcheck" =~ "3ware" ]] && [[ "$raidcheck" =~ "adaptec" ]] && [[ "$raidcheck" =~ "lsi" ]] && [[ -n $(ls /sys/block | grep sd) ]] && [[ -n $(ls /dev | grep nvme) ]];then
        echo "no drives detected"
        exit
    fi
  elif [[ "$raidcheck" =~ "3ware" ]];then
    echo "3ware raid-controller detected"
    dreiware=$(tw_cli show | grep c | cut -c -3)
    echo "------------------- 3ware controller: $dreiware --------------------"
    tw_cli /$dreiware show
    echo "---------------------------------------------------------------"
    dreiwareversion=$(ls /dev/ | grep t)
    if [[ -n $(echo $dreiwareversion | grep twe0) ]];then
      echo "6000/7000/8000 series controller detected"
      echo "---------------------------------------------------------------"
        dreiwaredrives=$(tw_cli /$dreiware show | grep p | cut -c -3)
        echo "===  sata drive check: ==="
        for x in {0..20};do
          if [[ -n $(echo $dreiwaredrives | grep p$x) ]];then
            echo "------------------- p$x --------------------"
            smartctl -a -d 3ware,p$x /dev/twe0
            echo "-------------------------------------------"
          else
            exit
          fi
        done
    elif [[ -n $(echo $dreiwareversion | grep twa0) ]];then
      echo "9000 series controller detected"
      echo "---------------------------------------------------------------"
        dreiwaredrives=$(tw_cli /$dreiware show | grep p | cut -c -3)
        echo "===  sata drive check: ==="
        for x in {0..20};do
          if [[ -n $(echo $dreiwaredrives | grep p$x) ]];then
            echo "------------------- p$x --------------------"
            smartctl -a -d 3ware,p$x /dev/twa0
            echo "-------------------------------------------"
          else
            exit
          fi
        done
    elif [[ -n $(echo $dreiwareversion | grep twl0) ]];then
      echo "9750 series controller detected"
      echo "---------------------------------------------------------------"
        dreiwaredrives=$(tw_cli /$dreiware show | grep p | cut -c -3)
        echo "===  sata drive check: ==="
        for x in {0..20};do
          if [[ -n $(echo $dreiwaredrives | grep p$x) ]];then
            echo "------------------- p$x --------------------"
            smartctl -a -d 3ware,p$x /dev/twl0
            echo "-------------------------------------------"
          else
            exit
          fi
        done
    else
      echo "reading smart values for this controller series is not supported"
      exit
    fi
  elif [[ "$raidcheck" =~ "adaptec" ]];then
    echo "adaptec raid-controller detected"
    echo "------------------- adaptec controller --------------------"
    arcconf GETCONFIG 1 LD
    echo "---------------------------------------------------------------"
    echo "===  sata drive check: ==="
    echo "-------------------....--------------------"
    arcconf getconfig 1 pd|egrep "Device #|State\>|Reported Location|Reported Channel|S.M.A.R.T. warnings"
    echo "-------------------------------------------"
      for x in {1..20};do
        if [[ -n $(echo $dreiwaredrives | grep p$x) ]];then
          echo "------------------- sg$x --------------------"
          smartctl -d sat -a /dev/sg$x
          echo "-------------------------------------------"
        else
            exit
        fi
      done
  elif [[ "$raidcheck" =~ "lsi" ]];then
    echo "lsi raid-controller detected"
    echo "------------------- adaptec controller --------------------"
    megacli -LDInfo -Lall -Aall
    echo "---------------------------------------------------------------"
    echo "===  sata drive check: ==="
    echo "-------------------....--------------------"
    megacli -PDList -aAll | egrep "Enclosure Device ID:|Slot Number:|Inquiry Data:|Error Count:|state"
    echo "-------------------------------------------"
      for x in {a..z};do
          scan=$(smartctl --scan)
          if [[ -n $(echo $scan | grep /dev/sd$x) ]];then
          echo "------------------- /dev/sd$x --------------------"
          smartctl -d sat+megaraid,4 -a /dev/sd$x
          echo "-------------------------------------------------"
          else
            exit
          fi
      done
  else
    exit
  fi
done
exit
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
