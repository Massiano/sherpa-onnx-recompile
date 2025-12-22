# Use a specific, stable version of Emscripten known to work with ONNX/Sherpa
FROM emscripten/emsdk:3.1.50

# Install necessary build tools
# cmake is usually in the base image, but we ensure git/python are there
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# We don't COPY the source yet to keep the image generic if you want to cache it.
# The source will be mounted or copied during the GitHub Action.

# Default command runs the build script
CMD ["/bin/bash", "./build-mv3.sh"]
