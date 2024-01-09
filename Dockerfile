FROM ubuntu:20.04

# Set environment variables to non-interactive (this will prevent some prompts)
ENV DEBIAN_FRONTEND=non-interactive

VOLUME /source_tile_cache

# Install required dependencies and utilities
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:rmescandon/yq && \
    apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    git \
    build-essential \
    libsqlite3-dev \
    zlib1g-dev \
    gdal-bin \
    yq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Tippecanoe
RUN git clone https://github.com/felt/tippecanoe.git && \
    cd tippecanoe && \
    make -j && \
    make install

# Set the working directory
WORKDIR /data

# Copy script and config to the container
COPY make-tiles.sh config.yml /data/

# Give execution permissions to the script
RUN chmod +x /data/make-tiles.sh

# Run the script on container start, assuming the local directory will be mounted to /output_directory
ENTRYPOINT ["./make-tiles.sh"]
