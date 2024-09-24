#!/bin/bash
source /etc/environment
DATA_DIR=$SHARED_DIR
cd $INSTALL_PATH/

for CONF_FILE in `ls $DATA_DIR/config/ | awk {'print $1'}`
do
  /bin/bash ./dump_terrabrasilis_dbs.sh "${CONF_FILE}" "${DATA_DIR}" "${INSTALL_PATH}" &
done

# to remove old files
find ${DATA_DIR}/${FREQUENCY}/* -mtime +${DAYS_TO_KEEP} -type f -delete
