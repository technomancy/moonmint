SRC=moonmint/*.lua
LUA ?= lua

test: ; $(LUA) test.lua

lint: ; luacheck $(SRC)

count: ; cloc $(SRC)

.PHONY: test lint count
