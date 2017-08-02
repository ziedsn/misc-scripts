# Variables - Set these
pth=`pwd`
# HOST DISCOVERY

#echo "$pth nmap host discovery has begun" | sendmail "email@email.com"

# Nmap - Pingsweep using ICMP echo
nmap -sP -PE -iL $pth/targets -oA $pth/icmpecho
cat $pth/icmpecho.gnmap | grep Up | cut -d ' ' -f 2 > $pth/live

# Nmap - Pingsweep using ICMP timestamp
nmap -sP -PP -iL $pth/targets -oA $pth/icmptimestamp
cat $pth/icmptimestamp.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live

# Nmap - Pingsweep using ICMP netmask
nmap -sP -PM -iL $pth/targets -oA $pth/icmpnetmask
cat $pth/icmpnetmask.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live

# Systems that respond to ping (finding)
cat $pth/live | sort | uniq > $pth/pingresponse

# Nmap - Pingsweep using TCP SYN and UDP
nmap -sP -PS21,22,23,25,53,80,88,110,111,135,139,443,445,8080 -iL $pth/targets -oA $pth/pingsweepTCP
nmap -sP -PU53,111,135,137,161,500 -iL $pth/targets -oA $pth/pingsweepUDP
cat $pth/pingsweepTCP.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
cat $pth/pingsweepUDP.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live

# Create unique live hosts file
cat $pth/live | sort | uniq > $pth/livehosts

# PORT SCANNING

# Nmap - Full TCP SYN scan on live targets
nmap -sS -PN -O -sV -T4 -p- --host-timeout 90m -iL $pth/livehosts -oA $pth/TCPdetails
cat $pth/TCPdetails.gnmap | grep ' 25/open' | cut -d ' ' -f 2 > $pth/SMTP
cat $pth/TCPdetails.gnmap | grep ' 53/open' | cut -d ' ' -f 2 > $pth/DNS
cat $pth/TCPdetails.gnmap | grep ' 23/open' | cut -d ' ' -f 2 > $pth/telnet
cat $pth/TCPdetails.gnmap | grep ' 445/open' | cut -d ' ' -f 2 > $pth/SMB
cat $pth/TCPdetails.gnmap | grep ' 139/open' | cut -d ' ' -f 2 > $pth/netbios
cat $pth/TCPdetails.gnmap | grep ' 80/open' | cut -d ' ' -f 2 > $pth/HTTP
cat $pth/TCPdetails.gnmap | grep ' 443/open' | cut -d ' ' -f 2 > $pth/HTTPS
cat $pth/TCPdetails.gnmap | grep ' 8080/open' | cut -d ' ' -f 2 > $pth/HTTP_ALT
cat $pth/TCPdetails.gnmap | grep ' 8443/open' | cut -d ' ' -f 2 >> $pth/HTTP_ALT
cat $pth/TCPdetails.gnmap | grep ' 22/open' | cut -d ' ' -f 2 > $pth/SSH
cat $pth/TCPdetails.gnmap | grep ' 21/open' | cut -d ' ' -f 2 > $pth/FTP
cat $pth/TCPdetails.gnmap | grep ' 3306/open' | cut -d ' ' -f 2 > $pth/MYSQL
cat $pth/TCPdetails.gnmap | grep ' 1433/open' | cut -d ' ' -f 2 > $pth/MSSQL
cat $pth/TCPdetails.gnmap | grep ' 1434/open' | cut -d ' ' -f 2 >> $pth/MSSQL
cat $pth/TCPdetails.gnmap | grep ' 3389/open' | cut -d ' ' -f 2 > $pth/RDP
cat $pth/TCPdetails.gnmap | grep ' 5800/open' | cut -d ' ' -f 2 > $pth/VNC
cat $pth/TCPdetails.gnmap | grep ' 5900/open' | cut -d ' ' -f 2 >> $pth/VNC



# Nmap - Default UDP scan on live targets
nmap -sU -PN -T4 --host-timeout 30m -iL $pth/livehosts -oA $pth/UDPdetails
cat $pth/UDPdetails.gnmap | grep ' 161/open\?\!|' | cut -d ' ' -f 2 > $pth/SNMP
cat $pth/UDPdetails.gnmap | grep ' 500/open\?\!|' | cut -d ' ' -f 2 > $pth/isakmp
cat $pth/UDPdetails.gnmap | grep ' 69/open\?\!|' | cut -d ' ' -f 2 > $pth/tftp

# Empty file cleanup
find $pth -size 0c -type f -exec rm -rf {} \;

