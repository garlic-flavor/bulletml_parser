/**
 * Version:    0.0003(dmd2.069)
 * Date:       2016-Jan-20 17:56:22
 * Authors:    KUMA
 * License:    CC0
*/
module sworks.gl.util;

import sworks.base.matrix;
public import sworks.gl.port;

// prog shouldn't throw any Exception.
void enableScope(cap ...)(scope void delegate() nothrow prog)
{
  foreach (one ; cap) glEnable(one);
    prog();
  foreach_reverse(one ; cap) glDisable(one);
}


///
T ennoerror(T, string file = __FILE__, size_t line = __LINE__)
    (T value, lazy const(char)[] msg = null)
{
    checkNoError!(file, line)(msg);
    return value;
}
///
void checkNoError(string file = __FILE__, size_t line = __LINE__)
    (lazy const(char)[] msg = null)
{
    switch(glGetError())
    {
    case GL_NO_ERROR:
        return;
    case GL_INVALID_ENUM:
        throw new Exception("GL_INVALID_ENUM:" ~ msg.idup, file, line);
    case GL_INVALID_VALUE:
        throw new Exception("GL_INVALID_VALUE:" ~ msg.idup, file, line);
    case GL_INVALID_OPERATION:
        throw new Exception("GL_INVALID_OPERATION:" ~ msg.idup, file, line);
    case GL_INVALID_FRAMEBUFFER_OPERATION:
        throw new Exception("GL_INVALID_FRAMEBUFFER_OPERATION:" ~ msg.idup,
                            file, line);
    case GL_OUT_OF_MEMORY:
        throw new Exception("GL_OUT_OF_MEMORY:" ~ msg.idup, file, line);
    default:
        throw new Exception("UNDEFINED ERROR:" ~ msg.idup, file, line);
    }
}

//------------------------------------------------------------------------------
/// アルファ値なし色情報
struct Color3(PRECISION)
{
    PRECISION[3] v; ///
    alias v this;

    @trusted @nogc pure nothrow:
    ///
    this(in PRECISION[3] v ...) { this.v[] = v[]; }
    ///
    ref auto r() inout { return v[0]; }
    ///
    ref auto g() inout { return v[1]; }
    ///
    ref auto b() inout { return v[2]; }
}
///
alias Color3!float Color3f;

//------------------------------------------------------------------------------
/// アルファ値あり色情報
struct Color4(PRECISION)
{
    PRECISION[4] v = [0.0, 0.0, 0.0, 1.0]; ///
    alias v this;

    @trusted @nogc pure nothrow:
    ///
    this(in PRECISION[4] v ...) { this.v[] = v[]; }
    ///
    this(in PRECISION[3] v ...) { this.v[0..3] = v[]; this.v[3] = 1.0; }
    ///
    ref auto r() inout { return v[0]; }
    ///
    ref auto g() inout { return v[1]; }
    ///
    ref auto b() inout { return v[2]; }
    ///
    ref auto a() inout { return v[3]; }
}
///
alias Color4!float Color4f;

//------------------------------------------------------------------------------
/// テクスチャ座標
struct UVCoordination(PRECISION)
{
    PRECISION[2] a; ///
    alias a this;

    @trusted @nogc pure nothrow
    ///
    this(in PRECISION[2] a ...) { this.a[] = a[]; }

    ///
    ref auto u() inout { return a[0]; }
    ///
    ref auto v() inout { return a[1]; }
}
///
alias UVCoordination!float UVf;


//==============================================================================
//
// 既成パーツ
//
//==============================================================================

//------------------------------------------------------------------------------
class IdentityObject(PRECISION)
    if (is(PRECISION == float) || is(PRECISION == double))
{
    import sworks.gl.glsl;

    // args[0] = 単精度の場合 true。倍精度の場合 false。
    enum _vertex_shader =
    q{
        #version 130
        ?0 uniform mat4 transform;
        !0 uniform dmat4 transform;
        uniform vec4 diffuse;

        ?0 in vec3 v;
        !0 in dvec3 v;
        out vec4 f_color;

        void main()
        {
            ?0 gl_Position = transform * vec4(v, 1.0);
            !0 gl_Position = transform * dvec4(v, 1.0);
            f_color = diffuse;
        }
    };

    enum _fragment_shader =
    q{
        #version 130
        in vec4 f_color;
        // layout(location = 0) out vec4 colorOut;
        out vec4 colorOut;
        void main()
        {
            colorOut = f_color;
        }
    };
    alias SProgram = CTShaderProgram!
        (buildShader(_vertex_shader, is(PRECISION == float))
        , buildShader(_fragment_shader, is(PRECISION == float)));

    //--------------------------------------------------
    static Shader vs, fs;
    static SProgram  prog;

    ///
    static void ready()
    {
        if (prog) return;
        prog = new SProgram;
        prog.alpha = 1.0f;
    }

    ///
    static void use() {prog.use;}

    ///
    static void use(ref const Matrix4!PRECISION world)
    {
        use;
        prog.transform = world;
    }

    ///
    static void clearAll()
    {
        if (prog) prog.clear;
        prog = null;
    }
}

