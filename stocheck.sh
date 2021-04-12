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
if [[ $(whoami) != "root" ]] && [[ "$1" != "-u" ]];then
  echo "-----------------------------------------"
  echo "ERROR: This script should be run as root."
  echo "-----------------------------------------"
  exit
fi
while [ -z "$1" ]; do
  raidcheck="$(lspci | grep -E 'LSI|3ware|Adaptec|Smartraid')"
  if [[ -z "$raidcheck" ]];then
    if [[ -n $(ls /proc | grep -e "mdstat") ]] && [[ -n $(grep -e "md" /proc/mdstat) ]];then
      raidlist=$(grep -e "md" /proc/mdstat | cut -d " " -f 1)
      raidlist2=$(echo "$raidlist" | wc -l)
      df=$(df -Th)
      lsbl=$(lsblk -f)
      if [[ "$raidlist2" == "1" ]];then
        echo -e "detected "$raidlist2" raid array"
      else
        echo -e "detected "$raidlist2" raid arrays"
      fi
      echo -e "--------------------------------------------------"
      for ((x=1;x<=raidlist2;x++)); do
          raid=$(echo "$raidlist" | sed -n "$x"p)
          if [[ "$df" =~ "$raid" ]];then
              raidts=$(df -Th | grep "$raid" | tr -s ' ' | cut -d " " -f 3)
          else
              raidts="unmounted"
          fi
          if [[ "$raidts" == "unmounted" ]];then
              raidfs=$(echo "$lsbl" | grep "$raid" | tr -s ' ' | cut -d " " -f 2,3)
              raidper="NaN"
              raidmp="NaN"
              raiduuid=$(echo "$lsbl" | grep "$raid" | tr -s ' ' | cut -d " " -f 4)
              raidstate=$(echo "$mdadmconf" | grep -e "$raid" | cut -d " " -f 4)
              raiddrives=$(echo "$mdadmconf" | grep -e "$raid" | cut -c 6- | grep -o -E "sd[a-z][0-9]|nvme[0-9]n[0-9]p[0-9]" | tr "\n" " ")
              echo -e "\033[1mArray:\033[0m "$raid" \033[1mType:\033[0m "$raidstate" \033[1mState:\033[0m "$raidts" \033[1mSize/%/Mountpoint/UUID:\033[0m "NaN""
              echo -e "\033[1mMembers:\033[0m "$raiddrives""
              echo -e ""
          else
              raidfs=$(echo "$lsbl" | grep "$raid" | tr -s ' ' | cut -d " " -f 2,3)
              raidper=$(echo "$lsblk" | grep "$raid" | tr -s ' ' | cut -d " " -f 6)
              raidmp=$(echo "$lsbl" | grep "$raid" | tr -s ' ' | cut -d " " -f 7)
              raiduuid=$(echo "$lsbl" | grep "$raid" | tr -s ' ' | cut -d " " -f 4)
              raidstate=$(echo "$mdadmconf" | grep -e "$raid" | cut -d " " -f 4)
              raiddrives=$(echo "$mdadmconf" | grep -e "$raid" | cut -c 6- | grep -o -E "sd[a-z][0-9]|nvme[0-9]n[0-9]p[0-9]" | tr "\n" " ")
              echo -e "\033[1mArray:\033[0m "$raid" \033[1mType:\033[0m "$raidstate" \033[1mState:\033[0m "mounted" \033[1mSize:\033[0m "$raidts" \033[1m%:\033[0m "$raidper" \033[1mFilesystem:\033[0m "$raidfs" \033[1mMountpoint:\033[0m "$raidmp" \033[1mP-UUID\033[0m "$raiduuid""
              echo -e "\033[1mMembers:\033[0m "$raiddrives""
              echo ""
          fi
      done
      if [[ "$mdadmconf" =~ "recovery" ]];then
          echo -e "\033[1mWarning:\033[0m one or more arrays are rebuilding right now"
          echo ""
      elif [[ "$mdadmconf" =~ "resync" ]];then
          echo -e "\033[1mWarning:\033[0m one or more arrays are resyncing right now"
          echo ""
      fi
      echo -e "--------------------------------------------------"
      echo ""
    fi
    if [[ -n $(ls /sys/block | grep sd) ]];then
        echo "===  sata drive check: ($(ls -l /sys/block | grep sd | wc -l) found) ==="
        for x in {a..z};do
          scan=$(smartctl --scan)
          if [[ -n $(echo $scan | grep /dev/sd$x) ]] && [[ -n $(ls /sys/block | grep sd"$x") ]];then
            argsl=$(smartctl -A /dev/sd$x | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -o --color=never)
            argse=$(smartctl -A /dev/sd$x | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -e "FAILING_NOW" --color=never)
            if [[ "$argse" =~ "FAILING_NOW" ]];then
              argsl="
              "$argsl"
              "$(echo $argse | grep -e "FAILING_NOW" | tr -s ' ' | cut -c 2- | cut -d ' ' -f 2)"
              "
            fi
            argsm=$(echo "$argsl" | wc -l)
            echo "------------------- /dev/sd"$x" --------------------"
            smartctl -i /dev/sd$x | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:" -e "Multi_Zone_Error_Rate" 
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H /dev/sd$x | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            argend=$(echo -e "\e[4mAttribute\e[0m|\e[4mValue (Raw)\e[0m|\e[4mWorst\e[0m|\e[4mThresh\e[0m|\e[4mType\e[0m|\e[4mUpdated\e[0m|\e[4mFailed\e[0m")
            for ((z=1;z<=argsm;z++)); do
              arg=$(echo "$argsl" | sed -n "$z"p)
              value=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 4)
              worst=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 5)
              thresh=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 6)
              type=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 7)
              updated=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 8)
              failed=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 9)
              raw=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 10)
              argend=""$argend"
