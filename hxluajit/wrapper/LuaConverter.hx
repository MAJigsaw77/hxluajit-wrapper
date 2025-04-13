package hxluajit.wrapper;

import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import hxluajit.Lua;
import hxluajit.LuaL;
import hxluajit.Types;

/**
 * Utility class for converting between Lua and Haxe types.
 * 
 * @see https://github.com/kevinresol/hxvm-lua/blob/master/src/vm/lua/Lua.hx
 * @see https://github.com/superpowers04/linc_luajit/blob/master/llua/Convert.hx
 * 
 * @author Mihai Alexandru (MAJigsaw77)
 */
class LuaConverter
{
	/**
	 * Converts a Haxe value to Lua.
	 * 
	 * @param L The Lua state.
	 * @param v The Haxe value.
	 */
	public static function toLua(L:cpp.RawPointer<Lua_State>, v:Dynamic):Void
	{
		switch (Type.typeof(v))
		{
			case TInt:
				Lua.pushinteger(L, cast(v, Int));
			case TFloat:
				Lua.pushnumber(L, cast(v, Float));
			case TBool:
				Lua.pushboolean(L, v == true ? 1 : 0);
			case TObject:
				final fields:Array<String> = Reflect.fields(v);

				Lua.createtable(L, fields.length, 0);

				for (field in fields)
				{
					Lua.pushstring(L, field);
					LuaConverter.toLua(L, Reflect.field(v, field));
					Lua.settable(L, -3);
				}
			case TClass(String):
				Lua.pushstring(L, cast(v, String));
			case TClass(Array):
				final elements:Array<Dynamic> = v;

				Lua.createtable(L, elements.length, 0);

				for (i in 0...elements.length)
				{
					Lua.pushinteger(L, i + 1);
					LuaConverter.toLua(L, elements[i]);
					Lua.settable(L, -3);
				}
			case TClass(IntMap) | TClass(StringMap) | TClass(ObjectMap):
				final values:Map<String, Dynamic> = v;

				Lua.createtable(L, Lambda.count(values), 0);

				for (key => value in values)
				{
					Lua.pushstring(L, key);
					LuaConverter.toLua(L, value);
					Lua.settable(L, -3);
				}
			default:
				Lua.pushnil(L);
		}
	}

	/**
	 * Converts a Lua value to Haxe.
	 * 
	 * @param L The Lua state.
	 * @param idx The stack index.
	 * @return The Haxe value.
	 */
	public static function fromLua(L:cpp.RawPointer<Lua_State>, idx:Int):Dynamic
	{
		var ret:Dynamic = null;

		switch (Lua.type(L, idx))
		{
			case type if (type == Lua.TNUMBER):
				ret = Lua.tonumber(L, idx);
			case type if (type == Lua.TSTRING):
				ret = Lua.tostring(L, idx).toString();
			case type if (type == Lua.TBOOLEAN):
				ret = Lua.toboolean(L, idx) == 1;
			case type if (type == Lua.TTABLE):
				ret = LuaConverter.convertTable(L, idx);
			case type if (type == Lua.TFUNCTION):
				ret = new LuaFunction(cpp.Pointer.fromRaw(L), LuaL.ref(L, Lua.REGISTRYINDEX));
			case type if (type == Lua.TUSERDATA || type == Lua.TLIGHTUSERDATA):
				ret = cpp.Pointer.fromRaw(Lua.touserdata(L, idx));
			default:
				ret = null;
		}

		return ret;
	}

	@:noCompletion
	private static inline function convertTable(L:cpp.RawPointer<Lua_State>, idx:Int):Dynamic
	{
		var isArray:Bool = true;

		var count:Int = 0;

		LuaConverter.iterateTable(L, idx, function():Void
		{
			if (isArray)
			{
				if (Lua.type(L, -2) == Lua.TNUMBER)
				{
					final index:Lua_Integer = Lua.tointeger(L, -2);

					if (index < 0)
						isArray = false;
				}
				else
					isArray = false;
			}

			count++;
		});

		if (count == 0)
			return {};

		if (isArray)
		{
			final obj:Array<Dynamic> = [];

			LuaConverter.iterateTable(L, idx, function():Void
			{
				obj[Lua.tointeger(L, -2) - 1] = LuaConverter.fromLua(L, -1);
			});

			return obj;
		}
		else
		{
			final obj:DynamicAccess<Dynamic> = {};

			LuaConverter.iterateTable(L, idx, function():Void
			{
				obj.set(Std.string(LuaConverter.fromLua(L, -2)), LuaConverter.fromLua(L, -1));
			});

			return obj;
		}
	}

	@:noCompletion
	private static function iterateTable(L:cpp.RawPointer<Lua_State>, idx:Int, fn:Void->Void):Void
	{
		Lua.pushnil(L);

		while (Lua.next(L, idx < 0 ? idx - 1 : idx) != 0)
		{
			fn();

			Lua.pop(L, 1);
		}
	}
}
