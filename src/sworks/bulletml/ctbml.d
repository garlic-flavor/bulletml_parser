/** Compile-Time BulletML Parser.
Version:    0.0003(dmd2.069)(dmd2.070.0)
Date:       2016-Feb-04 19:30:05
Authors:    KUMA

WHAT_IS_THIS:
$(UL
  $(LI This is a module of D Programming Language,)
  $(LI to use $(LINK2 http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/, BulletML) by $(LINK2 http://www.asahi-net.or.jp/~cs8k-cyu/, ABA Games).)
  $(LI I agree with this flow. $(LINK2 http://sourceforge.jp/projects/d-action/wiki/FrontPage, D言語でアクションゲームでも作ってみる？) $(LINK2 http://toro.2ch.net/test/read.cgi/tech/1329714331/574, 574).)
  $(LI bulletml.exe is for 64bit Windows.)
  $(LI bulletml.exe depends on $(LINK2 http://libsdl.org/, SDL2) and $(LINK2 http://opengl.org/, OpenGL).)
  $(LI About bulletml.exe, click the client area of the window to change bullet type.)
)

License:    CC0
$(LINK http://creativecommons.org/publicdomain/zero/1.0/).
<p xmlns:dct="http://purl.org/dc/terms/" xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
  <a rel="license" href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law,
  <a rel="dct:publisher" href="sweatygarlic@yahoo.co.jp">
    <span property="dct:title">KUMA</span></a>
  has waived all copyright and related or neighboring rights to
  <span property="dct:title">CT BulletML Parser</span>.
  This work is published from:
  <span property="vcard:Country" datatype="dct:ISO3166" content="JP" about="sweatygarlic@yahoo.co.jp">
  日本</span>.
</p>

Acknowledgements:
$(UL
  $(LI Files in "sample" directory are distributed by $(LINK2 http://www.asahi-net.or.jp/~cs8k-cyu/, ABA Games).)
  $(LI Files in "sample" directory are under BSD license.)
  $(LI $(LINK2 ./bulletml-readme.txt, bulletml-readme))
  $(LI $(LINK2 ./bulletml-readme_e.txt, bulletml-readme in English))
  $(LI bulletml.exe depends on $(LINK2 https://github.com/DerelictOrg, Derelict) to build.)
  $(LI written by $(LINK2 http://dlang.org/, D Programming Language).)
)

DevelopmentEnvironment:
This module is tested under,
$(UL
  $(LI Windows Vista x64 + dmd 2.069.2)
)

History:
$(UL
  $(LI 2016/01/27 ver. 0.0003(dmd2.069.2)
    fully rewritten.)
  $(LI 2012/08/18 ver. 0.0002(dmd2.060)
    debut on github.)
)

- - -

これは?:
これは $(LINK2 http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/, BulletML(http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/))
ファイルを読み込むためのプログラムです。

BUGS:
$(UL
  $(LI 本家アプレットと挙動がなんかちがう。)
)

謝辞:
$(UL
  $(LI
    BulletML は ABA Games さんが作ったものです。
    $(LINK2 http://www.asahi-net.or.jp/~cs8k-cyu/, ABA Games (http://www.asahi-net.or.jp/~cs8k-cyu/))
    $(LINK2 http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/, BulletML (http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/))
)
  $(LI
    sample フォルダ内のものは BSDライセンスです。
    $(LINK2 ./bulletml-readme.txt, bulletml-readme)
    $(LINK2 ./bulletml-readme_e.txt, bulletml-readme in English)
)
  $(LI
    2ch D言語 part29 $(LINK2 http://toro.2ch.net/test/read.cgi/tech/1329714331/574, 574)
    さんのゲーム作る流れが、モチベーションです。
    $(LINK2 http://sourceforge.jp/projects/d-action/wiki/FrontPage, D言語でアクションゲームでも作ってみる？(http://sourceforge.jp/projects/d-action/wiki/FrontPage))
)
  $(LI
    D言語用です。
    $(LINK2 http://dlang.org/index.html, D Programing Language 2.0 (http://dlang.org/index.html))
)
  $(LI
    C言語ライブラリのポーティングに Derelict を使っています。
    $(LINK2 https://github.com/DerelictOrg, Derelict (https://github.com/DerelictOrg))
)
  $(LI
    SDL2+OpenGL4.2 環境を想定しています。
    $(LINK2 http://www.libsdl.org/, SDL (http://www.libsdl.org/))
    $(LINK2 http://www.opengl.org/, OpenGL (http://www.opengl.org/))
)
  $(LI
    ドキュメントに JQuery を利用しています。
    $(LINK2 http://jquery.com/, JQuery (http://jquery.com/))
)
)

ライセンス:
$(LINK2 http://creativecommons.org/publicdomain/zero/1.0/, CC0(http://creativecommons.org/publicdomain/zero/1.0/))
<a rel="license" href="http://creativecommons.org/publicdomain/zero/1.0/">
  <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
</a>

開発環境:
以下の環境で開発&amp;動作確認しました。
$(UL
  $(LI Windows Vista x64)
  $(LI dmd 2.069.2)
)


履歴:
$(UL
  $(LI
    2016/01/27 ver. 0.0003(dmd2.069.2)
    全面的に書き直し。
)
  $(LI
    2012/08/18 ver. 0.0002(dmd2.060)
    github デビュー。SDL2.dll、SDL2_image.dll、derelict の更新。あとはいっしょ。
)
  $(LI
    2012/07/16 ver. 0.0001(dmd2.059)
    とりあえずでけた。なんやもうぐだぐだや。
)
)

**/
module sworks.bulletml.ctbml;

import sworks.base.matrix;
import sworks.base.factory;
import sworks.xml;

//------------------------------------------------------------------------------
/// 画面に表示されるキャラクタはこれを実装すべき
interface IPointable
{
    @property @trusted @nogc pure nothrow
    Vector2f point() const; /// キャラクタのグローバル座標
}

//------------------------------------------------------------------------------
/// 位置を変化させるキャラクタはこれを実装すべき。
interface IMovable : IPointable
{
    enum SPEED_SCALE = 3f; /// 謎のマジックナンバー

