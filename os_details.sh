#!/bin/bash
str=${hostname}
IPAddress1=""
HOSTS=(${str//" "/ })
today=`date '+%Y_%m_%d_%H%M_%S'`;
for i in ${!HOSTS[*]} ; do 
	IPAddress1+=${HOSTS[i]}_
done
FileName=${IPAddress1}${today}
IPAddress=${HOSTS[i]}
echo "Host Details","FQDN","Version Details","Release","Internal_IPAddress","SSODSA","File System Details","Ping Details" | paste -sd ',' >> ${FileName}.csv
echo "Host Details","FQDN","Version Details","Release","Internal_IPAddress","SSODSA","File System Details","Ping Details" | paste -sd ',' >> Ping_Details1_${FileName}.csv
echo "Host Details","FQDN","Version Details","Release","Internal_IPAddress","SSODSA","File System Details","Ping Details" | paste -sd ',' >> Telnet_Ping_Details_${FileName}.csv 
echo "Host Details","FQDN","Version Details","Release","Internal_IPAddress","SSODSA","File System Details","Ping Details" | paste -sd ',' >> Server_Details_${FileName}.csv 
echo "IPAddress","Port","Telnet Details" | paste -sd ',' >> Telnet_Details_${FileName}.csv 

for i in ${!HOSTS[*]} ; do 
	echo ${HOSTS[i]}
	ssh -tt -o StrictHostKeyChecking=no ec2-user@${HOSTS[i]} '(
		Hostname=`uname -a | cut -d " " -f 2`
		FQDN=`hostname --all-fqdns`
		Version=`uname -a | cut -d " " -f 3`
		Release=`cat /etc/redhat-release`
		Release1="Red Hat Enterprise Linux Server release 7.6 (Maipo)"
		if [[ $Release == $Release1 ]]
		then
			SSODSA="This is Relesae 6.10"
		else
			SSODSA="this is Releasse 8"
		fi
		#SSODSA=`/sbin/service ds_agent status | head -3`
		FSD=`df -h`
		IPAddress=$(hostname -I)
		IPAddress="$(echo -e "${IPAddress}" | tr -d '[:space:]')"
		PD="pingdetais"
		# TD="td"
		echo $Hostname,$FQDN,$Version,$Release,$IPAddress,$SSODSA,$FSD,$PD)'	| paste -sd ',' >> ${FileName}.csv
done
c=0
for i in ${!HOSTS[*]} ; do 
	PD=`ping -c 5 ${HOSTS[i]} | head -9 | tail -1` 
	fqdn1=`ssh -tt ec2-user@${HOSTS[i]} '( hostname -I)'`
	echo "Host:${HOSTS[i]}"
	pingd=(${PD//","/ })
	for j in ${!pingd[*]} ; do 
		pd1+=${pingd[j]}_
	done
	fqdn1="$(echo -e "${fqdn1}" | tr -d '[:space:]')"
	a[$c]=$pd1 
	b[$c]=$fqdn1 
	c=$((c+1));
	pd1=""
	hostname1=""
	td1=""
done
k=0
for i in ${!HOSTS[*]} ; do 
	echo "value$k: ${a[$k]} "
	echo "FDN$k: ${b[$k]}"
	awk -v pdd="${a[k]}" -v fq="${b[$k]}"   -F ',' '{ if($5==fq) {printf "%s,%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,pdd}}' OFS="," ${FileName}.csv >> Ping_Details1_${FileName}.csv 
	k=$((k+1));
done
g=0
str2=${telnetips}
str1=${telnetports}
ports=(${str1//" "/ })
telnet_ips=(${str2//" "/ })
for i in ${!telnet_ips[*]} ; do 
	for j in ${!ports[*]} ; do 
		
			td1=`(echo >/dev/tcp/${HOSTS[i]}/${ports[j]}) &>/dev/null && echo "Port Open" || echo "Port Closed"`
			tdar[$i,$j]=`echo "Telnet connected to ${telnet_ips[i]} Port ${ports[j]} :-"$td1`
			echo "tdar$i_$j: ${tdar[$i,$j]}"
			echo ${telnet_ips[i]},${ports[j]},${tdar[$i,$j]}	| paste -sd ',' >> Telnet_Details_${FileName}.csv 
			
done
done
# for i in ${!HOSTS[*]} ; do 
	# for j in ${!ports[*]} ; do 
		
			# td1=`(echo >/dev/tcp/${HOSTS[i]}/${ports[j]}) &>/dev/null && echo "Port Open" || echo "Port Closed"`
			# tdar[$i,$j]=`echo "Telnet connected to ${HOSTS[i]} Port ${ports[j]} :-"$td1`
			# echo "tdar$i_$j: ${tdar[$i,$j]}"
	# done
	# port_len=${#ports[@]}
	
	# for l in ${!ports[*]} ; do
	# awk -v fq="${b[$g]}" -v pl="$port_len" -v tld="${tdar[$i,$l]}"  -F ',' '$5==fq {printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,$8,tld}' OFS="," Ping_Details1_${FileName}.csv >> Server_Details_${FileName}.csv 
	# done
	# g=$((g+1));
# done