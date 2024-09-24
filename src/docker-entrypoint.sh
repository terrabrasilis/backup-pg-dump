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
    # used to append as filter in SQL to read the target databases
    echo "export FREQUENCY=daily" >> /etc/environment
else
    cp ${INSTALL_PATH}/weekly.cron /etc/crontabs/root
    echo "enable weekly cron job"
    # used to append as filter in SQL to read the target databases
    echo "export FREQUENCY=weekly" >> /etc/environment
fi;
chmod +x /etc/crontabs/root

# Start cron daemon.
crond -f -l 8
