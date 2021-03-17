#!/bin/bash
source /etc/environment
DATA_DIR=$SHARED_DIR
cd $INSTALL_PATH/

for CONF_FILE in `ls $DATA_DIR/config/ | awk {'print $1'}`
do
  echo "$CONF_FILE"
  # load settings to the each SGDB host.
  . ./dbconf.sh "$DATA_DIR/config/$CONF_FILE"
  . ./dump_terrabrasilis_dbs.sh
done