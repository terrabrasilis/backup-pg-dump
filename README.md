# Backing up PostgreSQL

Used to perform vacuum and dump on all databases for hosts defined by the pgconfig files within the config directory.

No ports are exposed, runs only autonomous job via cron.

## Configuration

We have some configurations to make this script work.

Define a directory to store your backup files and include a configuration file for each SGDB host that you need to back up. Look for suggestions in the section "Configuration of DBMS hosts".

The data storage directory is used to map to a volume inside the container, see the docker-compose.yml file or the manual container run session.

The script expects a configuration subdirectory within the data store directory where the configuration files are placed. Look for suggestions in the section "Configuration of DBMS hosts".

Database names and other settings are read from a table within the default postgres database. Look for informations in the section "Defining database names".

Adjust how often this job runs by following the steps in the "Defining Task Schedule" section.

### Configuration of DBMS hosts

Suppose the data storage directory is **/data/**, then we need **/data/config/** as the location to place the SGDB host settings.

 - /data/ (where the backup files and log file is placed)
 - /data/config/ (where the hosts setting files is placed)

The setting file example:
```txt
user="postgres"
host="localhost"
port=5432
password="postgres"
```

We may need more than one host configuration, so repeat the file using a new name.

 - /data/config/host1
 - /data/config/host2
 - /data/config/host3

## Defining database names

Use this table to define the names of the databases for which you want to run the dump or vacuum and dump.
You need to create this table on each server that you want to perform the backup.

```sql
-- Table: public.databases_for_bkp

-- DROP TABLE IF EXISTS public.databases_for_bkp;

CREATE TABLE IF NOT EXISTS public.databases_for_bkp
(
    id serial,
    database_name character varying NOT NULL,
    note character varying,
    created_at date NOT NULL DEFAULT (now())::date,
    need_vacuum boolean NOT NULL DEFAULT true,
    CONSTRAINT databases_for_bkp_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.databases_for_bkp
    OWNER to postgres;

COMMENT ON TABLE public.databases_for_bkp
    IS 'Used to keep the list of databases that should be backed up. See the script into "backup-pg-dump" at https://github.com/terrabrasilis/backup-pg-dump.git';

COMMENT ON COLUMN public.databases_for_bkp.database_name
    IS 'The name of the database that will be backed up';

COMMENT ON COLUMN public.databases_for_bkp.need_vacuum
    IS 'True to run vacuum or false otherwise';
```

## Defining Task Schedule

The backup schedule is set to run weekly by default. To change this behavior you must provide "FREQUENCY=DAILY" as environment variable when running the container.

There are only two options, daily or weekly, the default.

The time is predefined in weekly.cron and daily.cron and will only change if you rebuild your container.

The day of the week is Saturday and you also need to change it directly in the weekly.cron file and rebuild your container.

## Build image

To change the version of the image tag, change the version number within the PROJECT_VERSION file before building.

To build, use the following script.
```sh
./docker-build.sh
```

## Manual container run

Before running, read the configuration session.

Using canonical form.
```sh
docker run -d --rm --name backup_pg \
-v /volume/directory:/data \
terrabrasilis/backup-pg-dump:v<version>
```
Or use the compose file.
```sh
docker-compose -f docker-compose.yml up -d
```