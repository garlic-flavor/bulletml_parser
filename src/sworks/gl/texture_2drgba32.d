/**
 * Version:    0.0003(dmd2.069)(dmd2.070.0)
 * Date:       2016-Jan-21 23:22:22
 * Authors:    KUMA
 * License:    CC0
*/
module sworks.gl.texture_2drgba32;

import sworks.gl.port;

class Texture2DRGBA32
{
    GLuint id = 0;
    alias id this;
    this(GLint[GLenum] parameteri = [GL_TEXTURE_MAG_FILTER: GL_LINEAR,
                                     GL_TEXTURE_MIN_FILTER: GL_LINEAR])
    {
        glGenTextures(1, &id);
        glBindTexture(GL_TEXTURE_2D, id);
        foreach (key, param; parameteri)
            glTexParameteri(GL_TEXTURE_2D, key, param);
    }


    this(GLsizei width, GLsizei height, const(GLvoid)* data
        , GLint[GLenum] parameteri = [GL_TEXTURE_MAG_FILTER: GL_LINEAR,
                                      GL_TEXTURE_MIN_FILTER: GL_LINEAR])
    {
        this(parameteri);

        glPixelStorei(GL_UNPACK_ALIGNMENT,1);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,
                     GL_UNSIGNED_BYTE, cast(void*)data);
    }

    /**
     * Params:
     *   format = SDL_image -> GL_RGBA
     *            FreeImage -> GL_BGRA
     */
    this(GLsizei width, GLsizei height, GLenum format, const(GLvoid)* data,
         GLint[GLenum] parameteri = [GL_TEXTURE_MAG_FILTER: GL_LINEAR,
                                     GL_TEXTURE_MIN_FILTER: GL_LINEAR])
    {
        this(parameteri);

        glPixelStorei(GL_UNPACK_ALIGNMENT,1);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, format,
                     GL_UNSIGNED_BYTE, cast(void*)data);
    }


    void clear() { glDeleteTextures(1,&id); id = 0; }

    void bindScope(scope void delegate() prog)
    {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D,id);
        prog();
        glBindTexture(GL_TEXTURE_2D,0);
    }

    void use(int i)
    {
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, id);
    }
}

