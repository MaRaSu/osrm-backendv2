FROM ghcr.io/project-osrm/osrm-backend:v5.27.1

COPY foot.lua /opt/foot.lua
COPY road-bike.lua /opt/road-bike.lua
COPY gravel-bike.lua /opt/gravel-bike.lua
COPY mtb.lua /opt/mtb.lua
COPY safe-bike.lua /opt/safe-bike.lua

WORKDIR /opt

EXPOSE 5000