    @property @trusted @nogc pure nothrow
    {
        float heading() const; /// キャラクタの向き clockwise
        void heading(float); /// ditto
        Vector2f headingVector() const; /// ditto

        /// キャラクタの移動速度。 1フレーム(==1/60sec) で何ピクセル進むか。
        float speed() const;
        void speed(float); /// ditto

        bool alive() const; /// action 要素を消化しきっていない時 → true
        bool willVanish() const; /// vanish() が実行されたかどうか。
    }

    void update(float term); /// 位置を term フレーム更新する。

    /// これが実行されると次の update で activeBullets から消える。
    @trusted @nogc pure nothrow
    void vanish();
}

//------------------------------------------------------------------------------
/// 名前付き
interface ILabelable
{
    @property @trusted @nogc pure nothrow
    string label() const; /// タグのラベル属性に対応している。
}

//------------------------------------------------------------------------------
//
private
interface _IFireController
{
    // Bullet が発射された時に呼ばれる。(from init_bullet())
    @property
    void fireNotice(IBullet);
    @property @trusted @nogc pure nothrow
    IPlayer player(); // プレイヤ情報を返す。
}

//------------------------------------------------------------------------------
/// BulletML のユーザが実装する。
interface IPlayer : IPointable
{
    void fireNotice(IBullet);
}

//------------------------------------------------------------------------------
/// action 要素を表す。
interface IActionFunc : ISlist!IActionFunc
{
    bool update(ref float term);
    void remove();
}

//------------------------------------------------------------------------------
/// bullet 要素を表す。
interface IBullet : ISlist!IBullet, ILabelable, _IFireController, IMovable
{
    enum DEFAULT_SPEED = 1f; /// 値が指定されなかった場合の弾の速度
    /// シューターのタイプ
    enum Type { none, vertical, horizontal, }

    void remove();
    int opApply(scope int delegate(IBullet) dg);

    @property @trusted @nogc pure nothrow:

    bool hasChild() const;
    BulletIterator children(); /// 子
    IBullet parent(); /// 親弾

    /// ユーザ定義のデータを格納できるよ。
    ref BulletData data();

}

//------------------------------------------------------------------------------
/// 方向を示す。画面上向きを 0°として時計回りに 360°で一周を表す。
struct Direction
{
    /// 狙い方
    enum Type { aim, absolute, relative, sequence }
    Type type = Type.aim; ///
    float dir = 0f; /// 360 degree clockwise

    @trusted @nogc pure nothrow
    void clear(){ type = Type.aim; dir = 0f; }
}

//------------------------------------------------------------------------------
/// 速度を表す。1フレームで移動するピクセル数で表されている(と思われる。)l
struct Speed
{
    enum Type { absolute, relative, sequence }
    Type type = Type.absolute;
    float speed = float.nan; /// pixels per frame

    @trusted @nogc pure nothrow
    void clear(){ type = Type.absolute; speed = float.nan; }
}

//------------------------------------------------------------------------------
/**
BulletML ファイルの最外殻を表す。$(BR)
bulletml 要素直下のラベル付き要素に対応した初期化関数が定義されている。$(BR)
例えば、$(BR)
&lt;action label="top"&gt; ... &lt;/action&gt;$(BR)
ならば、$(BR)
BulletML.Action_top で参照できる。$(BR)
同様に、$(BR)
BulletML.Bullet_missile$(BR)
BulletML.Fire_aim1$(BR)
の様に要素を参照することが出来る。
**/
class Bullet(string filename = null) : IBullet
{ mixin SFactoryMix!IBullet SF;

    private string _label;
    private Vector2f _point;
    private float _heading;
    private Vector2f _headingVec;
    private float _speed;
    private IActionFunc _action;
    private bool _willVanish;
    private IBullet _parent;
    private BulletData _data;

    private IPlayer _player;
    private IBullet _children;
    private Vector2f _fireDirection;
    private float _fireSpeed;

    @property @trusted @nogc pure nothrow
    {
        /// 弾の名前
        string label() const { return _label; }
        /// 弾の位置(グローバル座標)
        Vector2f point() const { return _point; }

        /// 弾の向き
        float heading() const { return _heading; }
        /// ditto
        void heading(float h)
        {
            _heading = h % 360f;
            _headingVec = Vector2f(0, 1).rotateVector(-h * TO_RADIAN);
        }
        /// ditto
        Vector2f headingVector() const { return _headingVec; }
        /// 弾の速度
        float speed() const { return _speed; }
        void speed(float f) { _speed = f; }

        /// この弾が狙っているプレイヤ
        IPlayer player() { return _player; }

        /// action 要素を消化しきっている → false
        bool alive() const { return null !is _action; }

        IBullet parent() { return _parent; }
        ref BulletData data() { return _data; }

        /// vanish() が呼び出されたかどうか。
        bool willVanish() const { return _willVanish; }

        /// アクティブ(表示すべき)弾があるかどうか。
        bool hasChild() const { return _children !is null; }
        ///
        BulletIterator children() { return _children.iterator; }
    }

    /**
    この弾と、この弾から発射された弾を term フレーム分更新する。$(BR)
    vanish が実行され、子孫の弾も持たない子の弾は _activeBullets から取り除かれ
    る。
    **/
    void update(float term)
    {
        for (auto ite = _children.iterator ; !ite.empty ;)
        {
            if (!ite.willVanish || ite.hasChild)
            { ite.update(term); ite.popFront; }
            else (cast(This)ite.removeFront).remove;
        }

        _point += _headingVec * (term * _speed * SPEED_SCALE);

        if      (!_willVanish) _action.updateParallel(term);
        else if (null !is _action) { _action.remove; _action = null; }
    }

    /// 弾を消す。この弾の親の次の update 時の巡回で activeBullets から消える。
    @trusted @nogc pure nothrow
    void vanish() { _willVanish = true; }

    private @trusted @nogc pure nothrow
    void onReset(IBullet parent, string label, Vector2f point, float heading,
                 float speed)
    {
        _parent = parent;
        onReset(parent.player, label, point, heading, speed);
    }
    private @trusted @nogc pure nothrow
    void onReset(IPlayer player, string label, Vector2f point, float heading,
                 float speed)
    {
        _player = player;
        _label = label; _point = point; this.heading = heading;
        if (float.nan !is speed) _speed = speed;
        else _speed = DEFAULT_SPEED;
        _willVanish = false;
    }

    private
    void onRemove()
    {
        _parent = null;
        _player = null;
        _data = null;
        if (null !is _action) { _action.remove; _action = null; }
        if (_children !is null) { _children.remove; _children = null; }
    }

