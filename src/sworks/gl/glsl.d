/** GLSL のハンドリング
 * Version:    0.0003(dmd2.069)
 * Date:       2016-Jan-18 00:14:38
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.gl.glsl;

import sworks.util.cached_buffer;
import sworks.gl.port;
import sworks.gl.bo;
debug import std.stdio;

version (RM) enum ROW_MAJOR = true;
else enum ROW_MAJOR = false;

//------------------------------------------------------------------------------
/// シェーダのコンパイルと ID の管理
class Shader
{
    GLuint id;
    alias id this;

    /**
     * Params:
     *   shader_type = glCreateShader の引数
     *   cont        = シェーダの中身
     * Throws:
     *   Exception コンパイルが失敗した際に投げられる。$(BR)
     *             中身に OpenGL が生成したエラーメッセージを含む。
     */
    this(uint shader_type, const(char)[] cont)
    {
        id = glCreateShader(shader_type);
        char* cont_p = cast(char*)cont.ptr;
        int l_p = cast(int)cont.length;
        glShaderSource(id, 1, &cont_p, &l_p);
        glCompileShader(id);
        int compiled;
        glGetShaderiv(id, GL_COMPILE_STATUS, &compiled);
        if (GL_TRUE != compiled)
        {
            int max_length;
            glGetShaderiv(id, GL_INFO_LOG_LENGTH, &max_length);
            char[] log = new char[max_length];
            int log_length;
            glGetShaderInfoLog(id, max_length, &log_length, log.ptr);
            throw new Exception(log[0 .. log_length].idup);
        }
    }

    /// 終了処理を実行して下さい。
    void clear() { glDeleteShader(id); }
}

//------------------------------------------------------------------------------
/// シェーダのリンクと uniform の管理。
class ShaderProgram
{
    GLuint id;
    alias id this;

    /**
     * Params:
     *   s = コンパイル済みの物を渡して下さい。
     */
    this(Shader[] s ...)
    {
        id = glCreateProgram();
        assert(id);
        foreach (one ; s) glAttachShader(id, one);
    }
    /// 終了処理を実行して下さい。
    void clear() {glDeleteProgram(id);}
    /// リンク前ならば Shader を後から追加できます。
    ShaderProgram opOpAssign(string OP : "+")(Shader s) { glAttachShader(id, shader); return this; }

    /**
     * シェーダをリンクします。
     * Throws:
     *   Exception リンクに失敗した時に投げられる。$(BR)
     *             中身に OpenGL が生成したエラーメッセージを含んでいる。
     */
    ShaderProgram link()
    {
        glLinkProgram(id);
        int linked;
        glGetProgramiv(id, GL_LINK_STATUS, &linked);
        if (GL_TRUE != linked)
        {
            int max_length;
            glGetProgramiv(id, GL_INFO_LOG_LENGTH, &max_length);
            char[] log = new char[max_length];
            int log_length;
            glGetProgramInfoLog(id, max_length, &log_length, log.ptr);
            throw new Exception(log[0 .. log_length].idup);
        }
        return this;
    }

    // glProgramUniform* の関数名を生成する。
    static private string prog_name(T,size_t N)()
    {
        string result = "glProgramUniform";
        static if     (1 == N) result ~= "1";
        else static if (2 == N) result ~= "2";
        else static if (3 == N) result ~= "3";
        else static if (4 == N) result ~= "4";
        else static if (9 == N) result ~= "Matrix3";
        else static if (16 == N) result ~= "Matrix4";
        else static assert(0);

        static if     (is(T == int)) result ~= "iv";
        else static if (is(T == uint)) result ~= "uiv";
        else static if (is(T : float)) result ~= "fv";
        else static assert(0);
        return result;
    }

    /**
     * uniform 変数のロケーションを返す。
     * Params:
     *   NAME = 変数名
     *   N    = 配列の添字
     */
    GLint opDispatch(string NAME)() { return glGetUniformLocation(id, NAME.ptr); }
    /// ditto
    GLint opIndex(const(char)* NAME) { return glGetUniformLocation(id, NAME); }
    /// ditto
    GLint opIndex(string NAME, size_t N)
    {
        import std.conv : to;
        import std.array : join;
        return glGetUniformLocation(id, [NAME, "[", N.to!string, "]\0"].join.ptr);
    }