//------------------------------------------------------------------------------
class IdentityCube(PRECISION, uint TYPE, uint[] IDX)
    : IdentityObject!PRECISION, IdentityGeom!PRECISION
{
    import sworks.gl.glsl;

    alias Super = IdentityObject!PRECISION;
    alias V = Vector3!PRECISION;

    static VertexObject!V vo;
    static IndexObject!(V, uint) io;

    static void ready()
    {
        Super.ready;
        if (vo) return;
        vo = prog.makeVertex(VERTEX);
        io = vo.makeIndex(IDX);
    }

    static void use(ref const Matrix4!PRECISION world)
    {
        Super.use(world);
        vo.use;
        io.use;
    }

    static void use()
    {
        Super.use;
        vo.use;
        io.use;
    }

    static void clearAll()
    {
        if (io) io.clear; io = null;
        if (vo) vo.clear; vo = null;
        Super.clearAll;
    }

    //--------------------------------------------------------------------
    /// pos は ODE によって更新される可能性があるため、size と分ける必要がある。
    Matrix4!PRECISION pos, size;
    Color4f diffuse;

    this() { ready; }

    this(in Vector3!PRECISION s, in Matrix4!PRECISION p, in Color4f d)
    {
        this();
        size = scaleMatrix4!PRECISION(s);
        pos = p;
        diffuse = d;
    }

    void draw(ref const Matrix4!PRECISION world)
    {
        auto mat = world * pos * size;
        use(mat);
        prog.diffuse = diffuse;
        io.draw(TYPE);
    }

    /**
     * Return:
     *   ヒットしていた場合は正の数でポリゴンまでの距離
     *   ヒットしていなければ -1 が返る。
     */
    PRECISION hitDistance(in ref Arrow!PRECISION arr)
    {
        auto mat = pos * size;
        return IdentityGeom!PRECISION.hitDistance(mat, arr);
    }

    /// ヒットしたポリゴンまでの平均距離
    PRECISION hitDistanceAve(ref in Arrow!PRECISION arr)
    {
        auto mat = pos * size;
        return IdentityGeom!PRECISION.hitDistanceAve(mat, arr);
    }
}



//------------------------------------------------------------------------------
alias IdentityCubeLine
    = IdentityCube!(float, GL_LINES, IdentityGeom!float.INDEX_LINE);
alias IdentityCubePoly
    = IdentityCube!(float, GL_TRIANGLES, IdentityGeom!float.INDEX_POLY);

//------------------------------------------------------------------------------
// 四面体
// Y軸正の向き上に頂点があり、重心の位置に原点がある。
class IdentityTetrahedron(PRECISION, uint TYPE, uint[] IDX)
    : IdentityObject!PRECISION
{
    alias V = Vector3!PRECISION;
    alias Super = IdentityObject!PRECISION;

    import sworks.base.matrix;
    import sworks.gl.glsl;
    import std.math : sqrt;

    enum identityTetrahedronVertex =
        [V(0, (2*sqrt(10.0))/(3*sqrt(3.0)), 0)
        , V(0, -sqrt(10.0)/(3*sqrt(3.0)), 2/sqrt(3.0))
        , V(1, -sqrt(10.0)/(3*sqrt(3.0)), -1/sqrt(3.0))
        , V(-1, -sqrt(10.0)/(3*sqrt(3.0)), -1/sqrt(3.0))];

    static VertexObject!V vo;
    static IndexObject!(V, uint) io;

    static void ready()
    {
        Super.ready;
        if (vo) return;
        vo = prog.makeVertex(identityTetrahedronVertex);
        io = vo.makeIndex(IDX);
    }

    static void use(ref const Matrix4!PRECISION world)
    {
        Super.use(world);
        vo.use;
        io.use;
    }

    static void use()
    {
        Super.use;
        vo.use;
        io.use;
    }

    static void clearAll()
    {
        if (io) io.clear; io = null;
        if (vo) vo.clear; vo = null;
        Super.clearAll;
    }

    //----------------------------------------------------------
    Matrix4!PRECISION pos, size;
    Color4f diffuse;

    this(){ ready; }
    this(in Vector3!PRECISION s, in Matrix4!PRECISION p, in Color4f d)
    {
        this();
        pos = p;
        size = scaleMatrix4f(s);
        diffuse = d;
    }

    void draw(ref const Matrix4!PRECISION world)
    {
        auto mat = world * pos * size;
        use(mat);
        prog.diffuse = diffuse;
        io.draw(TYPE);
    }
}

