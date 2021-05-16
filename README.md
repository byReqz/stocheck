# stocheck
quick and dirty smart value checker

### features: 
- sata/nvme support
- show smart info and self-check results
<br>
supports most common raid-controller brands (but not all models): <br>
- 3ware (series 6000, 7000, 8000, 9000 and 9750) <br>
- adaptec (smartraid/aacraid not yet implemented) <br>
- lsi/dell <br>

### known issues:
- showing all attributes for raid controllers fails via SSH
- Dell/LSI controllers in IT/HBA mode fail
- smart arguments for some NVMe drives missing

# contributing
As different drives have different arguments, there are always ones which im gonna miss out on. Please submit smart arguments that you think to be missing as issue or merge request.

# usage
Usage: stocheck (options) <br>
Options: <br>
 -h/--help -- show help <br>
 -u/--update -- update the script <br>

### **running it on a remote machine:**
**running from the local file (can be automated with cron):**
```bash
ssh root@remote 'bash -s' < stocheck.sh
```

or

**running directly from github**
```bash
ssh root@remote "curl -s "https://raw.githubusercontent.com/byReqz/stocheck/main/stocheck.sh" | bash"
```

**proper alias:**
```bash
echo "function stocheck_remote { ssh root@'$'1 'bash -s' < ~/stocheck.sh; }" >> ~/.bashrc
echo "alias stocheck=stocheck_remote" >> ~/.bashrc
```

# installation
1. download the script: <br>
```bash
wget https://git.byreqz.de/byreqz/stocheck/raw/branch/main/stocheck.sh
```
2. run it with <br>
```bash
bash stocheck.sh
```
or <br>
```bash
chmod +x stockheck.sh && ./stocheck.sh
```
3. optionally alias it <br>
```bash
alias stocheck="~/stocheck.sh"
```

# sample output
```bash
===  sata drive check: (1 found) ===
------------------- /dev/sda --------------------
=== START OF INFORMATION SECTION ===
Device Model:     INTEL XXXXXXXX
Serial Number:    XXXXXXXXXXXXX
Firmware Version: XXXX
User Capacity:    240.057.409.536 bytes [240 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF SELF-ASSESSMENT TEST RESULT ===
SMART overall-health self-assessment test result: PASSED

Attribute                Value (Raw)  Worst  Thresh  Type     Updated  Failed
Reallocated_Sector_Ct    100 (0)      100    000     Old_age  Always   -
Power_On_Hours           100 (1991)   100    000     Old_age  Always   -
Power_Cycle_Count        100 (2332)   100    000     Old_age  Always   -
Reported_Uncorrect       100 (1)      100    000     Old_age  Always   -
Temperature_Celsius      026 (26)     100    000     Old_age  Always   -
Media_Wearout_Indicator  080 (0)      100    000     Old_age  Always   -
-------------------------------------------------
```
