#!/bin/bash

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
source /usr/local/script/backup_oa/main.def.sh

echo '開始刪除時間: '$(date +%F_%T)
#從 Google Drive 刪除一年前的檔案

gdrive_list_file=${tmp_dir}"/04_admindrive_backupfiles_delete.list.tmp"

# 撈出 erp-db 刪除名單
gdrive list -m max --no-header --name-width 60 | grep $(date --date="1 year ago" +%F | sed -e 's/-/_/g') | awk '{print $1}' > ${gdrive_list_file} 

# 撈出 hrm-db 刪除名單
gdrive list -m max --no-header --name-width 60 | grep $(date --date="1 year ago" +%F | sed -e 's/-//g') | awk '{print $1}' >> ${gdrive_list_file}

cat ${gdrive_list_file} | while read glist
do
    gdrive delete ${glist}
done
echo '刪除完成時間: '$(date +%F_%T)
