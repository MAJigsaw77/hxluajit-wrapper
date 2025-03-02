package hxluajit.wrapper;

import hxluajit.Types;

/**
 * Holds a Lua function that can be called from Haxe.
 * 
 * @see https://github.com/DragShot/linc_luajit/blob/master/llua/LuaCallback.hx
 * 
 * @author DragShot
 */
class LuaFunction
{
	@:noCompletion
	private var l:Null<cpp.Pointer<Lua_State>>;

	@:noCompletion
	private var ref:Int;

	/**
	 * Creates a new LuaFunction instance.
	 * 
	 * @param l The Lua state pointer.
	 * @param ref The Lua function reference.
	 */
	@:allow(hxluajit.wrapper.LuaConverter)
	private function new(l:cpp.Pointer<Lua_State>, ref:Int):Void
	{
		this.l = l;
		this.ref = ref;
	}

	/**
	 * Calls the Lua function.
	 * 
	 * @param args The function arguments.
	 * @return The function results as a Haxe array.
	 */
	public function call(args:Array<Dynamic>):Array<Dynamic>
	{
		if (l != null)
		{
			Lua.rawgeti(l.raw, Lua.REGISTRYINDEX, ref);

			return LuaUtils.callFunctionWithoutName(l.raw, args);
		}

		return [];
	}

	/**
	 * Disposes of the Lua function reference.
	 */
	public function dispose():Void
	{
		if (l != null)
		{
			LuaL.unref(l.raw, Lua.REGISTRYINDEX, ref);
			l = null;
		}
	}
}
