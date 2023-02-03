-- redis 连接池
local function redis_keepalive(rds)
    if not rds then
        return
    end
    local ok, err = rds:set_keepalive(10000, 100)
    if not ok then
        ngx.log(ngx.ERR, "failed to keepalive, ", err)
    end
end

-- 从 redis 中获取灰度比例
local function get_ratio(rds)
    if not rds then
        return 0
    end
    local ratio = rds:get("gray:ratio")
    if ratio == ngx.null or ratio == "0" then
        return 0
    end
    return tonumber(ratio)
end

-- ip 取模再和比例对比，然后转发
local function ratio_gray(source, ratio)
    local crc = ngx.crc32_long(source)
    local mod = math.fmod(crc, 10000)
    if mod < ratio then
        ngx.log(ngx.INFO, "request source [", source, "] is proxied to java server")
        return ngx.exec("@java_server")
    else
        return ngx.exec("@php_server")
    end
end

-- 特殊的灰度比列
local function im_gray(rds, from, ratio)
    if not from then
        return ngx.exec("@php_server")
    end
    -- 用户灰度白名单
    local isGrayUser = rds:sismember("gray:whitelist:user", from)
    redis_keepalive(rds)
    if isGrayUser == 1 then
        return ngx.exec("@java_server")
    end
    -- 用户灰度
    return ratio_gray(from, ratio)
end

local redis = require "resty.redis"
-- 创建一个 reids 链接对象
local rds = redis:new()
rds:set_timeout(1000)

local connect, cErr = rds:connect('192.168.8.27', 6379)
if not connect then
    ngx.log(ngx.ERR, "failed to connect, ", cErr)
    rds:close()
    return ngx.exec("@php_server")
end

-- 这里需要修改登录密码
local auth, aErr = rds:auth("xxx")
if not auth then
    ngx.log(ngx.ERR, "failed to auth, ", aErr)
    return ngx.exec("@php_server")
end

rds:select(0)

-- 是否开启了灰度
local grayOpen = rds:get("gray:open")
if grayOpen == ngx.null or grayOpen == "0" then
    redis_keepalive(rds)
    return ngx.exec("@php_server")
end

-- 路由白名单直接走php服务
local uri = ngx.var.uri
local route = rds:sismember("gray:whitelist:route", uri)
if route == 1 then
    redis_keepalive(rds)
    return ngx.exec("@php_server")
end

-- 灰度比例100%
local ratio = get_ratio(rds)
if ratio == 10000 then
    redis_keepalive(rds)
    ngx.log(ngx.INFO, "request is proxied to the java server")
    return ngx.exec("@java_server")
end

-- 有些比较特殊，需要通过 body 体的用户信息转发
-- IM 白名单走被代理到 java 服务
if uri == "/api/im/receive" then
    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    if args ~= nil then
        return im_gray(rds, args["fromUserId"])
    end
    return ngx.exec("@php_server")
end

if uri == "/api/im/verify" then
    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    ngx.log(ngx.ERR, "request body is ", data)
    if data ~= nil then
        local cjson = require("cjson")
        local args = cjson.decode(data)
        local content = args["content"]
        if content ~= nil then
            local cArgs = cjson.decode(content)
            return im_gray(rds, cArgs["fromUserId"])
        end
    end
    return ngx.exec("@php_server")
end

-- 获取客户端IP
local headers = ngx.req.get_headers()
local ip = headers["X-Forwarded-For"]
if ip == nil or string.len(ip) == 0 or ip == "unknown" then
    ip = headers["Proxy-Client-IP"]
end
if ip == nil or string.len(ip) == 0 or ip == "unknown" then
    ip = headers["WL-Proxy-Client-IP"]
end
if ip == nil or string.len(ip) == 0 or ip == "unknown" then
    ip = headers["X-Real-IP"]
end
if ip == nil or string.len(ip) == 0 or ip == "unknown" then
    ip = ngx.var.remote_addr
end
-- 对于通过多个代理的情况，第一个IP为客户端真实IP,多个IP按照','分割
if ip ~= nil and string.len(ip) > 15 then
    local pos = string.find(ip, ",", 1)
    ip = string.sub(ip, 1, pos - 1)
end

if ip == nil then
    redis_keepalive(rds)
    return ngx.exec("@php_server")
end

-- 是否为IP白名单
local isGrayIp = rds:sismember("gray:whitelist:ip", ip)
redis_keepalive(rds)
if isGrayIp == 1 then
    return ngx.exec("@java_server")
end
-- 不在IP白名单，则流量灰度
return ratio_gray(ip, ratio)