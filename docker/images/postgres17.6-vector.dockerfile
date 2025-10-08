FROM postgres:17.6-trixie

# Define build dependencies to be removed later
ARG BUILD_DEPS="git build-essential postgresql-server-dev-17"

# Define runtime dependencies
ARG RUN_DEPS="postgis postgresql-17-postgis-3"

RUN apt-get update && \
    apt-get install -y \
        ${BUILD_DEPS} \
        ${RUN_DEPS} && \
    \
    git clone --branch v0.8.0 https://github.com/pgvector/pgvector.git && \
    cd pgvector && \
    make OPTFLAGS="" && \
    make install && \
    cd .. && \
    \
    rm -rf pgvector && \
    apt-get purge -y --auto-remove ${BUILD_DEPS} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*