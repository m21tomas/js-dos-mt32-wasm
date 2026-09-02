#include "mt32/c_interface/c_interface.h"
#include <emscripten/emscripten.h>
#include <vector>
#include <cstdint>

static mt32emu_context context = nullptr;
static std::vector<int16_t> pcm_buffer;

extern "C" {

EMSCRIPTEN_KEEPALIVE
int mt32_init(uint32_t sample_rate) {
    if (context) {
        mt32emu_free_context(context);
        context = nullptr;
    }
    mt32emu_report_handler_i report_handler = {};
    context = mt32emu_create_context(report_handler, nullptr);
    if (!context) return 0;
    return 1;
}

EMSCRIPTEN_KEEPALIVE
int mt32_load_roms(const uint8_t* ctrl, size_t ctrl_len, const uint8_t* pcm, size_t pcm_len) {
    if (!context) return 0;
    mt32emu_add_rom_data(context, ctrl, ctrl_len, nullptr);
    mt32emu_add_rom_data(context, pcm, pcm_len, nullptr);
    return mt32emu_open_synth(context) == 0;
}

EMSCRIPTEN_KEEPALIVE
void mt32_send_midi(uint32_t msg) {
    if (context) {
        mt32emu_play_msg(context, msg);
    }
}

EMSCRIPTEN_KEEPALIVE
void mt32_send_sysex(const uint8_t* data, uint32_t len) {
    if (context) {
        mt32emu_play_sysex(context, data, len);
    }
}

EMSCRIPTEN_KEEPALIVE
void mt32_render_audio(float* out_l, float* out_r, int frames) {
    if (!context) return;
    pcm_buffer.resize(frames * 2);
    mt32emu_render_bit16s(context, reinterpret_cast<mt32emu_bit16s*>(pcm_buffer.data()), frames);
    
    for (int i = 0; i < frames; ++i) {
        out_l[i] = pcm_buffer[i * 2] / 32768.0f;
        out_r[i] = pcm_buffer[i * 2 + 1] / 32768.0f;
    }
}

EMSCRIPTEN_KEEPALIVE
void mt32_free() {
    if (context) {
        mt32emu_free_context(context);
        context = nullptr;
    }
}

}