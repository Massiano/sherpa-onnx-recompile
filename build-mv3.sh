#!/bin/bash
set -e

# Clean previous builds
rm -rf build-mv3 dist-mv3
mkdir build-mv3 dist-mv3
cd build-mv3

# 1. Define strict Emscripten flags for Manifest V3 compliance
# -s DYNAMIC_EXECUTION=0  -> Kills eval() (CRITICAL)
# -s ENVIRONMENT=web,worker -> Limits target to browser/worker
export LDFLAGS=" \
  -s DYNAMIC_EXECUTION=0 \
  -s TEXTDECODER=2 \
  -s MODULARIZE=1 \
  -s EXPORT_ES6=1 \
  -s EXPORT_NAME='SherpaOnnx' \
  -s ENVIRONMENT='web,worker' \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s MAXIMUM_MEMORY=4GB \
  -s WASM=1 \
  -s SINGLE_FILE=0 \
  -O3 \
"

# 2. Configure with CMake
emcmake cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=./install \
  -DBUILD_SHARED_LIBS=OFF \
  -DSHERPA_ONNX_ENABLE_PYTHON=OFF \
  -DSHERPA_ONNX_ENABLE_TESTS=OFF \
  -DSHERPA_ONNX_ENABLE_C_API=ON \
  -DSHERPA_ONNX_ENABLE_WASM_ASR=ON \
  -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
  ..

# 3. Build
emmake make -j$(nproc)

# 4. Extract Artifacts
# We need to flatten the directory structure for the extension
cp bin/wasm/asr/sherpa-onnx-wasm-asr.js ../dist-mv3/
cp bin/wasm/asr/sherpa-onnx-wasm-asr.wasm ../dist-mv3/

echo "✅ Build Success! Artifacts are in /dist-mv3"
