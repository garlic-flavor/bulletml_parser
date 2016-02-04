/** オフスクリーンレンダリング関連
 * Version:    0.0003(dmd2.069)(dmd2.070.0)
 * Date:       2016-Jan-16 00:51:04
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.gl.bo;

import sworks.gl.port;

//------------------------------------------------------------------------------
//
class BufferObject(GLenum Target)
{
    GLuint id;
    alias id this;

    this()
    {
        glGenBuffers(1, &id);
        glBindBuffer(Target, id);
    }

    this(GLuint i)
    {
        id = i;
        glBindBuffer(Target, id);
    }

    void bind(V)(in V[] v, GLenum usage = GL_STATIC_DRAW)
    {
        glBindBuffer(Target, id);
        glBufferData(Target, V.sizeof * v.length, v.ptr, usage);
    }

    void bindout() { glBindBuffer(Target, 0); }

    void clear()
    {
        glDeleteBuffers(1, &id);
        id = 0;
    }

    void use(){ glBindBuffer(Target, id); }
}

//------------------------------------------------------------------------------
//
class RenderbufferObject(GLenum InternalFormat)
{
    GLuint id;
    alias id this;

    this(GLsizei w, GLsizei h)
    {
        glGenRenderbuffers(1, &id);
        bind;
        glRenderbufferStorage(GL_RENDERBUFFER, InternalFormat, w, h);
    }

    void bind(){ glBindRenderbuffer(GL_RENDERBUFFER, id); }
    void bindout(){ glBindRenderbuffer(GL_RENDERBUFFER, 0); }
    void bind(scope void delegate() prog)
    {
        bind;
        prog();
        bindout;
    }

    void clear()
    {
        glDeleteRenderbuffers(1, &id);
        id = 0;
    }
}

//------------------------------------------------------------------------------
abstract class AFramebufferObject
{
    GLuint id;

    void bind(){ glBindFramebuffer(GL_FRAMEBUFFER, id); }
    void bindout(){ glBindFramebuffer(GL_FRAMEBUFFER, 0); }
    void bind(scope void delegate() prog)
    {
        bind;
        prog();
        bindout;
    }

    void clear()
    {
        glDeleteFramebuffers(1, &id);
        id = 0;
    }
}

/// レンダーバッファに書き込む場合
class FramebufferObject(GLenum ColorFormat, GLenum DepthFormat) : AFramebufferObject
{
    alias ColorBuffer = RenderbufferObject!ColorFormat;
    alias DepthBuffer = RenderbufferObject!DepthFormat;

    alias id this;

    this(ColorBuffer cb, DepthBuffer db)
    {
        glGenFramebuffers(1, &id);
        bind;
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, cb);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, db);
    }

    void read(int x, int y, int w, int h, ubyte* buf)
    {
        bind;
        glReadBuffer(GL_COLOR_ATTACHMENT0);
        glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buf);
        bindout;
    }
}

//
auto newFBO(GLenum C, GLenum D)(RenderbufferObject!C c, RenderbufferObject!D d)
{
    return new FramebufferObject!(C, D)(c, d);
}

/// テクスチャに書き込む場合
class FramebufferObject(GLenum DepthFormat) : AFramebufferObject
{
    alias DepthBuffer = RenderbufferObject!DepthFormat;

    alias id this;

    this(GLuint tex, DepthBuffer db)
    {
        glGenFramebuffers(1, &id);
        bind;
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, 0);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, db);
    }
}

//
auto newFBO(GLenum D)(GLenum tex, RenderbufferObject!D d)
{
    return new FramebufferObject!D(tex, d);
}


/// スクリーンショット用
class Screenshot
{
    alias Drawer = void delegate();
    alias Renderbuffer = RenderbufferObject!GL_RGBA4;
    alias Depthbuffer = RenderbufferObject!GL_DEPTH_COMPONENT16;
    alias Framebuffer = FramebufferObject!(GL_RGBA4, GL_DEPTH_COMPONENT16);

    protected Renderbuffer rb;
    protected Depthbuffer db;
    protected Framebuffer fb;
    Drawer drawer;
    int width, height;

    //
    this(int w, int h, Drawer d)
    {
        width = w;
        height = h;
        drawer = d;

        rb = new Renderbuffer(w, h);
        db = new Depthbuffer(w, h);
        fb = newFBO(rb, db);
        fb.bindout;
    }

    //
    void clear()
    {
        if (fb) fb.clear;
        fb = null;
        if (db) db.clear;
        db = null;
        if (rb) rb.clear;
        rb = null;
    }

    // buf はあらかじめ呼び出し側で確保しておく。
    void take(void* buf)
    {
        fb.bind(
        {
            drawer();

            glReadBuffer(GL_COLOR_ATTACHMENT0);
            glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buf);
        });
    }
}
