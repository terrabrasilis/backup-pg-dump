#!/bin/bash
#
# Used to backup all TerraBrasilis databases.
#

LOGFILE="$DATA_DIR/pg_backup.log"
BACKUP_DIR=$DATA_DIR

ACT_DATE=$(date '+%d-%m-%Y')
EXP_DATE=$(date -d '1 day ago' '+%d-%m-%Y')

COMPRESSION="9"
PG_FILTER="--tuples-only -P format=unaligned"
PG_QUERY="SELECT datname FROM pg_database WHERE NOT datistemplate AND datname <> 'postgres';"
BACKUP_OPTIONS="$PG_CON -b -C -F c -Z $COMPRESSION"
VACUUM_OPTIONS="$PG_CON -e"

if [[ ! -d "$BACKUP_DIR/$1" ]]; then
  mkdir $BACKUP_DIR/$1
fi

BACKUP_DIR="$BACKUP_DIR/$1"

echo "***** DB_BACKUP $ACT_DATE *****" >>$LOGFILE
for db in `echo -e $PG_QUERY |$PG_BIN/psql --dbname=postgres $PG_CON $PG_FILTER | sed /\eof/p | grep -v rows\) | awk {'print $1'}`
  do
    # vacuum
    echo $(date '+%c')" -- vacuuming database $db" >> $LOGFILE
    if $PG_BIN/vacuumdb $VACUUM_OPTIONS $db
      then
      echo "OK!" >>$LOGFILE
    else
      echo "No Vacuum in database $db!" >>$LOGFILE
    fi
    # backup
    echo $(date '+%c')" -- backing up database $db" >>$LOGFILE
    if  $PG_BIN/pg_dump $BACKUP_OPTIONS -f $BACKUP_DIR/$db-$ACT_DATE.backup $db
      then
        if [[ -f $BACKUP_DIR/$db-$EXP_DATE.backup ]]; then
          echo "OK, deleting old backup" >>$LOGFILE
          rm $BACKUP_DIR/$db-$EXP_DATE.backup
        fi
    else
      echo "Database $db not backuped!" >>$LOGFILE
    fi
  done