    // 子から通達がある。
    @trusted @nogc pure nothrow
    void fireNotice(IBullet bullet)
    {
        _fireDirection = bullet.heading;
        _fireSpeed = bullet.speed;
        _children.pushFront(bullet);
    }

    ///
    int opApply(scope int delegate(IBullet) dg)
    {
        auto result = dg(this);
        if (result == 0 && _children !is null) result = _children.opApply(dg);
        if (result == 0 && _next !is null) result = _next.opApply(dg);
        return result;
    }


    // メンバの登録。
    static if (filename)
        mixin(import(filename).defBMLMembers);
}

//------------------------------------------------------------------------------
/// action 要素を表す。
class Action : IActionFunc
{ mixin SFactoryMix!IActionFunc;

    private string _label;
    private IActionFunc _children;
    private float _fireDirection;
    private float _fireSpeed;

    private @trusted @nogc pure nothrow
    void onReset(string label)
    {
        _label = label;
        _children = null;
        _fireDirection = 0f;
        _fireSpeed = 1f;
    }

    private
    void onRemove()
    { if (null !is _children) _children.remove; _children = null; }

    /// 名前
    @property @trusted @nogc pure nothrow
    string label() const { return _label; }
    /// term フレーム分更新する。
    bool update(ref float term) {  return _children.updateAll(term); }

    // 前回の弾の発射方向
    @property @trusted @nogc pure nothrow
    float fireDirection() const { return _fireDirection; }
    // 前回の弾の発射速度
    @property @trusted @nogc pure nothrow
    float fireSpeed() const { return _fireSpeed; }
    // init_bullet() から呼び出されている。

    @trusted @nogc pure nothrow
    void fireNotice(IBullet bullet)
    {
        _fireDirection = bullet.heading;
        _fireSpeed = bullet.speed;
    }
}

//------------------------------------------------------------------------------
/// アクションを順に更新する。
bool updateAll(ref IActionFunc act, ref float term)
{
    for (auto ite = act.iterator ; !ite.empty ;)
    {
        if     (!ite.update(term)) ite.removeFront.remove;
        else if (0 < term) ite.popFront;
        else break;
    }
    return act !is null;
}

//------------------------------------------------------------------------------
/// 複数のアクションを同時進行で更新する。
bool updateParallel(ref IActionFunc act, ref float term)
{
    bool alive = true;
    for (auto ite = act.iterator ; !ite.empty && alive ;)
    {
        auto t = term;
        auto r = ite.update(t);
        alive &= r;
        if (r) ite.popFront;
        else ite.removeFront.remove;
    }

    return act !is null;
}

//------------------------------------------------------------------------------
/// Fire 要素を表す。Bullet を打ち出す。
class Fire : IActionFunc
{ mixin SFactoryMix!IActionFunc;

    string _label; /// label 属性
    alias BulletGenerator =
        IBullet function(Action, IBullet, Vector2f, float, float, RefParam);
    private BulletGenerator _generator;
    private IBullet _bullet;
    private Action _parent;
    private RefParam _rp;
    private Direction _direction;
    private Speed _speed;

    private @trusted pure
    void onReset(string label, Action parent, IBullet bul, RefParam rp,
                 Direction dir, Speed speed, BulletGenerator bg)
    {
        _label = label; _parent = parent; _bullet = bul; _direction = dir;
        _generator = bg; _rp = rp; _speed = speed;
    }

    private @trusted @nogc pure nothrow
    void onRemove()
    {
        _label = null; _parent = null; _bullet = null; _generator = null;
        _rp = null; _direction.clear; _speed.clear;
    }

    /// 名前
    @property @trusted @nogc pure nothrow
    string label() const { return _label; }

    /// Bullet を打ち出す。
    bool update(ref float term)
    {
        assert(_bullet);
        assert(_bullet.player);
        assert(_generator);
        assert(_parent);
        float heading;
        float s;
        final switch(_direction.type)
        {
        case Direction.Type.aim:
            heading = (_bullet.player.point - _bullet.point).direction +
                _direction.dir;
            break;
        case Direction.Type.sequence:
            heading = _parent.fireDirection + _direction.dir;
            break;
        case Direction.Type.absolute:
            heading = _direction.dir;
            break;
        case Direction.Type.relative:
            heading = _bullet.heading + _direction.dir;
            break;
        }

        final switch(_speed.type)
        {
        case Speed.Type.absolute:
            s = _speed.speed;
            break;
        case Speed.Type.sequence:
            s = _parent.fireSpeed + _speed.speed;
            break;
        case Speed.Type.relative:
            s = _bullet.speed + _speed.speed;
            break;
        }

        _generator(_parent, _bullet, _bullet.point, heading, s, _rp);

        return false;
    }
}

//------------------------------------------------------------------------------
/// 繰り返し
class Repeat : IActionFunc
{ mixin SFactoryMix!IActionFunc;

    private uint _times, _past;
    private IActionFunc _act;
    private IBullet _bullet;
    private Action _parent;
    private RefParam _rp;
    alias ActionInitializer = Action function(Action, IBullet, RefParam);
    private ActionInitializer _initializer;

    private @trusted pure
    void onReset(Action parent, IBullet bullet, RefParam rp, uint t,
                 ActionInitializer initializer)
    {
        _parent = parent; _bullet = bullet; _rp = rp; _times = t;
        _initializer = initializer;
        _past = 0;
        _act = null;
    }

    private @trusted
    void onRemove()
    {
        if (null !is _act) _act.remove; _act = null;
        _past = _times = 0; _bullet = null; _parent = null; _rp = null;
        _initializer = null;
    }

    /// term フレーム更新する。
    bool update(ref float term)
    {
        for (; _past < _times && 0f < term ;)
        {
            if (null is _act)
            {
                _act = _initializer(_parent, _bullet, _rp);
                ++_past;
            }
            _act.updateAll(term);
        }
        return _past < _times;
    }
}


//------------------------------------------------------------------------------
/// フレーム数を指定して、その分待つ。
class Wait : IActionFunc
{ mixin SFactoryMix!IActionFunc;

    private float _wait, _past;

    @trusted @nogc pure nothrow
    {
        void onReset(float w) { _wait = w; _past = 0; }
        void onRemove() { _wait = 0.0; _past = 0.0; }
    }

