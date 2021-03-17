#!/bin/sh

# Start cron daemon.
crond -f -l 8

# Start application.