#!/bin/bash
source /etc/environment
DATA_DIR=$SHARED_DIR
cd $INSTALL_PATH/

for CONF_FILE in `ls $DATA_DIR/config/ | awk {'print $1'}`
do
  # load settings to the each SGDB host.
  . ./dbconf.sh "$DATA_DIR/config/$CONF_FILE"
  . ./dump_terrabrasilis_dbs.sh "$CONF_FILE"
done