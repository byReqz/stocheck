# stocheck
quick and dirty smart value checker

### features: 
- sata/nvme support
- show smart info and self-check results

# usage
Usage: stocheck (options) <br>
Options: <br>
 -h/--help -- show help <br>
 -u/--update -- update the script <br>

**running it on a remote machine:**
```bash
ssh root@remote 'bash -s' < stocheck.sh
```

# installation
1. download the script: <br>
```bash
wget https://git.byreqz.de/byreqz/stocheck/raw/branch/main/stocheck.sh
```
2. run it with <br>
``
bash stocheck.sh
``
or <br>
``
chmod +x stockheck.sh && ./stocheck.sh
``
3. optionally alias it <br>
``alias stocheck="~/stocheck.sh"``
