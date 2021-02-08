#!/bin/bash
# license: gpl-3
if [[ ! "$0" =~ "bash" ]];then
  if [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/hash) != $(md5sum $0 | cut -c -32) ]] && [[ -z $1 ]] || [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/hash) != $(md5sum $0 | cut -c -32) ]] && [[ $1 != "--update" ]] || [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/hash) != $(md5sum $0 | cut -c -32) ]] && [[ $1 != "-u" ]];then
    echo "#############################################"
    echo -e "\e[4mnote: newer version detected, use -u to update\e[0m"
    echo "#############################################"
    echo ""
  fi
fi
while [ -z "$1" ]; do
  raidcheck="$(lspci | grep -E 'LSI|3Ware|Adaptec|Smartraid')"
  if [[ -z "$raidcheck" ]];then
    if [[ -n $(ls /sys/block | grep sd) ]];then
        echo "===  sata drive check: ==="
        for x in {a..z};do
          scan=$(smartctl --scan)
          if [[ -n $(echo $scan | grep /dev/sd$x) ]];then
            echo "------------------- /dev/sd$x --------------------"
            smartctl -i /dev/sd$x | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:"
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H /dev/sd$x | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            smartctl -A /dev/sd$x | grep -e "=== START OF READ SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Current_Pending_Sector:" -e "Offline_Uncorrectable:" -e "Raw_Read_Error_Rate:" -e "Seek_Error_Rate:" -e "Spin_Retry_Count:" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "FAILING_NOW"
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
            smartctl -i /dev/nvme$x | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:" -e "Model Number:" -e "Total NVM Capacity:" -e "Namespace 1 Utilization"
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H /dev/nvme$x | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            smartctl -A /dev/nvme$x | grep -e "=== START OF READ SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "FAILING_NOW"
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
  elif [[ -n $(echo "$raidcheck" | grep -e "3Ware") ]];then
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
            smartctl -i -d 3ware,p$x /dev/twe0 | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:"
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H -d 3ware,p$x /dev/twe0 | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            smartctl -A -d 3ware,p$x /dev/twe0 | grep -e "=== START OF READ SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect"
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
            smartctl -i -d 3ware,p$x /dev/twa0 | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:"
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H -d 3ware,p$x /dev/twa0 | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            smartctl -A -d 3ware,p$x /dev/twa0 | grep -e "=== START OF READ SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect"
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
            smartctl -i -d 3ware,p$x /dev/twl0 | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:"
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H -d 3ware,p$x /dev/twl0 | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            smartctl -A -d 3ware,p$x /dev/twl0 | grep -e "=== START OF READ SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect"
            echo "-------------------------------------------"
          else
            exit
          fi
        done
    else
      echo "reading smart values for this controller series is not supported"
      exit
    fi
  elif [[ -n $(echo "$raidcheck" | grep -e "Adaptec") ]];then
    echo "adaptec raid-controller detected"
    echo "------------------- adaptec controller --------------------"
    arcconf GETCONFIG 1 LD
    echo "---------------------------------------------------------------"
    echo "===  sata drive check: ==="
    echo "-------------------------------------------"
    arcconf getconfig 1 pd|egrep "Device #|State\>|Reported Location|Reported Channel|S.M.A.R.T. warnings"
    echo "-------------------------------------------"
      for x in {1..20};do
        if [[ -n $(echo $dreiwaredrives | grep p$x) ]];then
          echo "------------------- sg$x --------------------"
          smartctl -i -d sat /dev/sg$x | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:"
          echo ""
          echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
          smartctl -H -d sat /dev/sg$x | grep -e "SMART overall-health self-assessment test result:"
          echo ""
          smartctl -A -d sat /dev/sg$x | grep -e "=== START OF READ SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect"
          echo "-------------------------------------------"
        else
            exit
        fi
      done
  elif [[ -n $(echo "$raidcheck" | grep -e "LSI") ]];then
    echo "lsi raid-controller detected"
    echo "------------------- LSI controller --------------------"
    megacli -LDInfo -Lall -Aall
    echo "---------------------------------------------------------------"
    echo "===  sata drive check: ==="
    echo "-------------------------------------------"
    megacli -PDList -aAll | egrep "Enclosure Device ID:|Slot Number:|Inquiry Data:|Error Count:|state"
    echo "-------------------------------------------"
      for x in {0..32};do
          scan=$(megacli -pdlist -a0 | grep "Device Id")
          if [[ -n $(echo $scan | grep $x) ]];then
          echo "------------------- p$x --------------------"
          smartctl -i -d sat+megaraid,$x /dev/sda | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:"
          echo ""
          echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
          smartctl -H -d sat+megaraid,$x /dev/sda | grep -e "SMART overall-health self-assessment test result:"
          echo ""
          smartctl -A -d sat+megaraid,$x /dev/sda | grep -e "=== START OF READ SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect"
          echo "-------------------------------------------------"
          else
            exit
          fi
      done
  else
    exit
  fi
done
while [ -n "$1" ]; do
      if [[ $1 == "-u" ]] || [[ "$1" == "--update" ]];then
        if [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/hash) != $(md5sum $0 | cut -c -32) ]];then
          wget -O $0 --quiet "https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh"
          echo "#############################################"
          echo -e "\e[4mscript has been updated to the newest version\e[0m"
          echo "#############################################"
          exit
        elif [[ $(curl -s https://raw.githubusercontent.com/byReqz/stocheck/main/hash) = $(md5sum $0 | cut -c -32) ]];then
         echo "#############################################"
         echo "no newer version found"
         echo "#############################################"
         exit
        fi
      elif [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
         echo "Usage: $0 (options)"
         echo "Options:"
         echo " -u/--update -- update the script"
         echo " -h/--help -- show help"
         exit
      else
         echo "Usage: $0 (options)"
         echo "Options:"
         echo " -u/--update -- update the script"
         echo " -h/--help -- show help"
         exit
      fi
done
