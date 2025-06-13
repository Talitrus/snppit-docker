# Use Ubuntu as base image for compatibility and standard build tools
FROM --platform=$BUILDPLATFORM ubuntu:24.04

# Set metadata
LABEL maintainer="Bryan Nguyen"
LABEL description="SNPPIT - SNP Program for Intergenerational Tagging"
LABEL version="1.0"

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
        gcc \
        libc6-dev \
        make \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /usr/src/snppit

# Copy source code
COPY src/ ./src/
COPY shared/ ./shared/
COPY Compile_snppit.sh ./

# Build arguments for cross-compilation
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Make compile script executable and build the program
RUN chmod +x Compile_snppit.sh && \
    ./Compile_snppit.sh && \
    mv snppit-Linux /usr/local/bin/snppit

# Create directory for input/output files
WORKDIR /data

# Set the entrypoint to snppit
ENTRYPOINT ["snppit"]

# Default command shows help
CMD ["--help-full"]