    /**
     * 変数名を指定して uniform 変数に値を設定する。$(BR)
     * ロケーションを指定するよりもオーバーヘッドがある。
     * Warning:
     *   引数 value の型は正しいですか？ int と uint は明確に区別され、関数呼び出しの失敗は検知されません!
     * Bugs:
     *   対応していない型があります。$(BR)
     *   四次元正方行列以外の行列型は失敗します。$(BR)
     */
    void opDispatch(string NAME, TYPE)(in TYPE value)
    {
        opIndexAssign(value, glGetUniformLocation(id, NAME.ptr));
    }
    /// ditto
    void opDispatch(string NAME, TYPE)(ref const(TYPE) value)
    {
        opIndexAssign(value, glGetUniformLocation(id, NAME.ptr));
    }
    /// ditto
    void opIndexAssign(TYPE)(in TYPE value, const(char)* name)
    {
        opIndexAssign(value, glGetUniformLocation(id, name));
    }
    /// ditto
    void opIndexAssign(TYPE)(ref const(TYPE) value, const(char)* name)
    {
        opIndexAssign(value, glGetUniformLocation(id, name));
    }
    /// ditto
    void opIndexAssign(TYPE)(in TYPE value, string name, size_t idx)
    {
        opIndexAssign(value, glGetUniformLocation(id, (name ~ "[" ~ idx.to!string ~ "]\0").ptr));
    }
    /// ditto
    void opIndexAssign(TYPE)(ref const(TYPE) value, string name, size_t idx)
    {
        opIndexAssign(value, glGetUniformLocation(id, (name ~ "[" ~ idx.to!string ~ "]\0").ptr));
    }

    /**
     * ロケーションを指定して uniform 変数に値を代入する。
     */
    void opIndexAssign(TYPE)(in TYPE value, GLint loc){ opIndexAssign(value, loc); }
    void opIndexAssign(TYPE)(ref const(TYPE) value, GLint loc)
    {
        static if     (is(TYPE T : T[N], size_t N))
        {
            static if     (N == 9 || N == 16)
                mixin(prog_name!(T,N))(id, loc, 1, ROW_MAJOR, value.ptr);
            else static if (N <= 4)
                mixin(prog_name!(T,N))(id, loc, 1, value.ptr);
            else static assert(0);
        }
        else static if (is(TYPE T : T[]))
        {
            static if (is(T TT : TT[N], size_t N))
            {
                static if     (N == 9 || N == 16)
                    mixin(prog_name!(TT,N))(id, loc, cast(int)value.length, ROW_MAJOR, cast(TT*)value.ptr);
                else static if (N <= 4)
                    mixin(prog_name!(T,N))(id, loc, 1, value.ptr);
                else static assert(0);
            }
            else mixin(prog_name!(T,1))(id, loc, cast(int)value.length, value.ptr);
        }
        else mixin(prog_name!(TYPE,1))(id, loc, 1, &value);
    }

    void use(){ glUseProgram(id); }

    VertexObject!VERTEX makeVertex(VERTEX)(in VERTEX[] v) { return new VertexObject!VERTEX(this, v); }
}

//------------------------------------------------------------------------------
// シェーダのパース

///
void skipWhite(TICache!char buf)
{
    outer: for (;!buf.empty;)
    {
        switch(buf.front)
        {
            case        ' ': case '\t': case '\r': case '\n': case ',': buf.popFront;
            break; case '/':
                auto c = buf.peek(2);
                if     (c.length < 2) break outer;
                else if (c[1] == '/')
                    for (buf.popFront(2); buf.front != '\r' && buf.front != '\n'; buf.popFront){}
                else if (c[1] == '*')
                    for (buf.popFront(2); !buf.empty; buf.popFront){ if (buf.peek(2) == "*/"){ buf.popFront(2); break; } }
                else break outer;
            break; case '[':
                for (; !buf.empty;){ if (buf.popFront == ']'){ buf.popFront; break; } }
            break; default: break outer;
        }
    }
}

///
const(char)[] popToken(TICache!char buf)
{
    buf.skipWhite;
    buf.flush;
    for (auto c = buf.push; !buf.empty; c = buf.push)
    {
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == ',' || c == ';' || c == '[') break;
    }
    return buf.stack;
}

///
string[] getUniforms(string cont)
{
    string[] unis;
    auto buf = new TWholeCache!char(cont);
    for (; !buf.empty ;)
    {
        if (buf.popToken == "uniform")
        {
            buf.popToken;
            for (auto tok = buf.popToken; tok != ";"; tok = buf.popToken) unis~=tok.idup;
        }
    }
    return unis;
}

//------------------------------------------------------------------------------
/** コンパイル時シェーダパーサ。
 * ユニフォーム変数などをコンパイル時に準備しておく。
 */
