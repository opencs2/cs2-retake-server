# BUILD STAGE
FROM cm2network/steamcmd:root@sha256:4451abc449bb71a000be3bf6443cdc3a06a3b4291d00bb281b6fa0f6946b7e25 AS build_stage

ENV STEAMAPPID 730
ENV STEAMAPP cs2
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV STEAMAPPVALIDATE 0

COPY etc/entry.sh "${HOMEDIR}/entry.sh"
COPY etc/server.cfg "/etc/server.cfg"
COPY etc/pre.sh "/etc/pre.sh"
COPY etc/post.sh "/etc/post.sh"

RUN set -x \
	# Install, update & upgrade packages
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget \
		ca-certificates \
		lib32z1 \
                simpleproxy \
                libicu-dev \
                unzip \
		jq \
                tar \
                libarchive-tools \
	&& mkdir -p "${STEAMAPPDIR}" \
        # Add entry script
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" \
	# Clean up
        && apt-get clean \
        && find /var/lib/apt/lists/ -type f -delete

# BASE

FROM build_stage AS update_stage

# Set permissions on STEAMAPPDIR
#   Permissions may need to be reset if persistent volume mounted
RUN set -x \
        && chown -R "${USER}:${USER}" "${STEAMAPPDIR}" \
        && chmod 0777 "${STEAMAPPDIR}"

# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

# To test: using this API as a docker cache buster
# ADD https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=730&count=1&maxlength=1
# THIS IS BETTER TO CHECK VERSION UP TO DATE
#ADD https://api.steampowered.com/ISteamApps/UpToDateCheck/v0001/?appid=730&version=1.39.8.1&format=json
ARG buildbuster=bust
RUN ${STEAMCMDDIR}/steamcmd.sh +force_install_dir "${STEAMAPPDIR}" +login anonymous +app_update "${STEAMAPPID}" +quit

FROM update_stage AS bullseye-base

ENV CS2_SERVERNAME="CS2 RETAKES" \
    CS2_CHEATS=0 \
    CS2_IP=0.0.0.0 \
    CS2_SERVER_HIBERNATE=0 \
    CS2_PORT=27015 \
    CS2_RCON_PORT="" \
    CS2_MAXPLAYERS=10 \
    CS2_RCONPW="changeme" \
    CS2_PW="changeme" \
    CS2_MAPGROUP="mg_active" \
    CS2_STARTMAP="de_inferno" \
    CS2_GAMEALIAS="" \
    CS2_GAMETYPE=0 \
    CS2_GAMEMODE=1 \
    CS2_LAN=0 \
    TV_AUTORECORD=0 \
    TV_ENABLE=0 \
    TV_PORT=27020 \
    TV_PW="changeme" \
    TV_RELAY_PW="changeme" \
    TV_MAXRATE=0 \
    TV_DELAY=0 \
    SRCDS_TOKEN="" \
    CS2_CFG_URL="" \
    CS2_LOG="on" \
    CS2_LOG_MONEY=0 \
    CS2_LOG_DETAIL=0 \
    CS2_LOG_ITEMS=0 \
    CS2_ADDITIONAL_ARGS=""

# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

ARG cachebuster=buster
# Install the mods.
RUN wget -qO- https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1314-linux.tar.gz | tar xvz -C "${STEAMAPPDIR}"/game/csgo/ \
        &&  wget -qO- https://github.com/roflmuffin/CounterStrikeSharp/releases/download/v281/counterstrikesharp-with-runtime-build-281-linux-71ae253.zip | bsdtar -xvf- -C "${STEAMAPPDIR}"/game/csgo/ \
        && wget -qO- https://github.com/B3none/cs2-retakes/releases/download/2.0.13/cs2-retakes-2.0.13.zip | bsdtar -xvf- -C "${STEAMAPPDIR}"/game/csgo/addons/counterstrikesharp/plugins/ \
        && wget -qO- https://github.com/B3none/cs2-retakes/releases/download/2.0.13/cs2-retakes-shared-2.0.13.zip | bsdtar -xvf- -C "${STEAMAPPDIR}"/game/csgo/ \
        && wget -qO- https://github.com/B3none/cs2-instadefuse/releases/download/2.0.0/cs2-instadefuse-2.0.0.zip  | bsdtar -xvf- -C "${STEAMAPPDIR}"/game/csgo/addons/counterstrikesharp/plugins/ \
 #       && wget -qO- https://github.com/opencs2/cs2-agones/releases/download/0.0.5/cs2-agones.tar.gz | bsdtar -xvf- -C "${STEAMAPPDIR}"/game/csgo/addons/counterstrikesharp/plugins/ \
        && sed -i '/Game_LowViolence/a \\t\t\tGame\tcsgo/addons/metamod' ${STEAMAPPDIR}/game/csgo/gameinfo.gi

# use for local dev
ADD AgonesPlugin "${STEAMAPPDIR}"/game/csgo/addons/counterstrikesharp/plugins/AgonesPlugin

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 27015/tcp \
	27015/udp \
	27020/udp