    bool update(ref float term)
    {
        import std.algorithm : min;
        if (_past < _wait)
        {
            _past += term;
            term = 0;
            return true;
        }
        else
        {
            term -= min(term, _past - _wait);
            return false;
        }
    }
}

//------------------------------------------------------------------------------
/// 弾の方向を変える。
class ChangeDirection : IActionFunc
{ mixin SFactoryMix!IActionFunc;

    enum AIM_PRECISION = 0.08; // 謎のマジックナンバー

    private Direction _direction;
    private float _term, _past, _moment;
    private IBullet _bullet;

    private @trusted @nogc pure nothrow
    void onReset(IBullet bul, float term, Direction direction)
    {
        import std.math : isNaN;

        assert(bul);
        assert(!term.isNaN);
        _bullet = bul; _term = term; _direction = direction;
        _past = 0; _moment = 0;

        final switch(_direction.type)
        {
        case Direction.Type.aim:
            auto delta = (_bullet.player.point - _bullet.point).direction +
                _direction.dir - _bullet.heading;
            if      (180 < delta) delta -= 360;
            else if (delta < -180) delta += 360;
            _moment = delta / _term * AIM_PRECISION;
            break;
        case Direction.Type.relative:
            _moment = _direction.dir / _term;
            break;
        case Direction.Type.absolute:
            auto delta = _direction.dir - _bullet.heading;
            if      (180 < delta) delta -= 360;
            else if (delta < -180) delta += 360;
            _moment = delta / _term;
            break;
        case Direction.Type.sequence:
            _moment = _direction.dir;
            break;
        }
    }

    private @trusted @nogc pure nothrow
    void onRemove(){ _term = _past = _moment = 0; _bullet = null; }


    /// term フレーム更新する。
    bool update(ref float term)
    {
        import std.algorithm : min;
        import std.math;
        assert(_bullet);
        assert(!_term.isNaN);
        assert(!_past.isNaN);
        assert(!_moment.isNaN);

        if (_past < _term)
        {
            auto t = min(_past + term, _term) - _past;
            _bullet.heading = _bullet.heading + _moment * t;
            _past += term;
            return true;
        }
        else return false;
    }
}

//------------------------------------------------------------------------------
/// 弾を消す。(vanish() を実行する。)
class Vanish : IActionFunc
{ mixin SFactoryMix!IActionFunc;
    private IMovable _bullet;

    @trusted @nogc pure nothrow:

    private
    void onReset(IMovable bullet) { this._bullet = bullet; }

    private
    void onRemove() { this._bullet = null; }

    /// vanish() を実行する。
    bool update(ref float term){ _bullet.vanish; return false; }
}

//------------------------------------------------------------------------------
/// 弾の速度を変える。
class ChangeSpeed : IActionFunc
{ mixin SFactoryMix!IActionFunc;
    private IMovable _bullet;
    private float _accel, _speed, _term, _past;

    private @trusted @nogc pure nothrow
    void onReset(IMovable bullet, float term, float speed)
    {
        _bullet = bullet; _term = term; _speed = speed;
        _past = 0;
    }
    private @trusted @nogc pure nothrow
    void onRemove() { _bullet = null; _term = _past = 0f; }

    bool update(ref float term)
    {
        import std.algorithm : min;

        if (0 == _past)
        {
            _accel = (_speed - _bullet.speed) / _term;
        }
        if (_past < this._term)
        {
            auto t = min(_past + term, this._term) - _past;
            _bullet.speed = _bullet.speed + (_accel * t);
            _past += term;
            return true;
        }
        else return false;
    }
}

//------------------------------------------------------------------------------
/// X(Y)軸方向に加速する。
class Accel : IActionFunc
{ mixin SFactoryMix!IActionFunc;
    private IMovable _bullet;
    private float _term, _past;
    private Vector2f _accel;

    private @trusted @nogc pure nothrow
    void onReset(IMovable bullet, float term, float ax, float ay)
    {
        _bullet = bullet; _term = term;
        _accel = Vector2f(ax / term, -ay / term);
        _past = 0;
    }
    private @trusted @nogc pure nothrow
    void onRemove(){ _bullet = null; _term = _past = 0f; }

    ///
    bool update(ref float term)
    {
        import std.algorithm : min;
        if (_past < this._term)
        {
            auto t = min(_past + term, this._term) - _past;
            auto v = (_bullet.headingVector * _bullet.speed) + (_accel * t);
            _bullet.speed = v.length;
            _bullet.heading = v.direction;
            _past += term;
            return true;
        }
        else return false;
    }
}

//------------------------------------------------------------------------------
/// action を参照する。循環参照によるオーバーフローを軽減する為にワンクッション
/// おく。
class ActionRef : IActionFunc
{ mixin SFactoryMix!IActionFunc;
    private Action _parent;
    private IBullet _bullet;
    private RefParam _rp;
    alias Action function(Action, IBullet, RefParam) ActionInitializer;
    private ActionInitializer _initializer;
    private IActionFunc _act;

    private @trusted pure
    void onReset(Action parent, IBullet bul, RefParam rp,
                 ActionInitializer initializer)
    {
        _parent = parent; _bullet = bul; _rp =rp; _initializer = initializer;
        _act = null;
    }

    private @trusted
    void onRemove()
    {
        _parent = null; _bullet = null; _initializer = null;
        if (null !is _act) { _act.remove; _act = null; }
    }

    ///
    bool update(ref float term)
    {
        if (null is _act && null !is _initializer)
            _act = _initializer(_parent, _bullet, _rp);

        if (null !is _act)
            return _act.updateAll(term);
        else
            return false;
    }
}


//------------------------------------------------------------------------------
@trusted pure
string validName(string str)
{
    import std.ascii : isAlphaNum;
    import std.exception : assumeUnique;

    auto result = new char[str.length];
    for (size_t i = 0 ; i < str.length ; ++i)
        result[i] = str[i].isAlphaNum ? str[i] : '_';
    return result.assumeUnique;
}

//------------------------------------------------------------------------------
/// 設定されていない引数は 0f が返る。
struct RefParam
{
    private float[] _val; /// _val[0] == rank
    @trusted pure:

