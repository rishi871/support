#Ran below script to update all tables to utf8
#Please  change  tgt_db, tgt_user,tgt_pass 
# Login to some server where you have mysql installed

DT=`date +%Y%m%d%H%M%S`

cd /opt/ssp/admin
backup_dir=mysql_backup_${DT}

mkdir $backup_dir

tgt_db=db-***********.us-east-1.rds.amazonaws.com
tgt_user=sch
tgt_pass=********************

mkdir ${backup_dir}/tgt_bkp
cd ${backup_dir}/tgt_bkp

#taking backup
for db in `echo "dynamic_preview jobrunner messaging notification pipelinestore policy provisioning reporting scheduler sdp_classification security sla timeseries topology"`
do
echo "USE $db ;" > ${db}.sql
mysqldump --max_allowed_packet=1G --set-gtid-purged=OFF --single-transaction -u ${tgt_user} -p${tgt_pass} ${db} -h ${tgt_db} -P 3306 >> ${db}.sql
done ;

cd ${backup_dir}

for db in `echo "dynamic_preview jobrunner messaging notification pipelinestore policy provisioning reporting scheduler sdp_classification security sla timeseries topology"`
do
echo "running for ${db}"
echo 'USE `'"$db"'` ;' > ${db}.sql
echo "SET FOREIGN_KEY_CHECKS=0;" >> ${db}.sql
echo 'ALTER DATABASE `'"$db"'` CHARACTER SET utf8 COLLATE utf8_general_ci;' >> ${db}.sql
mysql -u ${tgt_user} -p${tgt_pass} -h ${tgt_db} "$db" -e "SHOW TABLES" --batch --skip-column-names \
| xargs -I{} echo 'ALTER TABLE `'{}'` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;' >> ${db}.sql
echo "SET FOREIGN_KEY_CHECKS=1;" >> ${db}.sql
done ;

for db in `echo "dynamic_preview jobrunner messaging notification pipelinestore policy provisioning reporting scheduler sdp_classification security sla timeseries topology"`
do
echo "Running on ${db}"
mysql -u ${tgt_user} -p${tgt_pass} -h ${tgt_db} < ${db}.sql
done ;
