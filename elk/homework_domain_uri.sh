#!/bin/bash

# Telegram
telegram_token=''
telegram_chat_id=''

# 定義參數
log_f='/var/log/nginx/web_access.log'
time_f='/tmp/time.temp'
temp_f='/tmp/temp'
text_f='/tmp/text.temp'

# 過濾時間
for ((t=0;t<=5;t=t+1))
do
        echo "$(cat ${log_f} | grep $(date +%d/%b/%Y:%H:%M -d "${t} min ago"))" >> ${time_f}
done

# 宣告參數
remote_addr=$(cat ${time_f} | awk '{print $14}' | awk -F '"' '{print $2}' | )
request_uri=$(cat ${time_f} | awk '{print $29}' | awk -F '"' '{print $2}')
domain=$(cat ${time_f} | awk -F 'domain' '{print $2}' | awk -F '[" ]' '{print $4}')

# 整理資料
for remote_addr_total in ${remote_addr}
do
    for request_uri_total in ${request_uri}
    do
        for domain_total in ${domain}
        do
            date_total=$(echo -e "${remote_addr_total}\t${request_uri_total}\t${domain_total}")
            echo ${date_total} >> ${temp_f}
        done
    done 
done

echo "$(cat ${temp_f} | awk '{print $1}' | sort | uniq -c)" | while read connect ip
do
    if [ "${connect}" -gt "2000" ]; then
    echo ${ip} | while read ip
    do
        echo -e "※※※※※※※※※" > ${text_f}
        echo -e "※※※ IP\t連線次數\n※※※ ${ip}\t${connect}" >> ${text_f}
        echo -e "※※※※※※※※※" >> ${text_f}
        echo -e "$(cat ${temp_f} | awk '{print $1,$3}' | sort | uniq -c | grep ${ip} | awk '{print $3,$1}')" | while read doma con
        do
            echo '' >> ${text_f}
            echo -e "Domain\t連線次數\n${doma}\t${con}" >> ${text_f}
            echo -e "URI\t連線次數" >> ${text_f}

            # 判斷 URI 連線次數
            echo "$(cat ${temp_f} | awk '{print $1,$3,$2}' | sort | uniq -c | grep ${ip} | grep ${doma} | awk '{print $4,$1}')" | while read uri conn
            do
                if [ "${conn}" -gt 100 ]; then
                echo -e "${uri}\t${conn}" >> ${text_f}
                fi
            done
        done
        echo ''
    done
    curl -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chat_id} -d text="$(cat ${text_f})"
    fi
done

rm -f ${temp_f} ${time_f} ${text_f}
