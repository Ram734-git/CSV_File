#!/bin/bash
str=${hostname}
IPAddress1=""
HOSTS=(${str//" "/ })
echo "HOSTS: ${HOSTS}"
today=`date '+%Y_%m_%d_%H%M_%S'`;
for i in ${!HOSTS[*]} ; do 
IPAddress1+=_${HOSTS[i]}
done
FileName=${IPAddress1}_${today}
IPAddress=${HOSTS[i]}
echo "Host Details","FQDN","Version Details","Release","IPAddress","File System Details","Ping Details","Telnet Details" | paste -sd ',' >> ${FileName}.csv
pingde=""
Td=""
for i in ${!HOSTS[*]} ; do 
echo ${HOSTS[i]}
#IPAddress=${HOSTS[i]}
ssh -tt ec2-user@${HOSTS[i]} '(
	pingde=""
	Td=""
    Hostname=`uname -a | cut -d " " -f 2`
	FQDN=`hostname --all-fqdns`
	Version=`uname -a | cut -d " " -f 3`
	Release=`cat /etc/redhat-release`
    #SSODSA=`/sbin/service ds_agent status | head -3`
	FSD=`df -h`
	IPAddress=$(hostname -I)
	echo $Hostname,$FQDN,$Version,$Release,$IPAddress,$FSD,$pingde,$Td

    )'	| paste -sd ',' >> ${FileName}.csv

echo "============out of loop=============="
#echo $Hostname,$FQDN,$Version,$Release,$IPAddress,$SSODSA,$FSD


#sed '7 s/""/"$PD"/' ${FileName}.csv

#echo "Telnet Status :-" | sed -i 's/,/,/,/,/,/,/' >> NameofFile 
pingde=`ping -c 5 ${HOSTS[i]} | head -9 | tail -1`
echo "Ping details: $pingde"
#sed 's/$/,$pingde/' ${FileName}.csv >> ${FileName}.csv
awk -F"," 'BEGIN { OFS = "," } ; {$7="$pingde" OFS $6; print}' ${FileName}.csv 
#sed '7 s/""/$pingde/'  ${FileName}.csv
#ping -c 5 ${HOSTS[i]} | head -9 | tail -1 | paste -sd ',' >> ${FileName}.csv
#echo "Telnet connected to ${HOSTS[i]} Port 22 :- `(echo >/dev/tcp/${HOSTS[i]}/22) &>/dev/null && echo "Port Open" || echo "Port Closed"`" | paste -sd ',' >> ${FileName}.csv
#echo "Telnet connected to ${HOSTS[i]} Port 4122 :- `(echo >/dev/tcp/${HOSTS[i]}/4122) &>/dev/null && echo "Port Open" || echo "Port Closed"`" | paste -sd ',' >> ${FileName}.csv
#echo "======================================================================" | paste -sd ',' >> NameofFile

done

cp ${FileName}.csv /var/lib/jenkins/workspace/oldcsv