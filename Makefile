SRC=moonmint/*.lua

test: ; lua test.lua

lint: ; luacheck $(SRC)

count: ; cloc $(SRC)

.PHONY: test lint count
