#--------- Generic stuff all our Dockerfiles should start -----------------------------------
FROM alpine:3.13

LABEL "br.inpe.dpi"="INPE/DPI-TerraBrasilis"
LABEL br.inpe.dpi.terrabrasilis="microservice"
LABEL author="Andre Carvalho"
LABEL author.email="andre.carvalho@inpe.br"
LABEL description="This microservice provides backup routines. \
No ports are exposed, runs only autonomous job via cron."
#-------------Application Specific Stuff ----------------------------------------------------

RUN apk update \
  && apk add --no-cache --update \
    bash \
    postgresql-client \
    dcron \
    coreutils \
    tzdata \
    && rm -rf /var/cache/apk/*

# define the timezone to run cron
ENV TZ=America/Sao_Paulo

# define the install and shared paths
ENV INSTALL_PATH /usr/local
ENV SHARED_DIR /data

## THE ENV VARS ARE NOT READED INSIDE A SHELL SCRIPT THAT RUNS IN CRON TASKS.
## SO, WE WRITE INSIDE THE /etc/environment FILE AND READS BEFORE RUN THE SCRIPT.
RUN echo "export SHARED_DIR=\"${SHARED_DIR}\"" >> /etc/environment \
    && echo "export INSTALL_PATH=\"${INSTALL_PATH}\"" >> /etc/environment \
    && echo "export TZ=America/Sao_Paulo" >> /etc/environment

COPY ./*.sh ${INSTALL_PATH}/
COPY ./cron/*.* ${INSTALL_PATH}/

RUN chmod +x /usr/local/*.sh

# expose shared dir
VOLUME ["${SHARED_DIR}"]

WORKDIR ${INSTALL_PATH}

ENTRYPOINT ["./docker-entrypoint.sh"]