/** to handle SDL
 * Version:    0.0003(dmd2.069)(dmd2.070.0)
 * Date:       2016-Jan-17 17:31:23
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.sdl.util;

import std.exception, std.conv, std.traits, std.algorithm, std.utf;
public import sworks.sdl.port;

//==============================================================================
// Miscs

///
alias SDLExtQuitDel =  void delegate();
///
alias SDLExtInitDel = SDLExtQuitDel delegate();
///
alias toUTF8z = std.utf.toUTFz!(char*);

//------------------------------------------------------------------------------
// Size
struct Size { int w, h; }

//
private version (Windows) extern(Windows) bool SetDllDirectoryW(const(wchar)*);
void setDLLDir(const(wchar)* dir)
{
    version (Windows) SetDllDirectoryW(dir);
}

//------------------------------------------------------------------------------
// RWops
import sworks.util.cached_buffer;
TICache!T toCache(T)(SDL_RWops* io)
{
    return new TCachedBuffer!T((b)=>cast(size_t)io.read(io, b.ptr, T.sizeof, b.length)
                              , (s){io.seek(io, cast(Sint64)s, RW_SEEK_CUR); return; }
                              , (){io.close(io); return; }
                              , (){io.seek(io, 0, RW_SEEK_SET); return;});
}


//==============================================================================
// about Exceptions

//------------------------------------------------------------------------------
T enforceSDL(T)(T val, lazy string msg = "", string file = __FILE__, size_t line = __LINE__)
{
    if (!val) throw new ExceptionSDL(msg, file, line);
    return val;
}

//------------------------------------------------------------------------------
class ExceptionSDL : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(SDL_GetError().to!string ~ " : " ~ msg, file, line);
        SDL_ClearError();
    }
}




//==============================================================================
// about debugging

//------------------------------------------------------------------------------
void logout(const(char)[] msg) nothrow
{
    import std.file;
    debug
    {
        if (2 == MsgBox(null, msg, "SDL ERROR", MsgBox.Error
                       , MsgBox.Button(MsgBox.Ret | MsgBox.Esc, 1, "OK")
                       , MsgBox.Button(0, 2, "Save")))
        {
            try append("log-out.txt", msg);
            catch (Throwable){}
            OkBox("saved as log-out.txt");
        }
    }
    else try append("log-out.txt", msg); catch (Throwable){}
}

//------------------------------------------------------------------------------
///
int OkBox(const(char)[] msg) nothrow
{
    return MsgBox(null, msg, "SDL Message", MsgBox.Information
                 , MsgBox.Button(MsgBox.Ret | MsgBox.Esc, 1, "OK"));
}

//------------------------------------------------------------------------------
///
int YesNoBox(const(char)[] msg)
{
    return MsgBox(null, msg, "SDL Query", MsgBox.Warning
                 , MsgBox.Button(MsgBox.Ret, 1, "OK")
                 , MsgBox.Button(MsgBox.Esc, 0, "Cancel"));
}

//------------------------------------------------------------------------------
///
struct MsgBox
{
    alias Information = SDL_MESSAGEBOX_INFORMATION;
    alias Warning = SDL_MESSAGEBOX_WARNING;
    alias Error = SDL_MESSAGEBOX_ERROR;
    alias Button = SDL_MessageBoxButtonData;
    alias Ret = SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT;
    alias Esc = SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT;

    static int opCall(SDL_Window* hWnd, const(char)[] msg, const(char)* caption, int flag, Button[] mbbd...)
        nothrow
    {
////////////////////////////////////////////////////////////////////////////////<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< THIS IS BUG!
/**/version (Windows)
/**/{
/**/    debug(SHOWBUG) pragma(msg, "layout of messagebox is broken.(lower part of the message is truncated.) @", __FILE__, " : ", __LINE__);
/**/    msg ~= "\n\n\n\n\n\n";
/**/}
////////////////////////////////////////////////////////////////////////////////
        SDL_MessageBoxData mbd;
        with (mbd)
        {
            flags = flag;
            window = hWnd;
            title = caption;
            message = msg.toUTF8z;
            numbuttons = cast(int)mbbd.length;
            buttons = mbbd.ptr;
            colorScheme = null;
        }
        int ret;
        SDL_ShowMessageBox(&mbd, &ret);
        return ret;
    }
}

//==============================================================================
// about Textures

//------------------------------------------------------------------------------
///
SDL_Surface* createSurfaceRGBA32(int width, int height)
{
    version (BigEndian) enum mask = [0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000];
    version (LittleEndian) enum mask = [0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff];
    return SDL_CreateRGBSurface(0, width, height, 32, mask[0], mask[1], mask[2], mask[3])
        .enforceSDL("fail to call SDL_CreateRGBSurface");
}

//------------------------------------------------------------------------------
SDL_Surface* convertSurfaceRGBA32(SDL_Surface* src)
{
    return enforceSDL(SDL_ConvertSurfaceFormat(src, SDL_PIXELFORMAT_RGBA8888, 0), "fail to call SDL_ConvertSurface");
}

