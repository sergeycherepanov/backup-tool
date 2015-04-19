#!/bin/bash
OUTPUT_FILENAME="db-"$(date +%Y%m%d%H%I%S)".sql"
OUTPUT_DIR="."

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -h|--host)
    DB_HOST="$2"
    shift
    ;;
    -hp|--port)
    DB_PORT="$2"
    shift
    ;;
    -u|--user)
    DB_USER="$2"
    shift
    ;;
    -p|--password)
    DB_PASSWORD="$2"
    shift
    ;;
    -d|--databases)
    DB_NAMES="$2"
    shift
    ;;
    -o|--output-dir)
    OUTPUT_DIR="$2"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
shift
done


if [ ! -d ${OUTPUT_DIR} ]; then
    mkdir -p ${OUTPUT_DIR}
fi

if [ -z "${DB_NAMES}" ]; then
  echo "Usage: $0 -h <mysql_hostname> -hp <mysql_port> -u <mysql_user> -p <mysql_password> -d \"<database_name1> [database_name2 ...]\""
  exit 1
fi

if mysqldump --host="${DB_HOST}" --port="${DB_PORT}" --user="${DB_USER}" --password="${DB_PASSWORD}" --databases ${DB_NAMES} > ${OUTPUT_DIR}/${OUTPUT_FILENAME}; then
  echo "Database saved successfully to ${OUTPUT_DIR}/${OUTPUT_FILENAME}"
else
  echo "Can't create database dump!"
  exit 1;
fi

