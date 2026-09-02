#!/bin/bash
set -e

echo "Starting MT-32 WASM build..."

# Ensure the output directory exists
mkdir -p ../dist

# Collect all MT-32 C++ sources excluding SamplerateAdapter and SoxrAdapter
MT32_SOURCES=$(find mt32 -name "*.cpp" | grep -vE 'SamplerateAdapter|SoxrAdapter')

# Compile C++ source code into WebAssembly via Emscripten
em++ -O3 -std=c++17 \
  -I. \
  -I./mt32 \
  mt32_wasm_bridge.cpp \
  $MT32_SOURCES \
  -s WASM=1 \
  -s EXPORTED_RUNTIME_METHODS='["cwrap", "getValue", "setValue", "HEAPU8", "HEAPF32"]' \
  -s EXPORTED_FUNCTIONS='["_mt32_init", "_mt32_load_roms", "_mt32_send_midi", "_mt32_send_sysex", "_mt32_render_audio", "_mt32_free", "_malloc", "_free"]' \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s MODULARIZE=1 \
  -s EXPORT_NAME='createMT32Module' \
  -o ../dist/mt32emu.js

echo "Build complete! Output generated in dist/mt32emu.js and dist/mt32emu.wasm"