//------------------------------------------------------------------------------
//
class SDLTexture2DRGBA
{
    SDL_Texture* _texture;
    this(SDL_Renderer* renderer, int width, int height)
    {
        _texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, width, height);
        enforce(_texture !is null);
    }
}



//==============================================================================
// Main Interface

//------------------------------------------------------------------------------
//
mixin template SDLMix()
{ static:
    private SDLExtQuitDel[] _dtors;

    void init(uint initFlag, SDLExtInitDel[] ctors...)
    {
        DerelictSDL2.load;
        SDL_Init(initFlag);
        _dtors.length = ctors.length;
        foreach (i, one; ctors) _dtors[i] = one();
    }

    void init(SDLExtInitDel[] ctors...)
    {
        auto l = _dtors.length;
        _dtors.length = l+ctors.length;
        foreach (i, one; ctors) _dtors[l+i] = one();
    }

    void clear()
    {
        foreach_reverse(one; _dtors) one();
        SDL_Quit();
        DerelictSDL2.unload;
    }

    void sdl_quit(const ref SDL_QuitEvent){}
    void sdl_window(const ref SDL_WindowEvent){}
    void sdl_syswm(const ref SDL_SysWMEvent){}
    void sdl_keydown(const ref SDL_KeyboardEvent){}
    void sdl_keyup(const ref SDL_KeyboardEvent){}
    void sdl_textediting(const ref SDL_TextEditingEvent){}
    void sdl_textinput(const ref SDL_TextInputEvent){}
    void sdl_mousemotion(const ref SDL_MouseMotionEvent){}
    void sdl_mousebuttondown(const ref SDL_MouseButtonEvent){}
    void sdl_mousebuttonup(const ref SDL_MouseButtonEvent){}
    void sdl_mousewheel(const ref SDL_MouseWheelEvent){}
    void sdl_joyaxismotion(const ref SDL_JoyAxisEvent){}
    void sdl_joyhatmotion(const ref SDL_JoyHatEvent){}
    void sdl_joybuttondown(const ref SDL_JoyButtonEvent){}
    void sdl_joybuttonup(const ref SDL_JoyButtonEvent){}

    void sdl_controlleraxismotion(const ref SDL_ControllerAxisEvent){}
    void sdl_controllerbuttondown(const ref SDL_ControllerButtonEvent){}
    void sdl_controllerbuttonup(const ref SDL_ControllerButtonEvent){}
    void sdl_controllerdeviceadded(const ref SDL_ControllerDeviceEvent){}
    void sdl_controllerdeviceremoved(const ref SDL_ControllerDeviceEvent){}
    void sdl_controllerdevicemapped(const ref SDL_ControllerDeviceEvent){}

    void sdl_userevent(const ref SDL_UserEvent){}


    bool dispatch_event(const ref SDL_Event event)
    {
        final switch(event.type)
        {
            case        SDL_FIRSTEVENT: // unused

            // Application events
            break; case SDL_QUIT: typeof(this).sdl_quit(event.quit); return false;

            // for Android ans iOS
            break; case SDL_APP_TERMINATING:
            break; case SDL_APP_LOWMEMORY:
            break; case SDL_APP_WILLENTERBACKGROUND:
            break; case SDL_APP_DIDENTERBACKGROUND:
            break; case SDL_APP_WILLENTERFOREGROUND:
            break; case SDL_APP_DIDENTERFOREGROUND:

            // Window events
            break; case SDL_WINDOWEVENT: typeof(this).sdl_window(event.window);
            break; case SDL_SYSWMEVENT: typeof(this).sdl_syswm(event.syswm);

            // Keyboard events
            break; case SDL_KEYDOWN: typeof(this).sdl_keydown(event.key);
            break; case SDL_KEYUP: typeof(this).sdl_keyup(event.key);
            break; case SDL_TEXTEDITING: typeof(this).sdl_textediting(event.edit);
            break; case SDL_TEXTINPUT: typeof(this).sdl_textinput(event.text);

            // Mouse events
            break; case SDL_MOUSEMOTION: typeof(this).sdl_mousemotion(event.motion);
            break; case SDL_MOUSEBUTTONDOWN: typeof(this).sdl_mousebuttondown(event.button);
            break; case SDL_MOUSEBUTTONUP: typeof(this).sdl_mousebuttonup(event.button);
            break; case SDL_MOUSEWHEEL: typeof(this).sdl_mousewheel(event.wheel);

            // Joystick evnets
            break; case SDL_JOYAXISMOTION: typeof(this).sdl_joyaxismotion(event.jaxis);
            break; case SDL_JOYBALLMOTION:
            break; case SDL_JOYHATMOTION: typeof(this).sdl_joyhatmotion(event.jhat);
            break; case SDL_JOYBUTTONDOWN: typeof(this).sdl_joybuttondown(event.jbutton);
            break; case SDL_JOYBUTTONUP: typeof(this).sdl_joybuttonup(event.jbutton);
            break; case SDL_JOYDEVICEADDED:
            break; case SDL_JOYDEVICEREMOVED:

            // Controller events
            break; case SDL_CONTROLLERAXISMOTION: typeof(this).sdl_controlleraxismotion(event.caxis);
            break; case SDL_CONTROLLERBUTTONDOWN: typeof(this).sdl_controllerbuttondown(event.cbutton);
            break; case SDL_CONTROLLERBUTTONUP: typeof(this).sdl_controllerbuttonup(event.cbutton);
            break; case SDL_CONTROLLERDEVICEADDED: typeof(this).sdl_controllerdeviceadded(event.cdevice);
            break; case SDL_CONTROLLERDEVICEREMOVED: typeof(this).sdl_controllerdeviceremoved(event.cdevice);
            break; case SDL_CONTROLLERDEVICEREMAPPED: typeof(this).sdl_controllerdevicemapped(event.cdevice);

            // Touch events
            break; case SDL_FINGERDOWN:
            break; case SDL_FINGERUP:
            break; case SDL_FINGERMOTION:

            // Gesture events
            break; case SDL_DOLLARGESTURE:
            break; case SDL_DOLLARRECORD:
            break; case SDL_MULTIGESTURE:

            // Clipboard events
            break; case SDL_CLIPBOARDUPDATE:

            // Drag and drop events
            break; case SDL_DROPFILE:

            // Render events
            break; case SDL_RENDER_TARGETS_RESET:
            break; case SDL_RENDER_DEVICE_RESET:

            // User events
            break; case SDL_USEREVENT: typeof(this).sdl_userevent(event.user);
            break; case SDL_LASTEVENT:
            break;
        }
        return true;
    }

    void start()
    {
        SDL_Event event;
        scope(exit) typeof(this).clear();
        loop:while(1)
        {
            try while(0 <= SDL_WaitEvent(&event))
            {
                if (!dispatch_event(event)) break loop;
            }
            catch (Throwable t) logout(t.toString);
        }
    }
}