"$(echo ""$arg"|"$value" ("$raw")|"$worst"|"$thresh"|"$type"|"$updated"|"$failed"")""
            done
            echo "$(echo "$argend" | column -t -s "|")"
            echo "-------------------------------------------------"
          elif [[ -z $(echo $scan | grep /dev/sd"$x") ]] && [[ -n $(ls /sys/block | grep sd"$x") ]];then
            echo "------------------- /dev/sd"$x" --------------------"
            echo -e "drive is not responding"
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
        echo "===  nvme drive check: ($(ls -l /sys/block | grep nvme | wc -l) found) ==="
        for x in {0..4};do
          scan=$(smartctl --scan)
          if [[ -n $(echo $scan | grep /dev/nvme$x) ]] && [[ -n $(ls /sys/block | grep nvme"$x") ]];then
          argsl=$(smartctl -A /dev/nvme$x | grep -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -e "Warning Comp. Temperature Time" -e "Critical Comp. Temperature Time" -e "Power On Hours" -e "Controller Busy Time" -e "Temperature Sensor 1" -e "Temperature Sensor 2" -o --color=never)
          argse=$(smartctl -A /dev/nvme$x | grep -e "=== START OF SMART DATA SECTION ===" -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "FAILING_NOW" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -e "Warning Comp. Temperature Time" -e "Critical Comp. Temperature Time" -e "Power On Hours" -e "Controller Busy Time" -e "Temperature Sensor 1" -e "Temperature Sensor 2" --color=never)
          if [[ "$argse" =~ "FAILING_NOW" ]];then
            argsl="
            "$argsl"
            "$(echo $argse | grep -e "FAILING_NOW" | tr -s ' ' | cut -c 2- | cut -d ' ' -f 2)"
            "
          fi
          argsm=$(echo "$argsl" | wc -l)
          echo "------------------- /dev/nvme$x --------------------"
            smartctl -i /dev/nvme$x | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "Multi_Zone_Error_Rate"  -e "Model Number:" -e "Total NVM Capacity:" -e "NVMe Version" -e "Available Spare" -e "Available Spare Threshold" -e "Controller Busy Time" -e "Unsafe Shutdowns"
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H /dev/nvme$x | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            argend=$(echo -e "\e[4mAttribute\e[0m|\e[4mValue\e[0m")
            for ((z=1;z<=argsm;z++)); do
              arg=$(echo "$argsl" | sed -n "$z"p)
              value=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ':' -f 2,3 | cut -c 2-)
              argend=""$argend""
            done
            echo "$(echo "$argend" | column -t -s "|")"
            echo ""
            echo smartctl -A /dev/nvme$x | grep -e "Error Information (" -e "No Errors Logged"
          echo "---------------------------------------------------"
          elif [[ -z $(echo $scan | grep /dev/nvme"$x") ]] && [[ -n $(ls /sys/block | grep nvme"$x") ]];then
            echo "------------------- /dev/nvme"$x" --------------------"
            echo -e "drive is not responding"
            echo "-------------------------------------------------"
          fi
        done
        if [[ -z $(ls /dev | grep sd) ]];then
          exit
        fi
    fi
    if [[ -n $(ls /sys/block | grep nvme) ]] || [[ -n $(ls /sys/block | grep sd) ]] || [[ ! "$raidcheck" =~ "3ware" ]] && [[ "$raidcheck" =~ "adaptec" ]] && [[ "$raidcheck" =~ "lsi" ]] && [[ -n $(ls /sys/block | grep sd) ]] && [[ -n $(ls /dev | grep nvme) ]];then
        echo "no drives detected"
        exit
    fi
  elif [[ -n $(echo "$raidcheck" | grep -e "3ware") ]];then
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
            argsl=$(smartctl -A -d 3ware,p$x /dev/twe0 | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -o --color=never)
            argse=$(smartctl -A -d 3ware,p$x /dev/twe0 | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "FAILING_NOW" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" --color=never)
            if [[ "$argse" =~ "FAILING_NOW" ]];then
              argsl="
              "$argsl"
              "$(echo $argse | grep -e "FAILING_NOW" | tr -s ' ' | cut -c 2- | cut -d ' ' -f 2)"
              "
            fi
            argsm=$(echo "$argsl" | wc -l)
            echo "------------------- p$x --------------------"
            smartctl -i -d 3ware,p$x /dev/twe0 | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:" -e "Multi_Zone_Error_Rate" 
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H -d 3ware,p$x /dev/twe0 | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            argend=$(echo -e "\e[4mAttribute\e[0m|\e[4mValue (Raw)\e[0m|\e[4mWorst\e[0m|\e[4mThresh\e[0m|\e[4mType\e[0m|\e[4mUpdated\e[0m|\e[4mFailed\e[0m")
            for ((z=1;z<=argsm;z++)); do
              arg=$(echo "$argsl" | sed -n "$z"p)
              value=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 4)
              worst=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 5)
              thresh=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 6)
              type=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 7)
              updated=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 8)
              failed=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 9)
              raw=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 10)
              argend=""$argend"
