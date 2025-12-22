# We use 3.1.53 because the sherpa-onnx build scripts explicitly
# check for this version to match their pre-compiled dependencies.
FROM emscripten/emsdk:3.1.53

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app
RUN chmod +x build-mv3.sh

CMD ["./build-mv3.sh"]