//------------------------------------------------------------------------------
// SDLIdleMix
mixin template SDLIdleMix()
{ mixin SDLMix!() SWM;
static:
    private uint _spf = 30;
    private uint _prevTime;

//--------------------------------------
    // ctor
    alias init = SWM.init;
    void init(uint initFlag, uint spf, SDLExtInitDel[] inits ...)
    {
        SWM.init(initFlag, inits);
        _spf = spf;
        _prevTime = SDL_GetTicks();
    }

    void update(uint){}
    void draw(){}

    void idle()
    {
        uint time = SDL_GetTicks();
        if (time < _prevTime + _spf)
        {
            SDL_Delay(_prevTime + _spf - time);
            time = _prevTime + _spf;
        }

        typeof(this).update(time - _prevTime);
        typeof(this).draw();
        _prevTime = time;
    }

    void start()
    {
        SDL_Event event;
        scope(exit) typeof(this).clear();
        try loop:while(1)
        {
            while(SDL_PollEvent(&event))
            {
                if (!dispatch_event(event)) break loop;
            }
            typeof(this).idle();
        }
        catch (Throwable t) logout(t.toString);
    }
}

//------------------------------------------------------------------------------
///
class Window
{
    SDL_Window* window;
    SDL_Renderer* renderer;
    alias window this;

    this(const(char)* title, int width, int height, uint videoFlag = 0)
    {
        window = enforceSDL(SDL_CreateWindow(title, SDL_WINDOWPOS_UNDEFINED_MASK, SDL_WINDOWPOS_UNDEFINED_MASK
                                             , width, height, videoFlag), "error in SDL_CreateWindow");
        renderer = enforceSDL(SDL_CreateRenderer(window, -1
            , SDL_WINDOW_OPENGL & videoFlag ? SDL_RENDERER_TARGETTEXTURE : SDL_RENDERER_ACCELERATED), "error in SDL_CreateRenderer");
    }

    void flush(){ SDL_UpdateWindowSurface(window);}
}

//------------------------------------------------------------------------------
///
class GLWindow : Window
{
    alias window this;
    SDL_GLContext context;

    this(const(char)* title, int width, int height, uint videoFlag = 0)
    {
        videoFlag |= SDL_WINDOW_OPENGL;
        super(title, width, height, videoFlag);
        context = SDL_GL_CreateContext(window).enforceSDL("error in SDL_GL_CreateContext");
        SDL_GL_MakeCurrent(window, context);
    }

    override void flush(){ SDL_GL_SwapWindow(window); }
    void makeCurrent(){ SDL_GL_MakeCurrent(window, context); }
}

////////////////////XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\\\\\\\\\\\\\\\\\\\\
debug(sdl_util) :

final class SDLTest
{ mixin SDLMix!() SM;
static:
    Window window;

    void start()
    {
        SM.init(SDL_INIT_VIDEO
        ,{
            window = new Window("hello SDL", 640, 480, 0);
            return cast(SDLExtQuitDel){};
        });
        SM.start;
    }
}

void main()
{
    setDLLDir("bin64");
    SDLTest.start;
}

