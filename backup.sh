#!/bin/bash
# Absolute path to this script.
SCRIPTPATH=$(readlink -f $0)
# Absolute path this script dir.
SCRIPTDIR=`dirname $SCRIPTPATH`

NAME="backup-"$(date +%Y%m%d%H%I%S)
DIR=/tmp/backup/${NAME}
TARGET_HOST=user@example.com
mkdir -p ${DIR}
cd ${DIR}
if  ${SCRIPTDIR}/backup-db.sh -o "${DIR}" -d "database_name_1 database_name_2 database_name_3"
then
tar -cjf "/tmp/${NAME}.tar.bz2" .

# Upload to server
rsync -t "/tmp/${NAME}.tar.bz2" ${TARGET_HOST}:~/backups/${NAME}.tar.bz2

# Remove more than 30 days old
ssh ${TARGET_HOST}  'if [ $(ls -l ~/backups/ | wc -l) -gt 30 ]; then find ~/backups/ -type f -mtime +1 | xargs rm -rf {}; fi'
fi

rm /tmp/${NAME}.tar.bz2
rm -rf /tmp/backup/${NAME}
