/** template mixin による Silgle linked list の実装。
 * Date:       2016-Jan-22 00:37:03
 * Authors:    KUMA
 * License:    CC0
 **/
module sworks.base.factory;

/**
Params:
  Base = ISlistを実装するクラスを渡す。
**/
interface ISlist(Base)
{
    @property @trusted @nogc pure nothrow:
    Base next();
    void next(Base b);
}

/// ISlist を実装したクラスかどうか。
template isSlist(T)
{
    static if (is(T : ISlist!T))
        enum isSlist = true;
    else
        enum isSlist = false;
}

///
@trusted @nogc pure nothrow
auto popFront(T)(ref T ite) if (isSlist!T)
{
    auto ret = ite;
    if (ite !is null) ite = ite.next;
    return ret;
}

///
@trusted @nogc pure nothrow
auto pickFront(T)(ref T ite) if (isSlist!T)
{
    auto ret = ite;
    if (ite !is null)
    {
        ite = ite.next;
        ret.next = null;
    }
    return ret;
}

///
@trusted @nogc pure nothrow
auto pushFront(T)(ref T stack, T item) if (isSlist!T)
{
    if (item !is null) item.next = stack;
    stack = item;
    return stack;
}

///
@trusted @nogc pure nothrow
auto insertAtNext(T)(T list, T item) if (isSlist!T)
{
    if (item !is null && list !is null)
    {
        item.next = list.next;
        list.next = item;
    }
    return list;
}

///
@trusted pure
void deleteAll(T)(ref T list) if (isSlist!T)
{
    for (auto ite = list; ite !is null;)
    {
        auto item = ite.popFront;
        delete item;
    }
    list = null;
}

///
@trusted @nogc pure nothrow
size_t traverseLength(T)(T list, T to = null) if (isSlist!T)
{
    size_t l;
    for (auto ite = list; ite !is null && ite !is to; ++l) ite.popFront;
    return l;
}


//------------------------------------------------------------------------------
/// ISlist を実装すべきクラスに mixin して実装を提供する。
mixin template SlistMix(Base)
{
    alias This = typeof(this);
    static assert (is(This == class));
    static assert (isSlist!Base);
    static assert (is(This : Base));

    private Base _next;

    @property @trusted @nogc pure nothrow
    {
        Base next() { return _next; }
        void next(Base b) { _next = b; }
    }
}

unittest
{
    class Test : ISlist!Test
    { mixin SlistMix!Test;
        int x;
        this(int i){ x = i; }
    }

    Test t;
    t.pushFront(new Test(3));
    t.pushFront(new Test(1));
    t.insertAtNext(new Test(2));
    size_t i;
    for (auto ite = t; ite !is null; ite.popFront)
        assert(ite.x == ++i);
}

//------------------------------------------------------------------------------
/// opCall() と remove() を実行することでインスタンス回数を減らす。
mixin template SFactoryMix(Base)
{ mixin SlistMix!Base;

    static
    {
        private Base _freeStack;

        auto opCall(T...)(T arg)
        {
            This ret;
            if (_freeStack !is null) ret = cast(This)_freeStack.pickFront;
            else ret = new This;
            ret.onReset(arg);
            return ret;
        }

        @trusted
        void clearAll()
        {
            for (; _freeStack !is null;)
            {
                auto ite = _freeStack.popFront;
                delete ite;
            }
        }
    }

    void remove()
    {
        if (next !is null) next.remove;
        this.onRemove;
        _freeStack.pushFront(this);
    }


    private
    void onReset(T ...)(T args){}
    private
    void onRemove(){}
}

unittest
{
    static size_t ctorCounter, dtorCounter, onResetCounter, onRemoveCounter;

    static class Test : ISlist!Test
    { mixin SFactoryMix!Test;
        this(){ ++ctorCounter; }
        ~this(){ ++dtorCounter; }
        void onReset(){ ++onResetCounter; }
        void onRemove(){ ++onRemoveCounter; }
    }
    auto t = Test();
    t.remove;
    t = Test();
    t.remove;
    Test.clearAll;

    assert(ctorCounter == 1 &&
           dtorCounter == 1 &&
           onResetCounter == 2 &&
           onRemoveCounter == 2);
}

//------------------------------------------------------------------------------
/**
ISlist を連結
コピーは起きない。
**/
struct SlistAppender(T) if (isSlist!T)
{
protected:
    T _front, _back;

public:
    @trusted pure:
    //----------------------------------------------------------------------
    // input range
    @property @nogc nothrow
    {
        bool empty() const { return _front is null; }
        auto front() inout { return _front; }
        auto back() inout { return _back; }
    }
    //----------------------------------------------------------------------
    // output range
    @nogc nothrow
    void opOpAssign(string OP : "~", U : T)(U new_one)
    {
        if      (null is new_one) return;
        else if (null is _front || null is _back) _front = _back = new_one;
        else _back.next = new_one;

        for (; _back.next !is null;) _back.popFront;

    }