alias TetrahedronLine = IdentityTetrahedron!(float, GL_LINES
    , [0u, 1, 0, 2, 0, 3, 1, 2, 2, 3, 3, 1]);

alias TetrahedronPoly = IdentityTetrahedron!(float, GL_TRIANGLES
    , [0u, 1, 2, 0, 2, 3, 0, 3, 1, 1, 3, 2]);


//------------------------------------------------------------------------------
class IdentityGridPlane : IdentityObject!float
{
    alias Super = IdentityObject!float;
    alias V = Vector3f;

    import sworks.base.matrix;
    import sworks.gl.glsl;

    VertexObject!V vo;
    IndexObject!(V, uint) io;
    Color4f diffuse;

    this(float y, float widthX, float widthZ, float densityX, float densityZ,
         Color4f d)
    {
        Super.ready;

        diffuse = d;

        auto xc = cast(size_t)(widthX / densityX);
        auto zc = cast(size_t)(widthZ / densityZ);

        auto v = new V[xc * 2 + zc * 2 + 4];
        auto j = 0;
        for (auto k = 0; k <= xc; ++k)
        {
            auto x = -widthX/2+densityX*k;
            v[j++] = V(x, y, -widthZ/2);
            v[j++] = V(x, y, widthZ/2);
        }
        for (auto k = 0; k <= zc; ++k)
        {
            auto z = -widthZ/2+densityZ*k;
            v[j++] = V(-widthX/2, y, z);
            v[j++] = V(widthX/2, y, z);
        }
        auto i = new uint[v.length];
        foreach (uint c, ref ii; i) ii = c;

        vo = prog.makeVertex(v);
        io = vo.makeIndex(i);
    }

    void clear()
    {
        if (io) io.clear;
        io = null;
        if (vo) vo.clear;
        vo = null;
    }

    void draw(ref const Matrix4f world)
    {
        use(world);
        vo.use;
        io.use;
        prog.diffuse = diffuse;
        io.draw(GL_LINES);
    }
}


//------------------------------------------------------------------------------
class IdentityAxis
{
    import sworks.base.matrix;
    IdentityCubePoly xAxis, yAxis, zAxis, origin;
    TetrahedronPoly xTip, yTip, zTip;

    this(float size, float a = 1.0)
    {
        auto sL = size;
        auto sW = size * 0.02;
        xAxis = new IdentityCubePoly(Vector3f(sL, sW, sW),
                                     translateMatrix4f(sL, 0, 0),
                                     Color4f(1, 0, 0, a));
        yAxis = new IdentityCubePoly(Vector3f(sW, sL, sW),
                                     translateMatrix4f(0, sL, 0),
                                     Color4f(0, 1, 0, a));
        zAxis = new IdentityCubePoly(Vector3f(sW, sW, sL),
                                     translateMatrix4f(0, 0, sL),
                                     Color4f(0, 0, 1, a));
        auto sO = size * 0.1;
        origin = new IdentityCubePoly(Vector3f(sO, sO, sO), identityMatrix4f,
                                      Color4f(0, 0, 0, a));

        auto sT = size * 0.1;
        xTip = new TetrahedronPoly(Vector3f(sT, sT*2, sT),
                                   translateMatrix4f(sL*2, 0, 0)
                                   * rotateXYMatrix4f(-HALF_PI),
                                   Color4f(1, 0, 0, a));
        yTip = new TetrahedronPoly(Vector3f(sT, sT*2, sT),
                                   translateMatrix4f(0, sL*2, 0),
                                   Color4f(0, 1, 0, a));
        zTip = new TetrahedronPoly(Vector3f(sT, sT*2, sT),
                                   translateMatrix4f(0, 0, sL*2)
                                   * rotateYZMatrix4f(HALF_PI),
                                   Color4f(0, 0, 1, a));
    }

    void alpha(float a) @property
    {
        xAxis.diffuse.a = a;
        yAxis.diffuse.a = a;
        zAxis.diffuse.a = a;
        origin.diffuse.a = a;
        xTip.diffuse.a = a;
        yTip.diffuse.a = a;
        zTip.diffuse.a = a;
    }

    void draw(ref const Matrix4f world)
    {
        xAxis.draw(world);
        yAxis.draw(world);
        zAxis.draw(world);
        origin.draw(world);

        xTip.draw(world);
        yTip.draw(world);
        zTip.draw(world);
    }
}
