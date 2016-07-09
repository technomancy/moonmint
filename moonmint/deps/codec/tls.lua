--
-- Modified from creationix/coro-tls
-- https://github.com/creationix/luv-coro-tls
--

local openssl = require('openssl')
local bit = require 'bit32'

local DEFAULT_CIPHERS = 'ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:' .. -- TLS 1.2
                        'RC4:HIGH:!MD5:!aNULL:!EDH'                     -- TLS 1.0

-- Load Default root certificate authority store
local DEFAULT_CA_STORE = nil

-- TODO Use a provided root certificate authority

-- Given a read/write pair, return a new read/write pair for plaintext
local function wrap(read, write, options)
    if not options then
        options = {}
    end

    local ctx = openssl.ssl.ctx_new(options.protocol or 'TLSv1_2', options.ciphers or DEFAULT_CIPHERS)

    local key, cert, ca
    if options.key then
        key = assert(openssl.pkey.read(options.key, true, 'pem'))
    end
    if options.cert then
        cert = assert(openssl.x509.read(options.cert))
    end
    if options.ca then
        if type(options.ca) == "string" then
            ca = { assert(openssl.x509.read(options.ca)) }
        elseif type(options.ca) == "table" then
            ca = {}
            for i = 1, #options.ca do
                ca[i] = assert(openssl.x509.read(options.ca[i]))
            end
        else
            error("options.ca must be string or table of strings")
        end
    elseif options.ca == false then
        ca = nil
    else
        ca = DEFAULT_CA_STORE
    end
    if key and cert then
        assert(ctx:use(key, cert))
    end
    if ca then
        local store = openssl.x509.store:new()
        for i = 1, #ca do
            assert(store:add(ca[i]))
        end
        ctx:cert_store(store)
    else
        ctx:verify_mode(openssl.ssl.none)
    end

    ctx:options(bit.bor(
    openssl.ssl.no_sslv2,
    openssl.ssl.no_sslv3,
    openssl.ssl.no_compression))
    local bin, bout = openssl.bio.mem(8192), openssl.bio.mem(8192)
    local ssl = ctx:ssl(bin, bout, options.server)

    local function flush()
        while bout:pending() > 0 do
            write(bout:read())
        end
    end

    -- Do handshake
    while true do
        if ssl:handshake() then break end
        flush()
        local chunk = read()
        if chunk then
            bin:write(chunk)
        else
            error("disconnect while handshaking")
        end
    end
    flush()

    local done = false
    local function shutdown()
        if done then return end
        done = true
        while true do
            if ssl:shutdown() then break end
            flush()
            local chunk = read()
            if chunk then
                bin:write(chunk)
            else
                break
            end
        end
        flush()
        write()
    end

    local function plainRead()
        while true do
            local chunk = ssl:read()
            if chunk then return chunk end
            local cipher = read()
            if not cipher then return end
            bin:write(cipher)
        end
    end

    local function plainWrite(plain)
        if not plain then
            return shutdown()
        end
        ssl:write(plain)
        flush()
    end

    return plainRead, plainWrite, ssl

end

-- local function readFile(file)
--     local f = io.open(file, 'rb')
--     local content = f:read('*all')
--     f:close()
--     return content
-- end

-- do
--     local data = readFile('~/Desktop/root_ca.dat')
--     DEFAULT_CA_STORE = openssl.x509.store:new()
--     local index = 1
--     local len = #data
--     while index < len do
--         local len1 = bit.bor(bit.lshift(data:byte(index), 8), data:byte(index + 1))
--         index = index + 2
--         local cert = assert(openssl.x509.read(data:sub(index, index + len1)))
--         index = index + len1
--         assert(DEFAULT_CA_STORE:add(cert))
--     end
-- end

return wrap