    @nogc nothrow
    void opOpAssign(string OP : "~", U : SlistAppender)(ref U new_one)
    {
        if      (new_one.empty) return;
        else if (null is _front || null is _back)
        {
            _front = new_one._front;
            _back = new_one._back;
        }
        else
        {
            _back.next = new_one._front;
            _back = new_one._back;
        }
    }

    alias put = opOpAssign!("~", T);
    alias put = opOpAssign!("~", SlistAppender);

    void clear()
    {
        _front.deleteAll;
        _front = null;
        _back = null;
    }

    @nogc nothrow
    auto flush() { auto ret = _front; _front = _back = null; return ret; }

    ///
    @property @nogc nothrow
    auto iterator() { return SlistIterator!T(_front, _back); }
}

unittest
{
    static class Test : ISlist!Test
    { mixin SlistMix!Test;
        int x;
        this(int i){ x = i; }
    }
    auto app = SlistAppender!Test();
    app.put(new Test(1));
    app.put(new Test(2));
    app.put(new Test(3));

    size_t i;
    for (auto ite = app.front; ite !is null; ite.popFront)
        assert(ite.x == ++i);
}


//------------------------------------------------------------------------------
/**
ISlist を巡回する。
途中でremoveFrontを実行することでリストの中身を変更できる。
 **/
struct SlistIterator(Base) if (isSlist!Base)
{
    private Base* _top;
    private Base* _tail;
    private Base _prev;
    ///
    Base _front;
    alias _front this; ///

    @trusted pure:
    ///
    @nogc nothrow
    this(ref Base top)
    {
        if (top !is null) _top = &top;
        _front = top;
        _prev = null;
    }

    ///
    @nogc nothrow
    this(ref Base top, ref Base tail)
    {
        this(top);
        if (tail !is null) _tail = &tail;
    }

    private @nogc nothrow
    this(Base* top, Base* tail, Base prev)
    {_top = top; _tail = tail; _prev = prev;}

    @nogc nothrow
    auto dup() { return SlistIterator(_top, _tail, _prev); }

    ///
    @property @nogc nothrow
    bool empty() const { return _front is null; }

    @property @trusted @nogc nothrow
    auto front() inout { return _front; }

    ///
    @nogc nothrow
    Base popFront()
    {
        if      (_front is null){}
        else if (_tail !is null && (*_tail) is _front)
        { _prev = _front; _front = null; }
        else _prev = _front.popFront;
        return _prev;
    }

    ///
    Base removeFront()
    {
        if (null is _front) return null;

        auto ret = _front;
        auto next = _front.next;
        ret.next = null;

        if (_tail !is null && (*_tail) is _front)
        { (*_tail) = _prev; next = null; }
        if (null !is _prev) _prev.next = next;
        if ((*_top) is _front) (*_top) = next;

        _front = next;

        return ret;
    }
}

/// suger
@trusted @nogc pure nothrow
auto iterator(T)(ref T t) if (isSlist!T) { return SlistIterator!T(t); }

unittest
{
    import std.conv : to;
    static class Test : ISlist!Test
    { mixin SlistMix!Test;
        int x;
        this(int i){ x = i; }
    }

    int i;

    auto app = SlistAppender!Test();
    for (i = 0; i < 3; ++i)
        app.put(new Test(i+1));

    i = 0;
    for (auto ite = app.iterator; !ite.empty; ite.popFront)
    {
        assert(ite.x == ++i);
        if (i == 3) ite.removeFront;
    }

    i = 0;
    for (auto ite = app.iterator; !ite.empty; ite.popFront)
        assert(ite.x == ++i);
    assert(i == 2);

    app.put(new Test(3));
    i = 0;
    for (auto ite = app.iterator; !ite.empty; ite.popFront)
        assert(ite.x == ++i, ite.x.to!string ~ " != " ~ i.to!string);

    i = 0;
    for (auto ite = app.iterator; !ite.empty;)
        if (++i == 1) ite.removeFront;
        else ite.popFront;

    i = 1;
    for (auto ite = app.iterator; !ite.empty; ite.popFront)
        assert(ite.x == ++i, ite.x.to!string ~ " != " ~ i.to!string);
    assert(i == 3);

    app.clear;
    for (i = 0; i < 3; ++i)
        app.put(new Test(i+1));

    i = 0;
    for (auto ite = app.iterator; !ite.empty;)
        if (++i == 2) ite.removeFront;
        else ite.popFront;

    auto ite = app.iterator;
    assert(ite.removeFront.x == 1);
    assert(ite.removeFront.x == 3);
    assert(app.empty);
}


