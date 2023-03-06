#!/bin/sh
#
# load environment vars
source /etc/environment

# install and enable cron job scripts
# using config $FREQUENCY env var from compose file to setup cron frequency
if [[ "DAILY" = "${FREQUENCY}" ]];
then
    cp ${INSTALL_PATH}/daily.cron /etc/crontabs/root
    echo "enable daily cron job"
else
    cp ${INSTALL_PATH}/weekly.cron /etc/crontabs/root
    echo "enable weekly cron job"
fi;
chmod +x /etc/crontabs/root

# Start cron daemon.
crond -f -l 8
