/**
 * Version:    0.0003(dmd2.069)(dmd2.070.0)
 * Date:       2016-Jan-19 20:41:32
 * Authors:    KUMA
 * License:    CC0
*/
/**
 * Macros:
 *   DOCUMENTS_ROOT = ../../
 */
module sworks.gl.port;

public import derelict.opengl3.gl3;

void load()
{ if (!DerelictGL3.isLoaded) DerelictGL3.load; }

void reload()
{ DerelictGL3.reload; }

/// check runtime versions.
void reloadGL(float gl, float glsl = 0)
{
    import std.conv : to;
    if (gl <= 1.1) return;
    auto glv = DerelictGL3.reload * 0.1;
    if (glv < gl)
        throw new Exception("Required OpenGL version is " ~ gl.to!string ~
                            ". but, loaded version is " ~ glv.to!string ~ ".");
    if (glsl <= 0) return;
    auto glslv = glGetString(GL_SHADING_LANGUAGE_VERSION).to!string.to!float;
    if (glslv < glsl)
        throw new Exception("Required OpenGLSL version is " ~ glsl.to!string ~
                            ". but, loaded version is " ~ glslv.to!string ~
                            ".");
}