    void opAssign(in RefParam rp) { _val = rp._val.dup; }
    @nogc nothrow
    void opAssign(float[] p ...) { _val = p; }
    @nogc nothrow
    float opIndex(size_t i) const { return i < _val.length ? _val[i] : 0f; }
    void opIndexAssign(float val, size_t i)
    {
        if (_val.length <= i)
        {
            auto pl = _val.length;
            _val.length = i+1;
            _val[pl .. i] = 0f;
        }
        _val[i] = val;
    }
    @nogc nothrow
    const(float)[] opSlice() const { return _val[]; }

    @property @nogc nothrow
    float rank() const { return opIndex(0); }
    @property
    void rank(float r) { opIndexAssign(r, 0); }
}

//------------------------------------------------------------------------------
@trusted @nogc pure nothrow
Matrix4f headingMatrix(Vector2f iy)
{
    auto z = Vector3f(0, 0, 1);
    auto x = Vector3f(iy.y, iy.x, 0);
    auto y = z.cross(x);
    return Matrix4f(x.x, y.x, z.x, 0,
                    x.y, y.y, z.y, 0,
                    x.z, y.z, z.z, 0,
                    0,   0,   0,   1);
}

//------------------------------------------------------------------------------
// OpenGL スタイルのベクタから BulletML スタイルの角度を取り出す。
@trusted @nogc pure nothrow
float direction(Vector2f v)
{
    import std.math : atan2;
    return -atan2(v.y, v.x) * TO_360 + 90;
}

//------------------------------------------------------------------------------
///
alias BulletIterator = SlistIterator!IBullet;

//------------------------------------------------------------------------------
///
class BulletData { }

//##############################################################################
//
// parser
//

string defBMLMembers(string filecont)
{
    import std.array : Appender, join;
    import std.algorithm : startsWith;
    import std.conv : to;

    auto xml = cast(XML)filecont.toXML!(XML_PARSER_PROPERTY.LOWER_CASE);

    Appender!(string[]) firstActions;
    Appender!(string[]) app;
    app.put(["enum type = Type.", xml.attr.get("type", "none"), ";",
             "import std.random : uniform;"]);
    foreach (i, one; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;

        auto label =
            child.attr.get("label", "anonymous_" ~ i.to!string).validName;

        switch(child.name)
        {
        case "action":
            if (label.startsWith("top")) firstActions.put(label);
            app.put(["static Action Action_", label, initAction(label, child)]);
            break;
        case "bullet":
            app.put(["static IBullet Bullet_", label,
                     initBullet(label, child)]);
            break;
        case "fire":
            app.put(["static Fire Fire_", label, initFire(label, child)]);
            break;
        default:
            assert(0);
        }

    }

    app.put(["void onReset(IPlayer player, Vector2f p, float h,",
             "             float speed, float rank)",
             "{", q{
                    SlistAppender!IActionFunc app;
                    onReset(player, filename, p, h, speed);
                    RefParam rp;
                    rp[0] = rank;
                }]);

    foreach (one; firstActions.data)
        app.put(["app.put(Action_", one, "(null, this, rp));"]);

    app.put("    _action = app.flush;"
            "}");
    return app.data.join;
}

//------------------------------------------------------------------------------
string initAction(string label, XML xml)
{
    import std.array : Appender, join;

    Appender!(string[]) app;
    app.put(["(Action parent, IBullet bul, RefParam rp)",
             "{",
             "    SlistAppender!IActionFunc app;",
             "    RefParam rrp;",
             "    auto act = Action(\"", label, "\");"
             "    auto p = null !is parent ? parent : act;"]);

    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;

        switch(child.name)
        {
        case "repeat":
            app.put(["app.put(", initRepeat(child), "(p, bul, rp));"]);
            break;
        case "wait":
            app.put(["app.put(", initWait(child),"(rp));"]);
            break;
        case "fire":
            app.put(["app.put(", initFire("", child), "(p, bul, rp));"]);
            break;
        case "fireref":
            app.put(["rrp = ", readyRef(child), "(rp);",
                     "app.put(Fire_", child.attr["label"], "(p, bul, rrp));"]);
            break;
        case "changespeed":
            app.put(["app.put(", initChangespeed(child), "(bul));"]);
            break;
        case "changedirection":
            app.put(["app.put(", initChangedirection(child), "(bul));"]);
            break;
        case "accel":
            app.put(["app.put(", initAccel(child), "(bul, rp));"]);
            break;
        case "vanish":
            app.put("app.put(Vanish(bul));");
            break;
        case "action":
            app.put(["app.put(", initAction(child.attr["label"], child),
                     "(p, bul, rp));"]);
            break;
        case "actionref":
            app.put(["app.put(", initActionref(child), "(p, bul, rp));"]);
            break;
        default: assert(0);
        }
    }
    app.put(["    act._children = app.flush;",
             "    return act;",
             "}",]);
    return app.data.join;
}

//------------------------------------------------------------------------------
string initFire(string label, XML xml)
{
    import std.array : Appender, join;

    Appender!(string[]) app;

    app.put(["(Action parent, IBullet bul, RefParam rp)",
             "{",
             "    Direction direction;",]);
    string speed = "Speed()";
    string generator;
    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;

        switch(child.name)
        {
        case "bulletref":
            app.put(["rp = ", readyRef(child), "(rp);"]);
            generator = "&Bullet_" ~ child.attr["label"];
            break;
        case "bullet":
            generator = initBullet("", child);
            break;
        case "direction":
            app.put(["direction = ", initDirection(child), ";"]);
            break;
        case "speed":
            speed = initSpeed(child);
            break;
        case "bulletRef":
            assert(0);
        default:
            assert(0, child.name);
        }
    }
    app.put(["    return Fire(\"", label, "\", parent, bul, rp, direction, ",
             speed, ", ", generator, ");",
             "}"]);
    return app.data.join;
}

//------------------------------------------------------------------------------
string initBullet(string label, XML xml)
{
    import std.array : Appender, join;
    Appender!(string[]) app;

    app.put(["(Action act, IBullet parent, Vector2f p, float h, float speed,",
             "RefParam rp)",
             "{",
             "    SlistAppender!IActionFunc app;",
             "    auto b = Bullet(parent, \"", label, "\", p, h, speed);"]);
    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;
        switch (child.name)
        {
        case "action":
            app.put(["app.put(", initAction(child.attr["label"], child),
                     "(null, b, rp));"]);
            break;
        case "speed":
            app.put(["if (float.nan is speed){ b.speed = ",
                     initLazyNumber(child.searchText), ";}"]);
            break;
        default:
            assert(0);
        }

    }
    app.put(["    b._action = app.flush;",
             "    parent.fireNotice(b);",
             "    act.fireNotice(b);",
             "    parent.player.fireNotice(b);",
             "    return cast(IBullet)b;",
             "}"]);
    return app.data.join;
}

