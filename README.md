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

### **running it on a remote machine:**
**running once:**
```bash
ssh root@remote 'bash -s' < stocheck.sh
```

**proper alias:**
```bash
echo "function stocheck_remote { ssh root@"$"1 'bash -s' < ~/stocheck.sh; }" >> ~/.bashrc
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