class CTShaderProgram(string VS, string FS)
{
    ShaderProgram program;
    alias program this;
    private enum UNIFORMS = VS.getUniforms ~ FS.getUniforms;
    mixin(
    {
        import std.array : Appender, join;
        Appender!(string[]) app;
        int[string] store;
        foreach (one; UNIFORMS)
        {
            if (one in store) continue;
            else store[one] = 1;

            app.put(["GLint ", one, "_loc;"
                     "void ", one, "(TYPE)(TYPE value) @property { program[",
                     one, "_loc] = value;}"]);
        }
        app.put(["this(){",
                 q{
                     auto vs = new Shader(GL_VERTEX_SHADER, VS);
                     scope(exit) vs.clear;
                     auto fs = new Shader(GL_FRAGMENT_SHADER, FS);
                     scope(exit) fs.clear;
                     program = (new ShaderProgram(vs, fs)).link;
                 }]);
        store = null;
        foreach (one; UNIFORMS)
        {
            if (one in store) continue;
            else store[one] = 1;
            app.put([one, "_loc = program[\"", one, "\"];"]);
        }
        app.put("}");
        return app.data.join;
    }());

    void clear(){ if (program !is null) program.clear; program = null; }
}


//------------------------------------------------------------------------------
///
class VertexObject(VERTEX) : BufferObject!(GL_ARRAY_BUFFER)
{
    private SetPointer[] setPointer;
    private struct SetPointer
    {
        GLuint location;
        GLint size;
        GLenum type;
        const(GLvoid*) pointer;
        this(GLuint l, GLint s, GLenum t, const(GLvoid*) p){ location = l; size = s; type = t; pointer = p; }
        void opCall(){glVertexAttribPointer(location, size, type, GL_FALSE, VERTEX.sizeof, pointer);}
    }

    template GLType(T)
    {
        static if     (is(T : float)) enum GLenum GLType = GL_FLOAT;
        else static if (is(T : byte)) enum GLenum GLType = GL_BYTE;
        else static if (is(T : ubyte)) enum GLenum GLType = GL_UNSIGNED_BYTE;
        else static if (is(T : short)) enum GLenum GLType = GL_SHORT;
        else static if (is(T : ushort)) enum GLenum GLType = GL_UNSIGNED_SHORT;
        else static if (is(T : int)) enum GLenum GLType = GL_INT;
        else static if (is(T : uint)) enum GLenum GLType = GL_UNSIGNED_INT;
        else static if (is(T : double)) enum GLenum GLType = GL_DOUBLE;
        else static assert(0);
    }

    void ready(ShaderProgram p)
    {
        import std.array : Appender;
        Appender!(SetPointer[]) app;
        foreach (one ; __traits(derivedMembers, VERTEX))
        {
            static if (is(typeof(__traits(getMember, VERTEX, one)) TYPE))
            {
                auto location = glGetAttribLocation(p, one.ptr);
                // assert(0 <= location, one ~" is not found in Shader");
                if (location < 0) continue;
                static if     (is(TYPE T : T[M][N], size_t N, size_t M))
                {
                    for (uint i = 0; i < N; ++i)
                    {
                        glEnableVertexAttribArray(location+i);
                        app.put(SetPointer(location+i, M, GLType!T
                            , cast(void*)(__traits(getMember, VERTEX, one)
                                .offsetof + T.sizeof * M * i)));
                    }
                }
                else static if (is(TYPE T : T[N], size_t N))
                {
                    glEnableVertexAttribArray(location);
                    app.put(SetPointer(location, N, GLType!T
                        , cast(void*)__traits(getMember, VERTEX, one)
                            .offsetof));
                }

            }
        }
        setPointer = app.data;
    }

    this(ShaderProgram p, in VERTEX[] v)
    {
        super();
        bind(v);
        ready(p);
    }

    this(ShaderProgram p, GLuint i)
    {
        super(i);
        ready(p);
    }


    IndexObject!(VERTEX, T) makeIndex(T)(in T[] idx, ShaderProgram p = null, GLuint[const(char)*] tex = null)
    {
        if (tex is null) return new IndexObject!(VERTEX, T)(this, idx);
        else return new IndexTexObject!(VERTEX, T)(p, this, idx, tex);
    }

    override void use()
    {
        super.use;
        foreach (one; setPointer) one();
    }

    void lock(scope void delegate(const(VERTEX)[]) prog) const
    {
        glBindBuffer(GL_ARRAY_BUFFER, id);
        long size;
        glGetBufferParameteri64v(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &size);
        prog((cast(const(VERTEX)*)glMapBuffer(GL_ARRAY_BUFFER, GL_READ_ONLY))[0..size/VERTEX.sizeof]);
        glUnmapBuffer(GL_ARRAY_BUFFER);
    }

    VertexObject makeClone(ShaderProgram p)
    {
        return new ClonedVertexObject(p, id);
    }

    private final class ClonedVertexObject : VertexObject
    {
        this(ShaderProgram p, GLuint i){ super(p, i); }
        override void clear(){}
    }
}