//------------------------------------------------------------------------------
string initRepeat(XML xml)
{
    import std.array : join;

    string times, act, rrp = "rp";
    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;
        switch(child.name)
        {
        case "times":
            times = initLazyNumber(child.searchText);
            break;
        case "action":
            act = initAction(child.attr["label"], child);
            break;
        case "actionref":
            act = ["&Action_", child.attr["label"]].join;
            rrp = [readyRef(child), "(rp)"].join;
            break;
        default:
        }
    }
    return ["(Action parent, IBullet bul, RefParam rp){"
            "return Repeat(parent, bul, ", rrp, ", cast(uint)(", times, "), ",
            act, "); }"].join;
}

//------------------------------------------------------------------------------
string initLazyNumber(string str)
{
    import std.array : join;
    import std.algorithm : findSkip, startsWith;
    import std.ascii : isDigit;

    for (auto prev = str ; str.findSkip("$") ; prev = str)
    {
        if      (str[0].isDigit)
            str = [prev[0 .. $ - str.length - 1], "rp[", str[0 .. 1], "]",
                   str[1 .. $]].join;
        else if (str.startsWith("rand"))
            str = [prev[0 .. $ - str.length - 1], "uniform(0f,1f)",
                   str[4 .. $]].join;
        else if (str.startsWith("rank"))
            str = [prev[0 .. $ - str.length - 1], "rp[0]", str[4 .. $]].join;
    }
    if (0 == str.length) str = "0";
    return str;
}

//------------------------------------------------------------------------------
string readyRef(XML xml)
{
    import std.conv : to;
    import std.array : Appender, join;
    Appender!(string[]) app;
    app.put("(RefParam rp)"
            "{"
            "    RefParam rrp;"
            "    rrp[0] = rp[0];");

    size_t i;
    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;
        if (child.name == "param")
            app.put(["rrp[", (++i).to!string, "] = ",
                     initLazyNumber(child.searchText), ";"]);
    }
    app.put("    return rrp;"
            "}");
    return app.data.join;
}

//------------------------------------------------------------------------------
string initDirection(XML xml)
{
    import std.array : join;
    string type;
    switch (xml.attr["type"])
    {
    case "absolute":
        type = "Direction.Type.absolute";
        break;
    case "relative":
        type = "Direction.Type.relative";
        break;
    case "sequence":
        type = "Direction.Type.sequence";
        break;
    default:
        type = "Direction.Type.aim";
    }

    return ["Direction(", type, ", ", initLazyNumber(xml.searchText), ")"].join;
}

//------------------------------------------------------------------------------
string initWait(XML xml)
{
    import std.array : join;
    return ["(RefParam rp){ return Wait(", initLazyNumber(xml.searchText),
            "); }"].join;
}


//------------------------------------------------------------------------------
string initChangedirection(XML xml)
{
    import std.array : Appender, join;

    string term = "0";
    Appender!(string[]) app;
    app.put("(IBullet bul){"
            "    Direction direction;"
            "    float term = 0;");
    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;
        switch (child.name)
        {
        case "term":
            app.put(["term = ", initLazyNumber(child.searchText), ";"]);
            break;
        case "direction":
            app.put(["direction = ", initDirection(child), ";"]);
            break;
        default:
            assert(0, child.name);
        }
    }
    app.put("    return ChangeDirection(bul, term, direction);"
            "}");
    return app.data.join;
}


//------------------------------------------------------------------------------
string initSpeed(XML xml)
{
    import std.array : join;
    string type;
    switch (xml.attr["type"])
    {
    case "relative":
        type = "Speed.Type.relative";
        break;
    case "sequence":
        type = "Speed.Type.sequence";
        break;
    default:
        type = "Speed.Type.absolute";
    }
    return ["Speed(", type, ", ", initLazyNumber(xml.searchText), ")"].join;
}

//------------------------------------------------------------------------------
string initChangespeed(XML xml)
{
    import std.array : join;
    string speed = "0", term = "0";
    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;
        switch (child.name)
        {
        case "speed":
            speed = initLazyNumber(child.searchText);
            break;
        case "term":
            term = initLazyNumber(child.searchText);
            break;
        default:
            assert(0);
        }
    }
    return ["(IMovable bul){ return ChangeSpeed(bul, ", term, ", ", speed,
            "); }"].join;
}

//------------------------------------------------------------------------------

string initActionref(XML xml)
{
    import std.array : join;
    return
        ["(Action parent, IBullet bul, RefParam rp){"
         "    return ActionRef(parent, bul, ", readyRef(xml),
         "(rp), &Action_", xml.attr["label"], "); }"].join;
}

//------------------------------------------------------------------------------
string initAccel(XML xml)
{
    import std.array : join;
    string horz = "0", vert = "0", term = "0";
    foreach (one ; xml.children)
    {
        auto child = cast(XML)one;
        if (child is null) continue;
        switch (child.name)
        {
        case "term":
            term = initLazyNumber(child.searchText);
            break;
        case "horizontal":
            horz = initLazyNumber(child.searchText);
            break;
        case "vertical":
            vert = initLazyNumber(child.searchText);
            break;
        default:
            assert(0);
        }
    }
    return
        ["(IMovable bul, RefParam rp)"
         "{"
         "    return Accel(bul, ", term, ", ", horz, ", ", vert, ");"
         "}"].join;
}



//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DEBUG
debug(bulletml):
import std.math;
import sworks.sdl.util;
import sworks.sdl.gl;
import sworks.sdl.image;
import sworks.gl.glsl;
import sworks.base.dump_members;

void main()
{
    setDLLDir("bin64");
    auto wnd = new BMLTest;
    scope(exit) wnd.clear;
    wnd.start;
}

class BMLTest
{ mixin SDLIdleMix!() SWM;
static:
    enum WIDTH = 640;
    enum HEIGHT = 480;
    enum hitDistanceSq = 50;

