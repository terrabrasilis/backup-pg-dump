#!/bin/bash
#
# Used to backup all TerraBrasilis databases.
#
CONF_FILE=${1}
DATA_DIR=${2}
INSTALL_PATH=${3}
# load settings to the each SGDB host.
. "${INSTALL_PATH}/dbconf.sh" "${DATA_DIR}/config/${CONF_FILE}"

BACKUP_DIR=${DATA_DIR}

ACT_DATE=$(date '+%d-%m-%Y')

FILTER_FREQUENCY=$(echo ${FREQUENCY} | tr '[:upper:]' '[:lower:]')
PG_QUERY="SELECT database_name, need_vacuum FROM public.databases_for_bkp"
PG_QUERY="${PG_QUERY} WHERE ${FILTER_FREQUENCY}"

COMPRESSION="9"
PG_FILTER="--tuples-only -P format=unaligned "
BACKUP_OPTIONS="${PG_CON} -b -C -F c -Z ${COMPRESSION}"
VACUUM_OPTIONS="${PG_CON} -e"

if [[ ! -d "${BACKUP_DIR}/${CONF_FILE}" ]]; then
  mkdir ${BACKUP_DIR}/${CONF_FILE}
fi

BACKUP_DIR="${BACKUP_DIR}/${CONF_FILE}"
LOGFILE="${BACKUP_DIR}/pg_backup_${ACT_DATE}.log"

echo "***** DB_BACKUP ${ACT_DATE} *****" >> ${LOGFILE}
for db in `echo -e ${PG_QUERY} |${PG_BIN}/psql --dbname=postgres ${PG_CON} ${PG_FILTER} | sed /\eof/p | grep -v rows\) | awk {'print $1'}`
  do
    DB_NAME=$(echo ${db} | cut -d'|' -f1)
    NEED_VACUUM=$(echo ${db} | cut -d'|' -f2)

    # vacuum
    if [[ "t" = "${NEED_VACUUM}" ]]; then
      echo $(date '+%c')" -- run vacuum on ${DB_NAME} database" >> ${LOGFILE}
      if ${PG_BIN}/vacuumdb ${VACUUM_OPTIONS} ${DB_NAME}
        then
        echo "Vacuum ran normally on the database" >> ${LOGFILE}
      else
        echo "Database vacuum failure" >> ${LOGFILE}
      fi;
    else
      echo "Vacuum in database is disabled." >> ${LOGFILE}
    fi;
    # backup
    echo $(date '+%c')" -- perform backup on ${DB_NAME} database" >> ${LOGFILE}
    if  ${PG_BIN}/pg_dump ${BACKUP_OPTIONS} -f ${BACKUP_DIR}/${DB_NAME}-${ACT_DATE}.backup ${DB_NAME}
      then
      echo "Backup was created:${DB_NAME}-${ACT_DATE}.backup" >> ${LOGFILE}
    else
      echo "Database ${DB_NAME} not backuped!" >> ${LOGFILE}
    fi;
  done