//------------------------------------------------------------------------------
///
class IndexObject(VERTEX, T)
{
    alias BO = BufferObject!(GL_ELEMENT_ARRAY_BUFFER);
    protected VertexObject!VERTEX vo;
    protected BO bo;
    const uint length;
    static if     (is(T : ubyte)) enum GLenum type = GL_UNSIGNED_BYTE;
    else static if (is(T : ushort)) enum GLenum type = GL_UNSIGNED_SHORT;
    else static if (is(T : uint)) enum GLenum type = GL_UNSIGNED_INT;
    else static assert(0, T.stringof ~ " is not supported as a type for index array.");

    //
    this(VertexObject!VERTEX v, in T[] idx)
    {
        bo = new BO;
        bo.bind(idx);
        vo = v;
        length = cast(uint)idx.length;
    }

    //
    this(IndexObject src)
    {
        bo = src.bo;
        vo = src.vo;
        length = src.length;
    }

    //
    void use() { bo.use; }

    //
    void draw(GLenum mode)
    {
        glDrawElements(mode, length, type, null);
    }

    //
    void clear(){ if (bo !is null) bo.clear; }

    //
    void lock(scope void delegate(const(T)[]) prog) const
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bo.id);
        prog((cast(const(T)*)glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_READ_ONLY))[0..length]);
        glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
    }

    //--------------------------------------
    ///
    IndexObject makeClone()
    {
        return new ClonedIndexObject(this);
    }
    private final class ClonedIndexObject : IndexObject
    {
        this(IndexObject src){ super(src); }
        override void clear(){}
    }
}

//------------------------------------------------------------------------------
/// テクスチャだけ変える場合にリソースを節約できる。
class IndexTexObject(VERTEX, T) : IndexObject!(VERTEX, T)
{
    private struct Tex{ GLuint id; GLuint loc; }
    Tex[] texes;
    ShaderProgram program;

    //
    this(ShaderProgram p, VertexObject!VERTEX v, in T[] idx, GLuint[const(char)*] ts = null)
    {
        super(v, idx);

        program = p;
        texes = new Tex[ts.length];
        size_t i = 0;
        foreach (key, one; ts) texes[i++] = Tex(one, program[key]);
    }

    //
    this(IndexObject!(VERTEX, T) src, GLuint[const(char)*] ts)
    {
        super(src);
        texes = new Tex[ts.length];
        size_t i = 0;
        foreach (key, one; ts) texes[i++] = Tex(one, program[key]);
    }

    //
    override void draw(GLenum mode)
    {
        foreach (int i, one; texes)
        {
            glActiveTexture(GL_TEXTURE0 + i);
            glBindTexture(GL_TEXTURE_2D, one.id);
            program[one.loc] = i;
        }
        super.draw(mode);
    }

    //--------------------------------------
    /** テクスチャだけ替える場合。
     */
    IndexTexObject makeClone(GLuint[const(char)*] ts)
    {
        return new ClonedIndexObject(this, ts);
    }
    private class ClonedIndexObject : IndexTexObject
    {
        this(IndexTexObject src, GLuint[const(char)*] ts){ super(src, ts); }
        override void clear(){}
    }
}

//------------------------------------------------------------------------------
/** シェーダ本文中で簡易マクロを使えるように。
 * ?x   --  空白文字以外の行頭に置く。args[x]が偽の時はその行は消去される。
 * !x   --  空白文字以外の行頭に置く。args[x]が真の時はその行は消去される。
 * %x   --  文中のどこにでも置ける。args[x]の値に展開される。
 * x には 0 ～ 9 まで使える。
 */
string buildShader(string cont, uint[] args...)
{
    import std.array : Appender, join;
    import std.conv : to;
    import std.string : splitLines, stripLeft, indexOf;

    Appender!(string[]) result;

    string checkLine(string line)
    {
        line = line.stripLeft;
        if      (line.length < 2) {}
        else if (line[0] == '?')
        {
            auto n = cast(int)(line[1] - '0');
            if (n < args.length && args[n]) line = checkLine(line[2..$]);
            else line = "";
        }
        else if (line[0] == '!')
        {
            auto n = cast(int)(line[1] - '0');
            if (n < args.length && !args[n]) line = checkLine(line[2..$]);
            else line = "";
        }
        return line;
    }

    foreach (line; cont.splitLines)
    {
        line = checkLine(line);
        if (0 == line.length) continue;
        for (sizediff_t i, j; ;)
        {
            if ((i = line[j..$].indexOf('%')) < 0) break;
            j += i;
            if (line.length <= j+1) break;
            auto needle = cast(int)(line[j+1]-'0');
            if (needle < args.length)
            {
                auto rest = line.length - j+2;
                line = [line[0..j], args[needle].to!string,
                        line[j+2..$]].join;
                j = line.length - rest;
            }
        }
        result.put(line);
    }
    return result.data.join("\n");
}
