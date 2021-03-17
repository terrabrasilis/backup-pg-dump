# Backing up PostgreSQL

Used to perform vacuum and dump on all databases for hosts defined by the pgconfig files within the config directory.

No ports are exposed, runs only autonomous job via cron.

### Run container manually

```sh
docker run -d --rm --name backup_pg \
-v /volume/directory:/data \
terrabrasilis/backup-pg-dump:v1.0.0
```