#!/bin/sh
#
# load environment vars
source /etc/environment

# How many days to keep backups and logs?
# Use the DAYS_TO_KEEP to change via env var
if [[ ! "${DAYS_TO_KEEP}" = "" ]];
then
    echo "export DAYS_TO_KEEP=${DAYS_TO_KEEP}" >> /etc/environment
fi;

# install and enable cron job scripts
# using config $FREQUENCY env var from compose file to setup cron frequency
if [[ "DAILY" = "${FREQUENCY}" ]];
then
    cp ${INSTALL_PATH}/daily.cron /etc/crontabs/root
    echo "enable daily cron job"
    # used to append as filter in SQL to read the target databases
    echo "export FREQUENCY=daily" >> /etc/environment
    # if no defined, use default to each frequency
    if [[ "${DAYS_TO_KEEP}" = "" ]];
        echo "export DAYS_TO_KEEP=45" >> /etc/environment
    fi;
else
    cp ${INSTALL_PATH}/weekly.cron /etc/crontabs/root
    echo "enable weekly cron job"
    # used to append as filter in SQL to read the target databases
    echo "export FREQUENCY=weekly" >> /etc/environment
    # if no defined, use default to each frequency
    if [[ "${DAYS_TO_KEEP}" = "" ]];
        echo "export DAYS_TO_KEEP=60" >> /etc/environment
    fi;
fi;
chmod +x /etc/crontabs/root

# Start cron daemon.
crond -f -l 8
