FROM ghcr.io/project-osrm/osrm-backend:v5.27.1

# Install basics
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
		apt-transport-https gpg ca-certificates \
    curl bash wget less git tar gzip pigz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Minio client
RUN curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x mc && mv mc /usr/local/bin/mc

WORKDIR /opt

COPY foot.lua .
COPY road-bike.lua .
COPY gravel-bike.lua .
COPY mtb.lua .
COPY mtb2.lua .
COPY safe-bike.lua .
COPY lib/trailmap.lua ./lib/


WORKDIR /app
COPY src/ .
RUN chmod +x *.sh

WORKDIR /opt

EXPOSE 5000
