FROM cm2network/steamcmd:root

#LABEL org.opencontainers.image.authors="Sebastian Schmidt"
#LABEL org.opencontainers.image.source="https://github.com/handzcz/docker-palworld-dedicated-server"

RUN apt-get update \
    && apt-get install -y --no-install-recommends procps xdg-user-dirs \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

USER steam

ENV TIMEZONE=UTC \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    ALWAYS_UPDATE_ON_START=false \
    MAX_PLAYERS=16 \
    MULTITHREAD_ENABLED=true \
    COMMUNITY_SERVER=false \
    RCON_ENABLED=true \
    PUBLIC_IP=10.0.0.1 \
    PUBLIC_PORT=8211 \
    SERVER_NAME="Default server name" \
    SERVER_DESCRIPTION="Default server description" \
    SERVER_PASSWORD=NONE \
    ADMIN_PASSWORD=admin \
    BACKUP_ENABLED=true \
    BACKUP_CRON_EXPRESSION="0 * * * *"

VOLUME [ "/palworld" ]

EXPOSE 8211/udp
EXPOSE 25575/tcp

ADD --chmod=777 servermanager.sh /servermanager.sh
ADD --chmod=777 backupmanager.sh /backupmanager.sh

CMD ["/servermanager.sh"]