    GLWindow window;
    IBullet battery;

    Drawer drawer;
    PlaneDrawer plane;     /// Player's plane.
    CannonDrawer cannon;
    BulletsDrawer bullets;
    SmokeManager smoke;
    Setsumei setsumei;


    this()
    {
        SWM.init(SDL_INIT_VIDEO, 33,
                 getImageInitializer(IMG_INIT_JPG),
                 getGLInitializer!DerelictGL3(true, 0, 8, 8, 8, 8),
                 {
                     window = new GLWindow("BulletML Test", WIDTH, HEIGHT);
                     return cast(SDLExtQuitDel){};
                 });
        reloadGL(3.0, 1.30);

        glClearColor(0.2, 0.2, 0.2, 1.0);

        glViewport(0, 0, WIDTH, HEIGHT);

        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        drawer = new Drawer(WIDTH, HEIGHT);
        plane = new PlaneDrawer(drawer, Vector2f(1, 0));
        cannon = new CannonDrawer(drawer, 200, 0);
        bullets = new BulletsDrawer(drawer);
        smoke = new SmokeManager(drawer);

        version      (Windows)
            setsumei = new Setsumei("img\\setsumei.jpg");
        else version (linux)
            setsumei = new Setsumei("img/setsumei.jpg");

        genBullet;
    }

    void genBullet()
    {
        auto b = BulletManager.newBullet(plane, 0.5, plane.heading, cannon.pos,
                                         cannon.heading);
        battery.pushFront(b);
        SDL_SetWindowTitle(window, b.label.ptr);
    }


    void clear()
    {
        setsumei.clear;
        Drawer.clearAll;
        SWM.clear;
    }

    static bool isOutOfWindow(Vector2f pos)
    {
        return
            pos.x < -WIDTH*0.5 || WIDTH*0.5 < pos.x ||
            pos.y < -HEIGHT*0.5 || HEIGHT*0.5+100 < pos.y;
    }


    private uint _shotInterval;
    void update(uint interval)
    {
        auto term = (cast(float)interval) * 0.06f;

        smoke.update(term);

        bool is_alive = false;

        for (auto ite = battery.iterator ; !ite.empty ;)
        {
            if (ite.alive || ite.hasChild)
            {
                ite.update(term);
                is_alive |= ite.alive;
                ite.popFront;
            }
            else ite.removeFront.remove;
        }

        if (battery !is null) foreach (one; battery)
        {
            if      (one.willVanish){}
            else if (isOutOfWindow(one.point)) one.vanish;
            else if (plane.pos.distanceSq(one.point) <= 50)
                smoke.hit(one.point);
        }

        if (!is_alive)
        {
            _shotInterval += interval;
            if (1000 < _shotInterval)
            {
                genBullet;
                _shotInterval = 0;
            }
        }
    }

    void draw()
    {
        glClear(GL_COLOR_BUFFER_BIT);

        setsumei.draw();

        smoke.draw();

        if (battery !is null) foreach (one; battery)
            if (!one.willVanish && one.parent !is null)
                bullets.draw(one);

        cannon.draw;
        plane.draw;

        SDL_GL_SwapWindow(window);
    }
    void sdl_mousemotion(in ref SDL_MouseMotionEvent e)
    {
        int x = cast(int)(e.x - WIDTH * 0.5);
        int y = -cast(int)(e.y - HEIGHT * 0.5);
        plane.update(x, y);
    }

    void sdl_mousebuttondown(in ref SDL_MouseButtonEvent e)
    {
        if (1 == e.button)
        {
            for (auto ite = battery.iterator; !ite.empty;)
                ite.popFront.vanish;
            BulletManager.nextBullet;
            _shotInterval = 0;
            genBullet;
        }
    }
}



class MyBulletData : BulletData
{
    float[4] color;
    this(float[4] c ...){ color[] = c; }
}

struct BulletManager
{
    import std.typetuple : TypeTuple;

    alias Data = TypeTuple!(
        Bullet!"test-bml1.xml",
        Bullet!"test-bml2.xml",
        Bullet!"test-bml3.xml",
        Bullet!"[1943]_rolling_fire.xml",
        Bullet!"[Guwange]_round_2_boss_circle_fire.xml",
        Bullet!"[Guwange]_round_3_boss_fast_3way.xml",
        Bullet!"[Guwange]_round_4_boss_eye_ball.xml",
        Bullet!"[G_DARIUS]_homing_laser.xml",
        Bullet!"[Progear]_round_1_boss_grow_bullets.xml",
        Bullet!"[Progear]_round_2_boss_struggling.xml",
        Bullet!"[Progear]_round_3_boss_back_burst.xml",
        Bullet!"[Progear]_round_3_boss_wave_bullets.xml",
        Bullet!"[Progear]_round_4_boss_fast_rocket.xml",
        Bullet!"[Progear]_round_5_boss_last_round_wave.xml",

        Bullet!"[Progear]_round_6_boss_parabola_shot.xml",

        Bullet!"[Psyvariar]_X-A_boss_opening.xml",
        Bullet!"[Psyvariar]_X-A_boss_winder.xml",
        Bullet!"[Psyvariar]_X-B_colony_shape_satellite.xml",
        Bullet!"[XEVIOUS]_garu_zakato.xml",
);

    static size_t current;

    static
    IBullet newBullet(IPlayer player, float rank,
                      ref Vector2f player_heading, ref Vector2f cannon_pos,
                      ref Vector2f cannon_heading)
    {
        IBullet _call(T)()
        {
            import std.random : uniform;
            float heading = 0;
            if (IBullet.Type.horizontal == T.type)
            {
                heading = 270;
                player_heading = Vector2f(1, 0);
                cannon_heading = Vector2f(-1, 0);
                cannon_pos = Vector2f(uniform(180f, 220f),
                                      uniform(-100f, 100f));
            }
            else
            {
                heading = 180;
                player_heading = Vector2f(0, 1);
                cannon_heading = Vector2f(0, -1);
                cannon_pos = Vector2f(uniform(-150f, 150f),
                                      uniform(130f, 180f));
            }
            return T(player, cannon_pos, heading, 0, rank);
        }
        foreach (i, one; Data)
            if (i == current) return _call!one;
        return null;
    }

    static void nextBullet()
    {
        ++current;
        if (Data.length <= current) current = 0;
    }
}

