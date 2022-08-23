#!/bin/bash
###########################################
# 每天同步一次 RS814 備份資料至 Old NetApp
###########################################

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
source /usr/local/script/backup_oa/main.def.sh
rs814_sour_list="${lst_dir}/rsync_dir_RS814.lst"

# 檢查來源資料夾掛載狀態
mou_rs814_status=$(mount | grep IP | grep RS814 | grep -v Photos | awk '{print $3}' | wc -l)
rs814_sour_quantity=$(awk '{print $1}' ${rs814_sour_list} | wc -l)

if [ ${mou_rs814_status} -ne ${rs814_sour_quantity} ]; then
    echo '/mnt/RS814 掛載數量有差異，排程中止執行'
    exit
fi

# 檢查遠端目的資料夾掛載狀態
destination=''
dest_dir='/vol/nfs_ds'
dest_local='/mnt/nfs_ds'
mou_status=$(mount | awk '($1=="'${destination}:${dest_dir}'")&&($3=="'${dest_local}'"){print $0}' | wc -l)

if [ ${mou_status} -ne '1' ]; then
    echo '/mnt/nfs_ds 沒有掛載遠端目錄，排程中止執行'
    exit
fi

destination02=''
dest_dir02='/vol/nfs_ds'
dest_local02='/mnt/nfs_ds_02'
mou_status02=$(mount | awk '($1=="'${destination02}:${dest_dir02}'")&&($3=="'${dest_local02}'"){print $0}' | wc -l)

if [ ${mou_status02} -ne '1' ]; then
    echo '/mnt/nfs_ds_02 沒有掛載遠端目錄，排程將止執行'
    exit
fi

echo "\nRS814: "$(date +%T)
cat ${rs814_sour_list} | while read sour dest
do
    echo "rsync -avl --delete --exclude '#recycle/'${sour} ${dest}" 
    rsync -avl --delete --exclude '#recycle/' ${sour} ${dest}
done

echo 'End: '$(date +%T)
