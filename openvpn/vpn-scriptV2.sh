#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

name=${1}
file_vpn='/etc/openvpn/client/openvpn.zip'
usermail="${name}@gomaji.com"
user_vpn_file="/etc/openvpn/client/${name}/gomaji.ovpn"
user_vpn_file2="${name}/gomaji.ovpn"
user_dir="/etc/openvpn/client/${name}"
user_ccd="/etc/openvpn/ccd/${1}"
pwd12=$(pwgen -s 12 | awk '{print $1}')

if [ "${name}x" == 'x' ]; then
    echo "請輸入帳號名稱: create_user.sh username"
else

    if [ "${2}x" == 'x' ]; then
        echo "請輸入 IP "
    else
        ipc=${2}
    fi
    
    if [ -d "/etc/openvpn/easyrsa/keys/${name}.crt" ]; then
        echo "User 已創立過，請重新確認。"
        exit
    else
        cd /etc/openvpn/easyrsa
        source ./vars
        bash build-key ${name}
    fi 

    if [ -d ${user_dir} ]; then
        echo "使用者資料夾已存在，請確認。"
        exit
    else
        mkdir ${user_dir}
    fi

    cp /etc/openvpn/client/gomaji.ovpn ${user_vpn_file}

    tail -n 29 /etc/openvpn/easyrsa/keys/${name}.crt | while read crt_f
    do
        sed -i "/<\/cert>/i ${crt_f}" ${user_vpn_file}
    done

    cat /etc/openvpn/easyrsa/keys/${name}.key | while read key_f
    do
        sed -i "/<\/key>/i ${key_f}" ${user_vpn_file}
    done
    
    echo "ifconfig-push 192.168.14.${ipc} 255.255.255.0" > ${user_ccd}
        
    cd /etc/openvpn/client/
    zip -q -P ${pwd12} ${file_vpn} ${user_vpn_file2}

    echo -e "\nVPN 連線請參考【二、OpneVPN 連線】設定 : URI\n解壓縮密碼另寄。" | EMAIL="GOMAJI<no-reply@gomaji.com>" mutt -s "VPN 連線資訊" -a ${file_vpn} -- ${usermail}
    echo -e "\n解壓縮密碼:${pwd12}" | EMAIL="GOMAJI<no-reply@gomaji.com>" mutt -s "VPN 解壓縮密碼。" -- ${usermail}
    rm -f ${file_vpn}
fi
