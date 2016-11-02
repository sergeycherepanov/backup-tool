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
PREFIX="fs"
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
[[ -f ${PIDFILE} ]] && ps aux | grep $(cat ${PIDFILE}) && error "Already running!"

echo $$ > ${PIDFILE}

trace "------------------------------------"
trace "Create tar archive"
SAVED_TAR=$(SAVEDIR=${SAVEDIR} INTAR=${DIR}/list-include.txt EXTAR=${DIR}/list-exclude.txt ${DIR}/tar-increment.sh) || {
  error "Can't tar!"
}

trace "Tar completed, file size: " $(du -sh ${SAVED_TAR})
trace "------------------------------------"

trace "Uploading to storage ($STORAGE_PROVIDER)"

${STORAGE_CMD} cp ${SAVED_TAR} ${PREFIX}/$(basename ${SAVED_TAR}) || {
    error "Can't upload fs!"
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
rm ${SAVED_TAR}

trace "------------------------------------"
trace "Complete"
trace "------------------------------------"