class Drawer
{
    Matrix4f projlook;
    TetrahedronLine tl;

    IdentityCubePoly cp;

    this(int w, int h)
    {
        projlook =
            orthoMatrix4f(-w * 0.5, w * 0.5, -h * 0.5, h * 0.5, 0, 20) *
            lookAtMatrix4f([0, 0, 10], [0, 0, 0], [0, 1, 0]);

        tl = new TetrahedronLine;
        tl.size = scaleMatrix4f(5, 10, 5);
        cp = new IdentityCubePoly;
    }

    void drawTri(float[2] pos, Vector2f heading, float[4] color)
    {
        tl.diffuse = Color4f(color);
        tl.pos = translateMatrix4f(pos[0], pos[1], 0) * headingMatrix(heading);
        tl.draw(projlook);
    }

    void drawCube(float[2] pos, Vector2f heading, float size, float[4] color)
    {
        cp.diffuse = Color4f(color);
        cp.pos = translateMatrix4f(pos[0], pos[1], 0) * headingMatrix(heading);
        cp.size = scaleMatrix4f(size, size, size);
        cp.draw(projlook);

    }

    static void clearAll()
    {
        TetrahedronLine.clearAll;
        IdentityCubePoly.clearAll;
    }
}

class PlaneDrawer : IPlayer
{
    Drawer drawer;

    float[4] color;
    Vector2f pos;
    float x, y;
    Vector2f heading;

    this(Drawer d, Vector2f h)
    {
        drawer = d;
        heading = h;
        color = [1f, 1, 1, 1];
        x = 0; y = -150;
    }

    void update(float[2] p ...) { pos[] = p; }

    void draw() { drawer.drawTri(pos, heading, color); }

    @property @trusted @nogc pure nothrow
    Vector2f point() const { return pos; }

    void fireNotice(IBullet bullet)
    {
        import std.random : uniform;

        if (null is bullet.parent || null is bullet.parent.data)
            bullet.data = new MyBulletData(uniform(0.4f, 1f), uniform(0.4f, 1f),
                                           uniform(0.4f, 1f), 1.0);
        else
            bullet.data = bullet.parent.data;
    }
}

class CannonDrawer
{
    Drawer drawer;
    float[4] color;
    Vector2f pos;
    Vector2f heading;

    this(Drawer d, float x, float y)
    {
        drawer = d;
        pos = Vector2f(x, y);
        color = [1f, 0, 0, 1];
        heading = Vector2f(0, 1);
    }
    void draw() { drawer.drawTri(pos, heading, color); }
}

class BulletsDrawer
{
    Drawer drawer;
    float[4] color;

    this(Drawer d)
    {
        drawer = d;
        color = [1f, 0.5, 0.5, 1];
    }

    void draw(IBullet b)
    {
        auto mbd = cast(MyBulletData)(b.data);
        float[4] c;
        if (null !is mbd) c[] = mbd.color;
        else c = [0f, 0f, 0f, 1];

        drawer.drawTri(b.point, b.headingVector, c);
    }
}

class SmokeManager
{
    Drawer drawer;
    RedSmoke bank;


    this(Drawer d)
    {
        drawer = d;
    }

    void update(float term)
    {
        for (auto ite = bank.iterator ; !ite.empty ;)
        {
            assert(ite);
            ite.update(term);
            if (ite.life <= 0.0) ite.removeFront.remove;
            else ite.popFront;
        }
    }

    void draw()
    {
        for (auto ite = bank.iterator ; !ite.empty ; ite.popFront)
        {
            float[4] color = [1f, 0, 0, 0.4 * ite.life / ite.MAX_LIFE];
            auto h = Vector2f(0, 1).rotate(ite.life * TO_RADIAN);
            drawer.drawCube(ite.center, h, 10, color);
        }
    }
    void clear() { if (bank) bank.remove; bank = null; }

    void hit(Vector2f pos) { bank.pushFront(RedSmoke(pos)); }
}


class RedSmoke : ISlist!RedSmoke
{ mixin SFactoryMix!RedSmoke;

    enum MAX_LIFE = 120.0f;
    Vector2f center;
    float life;
    Vector2f velocity;
    float speed;

    private
    void onReset(Vector2f pos)
    {
        import std.random : uniform;
        center = pos;
        life = MAX_LIFE;
        velocity = Vector2f(1, 0).rotate(uniform(-PI, PI));
        speed = 0.4;
    }

    void update(float term)
    {
        life -= term;
        center += velocity * (speed * term);
    }
}

class Setsumei
{
    import sworks.gl.glsl;

    enum vertexShader =
    q{ #version 130
        in vec2 position;
        in vec2 texcoord;

        out vec2 f_texcoord;

        void main()
        {
            gl_Position = vec4(position, 0.0, 1.0);
            f_texcoord = texcoord;
        }
    };

    enum fragmentShader =
    q{ #version 130
        in vec2 f_texcoord;
        uniform sampler2D texture1;

        out vec4 colorOut;

        void main()
        {
            colorOut = texture2D(texture1, f_texcoord);
        }
    };

    alias SProgram = CTShaderProgram!(vertexShader, fragmentShader);

    struct Vertex
    {
        float[2] position;
        float[2] texcoord;
        this(float[4] p ...){ position[] = p[0 .. 2]; texcoord = p[2 .. 4]; }
    }
    enum vertex = [Vertex(-0.9, 0.8,  0, 1), Vertex(-0.2, 0.8, 1, 1),
                   Vertex(-0.2, 1, 1, 0), Vertex(-0.9, 1, 0, 0)];
    enum uint[] index = [0, 1, 2, 3];

    SProgram prog;
    VertexObject!Vertex vo;
    IndexObject!(Vertex, uint) io;
    Texture2DRGBA32 tex;


    this(const(char)* texfile)
    {
        prog = new SProgram;
        vo = prog.makeVertex(vertex);
        tex = loadTexture2DRGBA32(texfile);
        io = vo.makeIndex(index, prog,  ["texture1": tex.id]);
    }

    void draw()
    {
        prog.use;
        vo.use;
        io.use;

        io.draw(GL_TRIANGLE_FAN);
    }

    void clear()
    {
        if (io) io.clear; io = null;
        if (vo) vo.clear; vo = null;
        if (prog) prog.clear; prog = null;
        if (tex) tex.clear; tex = null;
    }
}
