/** Compile-Time BulletML Parser.
 * Version:      0.0002(dmd2.060)
 * Date:         2012-Aug-18 21:51:50
 * Authors:      KUMA
 * License:      CC0
*/
module sworks.bulletml.ctbml;

import std.algorithm, std.ascii, std.string, std.conv, std.array, std.random, std.exception;
import sworks.compo.util.matrix;
import sworks.compo.util.factory;

/*############################################################################*\
|*#                                                                          #*|
|*#                         Compile-Time XML Parser                          #*|
|*#                                                                          #*|
\*############################################################################*/
/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                               parseXMLTag                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
/// 文字列を XMLTag にする。
XMLTag parseXMLTag( ref string cont )
{
	XMLTag result;
	cont.stripLeftXML;
	if( 0 == cont.length ) return result;
	if( '<' == cont[0] )
	{
		cont = cont[ 1 .. $ ];
		result.name = cont.until!"!std.ascii.isAlpha(a)".to!string;
		cont = cont[ result.name.length .. $ ];
		result.attributes = parseAttribute( cont );
		if( 0 == cont.length ) return result;
		if     ( cont.startsWith("/>") ) { cont = cont[ 2 .. $ ]; return result; }
		else if( '>' != cont[0] ) return result;
		cont = cont[ 1 .. $ ];
		for( ; ; )
		{
			cont.stripLeftXML;
			if( 0 == cont.length ) return result;
			if( cont.startsWith( "</" ) )
			{
				if( !cont.findSkip(">") ) cont = "";
				return result;
			}
			else{ result.children ~= parseXMLTag( cont ); }
		}
	}
	else
	{
		auto t = cont.until('<').to!string;
		cont = cont[ t.length .. $ ];
		result.text = t.strip;
	}

	return result;
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                  XMLTag                                  |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// XML 構造を表現する。
struct XMLTag
{
	string name; /// タグの名前
	string[string] attributes; /// 属性
	string _text; /// text
	XMLTag[] children; /// 子要素

	/// 属性を検索する。
	string opIndex( string key )
	{
		if( key in attributes ) return attributes[ key ];
		else return "";
	}
	/// ditto
	string get( string key, lazy string def )
	{
		if( key in attributes ) return attributes[key];
		else
		{
			attributes[ key ] = def;
			return def;
		}
	}

	/// 属性を適用する。
	void opIndexAssign( string val, string key ) { attributes[ key ] = val; }

	/// 文字列を設定、検索する。
	void text( string t ) @property { _text = t; }
	/// ditto
	string text() @property const
	{
		if( 0 < _text.length ) return _text;
		else
		{
			string result;
			foreach( child ; children )
			{
				result = child.text;
				if( 0 < result.length ) break;
			}
			return result;
		}
	}
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                               stripLeftXML                               |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
/// 文字列先頭から XML における、空白、コメントなどを取り除く。
void stripLeftXML( ref string cont )
{
	for(;;)
	{
		cont = cont.stripLeft;
		if     ( 0 == cont.length ) break;
		else if( 0 < cont.startsWith( "<!--" ) )
		{
			cont = cont[ 4 .. $ ];
			if( !cont.findSkip( "-->" ) ) { cont = cont[ $ .. $ ]; break; }
		}
		else if( '<' == cont[0] && 1 < cont.length && ( '!' == cont[1] || '?' == cont[1] ) )
		{
			cont = cont[ 2 .. $ ];
			if( !cont.findSkip( ">" ) ) { cont = cont[ $ .. $ ]; break; }
		}
		else break;
	}
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                              parseAttribute                              |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
/// 「label="hello" type="vertical"> ...」みたいな文字列から Attribute の連想配列を取り出す。
string[string] parseAttribute( ref string cont )
{
	string[string] result;
	string rest, key, val;
	for( ; ; )
	{
		cont = cont.stripLeft;
		if( 0 == cont.length ) return result;
		if( '>' == cont[0] || '/' == cont[0] ) break;
		key = cont.until('=').to!string;
		if( 0 == key.length ) break;;
		cont = cont[ key.length .. $ ];
		key.strip;
		if( !cont.findSkip("\"") ) { cont = ""; break; }
		val = cont.until('"').to!string;
		if( 0 == val.length ) { cont = ""; break; }
		result[ key ] = val;
		cont = cont[ val.length + 1 .. $ ];
	}
	return result;
}

/*############################################################################*\
|*#                                                                          #*|
|*#                                 BulletML                                 #*|
|*#                                                                          #*|
\*############################################################################*/
/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*\
|*|                                IPointable                                |*|
\*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/// 画面に表示されるキャラクタはこれを実装すべき
interface IPointable
{
	Vector2f point() @property const; /// キャラクタのグローバル座標
}
/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*\
|*|                                 IMovable                                 |*|
\*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/// 位置を変化させるキャラクタはこれを実装すべき。
interface IMovable : IPointable
{
	enum SPEED_SCALE = 3f; /// 謎のマジックナンバー

	float heading() @property const; /// キャラクタの向き clockwise
	void heading( float ) @property; /// ditto
	Vector2f headingVector() @property const; /// ditto

	float speed() @property const; /// キャラクタの移動速度 1フレーム(==1/60sec) で何ピクセル進むか。
	void speed( float ) @property; /// ditto

	bool isActive() @property const; /// action 要素を消化しきっていない時 → true
	bool willVanish() @property const; /// vanish() が実行されたかどうか。
	void update( float term ); /// 位置を term フレーム更新する。
	void vanish(); /// これが実行されると次の update で activeBullets から消える。
}
/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*\
|*|                                ILabelable                                |*|
\*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/// 名前付き
interface ILabelable
{
	string label() @property const; /// タグのラベル属性に対応している。
}

/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*\
|*|                             _IFireController                             |*|
\*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
private interface _IFireController
{
	void fireNotice( IBullet ) @property; // Bullet が発射された時に呼ばれる。( from init_bullet() )
	IPlayer player() @property; // プレイヤ情報を返す。
}

/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*\
|*|                                 IPlayer                                  |*|
\*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/// BulletML のユーザが実装する。
interface IPlayer : IPointable
{
	void fireNotice( IBullet );
}

/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*\
|*|                               IActionFunc                                |*|
\*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/// action 要素を表す。
interface IActionFunc : ISlist!IActionFunc
{
	bool update( ref float term );
}

/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*\
|*|                                 IBullet                                  |*|
\*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/// bullet 要素を表す。
interface IBullet : ISlist!IBullet, ILabelable, _IFireController, IMovable, IPointable //<ここに IPointable が必要なのはおそらくバグ。
{
	enum DEFAULT_SPEED = 1f; /// 値が指定されなかった場合の弾の速度
	/// シューターのタイプ
	enum TYPE { NONE, VERTICAL, HORIZONTAL, }

	ref ActiveIBulletsIterator activeBullets() @property; /// 現在アクティブな弾を巡回する。
	bool hasActiveBullets() @property const; /// 現在、アクティブな弾が存在するかどうか。

	IBullet parent() @property; /// 親弾

	/// ユーザ定義のデータを格納できるよ。
	BulletData data() @property;
	void data( BulletData ) @property;
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                          ActiveIBulletsIterator                          |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// IBullet とその中の アクティブな弾を巡回する。
struct ActiveIBulletsIterator
{
	private IBullet _base;
	private IBullet _front;
	private ActiveIBulletsIterator* _current;
	alias _front this;
	
	this( IBullet b ) { this._base = this._front = b; _current = null; }

	bool empty() @property const { return null is _front; }

	IBullet front() @property { return _front; }

	void popFront() @property
	{
		if     ( null is _base ){ }
		else
		{
			if( null !is _current ) _current.popFront;
			else _current = &(_base.activeBullets());

			if( !_current.empty ) _front = _current.front;
			else { _base = _front = _base.next; _current = null; }
		}
	}
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                  Bullet                                  |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// 弾
class Bullet : IBullet
{ mixin SFactory!IBullet;

	private string _label;
	private Vector2f _point;
	private float _heading;
	private Vector2f _heading_vec;
	private float _speed;
	private IActionFunc _action;
	private bool _will_vanish;
	private IBullet _parent;
	private BulletData _data;

	private IPlayer _player;
	private BulletBank _active_bullets;
	private Vector2f _fire_direction;
	private float _fire_speed;
	private ActiveIBulletsIterator _active_iterator;

	/// 弾の名前
	string label() @property const { return _label; }
	/// 弾の位置(グローバル座標)
	Vector2f point() @property const { return _point; }
	/// 弾の向き
	float heading() @property const { return _heading; }
	/// ditto
	void heading( float h ) @property
	{
		this._heading = h % 360f;
		this._heading_vec = Vector2f( 0, 1 ).rotateVector( - h * TO_RADIAN );
	}
	/// ditto
	Vector2f headingVector() @property const { return _heading_vec; }
	/// 弾の速度
	float speed() @property const { return _speed; }
	/// ditto
	void speed( float s ) @property { this._speed = s; }

	/// この弾が狙っているプレイヤ
	IPlayer player() @property { return _player; }

	/// action 要素を消化しきっている → false
	bool isActive() @property const { return null !is _action; }

	IBullet parent() @property { return _parent; }
	BulletData data() @property { return _data; }
	void data( BulletData bd ) @property { _data = bd; }

	/**
	 * この弾と、この弾から発射された弾を term フレーム分更新する。$(BR)
	 * vanish が実行され、子孫の弾も持たない子の弾は activeBullets から取り除かれる。
	 */
	void update( float term )
	{
		for( auto ite = _active_bullets.iterator ; !ite.empty ; )
		{
			if( !ite.willVanish || ite.hasActiveBullets ) { ite.update( term ); ite.popFront; }
			else ite.popAndRemoveFront;
		}

		_point += _heading_vec * ( term * _speed * SPEED_SCALE );

		if     ( !_will_vanish ) _action.update_parallel( term );
		else if( null !is _action ) { _action.remove_all; _action = null; }
	}

	/// 弾を消す。この弾の親の次の update 時の巡回で activeBullets から消える。
	void vanish()
	{
		_will_vanish = true;
	}
	/// vanish() が呼び出されたかどうか。
	bool willVanish() @property const { return _will_vanish; }

	private void onReset( IBullet parent, string label, Vector2f point, float heading, float speed )
	{
		this._parent = parent;
		onReset( parent.player, label, point, heading, speed );
	}
	private void onReset( IPlayer player, string label, Vector2f point, float heading, float speed )
	{
		this._player = player;
		this._label = label; this._point = point; this.heading = heading;
		if( float.nan !is speed ) this._speed = speed;
		else this._speed = DEFAULT_SPEED;

		_will_vanish = false;
	}
	private void onRemove()
	{
		this._parent = null;
		this._player = null;
		if( null !is _action ) { _action.remove_all; _action = null; }
		_active_bullets.clear;
	}

	// 子から通達がある。
	void fireNotice( IBullet bullet ) @property
	{
		_fire_direction = bullet.heading;
		_fire_speed = bullet.speed;
		_active_bullets += bullet;
	}

	/// アクティブ(表示すべき)弾があるかどうか。
	bool hasActiveBullets() @property const { return !_active_bullets.empty; }
	/// アクティブな弾を巡回する。
	ref ActiveIBulletsIterator activeBullets() @property
	{
		_active_iterator = ActiveIBulletsIterator( _active_bullets.front );
		return _active_iterator;
	}
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                               init_bullet                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_bullet( XMLTag xml )
{
	string result =
		"( Action act, IBullet parent, Vector2f p, float h, float speed, RefParam rp )"
		"{"
		"    SlistAppender!IActionFunc app;"
		"    auto b = Bullet( parent, \"" ~ xml["label"] ~ "\", p, h, speed );";
	foreach( child ; xml.children )
	{
		if     ( 0 == "action".icmp( child.name ) ) result ~= "app.put(" ~ init_action(child) ~ "( null, b, rp ));";
		else if( 0 == "speed".icmp( child.name ) )
			result ~= "if( float.nan is speed ){ b.speed = " ~ lazy_number( child.text ) ~ ";}";
	}
	result ~=
		"    b._action = app.flush;"
		"    parent.fireNotice( b );"
		"    act.fireNotice( b );"
		"    parent.player.fireNotice( b );"
		"    return b;"
		"}";
	return result;
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                 BulletML                                 |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/**
 * BulletML ファイルの最外殻を表す。$(BR)
 * bulletml 要素直下のラベル付き要素に対応した初期化関数が定義されている。$(BR)
 * 例えば、$(BR)
 * &lt;action label="top"&gt; ... &lt;/action&gt;$(BR)
 * ならば、$(BR)
 * BulletML.Action_top で参照できる。$(BR)
 * 同様に、$(BR)
 * BulletML.Bullet_missile$(BR)
 * BulletML.Fire_aim1$(BR)
 * の様に要素を参照することが出来る。
 */
class BulletML(string filename) : Bullet
{ mixin SFactory!IBullet SF;

	void onReset( IPlayer p, Vector2f point, float heading, float speed )
		{ super.onReset( p, filename, point, heading, speed ); }
	void onRemove() { super.onRemove(); }
	// bulletml 直下の、action 要素、bullet 要素及び fire 要素を表わすクラスのインスタンスを返す関数を定義する。
	mixin( import(filename).def_bullet_members );
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                            def_bullet_members                            |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string def_bullet_members( string filecont )
{
	auto xml = parseXMLTag( filecont );
	string type = xml["type"];
	if     ( 0 == "vertical".icmp(type) ) type = "TYPE.VERTICAL";
	else if( 0 == "horizontal".icmp(type) ) type = "TYPE.HORIZONTAL";
	else type = "TYPE.NONE";

	string result = "enum type = " ~ type ~ ";";
	foreach( i, child ; xml.children )
	{
		auto label = child["label"].valid_name;
		if( 0 == label.length ) label = "anonymous_" ~ i.to!string;
		child["label"] = label;
		if     ( 0 == "action".icmp( child.name ) )
			result ~= "static Action Action_" ~ label ~ init_action(child);
		else if( 0 == "bullet".icmp( child.name ) )
			result ~= "static Bullet Bullet_" ~ label ~ init_bullet(child);
		else if( 0 == "fire".icmp( child.name ) )
			result ~= "static Fire Fire_" ~ label ~ init_fire(child);
	}

	result ~=
		"static IBullet opCall( IPlayer player, Vector2f p, float h, float speed, float rank )"
		"{"
		"    SlistAppender!IActionFunc app;"
		"    auto b = SF.opCall( player, p, h, speed );"
		"    RefParam rp; rp[0] = rank;";
	foreach( child ; xml.children )
	{
		if( 0 == "action".icmp( child.name ) && child["label"].startsWith( "top" ) )
			result ~= "app.put( Action_" ~ child["label"] ~ "( null, b, rp ) );";
	}
	result ~=
		"    b._action = app.flush;"
		"    return b;"
		"}";
	return result;
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                  Action                                  |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// action 要素を表す。
class Action : IActionFunc
{ mixin SFactory!IActionFunc;

	private string _label;
	private IActionFunc _children;
	private float _fire_direction;
	private float _fire_speed;

	private void onReset( string label )
	{
		this._label = label;

		_fire_direction = 0f;
		_fire_speed = 1f;
	}

	private void onRemove() { if( null !is _children ) { _children.remove_all; _children = null; } }

	/// 名前
	string label() @property const { return _label; }
	/// term フレーム分更新する。
	bool update( ref float term ) {  return _children.update_all( term ); }

	// 前回の弾の発射方向
	float fireDirection() @property { return _fire_direction; }
	// 前回の弾の発射速度
	float fireSpeed() @property { return _fire_speed; }
	// init_bullet() から呼び出されている。
	void fireNotice( IBullet bullet )
	{
		this._fire_direction = bullet.heading;
		this._fire_speed = bullet.speed;
	}
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                               init_action                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_action( XMLTag xml )
{
	string result =
		"( Action parent, IBullet bul, RefParam rp )"
		"{"
		"    SlistAppender!IActionFunc app;"
		"    RefParam rrp;"
		"    auto act = Action( \"" ~ xml["label"] ~ "\" );"
		"    auto p = null !is parent ? parent : act;";
	foreach( child ; xml.children )
	{
		if     ( 0 == "repeat".icmp( child.name ) )
			result ~= "app.put(" ~ init_repeat(child) ~ "( p, bul, rp ));";
		else if( 0 == "wait".icmp( child.name ) ) result ~= "app.put(" ~ init_wait(child) ~"(rp) );";
		else if( 0 == "fire".icmp( child.name ) )
			result ~= "app.put(" ~ init_fire(child) ~ "( p, bul, rp ) );";
		else if( 0 == "fireref".icmp( child.name ) )
		{
			result ~= "rrp = " ~ ready_ref(child) ~ "(rp);";
			result ~= "app.put( Fire_" ~ child["label"] ~ "( p, bul, rrp ) );";
		}
		else if( 0 == "changespeed".icmp( child.name ) )
			result ~= "app.put(" ~ init_changespeed(child) ~ "( bul ) );";
		else if( 0 == "changedirection".icmp( child.name ) )
			result ~= "app.put(" ~ init_changedirection(child) ~ "( bul ) );";
		else if( 0 == "accel".icmp( child.name ) ) result ~= "app.put(" ~ init_accel(child) ~ "( bul, rp ) );";
		else if( 0 == "vanish".icmp( child.name ) ) result ~= "app.put( Vanish( bul ) );";
		else if( 0 == "action".icmp( child.name ) )
			result ~= "app.put( " ~ init_action(child) ~ "( p, bul, rp ) );";
		else if( 0 == "actionref".icmp( child.name ) )
			result ~= "app.put( " ~ init_actionref(child) ~ "( p, bul, rp ) );";
	}
	result ~=
		"    act._children = app.flush;"
		"    return act;"
		"}";
	return result;
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                update_all                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
/// アクションを順に更新する。
bool update_all( ref IActionFunc act, ref float term )
{
	for( auto ite = act.iterator ; !ite.empty ; )
	{
		if     ( !ite.update( term ) ) ite.popAndRemoveFront;
		else if( 0 < term ) ite.popFront;
		else break;
	}
	return null !is act;
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                             update_parallel                              |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
/// 複数のアクションを同時進行で更新する。
bool update_parallel( ref IActionFunc act, ref float term )
{
	bool alive = true;
	for( auto ite = act.iterator ; !ite.empty && alive ; ite.popFront )
	{
		auto t = term;
		alive &= ite.update( t );
	}
	if( !alive ) { act.remove_all(); act = null; }
	
	return null !is act;
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                Direction                                 |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// 方向を示す。画面上向きを 0°として時計回りに 360°で一周を表す。
struct Direction
{
	/// 狙い方
	enum TYPE { AIM, ABSOLUTE, RELATIVE, SEQUENCE }
	TYPE type = TYPE.AIM; ///
	float dir = 0f; /// 360 degree clockwise
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                              init_direction                              |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_direction( XMLTag xml )
{
	string type = xml["type"];
	if     ( 0 == "absolute".icmp( type ) ) type = "Direction.TYPE.ABSOLUTE";
	else if( 0 == "relative".icmp( type ) ) type = "Direction.TYPE.RELATIVE";
	else if( 0 == "sequence".icmp( type ) ) type = "Direction.TYPE.SEQUENCE";
	else type = "Direction.TYPE.AIM";

	return "Direction( " ~ type ~ ", " ~ lazy_number( xml.text ) ~ " )";
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                  Speed                                   |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// 速度を表す。1フレームで移動するピクセル数で表されている(と思われる。)l
struct Speed
{
	enum TYPE { ABSOLUTE, RELATIVE, SEQUENCE }
	TYPE type = TYPE.ABSOLUTE;
	float speed = float.nan; /// pixels per frame
}
/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                init_speed                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_speed( XMLTag xml )
{
	string type = xml["type"];
	if     ( 0 == "relative".icmp( type ) ) type = "Speed.TYPE.RELATIVE";
	else if( 0 == "sequence".icmp( type ) ) type = "Speed.TYPE.SEQUENCE";
	else type = "Speed.TYPE.ABSOLUTE";
	return "Speed( " ~ type ~ ", " ~ lazy_number( xml.text ) ~ " )";
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                   Fire                                   |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// Fire 要素を表す。Bullet を打ち出す。
class Fire : IActionFunc
{ mixin SFactory!IActionFunc;

	string _label; /// label 属性
	alias IBullet function( Action, IBullet, Vector2f, float, float, RefParam ) BulletGenerator;
	private BulletGenerator _generator;
	private IBullet _bullet;
	private Action _parent;
	private RefParam _rp;
	private Direction _direction;
	private Speed _speed;

	private void onReset( string label, Action parent, IBullet bul, RefParam rp, Direction dir, Speed speed
	                    , BulletGenerator bg )
	{
		this._label = label; this._parent = parent; this._bullet = bul; this._direction = dir; this._generator = bg;
		this._rp = rp; this._speed = speed;
	}
	private void onRemove()
	{
		this._label = null; this._parent = null; this._bullet = null; this._generator = null;
	}

	/// 名前
	string label() @property const { return _label; }

	/// Bullet を打ち出す。
	bool update( ref float term )
	{
		assert( _bullet );
		assert( _bullet.player );
		assert( _generator );
		assert( _parent );
		float heading;
		float s;
		if     ( Direction.TYPE.AIM == _direction.type )
			heading = (_bullet.player.point - _bullet.point ).direction + _direction.dir;
		else if( Direction.TYPE.SEQUENCE == _direction.type )
			heading = _parent.fireDirection + _direction.dir;
		else if( Direction.TYPE.ABSOLUTE == _direction.type )
			heading = _direction.dir;
		else if( Direction.TYPE.RELATIVE == _direction.type )
			heading = _bullet.heading + _direction.dir;

		if     ( Speed.TYPE.ABSOLUTE == _speed.type )
			s = _speed.speed;
		else if( Speed.TYPE.SEQUENCE == _speed.type )
			s = _parent.fireSpeed + _speed.speed;
		else if( Speed.TYPE.RELATIVE == _speed.type )
			s = _bullet.speed + _speed.speed;
		_generator( _parent, _bullet, _bullet.point, heading, s, _rp );

		return false;
	}
}


/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                init_fire                                 |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_fire( XMLTag xml )
{
	string result =
		"( Action parent, IBullet bul, RefParam rp )"
		"{"
		"    Direction direction;";
	string speed = "Speed()";
	string generator;
	foreach( child ; xml.children )
	{
		if     ( 0 == "bulletref".icmp( child.name ) )
		{
			result ~= "rp = " ~ ready_ref(child) ~ "(rp);";
			generator = "&Bullet_" ~ child["label"];
		}
		else if( 0 == "bullet".icmp( child.name ) ) generator = init_bullet(child);
		else if( 0 == "direction".icmp( child.name ) ) result ~= "direction = " ~ init_direction(child) ~ ";";
		else if( 0 == "speed".icmp( child.name ) ) speed = init_speed( child );
	}
	result ~=
		"    return Fire( \"" ~ xml["label"] ~ "\", parent, bul, rp, direction, " ~ speed ~ ", " ~ generator ~ " );"
		"}";
	return result;
}


/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                  Repeat                                  |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// 繰り返し
class Repeat : IActionFunc
{ mixin SFactory!IActionFunc;

	private uint _times, _past;
	private IActionFunc _act;
	private IBullet _bullet;
	private Action _parent;
	private RefParam _rp;
	alias Action function( Action, IBullet, RefParam ) ActionInitializer;
	private ActionInitializer _initializer;

	private void onReset( Action parent, IBullet bullet, RefParam rp, uint t, ActionInitializer initializer )
	{
		this._parent = parent;
		this._bullet = bullet;
		this._rp = rp;
		this._times = t;
		this._initializer = initializer;
		_past = 0;
		_act = null;
	}
	private void onRemove()
	{
		if( null !is _act ) { _act.remove_all(); _act = null; }
		_past = _times = 0;
		_bullet = null;
		_parent = null;
	}

	/// term フレーム更新する。
	bool update( ref float term )
	{
		for( ; _past < _times && 0f < term ; )
		{
			if( null is _act ) { _act = _initializer( _parent, _bullet, _rp ); _past++; }
			_act.update_all( term );
		}
		return _past < _times;
	}
}


/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                               init_repeat                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_repeat( XMLTag xml )
{
	string times, act, rrp = "rp";
	string result = "( Action parent, IBullet bul, RefParam rp ){";
	foreach( child ; xml.children )
	{
		if     ( 0 == "times".icmp( child.name ) ) times = lazy_number( child.text );
		else if( 0 == "action".icmp( child.name ) ) act = init_action( child );
		else if( 0 == "actionref".icmp( child.name ) )
		{
			act = "&Action_" ~ child["label"];
			rrp = ready_ref(child) ~ "(rp)";
		}
	}
	result ~= "return Repeat( parent, bul, " ~ rrp ~ ", cast(uint)(" ~ times ~ "), " ~ act ~ " ); }";
	return result;
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                   Wait                                   |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// フレーム数を指定して、その分待つ。
class Wait : IActionFunc
{ mixin SFactory!IActionFunc;

	private float _wait, _past;

	void onReset( float w ) { _wait = w; _past = 0; }
	void onRemove() { _wait = 0.0; _past = 0.0; }

	bool update( ref float term )
	{
		if( _past < _wait )
		{
			_past += term;
			term = 0;
			return true;
		}
		else
		{
			term -= min( term, _past - _wait );
			return false;
		}
	}
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                init_wait                                 |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_wait( XMLTag xml )
{
	string result = "( RefParam rp ){";
	result ~= "return Wait(" ~ lazy_number(xml.text) ~ "); }";
	return result;
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                             ChangeDirection                              |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// 弾の方向を変える。
class ChangeDirection : IActionFunc
{ mixin SFactory!IActionFunc;

	enum AIM_PRECISION = 0.08; // 謎のマジックナンバー

	private Direction _direction;
	private float _term, _past, _moment;
	private IBullet _bullet;

	private void onReset( IBullet bul, float term, Direction direction )
	{
		this._bullet = bul;
		this._term = term;
		this._direction = direction;
		
		_past = 0;
		_moment = 0;
	}

	private void onRemove(){ _term = 0; _past = 0; _bullet = null; _moment = 0; }

	/// term フレーム更新する。
	bool update( ref float term )
	{
		if( 0 == _past )
		{
			if     ( Direction.TYPE.AIM == _direction.type )
			{
				auto delta = (_bullet.player.point - _bullet.point).direction + _direction.dir - _bullet.heading;
				if     ( 180 < delta ) delta -= 360;
				else if( delta < -180 ) delta += 360;
				_moment = delta / this._term * AIM_PRECISION;
			}
			else if( Direction.TYPE.RELATIVE == _direction.type )
			{
				_moment = _direction.dir / this._term;
			}
			else if( Direction.TYPE.ABSOLUTE == _direction.type )
			{
				auto delta = _direction.dir - _bullet.heading;
				if     ( 180 < delta ) delta -= 360;
				else if( delta < -180 ) delta += 360;
				_moment = delta / this._term;
			}
			else if( Direction.TYPE.SEQUENCE == _direction.type )
			{
				_moment = _direction.dir;
			}
		}

		if( _past < this._term )
		{
			auto t = min( _past + term, this._term ) - _past;
			_bullet.heading = _bullet.heading + _moment * t;
			_past += term;
			return true;
		}
		else return false;
	}
}
/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                           init_changedirection                           |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_changedirection( XMLTag xml )
{
	string term;
	string result =
		"( IBullet bul ){"
		"    Direction direction;";
	foreach( child ; xml.children )
	{
		if     ( 0 == "term".icmp( child.name ) ) term = lazy_number( child.text );
		else if( 0 == "direction".icmp( child.name ) ) result ~= "direction = " ~ init_direction( child ) ~ ";";
	}
	result ~=
		"    return ChangeDirection( bul, " ~ term ~ ", direction );"
		"}";
	return result;
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                  Vanish                                  |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// 弾を消す。(vanish() を実行する。)
class Vanish : IActionFunc
{ mixin SFactory!IActionFunc;
	private IMovable _bullet;
	private void onReset( IMovable bullet ) { this._bullet = bullet; }
	private void onRemove() { this._bullet = null; }

	/// vanish() を実行する。
	bool update( ref float term ){ _bullet.vanish(); return false; }
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                               ChangeSpeed                                |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// 弾の速度を変える。
class ChangeSpeed : IActionFunc
{ mixin SFactory!IActionFunc;
	private IMovable _bullet;
	private float _accel, _speed, _term, _past;

	private void onReset( IMovable bullet, float term, float speed )
	{
		this._bullet = bullet;
		this._term = term;
		this._speed = speed;
		_past = 0;
	}
	private void onRemove() { this._bullet = null; _term = _past = 0f; }

	bool update( ref float term )
	{
		if( 0 == _past )
		{
			this._accel = ( this._speed - _bullet.speed ) / this._term;
		}
		if( _past < this._term )
		{
			auto t = min( _past + term, this._term ) - _past;
			_bullet.speed = _bullet.speed + (_accel * t);
			_past += term;
			return true;
		}
		else return false;
	}
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                             init_changespeed                             |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_changespeed( XMLTag xml )
{
	string speed, term;
	foreach( child ; xml.children )
	{
		if     ( 0 == "speed".icmp( child.name ) ) speed = lazy_number( child.text );
		else if( 0 == "term".icmp( child.name ) ) term = lazy_number( child.text );
	}
	return "( IMovable bul ){ return ChangeSpeed( bul, " ~ term ~ ", " ~ speed ~ " ); }";
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                  Accel                                   |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// X(Y)軸方向に加速する。
class Accel : IActionFunc
{ mixin SFactory!IActionFunc;
	private IMovable _bullet;
	private float _term, _past;
	private Vector2f _accel;

	private void onReset( IMovable bullet, float term, float ax, float ay )
	{
		this._bullet = bullet; this._term = term; this._accel = Vector2f( ax / term, -ay / term );
		_past = 0;
	}
	private void onRemove(){ _bullet = null; _term = _past = 0f; }

	///
	bool update( ref float term )
	{
		if( _past < this._term )
		{
			auto t = min( _past + term, this._term ) - _past;
			auto v = (_bullet.headingVector * _bullet.speed) + (_accel * t);
			_bullet.speed = v.length;
			_bullet.heading = v.direction;
			_past += term;
			return true;
		}
		else return false;
	}
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                init_accel                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_accel( XMLTag xml )
{
	string result =
		"( IMovable bul, RefParam rp )"
		"{";
	string horz = "0", vert = "0", term = "0";
	foreach( child ; xml.children )
	{
		if     ( 0 == "term".icmp( child.name ) ) term = lazy_number( child.text );
		else if( 0 == "horizontal".icmp( child.name ) ) horz = lazy_number( child.text );
		else if( 0 == "vertical".icmp( child.name ) ) vert = lazy_number( child.text );
	}
	result ~=
		"    return Accel( bul, " ~ term ~ ", " ~ horz ~ ", " ~ vert ~ " );"
		"}";
	return result;
}

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                ActionRef                                 |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
/// action を参照する。循環参照によるオーバーフローを軽減する為にワンクッションおく。
class ActionRef : IActionFunc
{ mixin SFactory!IActionFunc;
	private Action _parent;
	private IBullet _bullet;
	private RefParam _rp;
	alias Action function( Action, IBullet, RefParam ) ActionInitializer;
	private ActionInitializer _initializer;
	private IActionFunc _act;

	private void onReset( Action parent, IBullet bul, RefParam rp, ActionInitializer initializer )
	{
		this._parent = parent; this._bullet = bul; this._rp =rp; this._initializer = initializer;
		_act = null;
	}

	private void onRemove()
	{
		_parent = null; _bullet = null; _initializer = null;
		if( null !is _act ) { _act.remove_all(); _act = null; }
	}

	///
	bool update( ref float term )
	{
		if( null is _act && null !is _initializer ) _act = _initializer( _parent, _bullet, _rp );

		if( null !is _act )
			return _act.update_all( term );
		else
			return false;
	}
}
/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                              init_actionref                              |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string init_actionref( XMLTag xml )
{
	return
		"( Action parent, IBullet bul, RefParam rp ){"
		"    return ActionRef( parent, bul, " ~ ready_ref(xml) ~ "(rp), &Action_" ~ xml["label"] ~ " ); }";
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                ready_ref                                 |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string ready_ref( XMLTag xml )
{
	string result =
		"( RefParam rp )"
		"{"
		"    RefParam rrp;"
		"    rrp[0] = rp[0];";
	size_t i;
	foreach( child ; xml.children )
	{
		if( 0 == "param".icmp( child.name ) )
			result ~= "rrp[" ~ (++i).to!string ~ "] = " ~ lazy_number(child.text) ~ ";";
	}
	result ~=
		"    return rrp;"
		"}";
	return result;
}


/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                               lazy_number                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string lazy_number( string str )
{
	for( auto prev = str ; str.findSkip("$") ; prev = str )
	{
		if     ( str[0].isDigit )
			str = prev[ 0 .. $ - str.length - 1 ] ~ "rp[" ~ str[ 0 .. 1 ] ~ "]" ~ str[ 1 .. $ ];
		else if( str.startsWith( "rand" ) )
			str = prev[ 0 .. $ - str.length - 1 ] ~ "uniform(0f,1f)" ~ str[ 4 .. $ ];
		else if( str.startsWith( "rank" ) )
			str = prev[ 0 .. $ - str.length - 1 ] ~ "rp[0]" ~ str[ 4 .. $ ];
	}
	if( 0 == str.length ) str = "0";
	return str;
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                valid_name                                |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
string valid_name( string str )
{
	char[] result = new char[ str.length ];
	for( size_t i = 0 ; i < str.length ; i++ ) result[i] = str[i].isAlphaNum ? str[i] : '_';
	return result.assumeUnique;
}


/*############################################################################*\
|*#                                                                          #*|
|*#                                utilities                                 #*|
|*#                                                                          #*|
\*############################################################################*/
/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                              SlistIterator                               |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// sworks.compo.util.factory.ISlist を巡回する。
struct SlistIterator(TYPE)
{
	private TYPE* _top;
	private TYPE* _tail;
	private TYPE _prev;
	TYPE _front;
	alias _front this;

	this( ref TYPE top )
	{
		if( null !is top ) this._top = &top;
		_front = top;
		_prev = null;
	}

	this( ref TYPE top, ref TYPE tail )
	{
		this( top );
		if( null !is tail ) this._tail = &tail;
	}

	bool empty() @property const { return null is _front; }
	void popFront()
	{
		if( null !is _front )
		{
			_prev = _front;
			_front = _front.next;
		}
	}
	void popAndRemoveFront()
	{
		if( null is _front ) return;
		TYPE a = _front.next;
		if( null !is _prev ) _prev.next = a;
		if( (*_top) is _front ) (*_top) = a;
		if( null !is _tail && (*_tail) is _front ) (*_tail) = _prev;

		_front.remove();
		_front = a;
	}
}
/// suger
SlistIterator!TYPE iterator(TYPE)( ref TYPE t ){ return SlistIterator!TYPE( t ); }

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                 RefParam                                 |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// 設定されていない引数は 0f が返る。
struct RefParam
{
	float[] _val; /// _val[0] == rank
	void opAssign( in RefParam rp ) { _val = rp._val.dup; }
	void opAssign( float[] p ... ) { _val = p; }
	float opIndex( size_t i ) const { return i < _val.length ? _val[i] : 0f; }
	void opIndexAssign( float val, size_t i )
	{
		if( _val.length <= i )
		{
			auto pl = _val.length;
			_val.length = i+1;
			_val[ pl .. i ] = 0f;
		}
		_val[i] = val;
	}
	const(float)[] opSlice() const { return _val[]; }

	float rank() @property const { return opIndex(0); }
	void rank( float r ) @property { opIndexAssign( r, 0 ); }
}


/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                              headingMatrix                               |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
Matrix4f headingMatrix( Vector2f iy )
{
	auto z = Vector3f( 0, 0, 1 );
	auto x = Vector3f( iy.y, iy.x, 0 );
	auto y = z.cross(x);
	return Matrix4f( x.x, y.x, z.x, 0
	               , x.y, y.y, z.y, 0
	               , x.z, y.z, z.z, 0
	               , 0,   0,   0,   1 );
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                Direction                                 |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
// OpenGL スタイルのベクタから BulletML スタイルの角度を取り出す。
float direction( Vector2f v ) { return -atan2(v.y, v.x) * TO_360 + 90; }

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                   Bank                                   |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// sworks.compo.util.factory.Slist を溜める。
struct Bank(TYPE) if( is( TYPE == class ) || is( TYPE == interface ) )
{
	SlistAppender!TYPE _stack;

	bool empty() @property const { return _stack.empty; }
	TYPE front() @property { return _stack.front; }
	TYPE back() @property { return _stack.back; }

	void opOpAssign( string OP : "+" )( TYPE b ) { _stack.put( b ); }
	SlistIterator!TYPE iterator() @property { return SlistIterator!TYPE( _stack.front, _stack.back ); }

	void clear() { _stack.reset; }

	static if( is( TYPE : IBullet ) )
	{
		ActiveIBulletsIterator activeBullets() @property { return ActiveIBulletsIterator( _stack.front ); }
	}

}
alias Bank!IBullet BulletBank;

/*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*\
|*|                                BulletData                                |*|
\*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*/
class BulletData { }

////////////////////XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\\\\\\\\\\\\\\\\\\\\
////                                                                        \\\\
////                                 DEBUG                                  \\\\
////                                                                        \\\\
////////////////////XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\\\\\\\\\\\\\\\\\\\\
debug(bulletml):
import std.math;
import sworks.compo.sdl.util;
import sworks.compo.sdl.gl;
import sworks.compo.sdl.image;
import sworks.compo.gl.glsl;
import sworks.compo.util.dump_members;

class BMLTest : IPlayer
{ mixin SDLIdleWindowMix!() SWM;

	enum WIDTH = 640;
	enum HEIGHT = 480;
	
	BulletBank battery;

	Drawer drawer;
	PlaneDrawer plane;
	CannonDrawer cannon;
	BulletsDrawer bullets;
	SmokeManager smoke;
	Setsumei setsumei;

	this()
	{
		SWM.ctor( SDL_INIT_VIDEO, "BulletML Test", WIDTH, HEIGHT, SDL_WINDOW_OPENGL, 30
		        , getImageInitializer( IMG_INIT_JPG )
		        , getGLInitializer( true, 0, 8, 8, 8, 8 ) );
		DerelictGL3.reload();

		glClearColor( 0.2, 0.2, 0.2, 1.0 );

		glViewport( 0, 0, WIDTH, HEIGHT );

		glEnable( GL_CULL_FACE );
		glCullFace( GL_BACK );

		glEnable( GL_BLEND );
		glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

		drawer = new Drawer( WIDTH, HEIGHT );
		plane = new PlaneDrawer( drawer, Vector2f( 1, 0 ) );
		cannon = new CannonDrawer( drawer, 200, 0 );
		bullets = new BulletsDrawer( plane );
		smoke = new SmokeManager( drawer );
		setsumei = new Setsumei( "img\\setsumei.jpg" );

		IBullet b;
		battery += b = BulletMLIterator.newBullet( this, 0.5, plane.heading, cannon.pos );
		SDL_SetWindowTitle( window, b.label.ptr );

	}

	Vector2f point() @property { return plane.pos; }
	void fireNotice( IBullet bullet )
	{
		if( null is bullet.parent || null is bullet.parent.data )
			bullet.data = new MyBulletData( uniform( 0.4f, 1f ), uniform( 0.4f, 1f ), uniform( 0.4f, 1f ), 1.0 );
		else
			bullet.data = bullet.parent.data;
	}
	
	void clear()
	{
		setsumei.clear;
		smoke.clear;
		cannon.clear;
		plane.clear;
		drawer.clear;
		SWM.dtor();
	}

	uint shot_interval;
	void update( uint interval )
	{
		auto term = (cast(float)interval) * 0.06f;
		auto t = term;
		smoke.update( term );

		bool is_alive = false;

		for( auto ite = battery.iterator ; !ite.empty ; )
		{
			if( ite.isActive || ite.hasActiveBullets )
			{
				ite.update( term );
				is_alive |= ite.isActive;

				for( auto i = ite.activeBullets ; !i.empty ; i.popFront )
				{
					if( plane.pos.distanceSq( i.point ) <= 50 ) smoke.hit( i.point );
					if( i.point.x < -WIDTH*0.5 || WIDTH*0.5 < i.point.x
					  || i.point.y < -HEIGHT*0.5 || HEIGHT*0.5+100 < i.point.y ) i.vanish;
				}

				ite.popFront;
			}
			else ite.popAndRemoveFront;
		}

		if( !is_alive )
		{
			shot_interval += interval;
			if( 1000 < shot_interval )
			{
				IBullet b;
				battery += b = BulletMLIterator.newBullet( this, 0.5, plane.heading, cannon.pos );
				SDL_SetWindowTitle( window, b.label.ptr );
				shot_interval = 0;
			}
		}

	}

	void draw()
	{
		glClear( GL_COLOR_BUFFER_BIT );

		setsumei.draw();
		cannon.draw();
		smoke.draw();
		plane.draw();

		for( auto ite = battery.activeBullets ; !ite.empty ; ite.popFront )
			if( !ite.willVanish && null !is ite.parent ) bullets.draw( ite );

		SDL_GL_SwapWindow( window );
	}

	void sdl_mousemotion( ref SDL_MouseMotionEvent e )
	{
		int x = cast(int)( e.x - WIDTH * 0.5);
		int y = -cast(int)( e.y - HEIGHT * 0.5);
		plane.update( x, y );
	}

	void sdl_mousebuttondown( ref SDL_MouseButtonEvent e )
	{
		if( 1 == e.button )
		{
			for( auto ite = battery.iterator ; !ite.empty ; ite.popFront ) ite.vanish;
			BulletMLIterator.nextBullet();
			IBullet b;
			battery += b = BulletMLIterator.newBullet( this, 0.5, plane.heading, cannon.pos );
			SDL_SetWindowTitle( window, b.label.ptr );
		}
	}
}

void main()
{
	auto wnd = new BMLTest;
	scope( exit ) wnd.clear;
	wnd.mainLoop;
}

class MyBulletData : BulletData
{
	float[4] color;
	this( float[4] c ... ){ color[] = c; }
}

struct BulletMLIterator
{
	enum BML_COUNT = 19;
	alias BulletML!"test-bml1.xml" Test1;
	alias BulletML!"test-bml2.xml" Test2;
	alias BulletML!"test-bml3.xml" Test3;
	alias BulletML!"[1943]_rolling_fire.xml" RollingFire;
	alias BulletML!"[Guwange]_round_2_boss_circle_fire.xml" CircleFire;
	alias BulletML!"[Guwange]_round_3_boss_fast_3way.xml" Fast3Way;
	alias BulletML!"[Guwange]_round_4_boss_eye_ball.xml" EyeBall;
	alias BulletML!"[G_DARIUS]_homing_laser.xml" HoamingLaser;
	alias BulletML!"[Progear]_round_1_boss_grow_bullets.xml" GrowBullets;
	alias BulletML!"[Progear]_round_2_boss_struggling.xml" Struggling;
	alias BulletML!"[Progear]_round_3_boss_back_burst.xml" BackBurst;
	alias BulletML!"[Progear]_round_3_boss_wave_bullets.xml" WaveBullets;
	alias BulletML!"[Progear]_round_4_boss_fast_rocket.xml" FastRocket;
	alias BulletML!"[Progear]_round_5_boss_last_round_wave.xml" LastRoundWave;
	alias BulletML!"[Progear]_round_6_boss_parabola_shot.xml" ParabolaShot;
	alias BulletML!"[Psyvariar]_X-A_boss_opening.xml" BossOpening;
	alias BulletML!"[Psyvariar]_X-A_boss_winder.xml" Winder;
	alias BulletML!"[Psyvariar]_X-B_colony_shape_satellite.xml" ColonyShapeSatellite;
	alias BulletML!"[XEVIOUS]_garu_zakato.xml" GaruZakato;

	static uint current;

	static IBullet newBullet( IPlayer player, float rank
	                        , ref Vector2f player_heading, ref Vector2f cannon_pos )
	{
		IBullet _call(T)( )
		{
			float heading = 0;
			if( IBullet.TYPE.HORIZONTAL == T.type )
			{
				heading = 270;
				player_heading = Vector2f( 1, 0 );
				cannon_pos = Vector2f( uniform( 180f, 220f ), uniform( -100f, 100f ) );
			}
			else
			{
				heading = 180;
				player_heading = Vector2f( 0, 1 );
				cannon_pos = Vector2f( uniform( -150f, 150f ), uniform( 130f, 180f ) );
			}
			return T( player, cannon_pos, heading, 0, rank );
		}
		if     ( 0 == current ) return _call!Test1();
		else if( 1 == current ) return _call!Test2();
		else if( 2 == current ) return _call!Test3();
		else if( 3 == current ) return _call!RollingFire();
		else if( 4 == current ) return _call!CircleFire();
		else if( 5 == current ) return _call!Fast3Way();
		else if( 6 == current ) return _call!EyeBall();
		else if( 7 == current ) return _call!HoamingLaser();
		else if( 8 == current ) return _call!GrowBullets();
		else if( 9 == current ) return _call!Struggling();
		else if( 10 == current ) return _call!BackBurst();
		else if( 11 == current ) return _call!WaveBullets();
		else if( 12 == current ) return _call!FastRocket();
		else if( 13 == current ) return _call!LastRoundWave();
		else if( 14 == current ) return _call!ParabolaShot();
		else if( 15 == current ) return _call!BossOpening();
		else if( 16 == current ) return _call!Winder();
		else if( 17 == current ) return _call!ColonyShapeSatellite();
		else if( 18 == current ) return _call!GaruZakato();

		else return null;
	}

	static void nextBullet()
	{
		current++;
		if( BML_COUNT <= current ) current -= BML_COUNT;
	}
}

class Drawer
{
	string vertex_shader =
	q{#version 420
		uniform mat4 world;
		in vec2 pos;
		void main() { gl_Position = world * vec4(pos, 0.0, 1.0); }
	};

	string fragment_shader =
	q{#version 420
		uniform vec4 color;
		layout( location = 0 ) out vec4 colorOut;
		void main() { colorOut = color; }
	};

	struct Vertex { float[2] pos; }

	Shader vs, fs;
	ShaderProgram prog;
	Matrix4f projlook;
	Matrix4f world;
	GLuint world_loc, color_loc;

	this( int w, int h )
	{
		vs = new Shader( GL_VERTEX_SHADER, vertex_shader );
		fs = new Shader( GL_FRAGMENT_SHADER, fragment_shader );
		prog = (new ShaderProgram( vs, fs )).link;
		world_loc = prog.world;
		color_loc = prog.color;
		projlook = Matrix4f.orthoMatrix( -w * 0.5, w * 0.5, -h * 0.5, h * 0.5, 0, 20 )
		         * Matrix4f.lookAtMatrix( [ 0, 0, 10 ], [ 0, 0, 0 ], [ 0, 1, 0 ] );
	}

	void update( float[2] pos, Vector2f heading, float[4] color )
	{
		world = projlook * Matrix4f.translateMatrix( pos[0], pos[1], 0 ) * headingMatrix( heading );
		prog[ world_loc ] = world;
		prog[ color_loc ] = color;
	}

	void clear()
	{
		if( null !is prog ) { prog.clear(); prog = null; }
		if( null !is vs ) { vs.clear(); vs = null; }
		if( null !is fs ) { fs.clear(); fs = null; }
	}
}

class PlaneDrawer
{
	Drawer drawer;
	VertexArrayObject vao;

	void delegate() _draw;

	alias Drawer.Vertex Vertex;
	Vertex[] vertex = [ Vertex([ 0, 10 ]), Vertex([ -5, -5 ]), Vertex([ 5, -5 ]) ];
	ushort[] index = [ 0, 1, 2 ];
	float[4] color;
	Vector2f pos;
	float x, y;
	Vector2f heading;

	this( Drawer d, Vector2f h )
	{
		this.drawer = d;
		this.heading = h;
		this.color = [ 1f, 1, 1, 1 ];
		x = 0; y = -150;
		vao = new VertexArrayObject( drawer.prog, vertex );
		_draw = vao.getDrawer!GL_LINE_LOOP( index );
	}

	void update( float[2] p ... ) { this.pos = p; }

	void draw( ) { drawer.update( pos, heading, color ); _draw(); }
	void clear() { vao.clear;}
}

class CannonDrawer
{
	Drawer drawer;
	VertexArrayObject vao;
	void delegate() _draw;
	alias Drawer.Vertex Vertex;
	Vertex[] vertex = [ Vertex([-10, 10]), Vertex([-10, -10]), Vertex([10, -10]), Vertex([10, 10]) ];
	ushort[] index = [ 0, 1, 2, 3 ];
	float[4] color;
	Vector2f pos;

	this( Drawer d, float x, float y )
	{
		this.drawer = d;
		this.pos = Vector2f( x, y );
		this.color = [ 1f, 0, 0, 1 ];
		vao = new VertexArrayObject( drawer.prog, vertex );
		_draw = vao.getDrawer!GL_LINE_LOOP( index );
	}
	void draw(){ drawer.update( pos, Vector2f( 0, 1 ), color ); _draw(); }
	void clear(){ vao.clear; }
}


class BulletsDrawer
{
	PlaneDrawer pd;
	float[4] color;

	this( PlaneDrawer pd )
	{
		this.pd = pd;
		color = [ 1f, 0.5, 0.5, 1 ];
	}

	void draw( IBullet b )
	{
		auto mbd = cast(MyBulletData)(b.data);
		float[4] c;
		if( null !is mbd ) c[] = mbd.color;
		else c = [ 0f, 0f, 0f, 1 ];
		
		pd.drawer.update( b.point, b.headingVector, c );
		pd._draw();
	}
}

class SmokeManager
{
	Drawer drawer;
	VertexArrayObject vao;
	void delegate() _draw;

	alias Drawer.Vertex Vertex;
	Vertex[] vertex = [ Vertex([ -5, 5 ]), Vertex([-5, -5]), Vertex([5, -5]), Vertex([5, 5]) ];
	ushort[] index = [ 0, 1, 2, 3 ];
	Bank!RedSmoke bank;

	this( Drawer drawer )
	{
		this.drawer = drawer;
		vao = new VertexArrayObject( drawer.prog, vertex );
		_draw = vao.getDrawer!GL_TRIANGLE_FAN( index );
	}

	void update( float term )
	{
		for( auto ite = bank.iterator ; !ite.empty ; )
		{
			ite.update( term );
			if( ite.life <= 0.0 ) ite.popAndRemoveFront;
			else ite.popFront;
		}
	}

	void draw()
	{
		for( auto ite = bank.iterator ; !ite.empty ; ite.popFront ) { ite.ready( drawer ); _draw(); }
	}
	void clear() { bank.clear; vao.clear; }

	void hit( Vector2f pos ) { bank += RedSmoke( pos ); }
}


class RedSmoke : ISlist!RedSmoke
{ mixin SFactory!RedSmoke;

	enum MAX_LIFE = 120.0f;
	Vector2f center;
	float life;
	Vector2f velocity;
	float speed;
	
	void onReset( Vector2f pos )
	{
		this.center = pos;
		life = MAX_LIFE;
		velocity = Vector2f( 1, 0 ).rotate( uniform( -PI, PI ) );
		speed = 0.4;
	}
	void onRemove() {  }

	void update( float term )
	{
		life -= term;
		center += velocity * ( speed * term );
	}

	void ready( Drawer drawer )
	{
		float[4] color = [ 1f, 0, 0, 0.4 * life / MAX_LIFE ];
		drawer.update( center, Vector2f( 0, 1 ).rotate( life * TO_RADIAN ), color );
	}
}

class Setsumei
{
	static string vertex_shader =
	q{ #version 420
		in vec2 position;
		in vec2 texcoord;

		out vec2 f_texcoord;

		void main()
		{
			gl_Position = vec4( position, 0.0, 1.0 );
			f_texcoord = texcoord;
		}
	};

	static string fragment_shader =
	q{ #version 420
		in vec2 f_texcoord;
		uniform sampler2D texture1;

		layout( location = 0 ) out vec4 colorOut;

		void main()
		{
			colorOut = texture2D( texture1, f_texcoord );
		}
	};

	struct Vertex
	{
		float[2] position;
		float[2] texcoord;
		this( float[4] p ... ){ position[] = p[ 0 .. 2 ]; texcoord = p[ 2 .. 4 ]; }
	}
	Vertex[] vertex = [ Vertex( -0.9, 0.8,  0, 1 ), Vertex( -0.2, 0.8, 1, 1 )
	                  , Vertex( -0.2, 1, 1, 0 ), Vertex( -0.9, 1, 0, 0 ) ];
	ushort[] index = [ 0, 1, 2, 3 ];

	Shader vs, fs;
	ShaderProgram prog;
	VertexArrayObject vao;
	Texture2DRGBA32 tex;
	void delegate() draw;

	this( const(char)* texfile )
	{
		vs = new Shader( GL_VERTEX_SHADER, vertex_shader );
		fs = new Shader( GL_FRAGMENT_SHADER, fragment_shader );
		prog = (new ShaderProgram( vs, fs )).link;

		vao = new VertexArrayObject( prog, vertex );

		tex = loadTexture2DRGBA32( texfile );

		draw = drawSystem( vao.getDrawer!GL_TRIANGLE_FAN( index ), prog, [ "texture1" : tex ] );
	}

	void clear()
	{
		tex.clear();
		vao.clear();
		prog.clear();
		vs.clear();
		fs.clear();
	}

}
