#!/bin/bash
set -e

# Clean previous builds
rm -rf build-mv3 dist-mv3
mkdir build-mv3 dist-mv3
cd build-mv3

# --- CRITICAL AUTHOR FLAG ---
# This forces the CMakeLists.txt to download the pre-compiled
# onnxruntime-web-assembly static libraries.
export SHERPA_ONNX_IS_USING_BUILD_WASM_SH=ON

# --- MV3 & OPTIMIZATION FLAGS ---
# -s DYNAMIC_EXECUTION=0  -> Required for MV3 (No 'eval')
# -msimd128               -> Required for performance (Matches author's 'simd' build)
# -s ENVIRONMENT=...      -> restricts to web/worker
export LDFLAGS=" \
  -s DYNAMIC_EXECUTION=0 \
  -msimd128 \
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

echo "Configuring CMake..."

# Matches author's standard cmake invocation but with our MV3 flags injected
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

echo "Building..."
emmake make -j$(nproc)

# Organize Output
echo "Copying artifacts..."
cp bin/wasm/asr/sherpa-onnx-wasm-asr.js ../dist-mv3/
cp bin/wasm/asr/sherpa-onnx-wasm-asr.wasm ../dist-mv3/

echo "✅ Build Complete. Artifacts in dist-mv3/"