"$(echo ""$arg"|"$value" ("$raw")|"$worst"|"$thresh"|"$type"|"$updated"|"$failed"")""
            done
            echo "$(echo "$argend" | column -t -s "|")"
            echo "-------------------------------------------"
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
            argsl=$(smartctl -A -d 3ware,p$x /dev/twa0 | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -o --color=never)
            argse=$(smartctl -A -d 3ware,p$x /dev/twa0 | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "FAILING_NOW" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" --color=never)
            if [[ "$argse" =~ "FAILING_NOW" ]];then
              argsl="
              "$argsl"
              "$(echo $argse | grep -e "FAILING_NOW" | tr -s ' ' | cut -c 2- | cut -d ' ' -f 2)"
              "
            fi
            argsm=$(echo "$argsl" | wc -l)
            echo "------------------- p$x --------------------"
            smartctl -i -d 3ware,p$x /dev/twa0 | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:" -e "Multi_Zone_Error_Rate" 
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H -d 3ware,p$x /dev/twa0 | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            argend=$(echo -e "\e[4mAttribute\e[0m|\e[4mValue (Raw)\e[0m|\e[4mWorst\e[0m|\e[4mThresh\e[0m|\e[4mType\e[0m|\e[4mUpdated\e[0m|\e[4mFailed\e[0m")
            for ((z=1;z<=argsm;z++)); do
              arg=$(echo "$argsl" | sed -n "$z"p)
              value=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 4)
              worst=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 5)
              thresh=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 6)
              type=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 7)
              updated=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 8)
              failed=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 9)
              raw=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 10)
              argend=""$argend"
