package hxluajit.wrapper;

import hxluajit.Types;

/**
 * Utility class for handling Lua errors.
 * 
 * @author Mihai Alexandru (MAJigsaw77)
 */
class LuaError
{
	/**
	 * Function to handle Lua errors.
	 */
	public static var errorHandler:Null<String->Void>;

	/**
	 * Gets the error message from the Lua stack.
	 * 
	 * @param L The Lua state.
	 * @param status The Lua execution status.
	 * @return The error message.
	 */
	public static function getMessage(L:cpp.RawPointer<Lua_State>, status:Int):String
	{
		final err:String = Lua.tostring(L, status);
		Lua.pop(L, 1);
		return err;
	}
}
