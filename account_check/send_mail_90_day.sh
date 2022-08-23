#!/bin/bash
####################################
# 每季寄送 Backend 90 天未登入人員通知
####################################

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

mailtmplst=/usr/local/script/backend/tmp/backend.lst #mail內容
user_lst_file=/usr/local/script/backend/lst/backend.lst   #mail_user名單來源
mail_from='' #寄件者屬名

if [ ! -f ${user_lst_file} ]; then
    echo ${user_lst_file}' 名單檔不存在'
    exit
else
    cat ${user_lst_file} | while read userid username date_login
    do
        printf "Hi %s：\n\n" ${userid} > ${mailtmplst}
        printf "\t你(妳)的 Backend 後台的帳號因超過 90 天未使用，如下：\n" >> ${mailtmplst}
        printf "\t帳號：%s (%s)\n" ${userid} ${username} >> ${mailtmplst}
        printf "\t最後一次登入時間：%s \n" ${date_login} >> ${mailtmplst}
        printf "\n" >> ${mailtmplst}
        printf "\t請於 $(date --date='7 days' +%F) 前檢視：\n" >> ${mailtmplst}
        printf "\t1、若需要保留帳號，請登入一次系統。\n" >> ${mailtmplst}
        printf "\t2、若不需保留請回覆「可刪除」。\n" >> ${mailtmplst}
        printf "\t3、若沒回覆，則系統將變更密碼，你(妳)可使用「忘記密碼」功能，將密碼重設取回登入權限。\n\n" >> ${mailtmplst}
        printf "系統帳號管理 $(date +%F)" >> ${mailtmplst}

        email=${userid}'@gomaji.com'
        echo "cat \"${mailtmplst}\" |EMAIL=\"${mail_from}\" mutt -s \"[通知] ${username}，你(妳)的 Backend 後台的帳號因超過 90 天未使用，請檢視。\" -- ${email}"
        cat "${mailtmplst}" |EMAIL="${mail_from}" mutt -s "[通知] ${username}，你(妳)的 Backend 後台的帳號因超過 90 天未使用，請檢視。" -- ${email}
    done

    # 更名
    mv ${user_lst_file} ${user_lst_file}.$(date +%Y%m%d_%H%M%S).done
fi
exit;
