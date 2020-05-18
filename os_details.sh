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
echo "Host Details","FQDN","Version Details","Release","Internal_IPAddress","SSODSA","File System Details","Ping Details","Telnet Details" | paste -sd ',' >> ${FileName}.csv
echo "Host Details","FQDN","Version Details","Release","Internal_IPAddress","SSODSA","File System Details","Ping Details","Telnet Details" | paste -sd ',' >> Ping_Details1_${FileName}.csv
echo "Host Details","FQDN","Version Details","Release","Internal_IPAddress","SSODSA","File System Details","Ping Details","Telnet Details" | paste -sd ',' >> Telnet_Ping_Details_${FileName}.csv 

for i in ${!HOSTS[*]} ; do 
echo ${HOSTS[i]}
#IPAddress=${HOSTS[i]}
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
	TD="td"
	echo $Hostname,$FQDN,$Version,$Release,$IPAddress,$SSODSA,$FSD,$PD,$TD

    )'	| paste -sd ',' >> ${FileName}.csv
done
echo "============out of loop=============="
#echo $Hostname,$FQDN,$Version,$Release,$IPAddress,$SSODSA,$FSD
c=0


for i in ${!HOSTS[*]} ; do 
PD=`ping -c 5 ${HOSTS[i]} | head -9 | tail -1` 
fqdn1=`ssh -tt ec2-user@${HOSTS[i]} '( hostname -I)'`

echo "Host:${HOSTS[i]}"

pingd=(${PD//","/ })
for j in ${!pingd[*]} ; do 
pd1+=${pingd[j]}_
done

# td1=`(echo >/dev/tcp/${HOSTS[i]}/${ports[i]}) &>/dev/null && echo "Port Open" || echo "Port Closed"`
# td1=`echo "Telnet connected to ${HOSTS[i]} Port ${ports[i]} :-"$td1`


fqdn1="$(echo -e "${fqdn1}" | tr -d '[:space:]')"

a[$c]=$pd1 
b[$c]=$fqdn1 


c=$((c+1));
pd1=""
hostname1=""
td1=""
#awk -F"," 'BEGIN { OFS = "," } {$8="$PD"; print}' ${FileName}.csv > Ping_Details_${FileName}.csv
#awk -v pdd="$pd1" -v ip="$ipaddress" -F ',' '$1=="Host Details" {print};$1=="ip-172-31-44-205.us-east-2.compute.internal"  {printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,$8,pdd,$10}' OFS="," ${FileName}.csv > Ping_Details1_${FileName}.csv
#awk -v city="$pd1" -v ip="${HOSTS[i]}" -F ',' '$5==ip && $9=="pingdetais" {gsub("pingdetais",city,$9); print}' OFS="," ${FileName}.csv > Ping_Details1_${FileName}.csv  

done
k=0
for i in ${!HOSTS[*]} ; do 

echo "value$k: ${a[$k]} "
echo "FDN$k: ${b[$k]}"



#awk -v pdd="${a[k]}" -v fq="$Ip_In" -v t="${d[$k]}" -F ',' '{ if($1=="Host Details" {print};$5==fq	 {printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,pdd,t}' OFS="," ${FileName}.csv

awk -v pdd="${a[k]}" -v fq="${b[$k]}"   -F ',' '{ if($5==fq) {printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,pdd,$9}}' OFS="," ${FileName}.csv >> Ping_Details1_${FileName}.csv 

#awk -v pdd="${a[k]}" -v fq="${b[$k]}" -v t="${d[$k]}" -F ',' '$1=="Host Details" {print};$5=="'${b[$k]}'"  {printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,pdd,t}' OFS="," ${FileName}.csv  


k=$((k+1));
done
g=0
str1=${telnetports}
ports=(${str1//" "/ })
for i in ${!HOSTS[*]} ; do 
	for j in ${!ports[*]} ; do 
		
			td1=`(echo >/dev/tcp/${HOSTS[i]}/${ports[j]}) &>/dev/null && echo "Port Open" || echo "Port Closed"`
			tdar[$i,$j]=`echo "Telnet connected to ${HOSTS[i]} Port ${ports[j]} :-"$td1`
			echo "tdar$i_$j: ${tdar[$i,$j]}"
	done
	port_len=${#ports[@]}
	
	for l in ${!ports[*]} ; do
	awk -v fq="${b[$g]}" -v pl="$port_len" -v tld="${tdar[$i,$l]}"  -F ',' '$5==fq {printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,$8,tld}' OFS="," Ping_Details1_${FileName}.csv >> Telnet_Ping_Details_${FileName}.csv 
	done
	g=$((g+1));
done

			
	



#sed 's/$/;"${PD}"/' ${FileName}.csv

#sed 's/$/;"$PD"/' ${FileName}.csv

#echo "Telnet Status :-" | paste -sd ',' >> NameofFile 
#echo "================"| paste -sd ','  >> NameofFile

# for i in ${!HOSTS[*]} ; do 
# #td1=`echo "Telnet connected to ${HOSTS[i]} Port ${ports[i]} :- `(echo >/dev/tcp/${HOSTS[i]}/${ports[i]}) &>/dev/null && echo "Port Open" || echo "Port Closed"`" `
# echo "$td1"
# td=`(echo >/dev/tcp/${HOSTS[i]}/${ports[i]}) &>/dev/null && echo "Port Open" || echo "Port Closed"`
# td=`echo "Telnet connected to ${HOSTS[i]} Port ${ports[i]} :-"$td`
# echo "$td"
# #awk -v tds="$td" -F ',' '{gsub("td",tds,$10); print}' OFS="," Ping_Details_${FileName}.csv   > Telnet_Ping_Details_${FileName}.csv

# #echo "Telnet connected to ${HOSTS[i]} Port 4122 :- `(echo >/dev/tcp/${HOSTS[i]}/4122) &>/dev/null && echo "Port Open" || echo "Port Closed"`" | paste -sd ',' >> NameofFile
# #echo "======================================================================" | paste -sd ',' >> NameofFile

# done
