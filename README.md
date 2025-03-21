# moonmint

__moonmint__ is an HTTP web framework for Lua.
Use complex routing, static file serving, and templating with a
minimal code base. Harness the power of libuv to perform asynchronous operations.

Check out the [wiki](https://github.com/bakpakin/moonmint/wiki) for more information.

## Features

* Simple and flexible routing
* Middleware
* Static file server
* Nonblocking operations with coroutines and libuv
* Supports PUC Lua 5.2 - 5.4, LuaJIT 2.0, LuaJIT 2.1
* Templating engine

## Quick Install

Outside Lua, the main dependency is [luv](https://github.com/luvit/luv).
I recommend installing it with apt if possible. If not, luarocks might work.

## Example

moonmint is really simple - probably the simplest way to get a running
webserver in Lua out there!

The following example servers serve "Hello, World!" on the default port 8080.

```lua
local moonmint = require 'moonmint'
local app = moonmint()

app:get("/", 'Hello, World!')

app:start()
```

This can be even shorter if you use chaining.

```lua
require('moonmint')()
    :get('/', 'Hello, World!')
    :start()
```

## Credits

moonmint depends on the luv library, a Lua binding to libuv.

Most of the code in the `moonmint/deps` directory is taken either from
the [Luvit](https://luvit.io/) or [lit](https://github.com/luvit/lit) projects.

The exception is the `mimetypes` module whose original repo was deleted but
now lives under [lunarmodules](https://github.com/lunarmodules/lua-mimetypes).

## License

Moonmint itself is released under the MIT license
Copyright © 2015-2025 Calvin Rose and contributors

Some portions taken from Luvit/lit released under the Apache 2.0 license
Copyright © 2012 The Luvit Authors.

mimetypes.lua released under the MIT license
Copyright © 2011 Matthew "LeafStorm" Frazier
