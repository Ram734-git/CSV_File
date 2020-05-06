#!/bin/bash
str=${hostname}
HOSTS=(${str//" "/ })
echo "HOSTS: ${HOSTS}"
today=`date '+%Y_%m_%d_%H%M_%S'`;
FileName=${hostname}_${today}

echo "Host Details","FQDN","Version Details","Release","IPAddress","File System Details","Ping Details" | paste -sd ',' >> ${FileName}.csv
for i in ${!HOSTS[*]} ; do 
echo ${HOSTS[i]}
#IPAddress=${HOSTS[i]}
ssh -tt ec2-user@${HOSTS[i]} '(
    Hostname=`uname -a | cut -d " " -f 2`
	FQDN=`hostname --all-fqdns`
	Version=`uname -a | cut -d " " -f 3`
	Release=`cat /etc/redhat-release`
    #SSODSA=`/sbin/service ds_agent status | head -3`
	FSD=`df -h`
	IPAddress=$(hostname -I)
	echo $Hostname,$FQDN,$Version,$Release,$IPAddress,$FSD

    )'	| paste -sd ',' >> ${FileName}.csv

echo "============out of loop=============="
echo $Hostname,$FQDN,$Version,$Release,$IPAddress,$SSODSA,$FSD


#sed 's/$/;"$PD"/' ${FileName}.csv

#echo "Telnet Status :-" | paste -sd ',' >> NameofFile 
#echo "================"| paste -sd ','  >> NameofFile
#echo "Telnet connected to ${HOSTS[i]} Port 22 :- `(echo >/dev/tcp/${HOSTS[i]}/22) &>/dev/null && echo "Port Open" || echo "Port Closed"`" | paste -sd ',' >> NameofFile 
#echo "Telnet connected to ${HOSTS[i]} Port 4122 :- `(echo >/dev/tcp/${HOSTS[i]}/4122) &>/dev/null && echo "Port Open" || echo "Port Closed"`" | paste -sd ',' >> NameofFile
#echo "======================================================================" | paste -sd ',' >> NameofFile

done

cp ${FileName}.csv /var/lib/jenkins/workspace/oldcsv