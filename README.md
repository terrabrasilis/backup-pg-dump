# Backing up PostgreSQL

Used to perform vacuum and dump on all databases for hosts defined by the pgconfig files within the config directory.

No ports are exposed, runs only autonomous job via cron.

## Configuration

We have two configurations to make this script work.

Define a directory to store your backup files and include a configuration file for each SGDB host that you need to back up.

The data storage directory is used to map to a volume inside the container, see the docker-compose.yml file or the manual container run session.

The script expects a configuration subdirectory within the data store directory where the configuration files are placed.

### SGDB hosts configuration

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

## Defining the task scheduling

The backup schedule is now set to run weekly. To change this behavior, you must change the weekly.cron file and rebuild the image.

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