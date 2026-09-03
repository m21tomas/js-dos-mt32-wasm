# js-dos-mt32-wasm

A standalone WebAssembly (WASM) build of **munt (mt32emu)** for browser-based Roland MT-32 synthesis, tailored for `js-dos` integration and standalone Web Audio projects.

## Features

* **C++ Emscripten Bridge:** Clean C-style API exposing direct MIDI, SysEx, and 16-bit PCM buffer rendering functions.
* **TypeScript Definitions:** Complete `d.ts` typing out-of-the-box.
* **Sample Rate Flexibility:** Supports standard Web Audio sample rates (e.g., 44100 Hz, 48000 Hz).
* **Zero Heavy Dependencies:** Lightweight bridge that handles raw binary ROMs and real-time audio generation.

## Installation & Requirements

### Installation

`npm install git+https://github.com/m21tomas/js-dos-mt32-wasm.git`

### ROM Requirements

To initialize the MT-32 synth engine, you need two Roland MT-32 ROM files placed in your public directory or fetched as array buffers:
* MT32_CONTROL.ROM (64 KB)
* MT32_PCM.ROM (512 KB)

## Quick Start (TypeScript / Web Audio)

```typescript
import { Mt32Engine } from 'js-dos-mt32-wasm';

const engine = new Mt32Engine();

async function initSynth() {
  // 1. Fetch ROMs as ArrayBuffers
  const [ctrlRom, pcmRom] = await Promise.all([
    fetch('/MT32_CONTROL.ROM').then(r => r.arrayBuffer()),
    fetch('/MT32_PCM.ROM').then(r => r.arrayBuffer())
  ]);

  // 2. Load the Emscripten WASM module
  const mod = await import('js-dos-mt32-wasm/dist/mt32emu.js');
  const createModule = mod.default || mod.createMT32Module;

  // 3. Initialize Engine
  await engine.init(createModule, ctrlRom, pcmRom, {
    sampleRate: 44100,
    wasmBinaryPath: './node_modules/js-dos-mt32-wasm/dist/mt32emu.wasm'
  });

  console.log('MT-32 Engine initialized!');
}

// 4. Send MIDI events or SysEx blocks
function sendMidiMessage(status: number, data1: number, data2: number) {
  engine.sendMidiShort(status, data1, data2);
}

function sendSysExData(bytes: Uint8Array) {
  engine.sendSysEx(bytes);
}

// 5. Render PCM Audio inside a Web Audio callback
function processAudio(leftChannel: Float32Array, rightChannel: Float32Array) {
  engine.renderAudio(leftChannel, rightChannel, leftChannel.length);
}
```

## Low-Level C++ Bridge API

For host environments like `js-dos` or direct C++ / Emscripten wrappers, the underlying WASM exports C-compatible interface functions:

| Function | Parameters | Description |
| --- | --- | --- |
| `mt32_init` | `controlRomPtr`, `controlRomSize`, `pcmRomPtr`, `pcmRomSize`, `sampleRate` | Initializes `mt32emu` engine with raw ROM buffers. |
| `mt32_send_midi` | `msg` (uint32_t) | Sends a packed 3-byte short MIDI message. |
| `mt32_send_sysex` | `dataPtr`, `length` | Sends raw SysEx byte sequence. |
| `mt32_render_audio` | `outInterleavedPtr`, `frames` | Renders 16-bit PCM stereo audio into memory. |
| `mt32_free` | None | Disposes of engine instances and frees allocated memory. |

## Integration with `js-dos` (MPU-401 Port `0x330`)

To hook this module into `js-dos` (DOSBox C++ engine):

1. Intercept write events to MPU-401 data/command registers (`0x330` / `0x331`).
2. Pass raw MIDI bytes or SysEx buffers directly to `mt32_send_midi` / `mt32_send_sysex`.
3. Route rendered PCM stereo buffers from `mt32_render_audio` into the host Web Audio `AudioWorkletNode`.

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.

## Acknowledgments

* **munt (mt32emu):** The underlying Roland MT-32 emulation engine developed by the Munt Team.
* **js-dos:** Alexandr Guryanov and the `js-dos` / `dos.zone` community for pioneering DOS emulation in WebAssembly.