#!/bin/bash
if [[ -f "$1" ]];
then
  source "$1"
  export PGUSER=$user
  export PGPASSWORD=$password
  PG_BIN="/usr/bin"
  PG_CON=" --port=$port --host=$host "
else
  echo "Missing Postgres config file."
  exit
fi