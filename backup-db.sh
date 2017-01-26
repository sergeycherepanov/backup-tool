#!/usr/bin/env bash
[[ "Linux" != $(uname) ]] &&  { 
  echo "Unsupported Operation System: $(uname)" 
  exit 1
}

PIDFILE=/tmp/backup-fs.pid

# Resolve current script dir
cd `dirname $0` && DIR=$(pwd) && cd - > /dev/null
source ${DIR}/config.sh

TIMESTAMP=$(date +%Y%m%d%H%I%S)
PREFIX="db"
SAVEDIR=${SAVEDIR-'/srv/backup'}/${PREFIX}

mkdir -p ${SAVEDIR}

trace () {
    echo $(date '+%Y-%m-%dT%H:%M:%S.%3N')": $*"
}

error () {
    echo $(date '+%Y-%m-%dT%H:%M:%S.%3N')": $*"
    exit 1
}

# Check is already running
[[ -f ${PIDFILE} ]] && ps aux | grep -v grep | awk '{print $5}' | grep '^'$(cat ${PIDFILE})'$' && error "Already running!"

echo $$ > ${PIDFILE}

trace "------------------------------------"
trace "Mysqldump started, destination file: ${SAVEDIR}/${TIMESTAMP}-db.sql"

(MYSQL_PWD=${DB_PASS} mysqldump --single-transaction -h${DB_HOST} -u${DB_USER} ${DB_NAME} > ${SAVEDIR}/${TIMESTAMP}-db.sql) || {
    error "Can't create dump!"
}

trace "Mysqldump complete, file size: " $(du -sh ${SAVEDIR}/${TIMESTAMP}-db.sql)
trace "------------------------------------"
trace "Compressing of dump started, destination file: ${SAVEDIR}/${TIMESTAMP}-db.sql"

gzip -2f ${SAVEDIR}/${TIMESTAMP}-db.sql || {
    error "Can't compress dump!"
}
trace "Compressing complete, file size: " $(du -sh ${SAVEDIR}/${TIMESTAMP}-db.sql.gz)
trace "------------------------------------"

trace "Uploading to storage ($STORAGE_PROVIDER)"

${STORAGE_CMD} cp ${SAVEDIR}/${TIMESTAMP}-db.sql.gz ${PREFIX}/${TIMESTAMP}-db.sql.gz || {
    error "Can't upload db!"
}

trace "Uploading to storage complete"
trace "------------------------------------"

trace "Clear ald backups"

timeout="31 days"
olderThan=`date -d"-$timeout" +%s`
${STORAGE_CMD} ls ${PREFIX}/ | grep -v "^\s*DIR" | while read -r line; do
    createDate=`echo "$line" | awk {'print $1" "$2'}`
    echo $createDate;
    createDate=`date -d"$createDate" +%s`
    if [[ ${createDate} -lt ${olderThan} ]]; then
        fileName=`echo "$line" | awk {'print $4'}`
        fileId=`echo "$line" | awk {'print $5'}`
        echo "Deleting: $fileName ($fileId)"
        if [[ ${fileName} != "" ]]; then
            ${STORAGE_CMD} del "$fileName" "$fileId"
        fi
    fi
done;

trace "------------------------------------"

trace "Cleanup"
rm ${SAVEDIR}/${TIMESTAMP}-db.sql.gz

trace "------------------------------------"
trace "Complete"
trace "------------------------------------"
