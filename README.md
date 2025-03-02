# hxluajit-wrapper

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxluajit-wrapper) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxluajit-wrapper) ![](https://badgen.net/badge/license/MIT/green)

A wrapper for [hxluajit](https://github.com/MAJigsaw77/hxluajit) for a better integration with Haxe.

### Installation

You can install it through `Haxelib`
```bash
haxelib install hxluajit-wrapper
```
Or through `Git`, if you want the latest updates
```bash
haxelib git hxluajit-wrapper https://github.com/MAJigsaw77/hxluajit-wrapper.git
```

## Usage

```haxe
import cpp.RawPointer;
import hxluajit.wrapper.LuaUtils;
import hxluajit.Lua;
import hxluajit.LuaL;
import hxluajit.Types;

class Main
{
    public static function main():Void
    {
		Sys.println(Lua.VERSION);
		Sys.println(LuaJIT.VERSION);

        var vm:Null<RawPointer<Lua_State>> = LuaL.newstate();

        LuaL.openlibs(vm);

        LuaUtils.doString(vm, "function add(a, b) return a + b end");

		final ret:Array<Dynamic> = LuaUtils.callFunctionByName(vm, 'add', [3, 7]);
		Sys.println(Type.typeof(ret[0]));
		Sys.println(ret[0]);

        Lua.close(vm);
        vm = null;
    }
}
```

### Licensing

**hxluajit-wrapper** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.