"$(echo ""$arg"|"$value" ("$raw")|"$worst"|"$thresh"|"$type"|"$updated"|"$failed"")""
            done
            echo "$(echo "$argend" | column -t -s "|")"
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
            argsl=$(smartctl -A -d 3ware,p$x /dev/twl0 | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -o --color=never)
            argse=$(smartctl -A -d 3ware,p$x /dev/twl0 | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -e "FAILING_NOW" --color=never)
            if [[ "$argse" =~ "FAILING_NOW" ]];then
              argsl="
              "$argsl"
              "$(echo $argse | grep -e "FAILING_NOW" | tr -s ' ' | cut -c 2- | cut -d ' ' -f 2)"
              "
            fi
            argsm=$(echo "$argsl" | wc -l)
            echo "------------------- p$x --------------------"
            smartctl -i -d 3ware,p$x /dev/twl0 | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:" -e "Multi_Zone_Error_Rate" 
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H -d 3ware,p$x /dev/twl0 | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            argend=$(echo -e "\e[4mAttribute\e[0m|\e[4mValue (Raw)\e[0m|\e[4mWorst\e[0m|\e[4mThresh\e[0m|\e[4mType\e[0m|\e[4mUpdated\e[0m|\e[4mFailed\e[0m")
            for ((z=1;z<=argsm;z++)); do
              arg=$(echo "$argsl" | sed -n "$z"p)
              value=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 4)
              worst=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 5)
              thresh=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 6)
              type=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 7)
              updated=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 8)
              failed=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 9)
              raw=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 10)
              argend=""$argend"
"$(echo ""$arg"|"$value" ("$raw")|"$worst"|"$thresh"|"$type"|"$updated"|"$failed"")""
            done
            echo "$(echo "$argend" | column -t -s "|")"
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
    echo "--------------------- adaptec controller ----------------------"
    arcconf GETCONFIG 1 LD
    echo "---------------------------------------------------------------"
    echo "===  sata drive check: ==="
    echo "-------------------------------------------"
    arcconf getconfig 1 pd|egrep "Device #|State\>|Reported Location|Reported Channel|S.M.A.R.T. warnings"
    echo "-------------------------------------------"
    echo "show all smart values? (y/N)"
    read yn
    if [[ $yn == "y" ]] || [[ $yn == "Y" ]] || [[ $yn == "yes" ]];then
      for x in {1..20};do
        if [[ -n $(echo $dreiwaredrives | grep p$x) ]];then
          argsl=$(smartctl -A -d sat /dev/sg$x | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -o --color=never)
          argse=$(smartctl -A -d sat /dev/sg$x | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "FAILING_NOW" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" --color=never)
          if [[ "$argse" =~ "FAILING_NOW" ]];then
            argsl="
            "$argsl"
            "$(echo $argse | grep -e "FAILING_NOW" | tr -s ' ' | cut -c 2- | cut -d ' ' -f 2)"
            "
          fi
          argsm=$(echo "$argsl" | wc -l)
          echo "------------------- sg$x --------------------"
          smartctl -i -d sat /dev/sg$x | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:" -e "Multi_Zone_Error_Rate" 
          echo ""
          echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
          smartctl -H -d sat /dev/sg$x | grep -e "SMART overall-health self-assessment test result:"
          echo ""
          argend=$(echo -e "\e[4mAttribute\e[0m|\e[4mValue (Raw)\e[0m|\e[4mWorst\e[0m|\e[4mThresh\e[0m|\e[4mType\e[0m|\e[4mUpdated\e[0m|\e[4mFailed\e[0m")
          for ((z=1;z<=argsm;z++)); do
            arg=$(echo "$argsl" | sed -n "$z"p)
            value=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 4)
            worst=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 5)
            thresh=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 6)
            type=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 7)
            updated=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 8)
            failed=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 9)
            raw=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 10)
            argend=""$argend"
