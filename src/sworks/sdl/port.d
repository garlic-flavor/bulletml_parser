/**
 * Version:    0.0003(dmd2.069)
 * Date:       2016-Jan-16 00:50:56
 * Authors:    KUMA
 * License:    CC0
*/
module sworks.sdl.port;

public import derelict.sdl2.sdl;

version (linux)
{ // 分割コンパイルする場合は、-L-ldl -L-lDerelictUtil -L-lDerelictSDL をdmdに渡す
    pragma(lib, "dl");
    pragma(lib, "DerelictUtil");
    pragma(lib, "DerelictSDL2");
}

enum Uint32 SDL_INIT_EVENTS = 0x00004000;

enum
{
    SDL_APP_TERMINATING = 0x101,
    SDL_APP_LOWMEMORY,
    SDL_APP_WILLENTERBACKGROUND,
    SDL_APP_DIDENTERBACKGROUND,
    SDL_APP_WILLENTERFOREGROUND,
    SDL_APP_DIDENTERFOREGROUND,

    SDL_RENDER_TARGETS_RESET = 0x2000,
    SDL_RENDER_DEVICE_RESET
}

enum : Uint32
{
    SDL_RWOPS_UNKNOWN,
    SDL_RWOPS_WINFILE,
    SDL_RWOPS_STDFILE,
    SDL_RWOPS_JINFILE,
    SDL_RWOPS_MEMORY,
    SDL_RWOPS_MEMORY_RO,
}
