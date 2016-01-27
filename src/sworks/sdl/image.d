module sworks.sdl.image;

import std.exception : enforce;
import std.string : fromStringz;
public import derelict.sdl2.image;
public import sworks.sdl.util;


SDLExtInitDel getImageInitializer(uint initFlags)
{
    return {
        if (!DerelictSDL2Image.isLoaded)
        {
            DerelictSDL2Image.load();
            enforce(initFlags == IMG_Init(initFlags), "init : failure in IMG_Init");
            return { IMG_Quit(); };
        }
        else
        {
            enforce(initFlags == IMG_Init(initFlags), "init : failure in IMG_Init");
            return { };
        }
    };
}

SDL_Surface* loadImageRGBA32(const(char)* filename)
{
    // load image
    auto image = enforce(IMG_Load(filename),"fail at IMG_Load. about " ~ filename.fromStringz);
    scope(exit) SDL_FreeSurface(image);
    //  SDL_SetAlpha(image,0,0);

    //adjust its format to RGBA32
    auto adj = createSurfaceRGBA32(image.w,image.h);
    SDL_BlitSurface(image,null,adj,null);

    return adj;
}

SDL_Surface* loadImageRGBA32(SDL_RWops* ops)
{
    // load image
    auto image = enforce(IMG_Load_RW(ops, 1),"fail at IMG_Load_RW.");
    scope(exit) SDL_FreeSurface(image);
    //  SDL_SetAlpha(image,0,0);

    //adjust its format to RGBA32
    auto adj = createSurfaceRGBA32(image.w,image.h);
    SDL_BlitSurface(image,null,adj,null);

    return adj;
}

////////////////////XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\\\\\\\\\\\\\\\\\\\\
debug(sdl_image):


scope class SDLTest
{ mixin SDLWindowMix!() SWM;

    SDL_Surface* surface;
    SDL_Texture* texture;

    this()
    {
        SWM.ctor(SDL_INIT_VIDEO, "hello SDL",  640, 480, 0, getImageInitializer(IMG_INIT_JPG));

        surface = enforce(IMG_Load("img\\tex1.jpg"));
        texture = SDL_CreateTextureFromSurface(renderer, surface);
        
        SDL_SetRenderDrawColor(renderer, 0, 200, 0, 255);
        SDL_RenderClear(renderer);

        SDL_RenderCopy(renderer, texture, null, null);

        SDL_RenderPresent(renderer);
    }

    ~this()
    {
        SDL_DestroyTexture(texture);
        SDL_FreeSurface(surface);
        SWM.dtor;
    }
}


void main()
{
    scope auto sdltest = new SDLTest();
    sdltest.mainLoop;
}