"$(echo ""$arg"|"$value" ("$raw")|"$worst"|"$thresh"|"$type"|"$updated"|"$failed"")""
          done
          echo "$(echo "$argend" | column -t -s "|")"
          echo "-------------------------------------------"
        else
            exit
        fi
      done
    else
      exit
    fi
  elif [[ -n $(echo "$raidcheck" | grep -e "LSI") ]];then
    echo "lsi raid-controller detected"
    echo "----------------------- LSI controller ------------------------"
    megacli -LDInfo -Lall -Aall
    echo "---------------------------------------------------------------"
    echo "===  sata drive check: ==="
    echo "-------------------------------------------"
    megacli -PDList -aAll | egrep "Enclosure Device ID:|Slot Number:|Inquiry Data:|Error Count:|state"
    echo "-------------------------------------------"
    echo "show all smart values? (y/N)"
    read yn
    if [[ $yn == "y" ]] || [[ $yn == "Y" ]] || [[ $yn == "yes" ]];then
      scan=$(megacli -pdlist -a0 | grep "Device Id")
      p1=$(head -n 1 $scan | cut -c 12-)
      pz=$(tail -n 1 $scan | cut -c 12-)
        for x in {$p1..$pz};do
            if [[ -n $(echo $scan | grep -E "$x") ]] && [[ -n $(ls /sys/block | grep "$x") ]];then
            argsl=$(smartctl -A -d sat+megaraid,$x /dev/sda | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" -o --color=never)
            argse=$(smartctl -A -d sat+megaraid,$x /dev/sda | grep -e "SMART overall-health self-assessment test result:" -e "Reallocated_Sector_Ct" -e "Power_On_Hours" -e "Temperature_Celsius" -e "Media_Wearout_Indicator" -e "Power_Cycle_Count" -e "Reported_Uncorrect" -e "Temperature:" -e "Percentage Used:" -e "Data Units Read:" -e "Data Units Written:" -e "Power on Hours:" -e "Power Cycles:" -e "Media and Data Integrity Errors:" -e "Error Information Log Entries:" -e "Error Information" -e "No Errors Logged" -e "FAILING_NOW" -e "Percent_Lifetime_Remain" -e "Write_Error_Rate" -e "Offline_Uncorrectable" -e "Reported_Uncorrect" -e "Error_Correction_Count" -e "Unexpect_Power_Loss_Ct" -e "Raw_Read_Error_Rate" --color=never)
            if [[ "$argse" =~ "FAILING_NOW" ]];then
              argsl="
              "$argsl"
              "$(echo $argse | grep -e "FAILING_NOW" | tr -s ' ' | cut -c 2- | cut -d ' ' -f 2)"
              "
            fi
            argsm=$(echo "$argsl" | wc -l)
            echo "------------------- p$x --------------------"
            smartctl -i -d sat+megaraid,$x /dev/sda | grep -e "=== START OF INFORMATION SECTION ===" -e "Device Model:" -e "Serial Number:" -e "Firmware Version:" -e "User Capacity:" -e "SMART support is:" -e "Sector Size:" -e "Rotation Rate:" -e "Multi_Zone_Error_Rate" 
            echo ""
            echo "=== START OF SELF-ASSESSMENT TEST RESULT ==="
            smartctl -H -d sat+megaraid,$x /dev/sda | grep -e "SMART overall-health self-assessment test result:"
            echo ""
            argend=$(echo -e "\e[4mAttribute\e[0m|\e[4mValue (Raw)\e[0m|\e[4mWorst\e[0m|\e[4mThresh\e[0m|\e[4mType\e[0m|\e[4mUpdated\e[0m|\e[4mFailed\e[0m")
            for ((z=1;z<=argsm;z++)); do
              arg=$(echo "$argsl" | sed -n "$z"p)
              value=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 4)
              worst=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 5)
              thresh=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 6)
              type=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 7)
              updated=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 8)
              failed=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 9)
              raw=$(echo "$argse" | grep -e "$arg" | xargs | cut -d ' ' -f 10)
              argend=""$argend"
"$(echo ""$arg"|"$value" ("$raw")|"$worst"|"$thresh"|"$type"|"$updated"|"$failed"")""
            done
            echo "$(echo "$argend" | column -t -s "|")"
            echo "-------------------------------------------------"
            else
              exit
            fi
        done
    else
      exit
    fi
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
