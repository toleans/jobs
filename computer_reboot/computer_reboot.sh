#!/bin/bash

telegram_token=''
telegram_chat_id=''
host_list='/opt/host_group/host.list'
sedn_mesg='/tmp/mesg.tmp'
hostname_temp='/tmp/hostname_temp'

# 機器重啟失敗資料整理
if [ -s ${hostname_temp} ]; then
	cat ${host_list} | grep -A 99 "$(cat ${hostname_temp})" > ${hostname_temp}
fi

if [ ! -s ${hostname_temp} ]; then
	# 檢測機器重啟後服務狀態
	while read hostname hostname_ip
	do
		sudo ssh -o "StrictHostKeyChecking=no" \
				-o "UserKnownHostsFile=/dev/null" \
				jenkins@${hostname_ip} -f 'sleep 5; date +%F\ %T > /tmp/re_time.log;sync;sync;sync;sudo reboot'
		sleep 60
		if [ $(nmap -p T:22,80,443 ${hostname_ip} | grep open | wc -l ) -eq 3 ]; then
			uptime=$(sudo ssh -o "StrictHostKeyChecking=no" \
				-o "UserKnownHostsFile=/dev/null" \
				jenkins@${hostname_ip} -f uptime | awk -F ',' '{print $1}')
			echo "✅ 例行性主機重啟成功" > ${sedn_mesg}
			echo "主機名稱 : ${hostname}" >> ${sedn_mesg}
			echo "主機IP : ${hostname_ip}" >> ${sedn_mesg}
			echo "已開機時間 : ${uptime}" >> ${sedn_mesg}
			curl -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chat_id} -d text="$(cat ${sedn_mesg})"
		elif [ $(nmap -p T:22,80,443 ${hostname_ip} | grep open | wc -l ) -lt 3 ]; then
			echo "❌ 例行性主機重啟失敗" > ${sedn_mesg}
			echo "主機名稱 : ${hostname}" >> ${sedn_mesg}
			echo "主機IP : ${hostname_ip}" >> ${sedn_mesg}
			echo -e "服務異常 Port\n$(nmap -p T:22,80,443 119.8.52.106 | grep 'closed' | awk '{print $1,$3}' | sed -e 's/\/tcp//g') " >> ${sedn_mesg}
			curl -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chat_id} -d text="$(cat ${sedn_mesg})"
			echo "${hostname} ${hostname_ip}" > ${hostname_temp} 
			exit
		fi
	done < ${host_list}
elif [ -s ${hostname_temp} ]; then
	while read hostname hostname_ip
	do
		sudo ssh -o "StrictHostKeyChecking=no" \
				-o "UserKnownHostsFile=/dev/null" \
				jenkins@${hostname_ip} -f 'sleep 5; date +%F\ %T > /tmp/re_time.log;sync;sync;sync;sudo reboot'
		sleep 60
		if [ $(nmap -p T:22,80,443 ${hostname_ip} | grep open | wc -l ) -eq 3 ]; then
			uptime=$(sudo ssh -o "StrictHostKeyChecking=no" \
				-o "UserKnownHostsFile=/dev/null" \
				jenkins@${hostname_ip} -f uptime | awk -F ',' '{print $1}')
			echo "✅ 例行性主機重啟成功" > ${sedn_mesg}
			echo "主機名稱 : ${hostname}" >> ${sedn_mesg}
			echo "主機IP : ${hostname_ip}" >> ${sedn_mesg}
			echo "已開機時間 : ${uptime}" >> ${sedn_mesg}
			curl -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chat_id} -d text="$(cat ${sedn_mesg})"
		elif [ $(nmap -p T:22,80,443 ${hostname_ip} | grep open | wc -l ) -lt 3 ]; then
			echo "❌ 例行性主機重啟失敗" > ${sedn_mesg}
			echo "主機名稱 : ${hostname}" >> ${sedn_mesg}
			echo "主機IP : ${hostname_ip}" >> ${sedn_mesg}
			echo -e "服務異常 Port\n$(nmap -p T:22,80,443 119.8.52.106 | grep 'closed' | awk '{print $1,$3}' | sed -e 's/\/tcp//g') " >> ${sedn_mesg}
			curl -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chat_id} -d text="$(cat ${sedn_mesg})"
			echo "${hostname} ${hostname_ip}" > ${hostname_temp} 
			exit
		fi
		rm -f ${hostname_temp}
	done < ${hostname_temp}
fi
